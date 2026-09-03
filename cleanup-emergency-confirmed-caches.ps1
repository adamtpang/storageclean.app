[CmdletBinding()]
param()

Set-StrictMode -Version Latest
$ErrorActionPreference = 'Stop'

$tempRoot = [System.IO.Path]::GetFullPath('C:\Users\adamp\AppData\Local\Temp')
$targets = @(
    'C:\Users\adamp\AppData\Local\Temp\akohgynz'
    'C:\Users\adamp\AppData\Local\Temp\sellsniper-ranking-qa'
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
            foreach ($file in [System.IO.Directory]::EnumerateFiles($directory)) {
                try {
                    $bytes += [System.IO.FileInfo]::new($file).Length
                }
                catch {}
            }

            foreach ($child in [System.IO.Directory]::EnumerateDirectories($directory)) {
                try {
                    $info = [System.IO.DirectoryInfo]::new($child)
                    if (-not ($info.Attributes -band [System.IO.FileAttributes]::ReparsePoint)) {
                        $directories.Push($child)
                    }
                }
                catch {}
            }
        }
        catch {}
    }

    return $bytes
}

$processes = Get-CimInstance Win32_Process
$before = [int64]0

foreach ($target in $targets) {
    $resolved = [System.IO.Path]::GetFullPath($target)
    $expectedPrefix = $tempRoot + [System.IO.Path]::DirectorySeparatorChar

    if (-not $resolved.StartsWith($expectedPrefix, [System.StringComparison]::OrdinalIgnoreCase)) {
        throw "Refusing target outside the approved Temp root: $resolved"
    }

    if ($resolved -notin $targets) {
        throw "Resolved target does not exactly match an approved target: $resolved"
    }

    $leaf = [System.IO.Path]::GetFileName($resolved)
    $users = @($processes | Where-Object {
        $_.CommandLine -and $_.CommandLine.IndexOf($leaf, [System.StringComparison]::OrdinalIgnoreCase) -ge 0
    })

    if ($users.Count -gt 0) {
        $ids = ($users.ProcessId -join ', ')
        throw "Refusing to remove $resolved because process IDs $ids reference it."
    }

    $before += Get-TreeBytes -Path $resolved

    if (Test-Path -LiteralPath $resolved) {
        Remove-Item -LiteralPath $resolved -Recurse -Force
    }
}

$remaining = @($targets | Where-Object { Test-Path -LiteralPath $_ })
$freeBytes = (Get-CimInstance Win32_LogicalDisk -Filter "DeviceID='C:'").FreeSpace

[pscustomobject]@{
    RemovedGiB = [math]::Round($before / 1GB, 2)
    FreeGiB = [math]::Round($freeBytes / 1GB, 2)
    RemainingTargets = if ($remaining.Count -eq 0) { 'none' } else { $remaining -join '; ' }
} | Format-List
