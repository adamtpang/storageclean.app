namespace StorageClean.Core.Models;

public sealed record ScanOptions(
    int MaxConcurrency = 2,
    int MaxResults = 100);

public sealed record ScanProgress(
    string CurrentPath,
    int CompletedItems,
    int TotalItems);

public sealed record ScanEntry(
    string Name,
    string Path,
    long Bytes,
    long FileCount,
    long ErrorCount,
    long SkippedReparsePoints,
    DateTimeOffset? LatestWriteUtc,
    string Recommendation)
{
    public double SizeGiB => Bytes / 1024d / 1024d / 1024d;

    public double PercentOfUsed { get; init; }

    public double CumulativePercent { get; init; }

    public double PercentOfLargest { get; init; }

    public string FormattedSize => ByteFormatter.Format(Bytes);
}

public sealed record DriveScanResult(
    string RootPath,
    string VolumeLabel,
    string DriveFormat,
    long TotalBytes,
    long FreeBytes,
    DateTimeOffset ScannedAtUtc,
    IReadOnlyList<ScanEntry> Entries)
{
    public long UsedBytes => Math.Max(0, TotalBytes - FreeBytes);

    public string TotalSize => ByteFormatter.Format(TotalBytes);

    public string FreeSize => ByteFormatter.Format(FreeBytes);

    public string UsedSize => ByteFormatter.Format(UsedBytes);
}

public static class ByteFormatter
{
    private static readonly string[] Units = ["B", "KiB", "MiB", "GiB", "TiB", "PiB"];

    public static string Format(long bytes)
    {
        var value = Math.Max(0, bytes);
        var unitIndex = 0;
        var display = (double)value;

        while (display >= 1024 && unitIndex < Units.Length - 1)
        {
            display /= 1024;
            unitIndex++;
        }

        return unitIndex == 0
            ? $"{value:N0} {Units[unitIndex]}"
            : $"{display:N2} {Units[unitIndex]}";
    }
}
