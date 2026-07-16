param(
    [string]$Version = "1.0.0",
    [string]$Runtime = "win-x64"
)

$ErrorActionPreference = "Stop"
Set-StrictMode -Version Latest

$repoRoot = (Resolve-Path (Join-Path $PSScriptRoot "..")).Path
$buildScript = Join-Path $PSScriptRoot "Build-Release.ps1"
$releaseRoot = Join-Path $repoRoot "artifacts\release"
$assetDirectory = Join-Path $repoRoot "artifacts\github-release\v$Version"

Write-Host "Building and testing self-contained release..." -ForegroundColor Cyan
& $buildScript -Version $Version -Runtime $Runtime -SelfContained
if ($LASTEXITCODE -ne 0) {
    throw "Self-contained release build failed with exit code $LASTEXITCODE"
}

Write-Host "Building framework-dependent release..." -ForegroundColor Cyan
& $buildScript -Version $Version -Runtime $Runtime -SkipTests
if ($LASTEXITCODE -ne 0) {
    throw "Framework-dependent release build failed with exit code $LASTEXITCODE"
}

$selfContainedName = "RBar-v$Version-$Runtime-self-contained"
$frameworkDependentName = "RBar-v$Version-$Runtime-framework-dependent"
$sourceAssets = [ordered]@{
    "RBar-v$Version-$Runtime-self-contained-UNSIGNED-Setup.exe" = Join-Path $releaseRoot "$selfContainedName\installer\RBar-Setup-v$Version-$Runtime-self-contained.exe"
    "RBar-v$Version-$Runtime-framework-dependent-UNSIGNED-Setup.exe" = Join-Path $releaseRoot "$frameworkDependentName\installer\RBar-Setup-v$Version-$Runtime-framework-dependent.exe"
    "RBar-v$Version-$Runtime-self-contained-UNSIGNED-Portable.zip" = Join-Path $releaseRoot "$selfContainedName\packages\$selfContainedName.zip"
}

if (Test-Path -LiteralPath $assetDirectory) {
    Remove-Item -LiteralPath $assetDirectory -Recurse -Force
}
New-Item -ItemType Directory -Path $assetDirectory -Force | Out-Null

foreach ($asset in $sourceAssets.GetEnumerator()) {
    if (-not (Test-Path -LiteralPath $asset.Value -PathType Leaf)) {
        throw "Release asset was not generated: $($asset.Value)"
    }

    Copy-Item -LiteralPath $asset.Value -Destination (Join-Path $assetDirectory $asset.Key)
}

$hashes = Get-ChildItem -LiteralPath $assetDirectory -File |
    Sort-Object Name |
    ForEach-Object {
        [pscustomobject]@{
            File = $_.Name
            SizeBytes = $_.Length
            Sha256 = (Get-FileHash -LiteralPath $_.FullName -Algorithm SHA256).Hash
        }
    }

Write-Host ""
Write-Host "GitHub Release assets:" -ForegroundColor Cyan
$hashes | Format-Table -AutoSize
$hashes | ConvertTo-Json | Set-Content -LiteralPath (Join-Path $assetDirectory "release-assets.json") -Encoding UTF8
Write-Host "Asset directory: $assetDirectory"
