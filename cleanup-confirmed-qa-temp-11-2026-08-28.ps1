[CmdletBinding()]
param()

Set-StrictMode -Version Latest
$ErrorActionPreference = 'Stop'

$confirmation = 'Adam approved the exact 11 reviewed SellSniper QA Temp folders on 2026-08-28.'
$tempRoot = [System.IO.Path]::GetFullPath('C:\Users\adamp\AppData\Local\Temp').TrimEnd('\')
$names = @(
    'sellsniper-company-qa',
    'sellsniper-campaign-qa',
    'sellsniper-specialist-qa',
    'sellsniper-search-performance-qa',
    'sellsniper-google-connection-qa',
    'sellsniper-search-console-links-qa',
    'sellsniper-link-evidence-qa',
    'sellsniper-repository-context-qa',
    'sellsniper-brand-profile-qa',
    'sellsniper-refresh-qa',
    'sellsniper-feed-qa'
)
$expectedTargets = @($names | ForEach-Object {
    [System.IO.Path]::GetFullPath((Join-Path $tempRoot $_)).TrimEnd('\')
})

$beforeFree = (Get-PSDrive C).Free
$processes = @(Get-CimInstance Win32_Process | Where-Object { $_.CommandLine })
$results = [System.Collections.Generic.List[object]]::new()

foreach ($path in $expectedTargets) {
    if (-not $path.StartsWith($tempRoot + '\', [System.StringComparison]::OrdinalIgnoreCase)) {
        throw "Unsafe target outside Temp: $path"
    }

    if (-not (Test-Path -LiteralPath $path -PathType Container)) {
        $results.Add([pscustomobject]@{
            Path = $path
            Status = 'already-absent'
            MeasuredGiB = 0
            ActiveReferences = 0
            Detail = $null
        })
        continue
    }

    $info = Get-Item -LiteralPath $path -Force
    if ($info.Attributes -band [System.IO.FileAttributes]::ReparsePoint) {
        $results.Add([pscustomobject]@{
            Path = $path
            Status = 'skipped-reparse-point'
            MeasuredGiB = 0
            ActiveReferences = 0
            Detail = 'Root is a reparse point.'
        })
        continue
    }

    $references = @($processes | Where-Object {
        $_.Name -notin @('powershell.exe', 'pwsh.exe', 'cmd.exe', 'conhost.exe') -and
        $_.CommandLine.IndexOf($path, [System.StringComparison]::OrdinalIgnoreCase) -ge 0
    })
    if ($references.Count -gt 0) {
        $results.Add([pscustomobject]@{
            Path = $path
            Status = 'skipped-active'
            MeasuredGiB = 0
            ActiveReferences = $references.Count
            Detail = (($references | Select-Object ProcessId, Name) | ConvertTo-Json -Compress)
        })
        continue
    }

    $measurement = Get-ChildItem -LiteralPath $path -File -Recurse -Force -ErrorAction SilentlyContinue |
        Measure-Object -Property Length -Sum
    $measuredGiB = [math]::Round($measurement.Sum / 1GB, 3)

    try {
        Remove-Item -LiteralPath $path -Recurse -Force -ErrorAction Stop
        $status = if (Test-Path -LiteralPath $path) { 'failed-still-exists' } else { 'removed' }
        $detail = $null
    }
    catch {
        $status = 'failed-remove'
        $detail = $_.Exception.Message
    }

    $results.Add([pscustomobject]@{
        Path = $path
        Status = $status
        MeasuredGiB = $measuredGiB
        ActiveReferences = 0
        Detail = $detail
    })
}

$afterFree = (Get-PSDrive C).Free
$removedResults = @($results | Where-Object Status -eq 'removed')
$report = [pscustomobject]@{
    Confirmation = $confirmation
    CompletedAt = [DateTimeOffset]::Now.ToString('O')
    Removed = $removedResults.Count
    SkippedActive = @($results | Where-Object Status -eq 'skipped-active').Count
    Failed = @($results | Where-Object Status -like 'failed*').Count
    MeasuredRemovedGiB = [math]::Round((($removedResults | Measure-Object MeasuredGiB -Sum).Sum), 3)
    ActualFreeSpaceGainGiB = [math]::Round(($afterFree - $beforeFree) / 1GB, 3)
    CFreeGiB = [math]::Round($afterFree / 1GB, 2)
    Results = $results
}

$reportPath = 'C:\Users\adamp\Aether\storageclean.app\artifacts\cleanup-confirmed-qa-temp-11-2026-08-28.json'
$report | ConvertTo-Json -Depth 6 | Set-Content -LiteralPath $reportPath -Encoding utf8
$report | ConvertTo-Json -Depth 6
Write-Host "Report: $reportPath"
