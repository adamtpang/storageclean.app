using System.Collections.ObjectModel;
using System.Diagnostics;
using System.IO;
using System.Text.Json;
using System.Windows;
using Microsoft.Win32;
using StorageClean.Core.Models;
using StorageClean.Core.Services;

namespace StorageClean.App;

public partial class MainWindow : Window
{
    private readonly DriveScanner _scanner = new();
    private readonly ObservableCollection<ScanEntry> _entries = [];
    private readonly ObservableCollection<DriveSummaryRow> _driveSummaries = [];
    private CancellationTokenSource? _scanCancellation;
    private readonly List<DriveScanResult> _lastResults = [];
    private DriveChoice[] _drives = [];

    public MainWindow()
    {
        InitializeComponent();
        ResultsGrid.ItemsSource = _entries;
        DriveSummaryGrid.ItemsSource = _driveSummaries;
        LoadDrives();
    }

    protected override void OnClosed(EventArgs e)
    {
        _scanCancellation?.Cancel();
        _scanCancellation?.Dispose();
        base.OnClosed(e);
    }

    private void LoadDrives()
    {
        _drives = DriveInfo.GetDrives()
            .Where(drive => drive.IsReady && drive.DriveType is DriveType.Fixed or DriveType.Removable)
            .Select(drive => new DriveChoice(
                drive.RootDirectory.FullName,
                BuildDriveLabel(drive)))
            .ToArray();

        DrivePicker.ItemsSource = _drives;
        DrivePicker.SelectedItem = _drives.FirstOrDefault(drive =>
            drive.RootPath.Equals(Path.GetPathRoot(Environment.SystemDirectory), StringComparison.OrdinalIgnoreCase))
            ?? _drives.FirstOrDefault();
        ScanButton.IsEnabled = _drives.Length > 0;
        ScanAllButton.IsEnabled = _drives.Length > 0;
    }

    private async void ScanButton_Click(object sender, RoutedEventArgs e)
    {
        if (DrivePicker.SelectedItem is not DriveChoice selectedDrive)
        {
            return;
        }

        await ScanDrivesAsync([selectedDrive]);
    }

    private async void ScanAllButton_Click(object sender, RoutedEventArgs e)
    {
        if (_drives.Length == 0)
        {
            return;
        }

        await ScanDrivesAsync(_drives);
    }

    private async Task ScanDrivesAsync(IReadOnlyList<DriveChoice> selectedDrives)
    {
        _scanCancellation?.Dispose();
        _scanCancellation = new CancellationTokenSource();
        _lastResults.Clear();
        _entries.Clear();
        _driveSummaries.Clear();
        ResetSummary();
        SetBusy(true);
        StatusText.Text = selectedDrives.Count == 1
            ? $"Starting read-only scan of {selectedDrives[0].RootPath}"
            : $"Starting read-only scan of {selectedDrives.Count:N0} drives";

        try
        {
            for (var driveIndex = 0; driveIndex < selectedDrives.Count; driveIndex++)
            {
                var currentIndex = driveIndex;
                var selectedDrive = selectedDrives[currentIndex];
                var progress = new Progress<ScanProgress>(update =>
                {
                    var driveFraction = update.TotalItems == 0
                        ? 0
                        : update.CompletedItems / (double)update.TotalItems;
                    ScanProgress.Value = (currentIndex + driveFraction) * 100d / selectedDrives.Count;
                    StatusText.Text = $"Drive {currentIndex + 1:N0} of {selectedDrives.Count:N0}, measured {update.CompletedItems:N0} of {update.TotalItems:N0}: {update.CurrentPath}";
                });

                var result = await _scanner.ScanDriveAsync(
                    selectedDrive.RootPath,
                    new ScanOptions(MaxConcurrency: 2, MaxResults: 100),
                    progress,
                    _scanCancellation.Token);

                _lastResults.Add(result);
                _driveSummaries.Add(DriveSummaryRow.From(result));
            }

            PopulateCombinedRanking(selectedDrives.Count > 1);

            CapacityText.Text = ByteFormatter.Format(_lastResults.Sum(result => result.TotalBytes));
            UsedText.Text = ByteFormatter.Format(_lastResults.Sum(result => result.UsedBytes));
            FreeText.Text = ByteFormatter.Format(_lastResults.Sum(result => result.FreeBytes));
            ItemsText.Text = _entries.Count.ToString("N0");
            ScanProgress.Value = 100;
            StatusText.Text = $"Scan complete. Ranked {_entries.Count:N0} items across {_lastResults.Count:N0} drive(s) without changing files.";
            ExportButton.IsEnabled = true;
        }
        catch (OperationCanceledException)
        {
            StatusText.Text = "Scan canceled. No files were changed.";
            ScanProgress.Value = 0;
        }
        catch (Exception exception)
        {
            StatusText.Text = "Scan failed. No files were changed.";
            MessageBox.Show(
                this,
                exception.Message,
                "StorageClean scan error",
                MessageBoxButton.OK,
                MessageBoxImage.Error);
        }
        finally
        {
            SetBusy(false);
        }
    }

    private void PopulateCombinedRanking(bool includeDrivePrefix)
    {
        var totalUsedBytes = Math.Max(1, _lastResults.Sum(result => result.UsedBytes));
        var ordered = _lastResults
            .SelectMany(result => result.Entries.Select(entry => new
            {
                Result = result,
                Entry = entry,
            }))
            .OrderByDescending(item => item.Entry.Bytes)
            .ToArray();
        var largestBytes = Math.Max(1, ordered.FirstOrDefault()?.Entry.Bytes ?? 1);
        long cumulativeBytes = 0;

        foreach (var item in ordered)
        {
            cumulativeBytes += item.Entry.Bytes;
            var drivePrefix = includeDrivePrefix ? $"{item.Result.RootPath}  " : string.Empty;
            _entries.Add(item.Entry with
            {
                Name = drivePrefix + item.Entry.Name,
                PercentOfLargest = item.Entry.Bytes * 100d / largestBytes,
                PercentOfUsed = item.Entry.Bytes * 100d / totalUsedBytes,
                CumulativePercent = cumulativeBytes * 100d / totalUsedBytes,
            });
        }
    }

    private void CancelButton_Click(object sender, RoutedEventArgs e)
    {
        CancelButton.IsEnabled = false;
        StatusText.Text = "Canceling after the current filesystem item...";
        _scanCancellation?.Cancel();
    }

    private async void ExportButton_Click(object sender, RoutedEventArgs e)
    {
        if (_lastResults.Count == 0)
        {
            return;
        }

        var dialog = new SaveFileDialog
        {
            AddExtension = true,
            DefaultExt = ".json",
            Filter = "JSON audit (*.json)|*.json",
            FileName = $"storageclean-audit-{DateTime.Now:yyyy-MM-dd-HHmm}.json",
            OverwritePrompt = true,
            Title = "Export StorageClean audit",
        };

        if (dialog.ShowDialog(this) != true)
        {
            return;
        }

        try
        {
            var audit = new
            {
                Product = "StorageClean",
                SafetyMode = "read-only",
                ExportedAtUtc = DateTimeOffset.UtcNow,
                Drives = _lastResults,
            };
            var json = JsonSerializer.Serialize(
                audit,
                new JsonSerializerOptions { WriteIndented = true });
            await File.WriteAllTextAsync(dialog.FileName, json);
            StatusText.Text = $"Exported read-only audit to {dialog.FileName}";
        }
        catch (Exception exception)
        {
            MessageBox.Show(
                this,
                exception.Message,
                "StorageClean export error",
                MessageBoxButton.OK,
                MessageBoxImage.Error);
        }
    }

    private void WebsiteButton_Click(object sender, RoutedEventArgs e)
    {
        Process.Start(new ProcessStartInfo("https://storageclean.app") { UseShellExecute = true });
    }

    private void SetBusy(bool isBusy)
    {
        ScanButton.IsEnabled = !isBusy && DrivePicker.Items.Count > 0;
        ScanAllButton.IsEnabled = !isBusy && _drives.Length > 0;
        DrivePicker.IsEnabled = !isBusy;
        CancelButton.IsEnabled = isBusy;
        ExportButton.IsEnabled = !isBusy && _lastResults.Count > 0;
    }

    private void ResetSummary()
    {
        CapacityText.Text = "-";
        UsedText.Text = "-";
        FreeText.Text = "-";
        ItemsText.Text = "-";
        ScanProgress.Value = 0;
    }

    private static string BuildDriveLabel(DriveInfo drive)
    {
        var label = string.IsNullOrWhiteSpace(drive.VolumeLabel) ? "Local disk" : drive.VolumeLabel;
        return $"{drive.Name}  {label}  •  {ByteFormatter.Format(drive.AvailableFreeSpace)} free";
    }

    private sealed record DriveChoice(string RootPath, string Display);

    private sealed record DriveSummaryRow(
        string Drive,
        string Label,
        string Capacity,
        string Used,
        string Free,
        double UsedPercent,
        double FreePercent,
        string Health,
        string Recommendation)
    {
        public static DriveSummaryRow From(DriveScanResult result)
        {
            var freePercent = result.TotalBytes == 0
                ? 0
                : result.FreeBytes * 100d / result.TotalBytes;
            var usedPercent = 100d - freePercent;
            var health = freePercent switch
            {
                < 5 => "Critical",
                < 10 => "Low",
                < 15 => "Tight",
                _ => "Healthy",
            };
            var driveType = new DriveInfo(result.RootPath).DriveType;
            var recommendation = BuildRecommendation(freePercent, driveType);
            var label = string.IsNullOrWhiteSpace(result.VolumeLabel) ? "Local disk" : result.VolumeLabel;

            return new DriveSummaryRow(
                result.RootPath,
                label,
                result.TotalSize,
                result.UsedSize,
                result.FreeSize,
                usedPercent,
                freePercent,
                health,
                recommendation);
        }

        private static string BuildRecommendation(double freePercent, DriveType driveType)
        {
            if (freePercent < 10)
            {
                return "Move one large verified folder or launcher-managed game off this drive. Aim for at least 15% free.";
            }

            if (freePercent < 15)
            {
                return "Create a 15% buffer with a verified move, then prune only confirmed regenerable caches.";
            }

            return driveType == DriveType.Removable
                ? "Healthy destination capacity. Keep at least 15% free after accepting large moves."
                : "Healthy capacity. Review the largest item before considering smaller cleanup.";
        }
    }
}
