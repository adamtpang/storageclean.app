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
    private CancellationTokenSource? _scanCancellation;
    private DriveScanResult? _lastResult;

    public MainWindow()
    {
        InitializeComponent();
        ResultsGrid.ItemsSource = _entries;
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
        var drives = DriveInfo.GetDrives()
            .Where(drive => drive.IsReady && drive.DriveType is DriveType.Fixed or DriveType.Removable)
            .Select(drive => new DriveChoice(
                drive.RootDirectory.FullName,
                BuildDriveLabel(drive)))
            .ToArray();

        DrivePicker.ItemsSource = drives;
        DrivePicker.SelectedItem = drives.FirstOrDefault(drive =>
            drive.RootPath.Equals(Path.GetPathRoot(Environment.SystemDirectory), StringComparison.OrdinalIgnoreCase))
            ?? drives.FirstOrDefault();
        ScanButton.IsEnabled = drives.Length > 0;
    }

    private async void ScanButton_Click(object sender, RoutedEventArgs e)
    {
        if (DrivePicker.SelectedItem is not DriveChoice selectedDrive)
        {
            return;
        }

        _scanCancellation?.Dispose();
        _scanCancellation = new CancellationTokenSource();
        _lastResult = null;
        _entries.Clear();
        ResetSummary();
        SetBusy(true);
        StatusText.Text = $"Starting read-only scan of {selectedDrive.RootPath}";

        var progress = new Progress<ScanProgress>(update =>
        {
            var percent = update.TotalItems == 0
                ? 0
                : update.CompletedItems * 100d / update.TotalItems;
            ScanProgress.Value = percent;
            StatusText.Text = $"Measured {update.CompletedItems:N0} of {update.TotalItems:N0}: {update.CurrentPath}";
        });

        try
        {
            var result = await _scanner.ScanDriveAsync(
                selectedDrive.RootPath,
                new ScanOptions(MaxConcurrency: 2, MaxResults: 100),
                progress,
                _scanCancellation.Token);

            _lastResult = result;
            foreach (var entry in result.Entries)
            {
                _entries.Add(entry);
            }

            CapacityText.Text = result.TotalSize;
            UsedText.Text = result.UsedSize;
            FreeText.Text = result.FreeSize;
            ItemsText.Text = result.Entries.Count.ToString("N0");
            ScanProgress.Value = 100;
            StatusText.Text = $"Scan complete. Ranked {result.Entries.Count:N0} top-level items without changing files.";
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

    private void CancelButton_Click(object sender, RoutedEventArgs e)
    {
        CancelButton.IsEnabled = false;
        StatusText.Text = "Canceling after the current filesystem item...";
        _scanCancellation?.Cancel();
    }

    private async void ExportButton_Click(object sender, RoutedEventArgs e)
    {
        if (_lastResult is null)
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
            var json = JsonSerializer.Serialize(
                _lastResult,
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
        DrivePicker.IsEnabled = !isBusy;
        CancelButton.IsEnabled = isBusy;
        ExportButton.IsEnabled = !isBusy && _lastResult is not null;
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
}
