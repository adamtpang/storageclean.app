using StorageClean.Core.Models;
using StorageClean.Core.Services;

var fixtureRoot = Path.Combine(Path.GetTempPath(), $"storageclean-self-test-{Guid.NewGuid():N}");

try
{
    var alpha = Directory.CreateDirectory(Path.Combine(fixtureRoot, "Alpha"));
    var beta = Directory.CreateDirectory(Path.Combine(fixtureRoot, "Beta", "Nested"));
    CreateSizedFile(Path.Combine(alpha.FullName, "alpha.bin"), 1_048_576);
    CreateSizedFile(Path.Combine(beta.FullName, "beta.bin"), 262_144);
    CreateSizedFile(Path.Combine(fixtureRoot, "root.bin"), 65_536);

    var scanner = new DriveScanner();
    var result = await scanner.ScanDriveAsync(
        fixtureRoot,
        new ScanOptions(MaxConcurrency: 2, MaxResults: 10));

    Require(result.Entries.Count == 3, $"Expected 3 entries, found {result.Entries.Count}.");
    Require(result.Entries[0].Name == "Alpha", "Expected Alpha to rank first.");
    Require(result.Entries[0].Bytes == 1_048_576, "Alpha byte count is incorrect.");
    Require(result.Entries.Single(entry => entry.Name == "Beta").Bytes == 262_144, "Beta byte count is incorrect.");
    Require(result.Entries.Single(entry => entry.Name == "Files in drive root").Bytes == 65_536, "Root-file byte count is incorrect.");
    Require(result.Entries.All(entry => entry.ErrorCount == 0), "Fixture scan reported unexpected errors.");
    Require(result.Entries[0].PercentOfLargest == 100, "Largest item should have a 100 percent relative bar.");

    Console.WriteLine("SELF_TEST_PASS");
    Console.WriteLine($"Entries={result.Entries.Count}; Bytes={result.Entries.Sum(entry => entry.Bytes)}");
    return 0;
}
catch (Exception exception)
{
    Console.Error.WriteLine("SELF_TEST_FAIL");
    Console.Error.WriteLine(exception);
    return 1;
}
finally
{
    if (Directory.Exists(fixtureRoot))
    {
        Directory.Delete(fixtureRoot, recursive: true);
    }
}

static void CreateSizedFile(string path, long bytes)
{
    Directory.CreateDirectory(Path.GetDirectoryName(path)!);
    using var stream = new FileStream(path, FileMode.CreateNew, FileAccess.Write, FileShare.None);
    stream.SetLength(bytes);
}

static void Require(bool condition, string message)
{
    if (!condition)
    {
        throw new InvalidOperationException(message);
    }
}
