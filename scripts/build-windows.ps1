[CmdletBinding()]
param(
    [string]$Version = '0.3.0-beta.1',
    [string]$NumericVersion = '0.3.0.0',
    [string]$BuildRoot = '',
    [switch]$SkipInstaller
)

Set-StrictMode -Version Latest
$ErrorActionPreference = 'Stop'

$repositoryRoot = [System.IO.Path]::GetFullPath((Join-Path $PSScriptRoot '..'))

if ([string]::IsNullOrWhiteSpace($BuildRoot)) {
    $BuildRoot = if (Test-Path -LiteralPath 'E:\') {
        'E:\Aether-generated-deps\storageclean-build'
    }
    else {
        Join-Path $repositoryRoot 'artifacts\windows'
    }
}

$BuildRoot = [System.IO.Path]::GetFullPath($BuildRoot)
$dotnetHome = Join-Path $BuildRoot 'dotnet-home'
$nugetPackages = Join-Path $BuildRoot 'nuget-packages'
$publishDirectory = Join-Path $BuildRoot "publish\$Version\win-x64"
$installerDirectory = Join-Path $BuildRoot "installer\$Version"

foreach ($directory in @($dotnetHome, $nugetPackages, $publishDirectory, $installerDirectory)) {
    New-Item -ItemType Directory -Path $directory -Force | Out-Null
}

$env:DOTNET_CLI_HOME = $dotnetHome
$env:NUGET_PACKAGES = $nugetPackages
$env:DOTNET_NOLOGO = '1'
$env:DOTNET_CLI_TELEMETRY_OPTOUT = '1'

$selfTestProject = Join-Path $repositoryRoot 'desktop\StorageClean.SelfTest\StorageClean.SelfTest.csproj'
$appProject = Join-Path $repositoryRoot 'desktop\StorageClean.App\StorageClean.App.csproj'
$installerScript = Join-Path $repositoryRoot 'installer\storageclean.iss'

Write-Host 'Running StorageClean scanner self-test...'
& dotnet run --project $selfTestProject --configuration Release
if ($LASTEXITCODE -ne 0) {
    throw "Self-test failed with exit code $LASTEXITCODE."
}

Write-Host 'Publishing self-contained Windows application...'
& dotnet publish $appProject `
    --configuration Release `
    --runtime win-x64 `
    --self-contained true `
    --output $publishDirectory `
    -p:Version=$NumericVersion `
    -p:FileVersion=$NumericVersion `
    -p:AssemblyVersion=$NumericVersion `
    -p:PublishSingleFile=true `
    -p:IncludeNativeLibrariesForSelfExtract=true
if ($LASTEXITCODE -ne 0) {
    throw "Publish failed with exit code $LASTEXITCODE."
}

$appPath = Join-Path $publishDirectory 'StorageClean.exe'
if (-not (Test-Path -LiteralPath $appPath)) {
    throw "Published application was not found at $appPath."
}

$installerPath = $null
if (-not $SkipInstaller) {
    $compilerCandidates = @(
        (Join-Path ${env:ProgramFiles(x86)} 'Inno Setup 6\ISCC.exe')
        (Join-Path $env:LOCALAPPDATA 'Programs\Inno Setup 6\ISCC.exe')
    )
    $compiler = $compilerCandidates | Where-Object { Test-Path -LiteralPath $_ } | Select-Object -First 1

    if (-not $compiler) {
        throw 'Inno Setup 6 was not found. Install it, or rerun with -SkipInstaller to build only the portable application.'
    }

    Write-Host 'Compiling installer wizard...'
    & $compiler `
        "/DAppVersion=$Version" `
        "/DNumericVersion=$NumericVersion" `
        "/DAppPublishDir=$publishDirectory" `
        "/DOutputDir=$installerDirectory" `
        $installerScript
    if ($LASTEXITCODE -ne 0) {
        throw "Installer compilation failed with exit code $LASTEXITCODE."
    }

    $installerPath = Join-Path $installerDirectory "StorageClean-Setup-$Version-win-x64.exe"
    if (-not (Test-Path -LiteralPath $installerPath)) {
        throw "Installer was not found at $installerPath."
    }
}

$artifacts = @($appPath)
if ($installerPath) {
    $artifacts += $installerPath
}

$releaseFiles = foreach ($artifact in $artifacts) {
    $file = Get-Item -LiteralPath $artifact
    $hash = Get-FileHash -LiteralPath $artifact -Algorithm SHA256
    $checksumPath = "$artifact.sha256"
    [System.IO.File]::WriteAllText($checksumPath, "$($hash.Hash.ToLowerInvariant())  $($file.Name)`n")

    [pscustomobject]@{
        Name = $file.Name
        Path = $file.FullName
        Bytes = $file.Length
        Sha256 = $hash.Hash.ToLowerInvariant()
        AuthenticodeStatus = (Get-AuthenticodeSignature -LiteralPath $artifact).Status.ToString()
    }
}

$manifest = [pscustomobject]@{
    Product = 'StorageClean'
    Version = $Version
    NumericVersion = $NumericVersion
    Runtime = 'win-x64'
    SafetyMode = 'read-only'
    BuiltAtUtc = [DateTimeOffset]::UtcNow.ToString('O')
    Files = $releaseFiles
}

$manifestPath = Join-Path $installerDirectory "StorageClean-$Version-manifest.json"
$manifest | ConvertTo-Json -Depth 5 | Set-Content -LiteralPath $manifestPath -Encoding utf8

Write-Host ''
Write-Host 'StorageClean Windows build complete.'
Write-Host "Manifest: $manifestPath"
$releaseFiles | Format-Table Name, Bytes, Sha256, AuthenticodeStatus -AutoSize
