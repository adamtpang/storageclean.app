[CmdletBinding(SupportsShouldProcess)]
param(
    [switch]$RemoveArchivedInstaller
)

Set-StrictMode -Version Latest
$ErrorActionPreference = 'Stop'

$expectedProfile = 'C:\Users\adamp'
if ([Environment]::GetFolderPath('UserProfile') -ne $expectedProfile) {
    throw "Safety check failed: expected profile $expectedProfile"
}

$fileTargets = @(
    'C:\Users\adamp\.antigravity',
    'C:\Users\adamp\AppData\Local\antigravity-updater',
    'C:\Users\adamp\AppData\Roaming\Antigravity',
    'C:\Users\adamp\AppData\Local\Programs\Antigravity',
    'C:\Users\adamp\AppData\Local\Programs\Antigravity IDE',
    'C:\Users\adamp\AppData\Roaming\Microsoft\Windows\Start Menu\Programs\Antigravity'
)

if ($RemoveArchivedInstaller) {
    $fileTargets += 'C:\Users\adamp\Desktop\win\Software\Installers\Antigravity.exe'
}

$allowedPrefixes = @(
    'C:\Users\adamp\.antigravity',
    'C:\Users\adamp\AppData\',
    'C:\Users\adamp\Desktop\win\Software\Installers\Antigravity.exe'
)

foreach ($target in $fileTargets) {
    if (-not ($allowedPrefixes | Where-Object { $target.StartsWith($_, [StringComparison]::OrdinalIgnoreCase) })) {
        throw "Safety check failed for target: $target"
    }
}

$backupBase = if (Test-Path -LiteralPath 'E:\Backup') {
    'E:\Backup\CleanupBackups'
} else {
    $PSScriptRoot
}
$backupRoot = Join-Path $backupBase ('antigravity-registry-backup-' + (Get-Date -Format 'yyyyMMdd-HHmmss'))
if (-not $WhatIfPreference) {
    New-Item -ItemType Directory -Path $backupRoot -Force | Out-Null
    & reg.exe export 'HKCU\Software\Microsoft\Windows\CurrentVersion\Uninstall\{AA73B3E3-C6C8-45C8-B1DC-4AE56C751432}_is1' (Join-Path $backupRoot 'uninstall-entry.reg') /y | Out-Null
    & reg.exe export 'HKCU\Software\Classes' (Join-Path $backupRoot 'user-classes.reg') /y | Out-Null
}

Get-Process -ErrorAction SilentlyContinue |
    Where-Object { $_.ProcessName -match '^Antigravity' } |
    ForEach-Object {
        if ($PSCmdlet.ShouldProcess($_.ProcessName, 'Stop process')) {
            Stop-Process -Id $_.Id -Force
        }
    }

foreach ($target in $fileTargets) {
    if (Test-Path -LiteralPath $target) {
        if ($PSCmdlet.ShouldProcess($target, 'Remove Antigravity file remnant')) {
            Remove-Item -LiteralPath $target -Recurse -Force
        }
    }
}

$registryKeys = @(
    'HKCU:\Software\Microsoft\Windows\CurrentVersion\Uninstall\{AA73B3E3-C6C8-45C8-B1DC-4AE56C751432}_is1',
    'HKCU:\Software\Classes\Applications\Antigravity.exe',
    'HKCU:\Software\Classes\CLSID\{0CA0EE8A-AFC5-474C-AE3A-059FB244B85B}',
    'HKCU:\Software\Classes\CLSID\{578BF383-315A-4ACA-9144-C939D97DF2F1}',
    'HKCU:\Software\Microsoft\Windows\CurrentVersion\CapabilityAccessManager\ConsentStore\microphone\NonPackaged\C:#Users#adamp#AppData#Local#Programs#antigravity#Antigravity.exe',
    'HKCU:\Software\Microsoft\Windows\CurrentVersion\Notifications\Settings\electron.app.Antigravity',
    'HKCU:\Software\Microsoft\Windows\CurrentVersion\Notifications\Settings\Google.Antigravity',
    'HKCU:\Software\Microsoft\Windows\CurrentVersion\PushNotifications\Backup\Google.Antigravity',
    'HKCU:\Software\Microsoft\Windows\CurrentVersion\Start\TileProperties\W~com.google.antigravity',
    'HKCU:\Software\Microsoft\Windows\CurrentVersion\Start\TileProperties\W~electron.app.Antigravity',
    'HKCU:\Software\Microsoft\Windows\CurrentVersion\Start\TileProperties\W~Google.Antigravity',
    'HKCU:\Software\Microsoft\Windows\CurrentVersion\Start\TileProperties\W~Google.AntigravityIDE'
)

Get-ChildItem -LiteralPath 'HKCU:\Software\Classes' -ErrorAction SilentlyContinue |
    Where-Object { $_.PSChildName -like 'Antigravity*' } |
    ForEach-Object { $registryKeys += $_.PSPath }

foreach ($key in ($registryKeys | Select-Object -Unique)) {
    if (Test-Path -LiteralPath $key) {
        if ($PSCmdlet.ShouldProcess($key, 'Remove Antigravity registry key')) {
            Remove-Item -LiteralPath $key -Recurse -Force
        }
    }
}

Get-ChildItem -LiteralPath 'HKCU:\Software\Classes' -ErrorAction SilentlyContinue |
    Where-Object { $_.PSChildName -like '.*' } |
    ForEach-Object {
        $openWith = Join-Path $_.PSPath 'OpenWithProgids'
        if (Test-Path -LiteralPath $openWith) {
            $properties = Get-ItemProperty -LiteralPath $openWith
            $properties.PSObject.Properties |
                Where-Object { $_.Name -like 'Antigravity.*' } |
                ForEach-Object {
                    if ($PSCmdlet.ShouldProcess("$openWith::$($_.Name)", 'Remove Antigravity file association')) {
                        Remove-ItemProperty -LiteralPath $openWith -Name $_.Name -Force
                    }
                }
        }
    }

$historyLocations = @(
    'HKCU:\Software\Microsoft\Windows\CurrentVersion\ApplicationAssociationToasts',
    'HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\FeatureUsage\AppBadgeUpdated',
    'HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\FeatureUsage\AppLaunch',
    'HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\FeatureUsage\AppSwitched',
    'HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\FeatureUsage\ShowJumpView',
    'HKCU:\Software\Microsoft\Windows\CurrentVersion\Search\JumplistData'
)

foreach ($location in $historyLocations) {
    if (Test-Path -LiteralPath $location) {
        $properties = Get-ItemProperty -LiteralPath $location
        $properties.PSObject.Properties |
            Where-Object { $_.Name -match 'Antigravity' } |
            ForEach-Object {
                if ($PSCmdlet.ShouldProcess("$location::$($_.Name)", 'Remove Antigravity shell history')) {
                    Remove-ItemProperty -LiteralPath $location -Name $_.Name -Force
                }
            }
    }
}

$remainingFiles = @($fileTargets | Where-Object { Test-Path -LiteralPath $_ })
$orphanKey = 'HKCU:\Software\Microsoft\Windows\CurrentVersion\Uninstall\{AA73B3E3-C6C8-45C8-B1DC-4AE56C751432}_is1'
$remainingRegistry = Test-Path -LiteralPath $orphanKey

if (-not $WhatIfPreference -and ($remainingFiles.Count -gt 0 -or $remainingRegistry)) {
    throw "Antigravity cleanup did not fully verify. Remaining files: $($remainingFiles -join ', '); orphan entry: $remainingRegistry"
}

if ($WhatIfPreference) {
    Write-Output 'Antigravity cleanup preview completed. No changes were made.'
} else {
    Write-Output 'Antigravity cleanup verified.'
    Write-Output "Registry backup: $backupRoot"
}
