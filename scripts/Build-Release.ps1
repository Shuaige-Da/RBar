param(
    [string]$Version = "1.0.0",
    [string]$Configuration = "Release",
    [string]$Runtime = "win-x64",
    [string]$InnoCompilerPath,
    [switch]$SelfContained,
    [switch]$SkipTests
)

$ErrorActionPreference = "Stop"
Set-StrictMode -Version Latest

$repoRoot = Resolve-Path (Join-Path $PSScriptRoot "..")
$productName = "RBar"
$legacyProductName = "DynamicIslandBar"
$projectPath = Join-Path $repoRoot "DynamicIslandBar\DynamicIslandBar.csproj"
$testProjectPath = Join-Path $repoRoot "DynamicIslandBar.Tests\DynamicIslandBar.Tests.csproj"
$releaseRoot = Join-Path $repoRoot "artifacts\release"
$dependencyLabel = if ($SelfContained) { "self-contained" } else { "framework-dependent" }
$releaseName = "$productName-v$Version-$Runtime-$dependencyLabel"
$releaseDir = Join-Path $releaseRoot $releaseName
$publishDir = Join-Path $releaseDir "publish"
$packageDir = Join-Path $releaseDir "packages"
$installerDir = Join-Path $releaseDir "installer"
$installerScript = Join-Path $repoRoot "release\installer\RBar.iss"

function Write-Step {
    param([string]$Message)
    Write-Host ""
    Write-Host "==> $Message" -ForegroundColor Cyan
}

function Invoke-DotNet {
    param([string[]]$Arguments)
    Write-Host "dotnet $($Arguments -join ' ')" -ForegroundColor DarkGray
    & dotnet @Arguments
    if ($LASTEXITCODE -ne 0) {
        throw "dotnet command failed with exit code $LASTEXITCODE"
    }
}

Write-Step "Preparing release directories"
if (Test-Path $releaseDir) {
    Remove-Item -LiteralPath $releaseDir -Recurse -Force
}
New-Item -ItemType Directory -Force -Path $publishDir, $packageDir, $installerDir | Out-Null

$running = Get-Process -Name @($productName, $legacyProductName) -ErrorAction SilentlyContinue
if ($running) {
    $runningPaths = $running.Path | Where-Object { $_ } | Select-Object -Unique
    Write-Step "Stopping running RBar processes"
    $running | Stop-Process -Force
    Start-Sleep -Milliseconds 500
    foreach ($runningPath in $runningPaths) {
        if (Test-Path -LiteralPath $runningPath) {
            Start-Process `
                -FilePath $runningPath `
                -ArgumentList "--restore-taskbar" `
                -WindowStyle Hidden `
                -Wait
        }
    }
}

function Find-InnoCompiler {
    if ($InnoCompilerPath) {
        if (-not (Test-Path -LiteralPath $InnoCompilerPath -PathType Leaf)) {
            throw "Inno Setup compiler was not found at: $InnoCompilerPath"
        }

        return (Resolve-Path -LiteralPath $InnoCompilerPath).Path
    }

    $command = Get-Command "ISCC.exe" -ErrorAction SilentlyContinue
    if ($command) {
        return $command.Source
    }

    $uninstallKeys = @(
        "HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\Uninstall\Inno Setup 6_is1",
        "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Uninstall\Inno Setup 6_is1",
        "HKLM:\SOFTWARE\WOW6432Node\Microsoft\Windows\CurrentVersion\Uninstall\Inno Setup 6_is1"
    )
    foreach ($key in $uninstallKeys) {
        $installLocation = (Get-ItemProperty -LiteralPath $key -ErrorAction SilentlyContinue).InstallLocation
        if ($installLocation) {
            $candidate = Join-Path $installLocation "ISCC.exe"
            if (Test-Path -LiteralPath $candidate -PathType Leaf) {
                return $candidate
            }
        }
    }

    return $null
}

if (-not $SkipTests) {
    Write-Step "Running tests"
    Invoke-DotNet @("test", $testProjectPath, "-c", $Configuration)
}

Write-Step "Publishing application"
$publishArgs = @(
    "publish",
    $projectPath,
    "-c", $Configuration,
    "-r", $Runtime,
    "--self-contained", $SelfContained.ToString().ToLowerInvariant(),
    "-o", $publishDir,
    "-p:PublishSingleFile=true",
    "-p:IncludeNativeLibrariesForSelfExtract=true",
    "-p:DebugType=none",
    "-p:DebugSymbols=false",
    "-p:Version=$Version"
)
if ($SelfContained) {
    $publishArgs += "-p:EnableCompressionInSingleFile=true"
}
Invoke-DotNet $publishArgs

Write-Step "Creating portable package"
$zipPath = Join-Path $packageDir "$releaseName.zip"
Compress-Archive -Path (Join-Path $publishDir "*") -DestinationPath $zipPath -Force

$iscc = Find-InnoCompiler
$installerPath = $null
if ($iscc) {
    Write-Step "Building Inno Setup installer"
    & $iscc `
        "/DAppVersion=$Version" `
        "/DSourceDir=$publishDir" `
        "/DOutputDir=$installerDir" `
        "/DDependencyLabel=$dependencyLabel" `
        $installerScript
    if ($LASTEXITCODE -ne 0) {
        throw "Inno Setup failed with exit code $LASTEXITCODE"
    }

    $installerPath = Join-Path $installerDir "RBar-Setup-v$Version-$Runtime-$dependencyLabel.exe"
} else {
    Write-Host "Inno Setup compiler (ISCC.exe) was not found; installer exe was skipped." -ForegroundColor Yellow
}

$manifest = [ordered]@{
    product = $productName
    publisher = "rainwave"
    version = $Version
    runtime = $Runtime
    dependency = $dependencyLabel
    requiresDotNetDesktopRuntime = -not $SelfContained
    dotNetDesktopRuntime = if ($SelfContained) { $null } else { "Microsoft Windows Desktop Runtime 8.x (x64)" }
    createdAt = (Get-Date).ToString("s")
    publishDir = $publishDir
    portableZip = $zipPath
    portableZipSha256 = (Get-FileHash -LiteralPath $zipPath -Algorithm SHA256).Hash
    installer = $installerPath
    installerSha256 = if ($installerPath) {
        (Get-FileHash -LiteralPath $installerPath -Algorithm SHA256).Hash
    } else {
        $null
    }
    executableSha256 = (Get-FileHash -LiteralPath (Join-Path $publishDir "$productName.exe") -Algorithm SHA256).Hash
    signatureStatus = (Get-AuthenticodeSignature -LiteralPath (Join-Path $publishDir "$productName.exe")).Status.ToString()
}
$manifestPath = Join-Path $releaseDir "release-manifest.json"
$manifest | ConvertTo-Json -Depth 4 | Set-Content -Path $manifestPath -Encoding UTF8

Write-Step "Release output"
Write-Host "Publish:   $publishDir"
Write-Host "Zip:       $zipPath"
Write-Host "Installer: $(if ($installerPath) { $installerPath } else { 'skipped - install Inno Setup to build it' })"
Write-Host "Manifest:  $manifestPath"
