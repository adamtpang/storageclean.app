[CmdletBinding()]
param()

Set-StrictMode -Version Latest
$ErrorActionPreference = 'Stop'

$targets = @(
    'C:\Users\adamp\AppData\Local\Temp\sellsniper-link-evidence-qa'
    'C:\Users\adamp\AppData\Local\Temp\sellsniper-search-performance-qa'
    'C:\Users\adamp\AppData\Local\Temp\sellsniper-website-change-qa'
    'C:\Users\adamp\AppData\Local\Temp\sellsniper-campaign-qa'
    'C:\Users\adamp\AppData\Local\Temp\crossbar-edge-cdp'
    'C:\Users\adamp\AppData\Local\Temp\moneymeta-cdp'
    'C:\Users\adamp\AppData\Local\Temp\HeadlessEdge3579273821062'
    'C:\Users\adamp\AppData\Local\Temp\sellsniper-company-qa'
    'C:\Users\adamp\AppData\Local\Temp\adam-gives-edge-prod-codex'
    'C:\Users\adamp\AppData\Local\Temp\skill-supply-bh-20260826-v2'
    'C:\Users\adamp\AppData\Local\Temp\sellsniper-competitor-qa'
    'C:\Users\adamp\AppData\Local\Temp\beeper-chat-visual'
    'C:\Users\adamp\AppData\Local\Temp\cleared-chat-cdp-clean'
    'C:\Users\adamp\AppData\Local\Temp\node-compile-cache'
    'C:\Users\adamp\AppData\Local\Temp\bc-cdp-profile'
    'C:\Users\adamp\AppData\Local\Temp\HeadlessEdge1169615096109'
    'C:\Users\adamp\AppData\Local\Temp\sellsniper-edge-cdp-evidence2'
    'C:\Users\adamp\AppData\Local\Temp\skill-supply-bh-3107'
    'C:\Users\adamp\AppData\Local\Temp\sellsniper-brand-profile-qa'
    'C:\Users\adamp\AppData\Local\Temp\sellsniper-refresh-qa'
    'C:\Users\adamp\AppData\Local\npm-cache\_npx'
    'C:\Users\adamp\AppData\Local\npm-cache\_cacache'
    'C:\Users\adamp\.cache\puppeteer'
    'C:\Users\adamp\.cache\codex-incomplete-node-modules'
)

$allowedRoots = @(
    [System.IO.Path]::GetFullPath('C:\Users\adamp\AppData\Local\Temp')
    [System.IO.Path]::GetFullPath('C:\Users\adamp\AppData\Local\npm-cache')
    [System.IO.Path]::GetFullPath('C:\Users\adamp\.cache')
)

function Get-TreeBytes {
    param([Parameter(Mandatory)][string]$Path)

    if (-not (Test-Path -LiteralPath $Path)) {
        return [int64]0
    }

    [int64]$bytes = 0
    $directories = [System.Collections.Generic.Stack[string]]::new()
    $directories.Push($Path)

    while ($directories.Count -gt 0) {
        $directory = $directories.Pop()

        try {
            foreach ($filePath in [System.IO.Directory]::EnumerateFiles($directory)) {
                try {
                    $bytes += [System.IO.FileInfo]::new($filePath).Length
                }
                catch {}
            }

            foreach ($childPath in [System.IO.Directory]::EnumerateDirectories($directory)) {
                try {
                    $child = [System.IO.DirectoryInfo]::new($childPath)
                    if (-not ($child.Attributes -band [System.IO.FileAttributes]::ReparsePoint)) {
                        $directories.Push($childPath)
                    }
                }
                catch {}
            }
        }
        catch {}
    }

    return $bytes
}

function Assert-ExactApprovedTarget {
    param([Parameter(Mandatory)][string]$Path)

    $resolved = [System.IO.Path]::GetFullPath($Path)
    if ($resolved -notin $targets) {
        throw "Resolved target is not in the exact confirmed list: $resolved"
    }

    $insideApprovedRoot = $false
    foreach ($root in $allowedRoots) {
        $prefix = $root + [System.IO.Path]::DirectorySeparatorChar
        if ($resolved.StartsWith($prefix, [System.StringComparison]::OrdinalIgnoreCase)) {
            $insideApprovedRoot = $true
            break
        }
    }

    if (-not $insideApprovedRoot) {
        throw "Target is outside the approved cache roots: $resolved"
    }

    if (Test-Path -LiteralPath $resolved) {
        $info = Get-Item -LiteralPath $resolved -Force
        if (-not $info.PSIsContainer) {
            throw "Confirmed target is no longer a directory: $resolved"
        }
        if ($info.Attributes -band [System.IO.FileAttributes]::ReparsePoint) {
            throw "Refusing reparse-point target: $resolved"
        }
    }

    return $resolved
}

$results = [System.Collections.Generic.List[object]]::new()
$freeBefore = (Get-CimInstance Win32_LogicalDisk -Filter "DeviceID='C:'").FreeSpace

foreach ($target in $targets) {
    $resolved = Assert-ExactApprovedTarget -Path $target

    if (-not (Test-Path -LiteralPath $resolved)) {
        $results.Add([pscustomobject]@{
            Path = $resolved
            Status = 'already absent'
            RemovedBytes = [int64]0
            Detail = ''
        })
        continue
    }

    $processes = @(Get-CimInstance Win32_Process | Where-Object {
        $_.ProcessId -ne $PID -and
        $_.CommandLine -and
        $_.CommandLine.IndexOf($resolved, [System.StringComparison]::OrdinalIgnoreCase) -ge 0
    })

    if ($processes.Count -gt 0) {
        $results.Add([pscustomobject]@{
            Path = $resolved
            Status = 'skipped active'
            RemovedBytes = [int64]0
            Detail = "Process IDs: $($processes.ProcessId -join ', ')"
        })
        continue
    }

    $bytes = Get-TreeBytes -Path $resolved

    try {
        Remove-Item -LiteralPath $resolved -Recurse -Force
        $results.Add([pscustomobject]@{
            Path = $resolved
            Status = 'removed'
            RemovedBytes = $bytes
            Detail = ''
        })
    }
    catch {
        $results.Add([pscustomobject]@{
            Path = $resolved
            Status = 'failed'
            RemovedBytes = [int64]0
            Detail = $_.Exception.Message
        })
    }
}

$freeAfter = (Get-CimInstance Win32_LogicalDisk -Filter "DeviceID='C:'").FreeSpace
$removedBytes = [int64](($results | Measure-Object -Property RemovedBytes -Sum).Sum)
$report = [pscustomobject]@{
    ConfirmedPhrase = 'CONFIRM TEMP-20 + CACHE-4'
    CompletedAt = [DateTimeOffset]::Now.ToString('O')
    RemovedTargets = @($results | Where-Object Status -eq 'removed').Count
    SkippedActiveTargets = @($results | Where-Object Status -eq 'skipped active').Count
    FailedTargets = @($results | Where-Object Status -eq 'failed').Count
    MeasuredRemovedGiB = [math]::Round($removedBytes / 1GB, 2)
    ActualFreeSpaceGainGiB = [math]::Round(($freeAfter - $freeBefore) / 1GB, 2)
    FreeGiB = [math]::Round($freeAfter / 1GB, 2)
    Results = $results
}

$reportPath = 'C:\Users\adamp\Aether\storageclean.app\artifacts\cleanup-confirmed-powerlaw-2026-08-28.json'
$report | ConvertTo-Json -Depth 5 | Set-Content -LiteralPath $reportPath -Encoding utf8

$report | Select-Object RemovedTargets, SkippedActiveTargets, FailedTargets, MeasuredRemovedGiB, ActualFreeSpaceGainGiB, FreeGiB | Format-List
Write-Host "Report: $reportPath"
