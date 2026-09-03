[CmdletBinding()]
param(
    [ValidateSet('Desktop', 'Pictures')]
    [string]$Profile = 'Desktop',
    [string]$Source = 'C:\Users\adamp\Desktop\win',
    [string]$Destination = 'E:\Backup\Desktop\win',
    [string]$ReportRoot = 'E:\Backup\verification',
    [string]$ResumeFrom,
    [switch]$TraverseConfirmedCloudDirectories
)

Set-StrictMode -Version Latest
$ErrorActionPreference = 'Stop'

$expectedSource = if ($Profile -eq 'Pictures') {
    [System.IO.Path]::GetFullPath('C:\Users\adamp\Pictures')
}
else {
    [System.IO.Path]::GetFullPath('C:\Users\adamp\Desktop\win')
}
$expectedDestination = if ($Profile -eq 'Pictures') {
    [System.IO.Path]::GetFullPath('E:\Backup\Pictures')
}
else {
    [System.IO.Path]::GetFullPath('E:\Backup\Desktop\win')
}
$sourceRoot = [System.IO.Path]::GetFullPath($Source).TrimEnd('\')
$destinationRoot = [System.IO.Path]::GetFullPath($Destination).TrimEnd('\')
$confirmedCloudDirectoryRoots = @(
    [System.IO.Path]::GetFullPath('C:\Users\adamp\Desktop\win\Unsorted\Apps\comparrow MVP V1 - Copy').TrimEnd('\'),
    [System.IO.Path]::GetFullPath('C:\Users\adamp\Desktop\win\Unsorted\Apps\win64').TrimEnd('\')
)

if (-not $sourceRoot.Equals($expectedSource, [System.StringComparison]::OrdinalIgnoreCase)) {
    throw "Source must exactly match $expectedSource"
}

if (-not $destinationRoot.Equals($expectedDestination, [System.StringComparison]::OrdinalIgnoreCase)) {
    throw "Destination must exactly match $expectedDestination"
}

if (-not (Test-Path -LiteralPath $sourceRoot -PathType Container)) {
    throw "Source directory is unavailable: $sourceRoot"
}

if (-not (Test-Path -LiteralPath $destinationRoot -PathType Container)) {
    throw "Destination directory is unavailable: $destinationRoot"
}

$sourceInfo = Get-Item -LiteralPath $sourceRoot -Force
$destinationInfo = Get-Item -LiteralPath $destinationRoot -Force
if (($sourceInfo.Attributes -band [System.IO.FileAttributes]::ReparsePoint) -or
    ($destinationInfo.Attributes -band [System.IO.FileAttributes]::ReparsePoint)) {
    throw 'Source and destination roots must not be reparse points.'
}

$runPrefix = if ($Profile -eq 'Pictures') { 'pictures-full-verify' } else { 'desktop-win-full-verify' }
$runName = "$runPrefix-$([DateTimeOffset]::Now.ToString('yyyyMMdd-HHmmss'))"
$reportDirectory = Join-Path ([System.IO.Path]::GetFullPath($ReportRoot)) $runName
New-Item -ItemType Directory -Path $reportDirectory -Force | Out-Null

$manifestPath = Join-Path $reportDirectory 'manifest.jsonl'
$placeholderPath = Join-Path $reportDirectory 'offline-placeholders.jsonl'
$problemPath = Join-Path $reportDirectory 'problems.jsonl'
$summaryPath = Join-Path $reportDirectory 'summary.json'

$resumeVerified = [System.Collections.Generic.Dictionary[string, object]]::new(
    [System.StringComparer]::OrdinalIgnoreCase
)
[int64]$resumeManifestRecords = 0
[int64]$resumeInvalidLines = 0

if ($ResumeFrom) {
    $resumeRoot = [System.IO.Path]::GetFullPath($ResumeFrom).TrimEnd('\')
    $expectedReportRoot = [System.IO.Path]::GetFullPath($ReportRoot).TrimEnd('\')
    if (-not $resumeRoot.StartsWith($expectedReportRoot + '\', [System.StringComparison]::OrdinalIgnoreCase)) {
        throw "Resume directory must be inside $expectedReportRoot"
    }

    $resumeManifestPath = Join-Path $resumeRoot 'manifest.jsonl'
    if (-not (Test-Path -LiteralPath $resumeManifestPath -PathType Leaf)) {
        throw "Resume manifest is unavailable: $resumeManifestPath"
    }

    foreach ($line in [System.IO.File]::ReadLines($resumeManifestPath)) {
        if ([string]::IsNullOrWhiteSpace($line)) {
            continue
        }

        try {
            $prior = $line | ConvertFrom-Json
            $resumeManifestRecords++
            if (($prior.Status -eq 'verified' -or $prior.Status -eq 'verified-reused') -and $prior.RelativePath -and $null -ne $prior.Bytes -and $prior.LastWriteUtc) {
                $resumeVerified[$prior.RelativePath] = $prior
            }
        }
        catch {
            $resumeInvalidLines++
        }
    }

    Write-Host ("Resume evidence: {0:N0} verified records loaded, {1:N0} invalid trailing lines ignored" -f $resumeVerified.Count, $resumeInvalidLines)
}

$manifestWriter = [System.IO.StreamWriter]::new($manifestPath, $false, [System.Text.UTF8Encoding]::new($false))
$placeholderWriter = [System.IO.StreamWriter]::new($placeholderPath, $false, [System.Text.UTF8Encoding]::new($false))
$problemWriter = [System.IO.StreamWriter]::new($problemPath, $false, [System.Text.UTF8Encoding]::new($false))

function Get-Sha256 {
    param([Parameter(Mandatory)][string]$Path)

    $share = [System.IO.FileShare]::ReadWrite -bor [System.IO.FileShare]::Delete
    $stream = [System.IO.File]::Open($Path, [System.IO.FileMode]::Open, [System.IO.FileAccess]::Read, $share)
    $algorithm = [System.Security.Cryptography.SHA256]::Create()
    try {
        $hashBytes = $algorithm.ComputeHash($stream)
        return ([System.BitConverter]::ToString($hashBytes)).Replace('-', '').ToLowerInvariant()
    }
    finally {
        $algorithm.Dispose()
        $stream.Dispose()
    }
}

function Write-JsonLine {
    param(
        [Parameter(Mandatory)][System.IO.StreamWriter]$Writer,
        [Parameter(Mandatory)][object]$Value
    )

    $Writer.WriteLine(($Value | ConvertTo-Json -Compress -Depth 4))
}

[int64]$processed = 0
[int64]$verified = 0
[int64]$verifiedBytes = 0
[int64]$reusedVerified = 0
[int64]$reusedVerifiedBytes = 0
[int64]$placeholderCount = 0
[int64]$placeholderLogicalBytes = 0
[int64]$missingDestination = 0
[int64]$sizeMismatch = 0
[int64]$hashMismatch = 0
[int64]$unreadable = 0
[int64]$changedDuringHash = 0
[int64]$skippedReparseDirectories = 0
[int64]$traversedConfirmedCloudReparseDirectories = 0
[int64]$sourceLogicalBytes = 0
$startedAt = [DateTimeOffset]::Now
$stopwatch = [System.Diagnostics.Stopwatch]::StartNew()
$directories = [System.Collections.Generic.Stack[string]]::new()
$directories.Push($sourceRoot)

try {
    while ($directories.Count -gt 0) {
        $directory = $directories.Pop()

        try {
            foreach ($childPath in [System.IO.Directory]::EnumerateDirectories($directory)) {
                try {
                    $child = [System.IO.DirectoryInfo]::new($childPath)
                    if ($child.Attributes -band [System.IO.FileAttributes]::ReparsePoint) {
                        $normalizedChildPath = [System.IO.Path]::GetFullPath($childPath).TrimEnd('\')
                        $isConfirmedCloudDirectory = $false
                        if ($TraverseConfirmedCloudDirectories) {
                            foreach ($confirmedRoot in $confirmedCloudDirectoryRoots) {
                                if ($normalizedChildPath.Equals($confirmedRoot, [System.StringComparison]::OrdinalIgnoreCase) -or
                                    $normalizedChildPath.StartsWith($confirmedRoot + '\', [System.StringComparison]::OrdinalIgnoreCase)) {
                                    $isConfirmedCloudDirectory = $true
                                    break
                                }
                            }
                        }

                        if ($isConfirmedCloudDirectory) {
                            $traversedConfirmedCloudReparseDirectories++
                            $directories.Push($childPath)
                        }
                        else {
                            $skippedReparseDirectories++
                        }
                    }
                    else {
                        $directories.Push($childPath)
                    }
                }
                catch {
                    $unreadable++
                    Write-JsonLine -Writer $problemWriter -Value ([pscustomobject]@{
                        Status = 'unreadable-directory'
                        Path = $childPath
                        Detail = $_.Exception.Message
                    })
                }
            }
        }
        catch {
            $unreadable++
            Write-JsonLine -Writer $problemWriter -Value ([pscustomobject]@{
                Status = 'unreadable-directory-enumeration'
                Path = $directory
                Detail = $_.Exception.Message
            })
        }

        try {
            foreach ($filePath in [System.IO.Directory]::EnumerateFiles($directory)) {
                $processed++
                $relativePath = $filePath.Substring($sourceRoot.Length).TrimStart('\')
                $destinationPath = Join-Path $destinationRoot $relativePath

                try {
                    $before = [System.IO.FileInfo]::new($filePath)
                    $sourceLength = $before.Length
                    $sourceLogicalBytes += $sourceLength
                    $attributeValue = [int64]$before.Attributes
                    $isOffline = ($attributeValue -band 0x1000) -ne 0
                    $recallOnOpen = ($attributeValue -band 0x40000) -ne 0
                    $recallOnDataAccess = ($attributeValue -band 0x400000) -ne 0

                    if ($isOffline -or $recallOnOpen -or $recallOnDataAccess) {
                        $placeholderCount++
                        $placeholderLogicalBytes += $sourceLength
                        $entry = [pscustomobject]@{
                            RelativePath = $relativePath
                            Status = 'offline-placeholder'
                            LogicalBytes = $sourceLength
                            Attributes = $before.Attributes.ToString()
                            LastWriteUtc = $before.LastWriteTimeUtc.ToString('O')
                            DestinationExists = [System.IO.File]::Exists($destinationPath)
                        }
                        Write-JsonLine -Writer $placeholderWriter -Value $entry
                        Write-JsonLine -Writer $manifestWriter -Value $entry
                        continue
                    }

                    if (-not [System.IO.File]::Exists($destinationPath)) {
                        $missingDestination++
                        $entry = [pscustomobject]@{
                            RelativePath = $relativePath
                            Status = 'missing-destination'
                            SourceBytes = $sourceLength
                        }
                        Write-JsonLine -Writer $problemWriter -Value $entry
                        Write-JsonLine -Writer $manifestWriter -Value $entry
                        continue
                    }

                    $destinationFile = [System.IO.FileInfo]::new($destinationPath)
                    if ($destinationFile.Length -ne $sourceLength) {
                        $sizeMismatch++
                        $entry = [pscustomobject]@{
                            RelativePath = $relativePath
                            Status = 'size-mismatch'
                            SourceBytes = $sourceLength
                            DestinationBytes = $destinationFile.Length
                        }
                        Write-JsonLine -Writer $problemWriter -Value $entry
                        Write-JsonLine -Writer $manifestWriter -Value $entry
                        continue
                    }

                    $priorVerified = $null
                    if ($resumeVerified.TryGetValue($relativePath, [ref]$priorVerified)) {
                        $priorLastWriteUtc = [DateTime]::Parse(
                            [string]$priorVerified.LastWriteUtc,
                            [System.Globalization.CultureInfo]::InvariantCulture,
                            [System.Globalization.DateTimeStyles]::RoundtripKind
                        ).ToUniversalTime()

                        $metadataStillMatches = (
                            [int64]$priorVerified.Bytes -eq $sourceLength -and
                            $before.LastWriteTimeUtc -eq $priorLastWriteUtc -and
                            $destinationFile.LastWriteTimeUtc -eq $before.LastWriteTimeUtc
                        )

                        if ($metadataStillMatches) {
                            $verified++
                            $verifiedBytes += $sourceLength
                            $reusedVerified++
                            $reusedVerifiedBytes += $sourceLength
                            Write-JsonLine -Writer $manifestWriter -Value ([pscustomobject]@{
                                RelativePath = $relativePath
                                Status = 'verified-reused'
                                Bytes = $sourceLength
                                Sha256 = $priorVerified.Sha256
                                LastWriteUtc = $before.LastWriteTimeUtc.ToString('O')
                                DestinationLastWriteUtc = $destinationFile.LastWriteTimeUtc.ToString('O')
                            })

                            if (($processed % 250) -eq 0) {
                                $rate = if ($stopwatch.Elapsed.TotalSeconds -gt 0) { $processed / $stopwatch.Elapsed.TotalSeconds } else { 0 }
                                Write-Host ("Progress: {0:N0} files, {1:N2} GiB verified, {2:N1} files/sec, {3:N0} problems, {4:N0} placeholders, {5:N0} prior hashes reused" -f $processed, ($verifiedBytes / 1GB), $rate, ($missingDestination + $sizeMismatch + $hashMismatch + $unreadable + $changedDuringHash), $placeholderCount, $reusedVerified)
                                $manifestWriter.Flush()
                                $placeholderWriter.Flush()
                                $problemWriter.Flush()
                            }
                            continue
                        }
                    }

                    $sourceHash = Get-Sha256 -Path $filePath
                    $destinationHash = Get-Sha256 -Path $destinationPath
                    $after = [System.IO.FileInfo]::new($filePath)

                    if ($after.Length -ne $sourceLength -or $after.LastWriteTimeUtc -ne $before.LastWriteTimeUtc) {
                        $changedDuringHash++
                        $entry = [pscustomobject]@{
                            RelativePath = $relativePath
                            Status = 'source-changed-during-hash'
                            SourceBytesBefore = $sourceLength
                            SourceBytesAfter = $after.Length
                        }
                        Write-JsonLine -Writer $problemWriter -Value $entry
                        Write-JsonLine -Writer $manifestWriter -Value $entry
                        continue
                    }

                    if ($sourceHash -ne $destinationHash) {
                        $hashMismatch++
                        $entry = [pscustomobject]@{
                            RelativePath = $relativePath
                            Status = 'hash-mismatch'
                            Bytes = $sourceLength
                            SourceSha256 = $sourceHash
                            DestinationSha256 = $destinationHash
                        }
                        Write-JsonLine -Writer $problemWriter -Value $entry
                        Write-JsonLine -Writer $manifestWriter -Value $entry
                        continue
                    }

                    $verified++
                    $verifiedBytes += $sourceLength
                    Write-JsonLine -Writer $manifestWriter -Value ([pscustomobject]@{
                        RelativePath = $relativePath
                        Status = 'verified'
                        Bytes = $sourceLength
                        Sha256 = $sourceHash
                        LastWriteUtc = $before.LastWriteTimeUtc.ToString('O')
                    })
                }
                catch {
                    $unreadable++
                    $entry = [pscustomobject]@{
                        RelativePath = $relativePath
                        Status = 'unreadable-file'
                        Detail = $_.Exception.Message
                    }
                    Write-JsonLine -Writer $problemWriter -Value $entry
                    Write-JsonLine -Writer $manifestWriter -Value $entry
                }

                if (($processed % 250) -eq 0) {
                    $rate = if ($stopwatch.Elapsed.TotalSeconds -gt 0) { $processed / $stopwatch.Elapsed.TotalSeconds } else { 0 }
                    Write-Host ("Progress: {0:N0} files, {1:N2} GiB verified, {2:N1} files/sec, {3:N0} problems, {4:N0} placeholders" -f $processed, ($verifiedBytes / 1GB), $rate, ($missingDestination + $sizeMismatch + $hashMismatch + $unreadable + $changedDuringHash), $placeholderCount)
                    $manifestWriter.Flush()
                    $placeholderWriter.Flush()
                    $problemWriter.Flush()
                }
            }
        }
        catch {
            $unreadable++
            Write-JsonLine -Writer $problemWriter -Value ([pscustomobject]@{
                Status = 'unreadable-file-enumeration'
                Path = $directory
                Detail = $_.Exception.Message
            })
        }
    }
}
finally {
    $stopwatch.Stop()
    $manifestWriter.Dispose()
    $placeholderWriter.Dispose()
    $problemWriter.Dispose()
}

$problemCount = $missingDestination + $sizeMismatch + $hashMismatch + $unreadable + $changedDuringHash
$summary = [pscustomobject]@{
    Confirmation = if ($Profile -eq 'Pictures') { 'READ-ONLY PICTURES FULL VERIFY' } else { 'CONFIRM DESKTOP FULL VERIFY' }
    Source = $sourceRoot
    Destination = $destinationRoot
    StartedAt = $startedAt.ToString('O')
    CompletedAt = [DateTimeOffset]::Now.ToString('O')
    ElapsedMinutes = [math]::Round($stopwatch.Elapsed.TotalMinutes, 2)
    ProcessedFiles = $processed
    SourceLogicalGiB = [math]::Round($sourceLogicalBytes / 1GB, 3)
    VerifiedFiles = $verified
    VerifiedGiB = [math]::Round($verifiedBytes / 1GB, 3)
    ReusedVerifiedFiles = $reusedVerified
    ReusedVerifiedGiB = [math]::Round($reusedVerifiedBytes / 1GB, 3)
    ResumeManifestRecords = $resumeManifestRecords
    ResumeInvalidLinesIgnored = $resumeInvalidLines
    OfflinePlaceholders = $placeholderCount
    PlaceholderLogicalMiB = [math]::Round($placeholderLogicalBytes / 1MB, 2)
    MissingDestination = $missingDestination
    SizeMismatch = $sizeMismatch
    HashMismatch = $hashMismatch
    ChangedDuringHash = $changedDuringHash
    Unreadable = $unreadable
    SkippedReparseDirectories = $skippedReparseDirectories
    TraversedConfirmedCloudReparseDirectories = $traversedConfirmedCloudReparseDirectories
    ProblemCount = $problemCount
    SafeToConsiderSourceRemoval = ($problemCount -eq 0)
    Manifest = $manifestPath
    PlaceholderManifest = $placeholderPath
    Problems = $problemPath
}

$summary | ConvertTo-Json -Depth 4 | Set-Content -LiteralPath $summaryPath -Encoding utf8
$summary | Format-List
Write-Host "Summary: $summaryPath"
