using System.Collections.Concurrent;
using StorageClean.Core.Models;

namespace StorageClean.Core.Services;

public sealed class DriveScanner
{
    public async Task<DriveScanResult> ScanDriveAsync(
        string rootPath,
        ScanOptions? options = null,
        IProgress<ScanProgress>? progress = null,
        CancellationToken cancellationToken = default)
    {
        options ??= new ScanOptions();
        if (options.MaxConcurrency < 1 || options.MaxConcurrency > 8)
        {
            throw new ArgumentOutOfRangeException(nameof(options), "MaxConcurrency must be between 1 and 8.");
        }

        var normalizedRoot = NormalizeRoot(rootPath);
        var driveRoot = Path.GetPathRoot(normalizedRoot)
            ?? throw new ArgumentException("The scan path must be on a mounted drive.", nameof(rootPath));
        var drive = new DriveInfo(driveRoot);
        if (!drive.IsReady)
        {
            throw new IOException($"Drive {normalizedRoot} is not ready.");
        }

        var candidates = EnumerateTopLevelDirectories(normalizedRoot, cancellationToken);
        var results = new ConcurrentBag<ScanEntry>();
        using var gate = new SemaphoreSlim(options.MaxConcurrency);
        var completed = 0;

        var tasks = candidates.Select(async candidate =>
        {
            await gate.WaitAsync(cancellationToken).ConfigureAwait(false);
            try
            {
                var entry = await Task.Run(
                    () => MeasureDirectory(candidate, cancellationToken),
                    cancellationToken).ConfigureAwait(false);
                results.Add(entry);
            }
            finally
            {
                gate.Release();
                var completedNow = Interlocked.Increment(ref completed);
                progress?.Report(new ScanProgress(candidate, completedNow, candidates.Count));
            }
        }).ToArray();

        await Task.WhenAll(tasks).ConfigureAwait(false);

        var rootFiles = await Task.Run(
            () => MeasureRootFiles(normalizedRoot, cancellationToken),
            cancellationToken).ConfigureAwait(false);
        if (rootFiles.FileCount > 0 || rootFiles.ErrorCount > 0)
        {
            results.Add(rootFiles);
        }

        var usedBytes = Math.Max(1, drive.TotalSize - drive.AvailableFreeSpace);
        var ordered = results
            .OrderByDescending(entry => entry.Bytes)
            .Take(Math.Max(1, options.MaxResults))
            .ToArray();
        var largest = Math.Max(1, ordered.FirstOrDefault()?.Bytes ?? 1);
        long cumulative = 0;

        var ranked = ordered.Select(entry =>
        {
            cumulative += entry.Bytes;
            return entry with
            {
                PercentOfUsed = entry.Bytes * 100d / usedBytes,
                CumulativePercent = cumulative * 100d / usedBytes,
                PercentOfLargest = entry.Bytes * 100d / largest,
            };
        }).ToArray();

        return new DriveScanResult(
            normalizedRoot,
            drive.VolumeLabel,
            drive.DriveFormat,
            drive.TotalSize,
            drive.AvailableFreeSpace,
            DateTimeOffset.UtcNow,
            ranked);
    }

    private static string NormalizeRoot(string rootPath)
    {
        if (string.IsNullOrWhiteSpace(rootPath))
        {
            throw new ArgumentException("A drive root is required.", nameof(rootPath));
        }

        var fullPath = Path.GetFullPath(rootPath);
        if (!Directory.Exists(fullPath))
        {
            throw new DirectoryNotFoundException($"Scan path does not exist: {fullPath}");
        }

        return fullPath;
    }

    private static IReadOnlyList<string> EnumerateTopLevelDirectories(string rootPath, CancellationToken cancellationToken)
    {
        var directories = new List<string>();
        try
        {
            foreach (var directory in Directory.EnumerateDirectories(rootPath))
            {
                cancellationToken.ThrowIfCancellationRequested();
                directories.Add(directory);
            }
        }
        catch (UnauthorizedAccessException)
        {
        }
        catch (IOException)
        {
        }

        return directories;
    }

    private static ScanEntry MeasureDirectory(string rootPath, CancellationToken cancellationToken)
    {
        long bytes = 0;
        long fileCount = 0;
        long errorCount = 0;
        long skippedReparsePoints = 0;
        DateTimeOffset? latestWriteUtc = null;
        var directories = new Stack<string>();

        try
        {
            var rootInfo = new DirectoryInfo(rootPath);
            if (rootInfo.Attributes.HasFlag(FileAttributes.ReparsePoint))
            {
                return NewEntry(rootPath, 0, 0, 0, 1, rootInfo.LastWriteTimeUtc);
            }

            directories.Push(rootPath);
        }
        catch (Exception exception) when (IsExpectedFileSystemException(exception))
        {
            return NewEntry(rootPath, 0, 0, 1, 0, null);
        }

        while (directories.Count > 0)
        {
            cancellationToken.ThrowIfCancellationRequested();
            var current = directories.Pop();

            try
            {
                foreach (var filePath in Directory.EnumerateFiles(current))
                {
                    cancellationToken.ThrowIfCancellationRequested();
                    try
                    {
                        var file = new FileInfo(filePath);
                        bytes = checked(bytes + file.Length);
                        fileCount++;
                        latestWriteUtc = Max(latestWriteUtc, file.LastWriteTimeUtc);
                    }
                    catch (Exception exception) when (IsExpectedFileSystemException(exception))
                    {
                        errorCount++;
                    }
                }
            }
            catch (Exception exception) when (IsExpectedFileSystemException(exception))
            {
                errorCount++;
            }

            try
            {
                foreach (var childPath in Directory.EnumerateDirectories(current))
                {
                    cancellationToken.ThrowIfCancellationRequested();
                    try
                    {
                        var child = new DirectoryInfo(childPath);
                        latestWriteUtc = Max(latestWriteUtc, child.LastWriteTimeUtc);
                        if (child.Attributes.HasFlag(FileAttributes.ReparsePoint))
                        {
                            skippedReparsePoints++;
                            continue;
                        }

                        directories.Push(childPath);
                    }
                    catch (Exception exception) when (IsExpectedFileSystemException(exception))
                    {
                        errorCount++;
                    }
                }
            }
            catch (Exception exception) when (IsExpectedFileSystemException(exception))
            {
                errorCount++;
            }
        }

        return NewEntry(rootPath, bytes, fileCount, errorCount, skippedReparsePoints, latestWriteUtc);
    }

    private static ScanEntry MeasureRootFiles(string rootPath, CancellationToken cancellationToken)
    {
        long bytes = 0;
        long fileCount = 0;
        long errorCount = 0;
        DateTimeOffset? latestWriteUtc = null;

        try
        {
            foreach (var filePath in Directory.EnumerateFiles(rootPath))
            {
                cancellationToken.ThrowIfCancellationRequested();
                try
                {
                    var file = new FileInfo(filePath);
                    bytes = checked(bytes + file.Length);
                    fileCount++;
                    latestWriteUtc = Max(latestWriteUtc, file.LastWriteTimeUtc);
                }
                catch (Exception exception) when (IsExpectedFileSystemException(exception))
                {
                    errorCount++;
                }
            }
        }
        catch (Exception exception) when (IsExpectedFileSystemException(exception))
        {
            errorCount++;
        }

        return new ScanEntry(
            "Files in drive root",
            rootPath,
            bytes,
            fileCount,
            errorCount,
            0,
            latestWriteUtc,
            "Inspect individually. System-managed files should not be treated as disposable cache.");
    }

    private static ScanEntry NewEntry(
        string path,
        long bytes,
        long fileCount,
        long errorCount,
        long skippedReparsePoints,
        DateTimeOffset? latestWriteUtc)
    {
        var name = new DirectoryInfo(path).Name;
        if (string.IsNullOrWhiteSpace(name))
        {
            name = path;
        }

        return new ScanEntry(
            name,
            path,
            bytes,
            fileCount,
            errorCount,
            skippedReparsePoints,
            latestWriteUtc,
            Recommend(path, name));
    }

    private static string Recommend(string path, string name)
    {
        if (name.Contains("temp", StringComparison.OrdinalIgnoreCase) ||
            name.Contains("cache", StringComparison.OrdinalIgnoreCase))
        {
            return "Classify active use and ownership, then confirm exact regenerable targets.";
        }

        if (path.Contains("Program Files", StringComparison.OrdinalIgnoreCase) ||
            path.Contains("WindowsApps", StringComparison.OrdinalIgnoreCase))
        {
            return "Uninstall or move through the owning application. Do not delete files directly.";
        }

        if (name.Equals("Windows", StringComparison.OrdinalIgnoreCase) ||
            name.Equals("System Volume Information", StringComparison.OrdinalIgnoreCase))
        {
            return "System-managed. Inspect with Windows-supported maintenance tools only.";
        }

        if (name.Equals("Users", StringComparison.OrdinalIgnoreCase))
        {
            return "Drill into user data, then verify backups before moving cold folders.";
        }

        return "Inspect the largest child folders before proposing an action.";
    }

    private static DateTimeOffset? Max(DateTimeOffset? current, DateTimeOffset candidate) =>
        current is null || candidate > current ? candidate : current;

    private static bool IsExpectedFileSystemException(Exception exception) =>
        exception is UnauthorizedAccessException
            or IOException
            or System.Security.SecurityException
            or NotSupportedException
            or PathTooLongException;
}
