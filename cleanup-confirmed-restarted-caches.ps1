[CmdletBinding(SupportsShouldProcess)]
param()

Set-StrictMode -Version Latest
$ErrorActionPreference = 'Stop'

$expectedProfile = 'C:\Users\adamp'
$tempRoot = 'C:\Users\adamp\AppData\Local\Temp'
$confirmedTempFolders = @(
    'C:\Users\adamp\AppData\Local\Temp\sellsniper-ranking-qa',
    'C:\Users\adamp\AppData\Local\Temp\akohgynz',
    'C:\Users\adamp\AppData\Local\Temp\sellsniper-campaign-qa',
    'C:\Users\adamp\AppData\Local\Temp\cleared-chat-cdp-light',
    'C:\Users\adamp\AppData\Local\Temp\adam-gives-edge-codex'
)

$oneDriveFolder = 'C:\Users\adamp\OneDrive'
$runKey = 'HKCU:\Software\Microsoft\Windows\CurrentVersion\Run'
$oneDriveRunValue = 'OneDriveSetup'

function Get-OptionalRegistryValue {
    param(
        [Parameter(Mandatory)]
        [string]$Path,

        [Parameter(Mandatory)]
        [string]$Name
    )

    $item = Get-ItemProperty -Path $Path -Name $Name -ErrorAction SilentlyContinue
    if ($null -eq $item) {
        return $null
    }

    $property = $item.PSObject.Properties[$Name]
    if ($null -eq $property) {
        return $null
    }

    return $property.Value
}

if ([Environment]::GetFolderPath('UserProfile') -ne $expectedProfile) {
    throw "Safety check failed: expected profile $expectedProfile"
}

$resolvedTempRoot = [IO.Path]::GetFullPath($tempRoot).TrimEnd('\') + '\'
$diskBefore = Get-CimInstance Win32_LogicalDisk -Filter "DeviceID='C:'"
$freeBefore = $diskBefore.FreeSpace
$removed = @()

foreach ($target in $confirmedTempFolders) {
    $resolved = [IO.Path]::GetFullPath($target).TrimEnd('\')
    if (-not $resolved.StartsWith($resolvedTempRoot, [StringComparison]::OrdinalIgnoreCase)) {
        throw "Safety check failed for out-of-scope target: $resolved"
    }

    if (-not (Test-Path -LiteralPath $resolved)) {
        $removed += [pscustomobject]@{
            Path = $resolved
            PriorGiB = 0
            PriorFiles = 0
            Status = 'Already absent'
        }
        continue
    }

    $leaf = [IO.Path]::GetFileName($resolved)
    $liveUsers = Get-CimInstance Win32_Process |
        Where-Object {
            $_.ProcessId -ne $PID -and
            $_.CommandLine -and
            $_.CommandLine.IndexOf($leaf, [StringComparison]::OrdinalIgnoreCase) -ge 0
        }

    if ($liveUsers) {
        throw "Target appears in a live process command line: $resolved"
    }

    $measurement = Get-ChildItem -LiteralPath $resolved -Recurse -Force -File -ErrorAction SilentlyContinue |
        Measure-Object Length -Sum

    if ($PSCmdlet.ShouldProcess($resolved, 'Remove confirmed temporary folder')) {
        Remove-Item -LiteralPath $resolved -Recurse -Force
    }

    $removed += [pscustomobject]@{
        Path = $resolved
        PriorGiB = [math]::Round($measurement.Sum / 1GB, 3)
        PriorFiles = $measurement.Count
        Status = if ($WhatIfPreference) {
            'Would remove'
        } elseif (-not (Test-Path -LiteralPath $resolved)) {
            'Removed'
        } else {
            'Still present'
        }
    }
}

$oneDriveCommand = Get-OptionalRegistryValue -Path $runKey -Name $oneDriveRunValue
if ($null -ne $oneDriveCommand -and $PSCmdlet.ShouldProcess("$runKey::$oneDriveRunValue", 'Remove OneDrive startup value')) {
    $backupBase = if (Test-Path -LiteralPath 'E:\Backup') {
        'E:\Backup\CleanupBackups'
    } else {
        $PSScriptRoot
    }
    $backupRoot = Join-Path $backupBase ('onedrive-run-key-' + (Get-Date -Format 'yyyyMMdd-HHmmss'))
    New-Item -ItemType Directory -Path $backupRoot -Force | Out-Null
    & reg.exe export 'HKCU\Software\Microsoft\Windows\CurrentVersion\Run' (Join-Path $backupRoot 'run-key.reg') /y | Out-Null
    Remove-ItemProperty -Path $runKey -Name $oneDriveRunValue
}

$oneDriveFiles = 0
$oneDriveBytes = 0
if (Test-Path -LiteralPath $oneDriveFolder) {
    $resolvedOneDrive = [IO.Path]::GetFullPath($oneDriveFolder).TrimEnd('\')
    if (-not $resolvedOneDrive.Equals($oneDriveFolder, [StringComparison]::OrdinalIgnoreCase)) {
        throw "Safety check failed for OneDrive target: $resolvedOneDrive"
    }

    $oneDriveContents = @(Get-ChildItem -LiteralPath $resolvedOneDrive -Recurse -Force -File -ErrorAction SilentlyContinue)
    $oneDriveFiles = $oneDriveContents.Count
    $oneDriveBytes = ($oneDriveContents | Measure-Object Length -Sum).Sum

    if ($oneDriveFiles -gt 10 -or $oneDriveBytes -gt 1MB) {
        throw "OneDrive repopulated unexpectedly. Refusing removal: $oneDriveFiles files, $oneDriveBytes bytes"
    }

    if ($PSCmdlet.ShouldProcess($resolvedOneDrive, 'Remove confirmed residual OneDrive folder')) {
        Remove-Item -LiteralPath $resolvedOneDrive -Recurse -Force
    }
}

if (-not $WhatIfPreference) {
    $remainingTemp = @($confirmedTempFolders | Where-Object { Test-Path -LiteralPath $_ })
    $remainingRunValue = Get-OptionalRegistryValue -Path $runKey -Name $oneDriveRunValue
    $oneDriveRemains = Test-Path -LiteralPath $oneDriveFolder

    if ($remainingTemp.Count -gt 0 -or $null -ne $remainingRunValue -or $oneDriveRemains) {
        throw "Cleanup verification failed. Remaining temp targets: $($remainingTemp -join ', '); startup value: $remainingRunValue; OneDrive folder: $oneDriveRemains"
    }
}

$diskAfter = Get-CimInstance Win32_LogicalDisk -Filter "DeviceID='C:'"
$freeAfter = $diskAfter.FreeSpace

$removed | Format-Table -AutoSize

$summary = [ordered]@{
    OneDriveStartupBefore = $oneDriveCommand
    OneDriveFilesBefore = $oneDriveFiles
    OneDriveBytesBefore = $oneDriveBytes
    OneDriveFolderStatus = if ($WhatIfPreference) {
        if (Test-Path -LiteralPath $oneDriveFolder) { 'Would remove' } else { 'Already absent' }
    } elseif (-not (Test-Path -LiteralPath $oneDriveFolder)) {
        'Removed'
    } else {
        'Still present'
    }
}

if ($WhatIfPreference) {
    $summary.CurrentFreeGiB = [math]::Round($freeAfter / 1GB, 3)
} else {
    $summary.FreeGiBBefore = [math]::Round($freeBefore / 1GB, 3)
    $summary.FreeGiBAfter = [math]::Round($freeAfter / 1GB, 3)
    $summary.RecoveredGiB = [math]::Round(($freeAfter - $freeBefore) / 1GB, 3)
}

[pscustomobject]$summary | Format-List

if ($WhatIfPreference) {
    Write-Output 'Cleanup preview completed. No changes were made.'
} else {
    Write-Output 'Confirmed cleanup completed and verified.'
}
