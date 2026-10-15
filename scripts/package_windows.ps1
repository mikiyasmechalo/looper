<#
.SYNOPSIS
    Builds and packages Looper Player for Windows (Portable .zip and Inno Setup .exe Installer).
.DESCRIPTION
    1. Executes `flutter build windows --release`.
    2. Packages the portable distribution into `dist\looper-windows-x64-portable.zip`.
    3. If Inno Setup is installed, compiles `dist\Looper-Setup-x64.exe`.
#>

[CmdletBinding()]
param(
    [switch]$SkipBuild = $false
)

$ErrorActionPreference = "Stop"

Write-Host "==========================================================" -ForegroundColor Cyan
Write-Host "  Looper Player - Windows Packaging Script                " -ForegroundColor Cyan
Write-Host "==========================================================" -ForegroundColor Cyan

$ProjectRoot = Resolve-Path "$PSScriptRoot\.."
Set-Location $ProjectRoot

$ReleaseDir = "$ProjectRoot\build\windows\x64\runner\Release"
$DistDir = "$ProjectRoot\dist"

if (-not (Test-Path $DistDir)) {
    New-Item -ItemType Directory -Path $DistDir -Force | Out-Null
}

# 1. Flutter Release Build
if (-not $SkipBuild) {
    # Close any running instances to prevent LNK1104 file lock errors
    Get-Process -Name "looper_player" -ErrorAction SilentlyContinue | Stop-Process -Force
    Start-Sleep -Milliseconds 500

    Write-Host "`n[1/3] Building release Windows application with Flutter..." -ForegroundColor Yellow
    flutter build windows --release
    if ($LASTEXITCODE -ne 0) {
        Write-Error "Flutter release build failed with exit code $LASTEXITCODE."
        exit $LASTEXITCODE
    }
} else {
    Write-Host "`n[1/3] Skipping build step (requested via -SkipBuild)..." -ForegroundColor Yellow
}

if (-not (Test-Path "$ReleaseDir\looper_player.exe")) {
    Write-Error "Release executable not found at $ReleaseDir\looper_player.exe!"
    exit 1
}

# 2. Package Portable ZIP
Write-Host "`n[2/3] Creating Windows portable ZIP package..." -ForegroundColor Yellow
$ZipPath = "$DistDir\looper-windows-x64-portable.zip"
if (Test-Path $ZipPath) {
    Remove-Item -Path $ZipPath -Force
}

Compress-Archive -Path "$ReleaseDir\*" -DestinationPath $ZipPath -CompressionLevel Optimal
$ZipSizeMB = [math]::Round((Get-Item $ZipPath).Length / 1MB, 2)
Write-Host "  -> Portable ZIP created: $ZipPath ($ZipSizeMB MB)" -ForegroundColor Green

# 3. Compile Inno Setup Installer (.exe)
Write-Host "`n[3/3] Checking for Inno Setup compiler (ISCC.exe)..." -ForegroundColor Yellow

$IsccPaths = @(
    "ISCC.exe",
    "${env:ProgramFiles(x86)}\Inno Setup 6\ISCC.exe",
    "$env:ProgramFiles\Inno Setup 6\ISCC.exe",
    "${env:LOCALAPPDATA}\Programs\Inno Setup 6\ISCC.exe"
)

$FoundIscc = $null
foreach ($path in $IsccPaths) {
    if (Get-Command $path -ErrorAction SilentlyContinue) {
        $FoundIscc = $path
        break
    } elseif (Test-Path $path) {
        $FoundIscc = $path
        break
    }
}

if ($FoundIscc) {
    Write-Host "  -> Compiling Windows installer with $FoundIscc..." -ForegroundColor Green
    & $FoundIscc "windows\installer\looper_setup.iss"
    if ($LASTEXITCODE -eq 0) {
        $InstallerPath = "$DistDir\Looper-Setup-x64.exe"
        if (Test-Path $InstallerPath) {
            $InstallerSizeMB = [math]::Round((Get-Item $InstallerPath).Length / 1MB, 2)
            Write-Host "  -> Setup Installer created: $InstallerPath ($InstallerSizeMB MB)" -ForegroundColor Green
        }
    } else {
        Write-Warning "Inno Setup compilation exited with code $LASTEXITCODE."
    }
} else {
    Write-Host "  [NOTICE] Inno Setup (ISCC.exe) was not found locally." -ForegroundColor Yellow
    Write-Host "  -> To generate the .exe installer locally, install Inno Setup by running:" -ForegroundColor Gray
    Write-Host "       winget install JRSoftware.InnoSetup" -ForegroundColor White
    Write-Host "  -> Note: In GitHub Actions CI, Inno Setup is preinstalled and will generate the installer automatically!" -ForegroundColor Cyan
}

Write-Host "`n==========================================================" -ForegroundColor Cyan
Write-Host "  Packaging complete! Artifacts located in: $DistDir" -ForegroundColor Green
Write-Host "==========================================================" -ForegroundColor Cyan
Get-ChildItem -Path $DistDir | Select-Object Name, @{Name="Size (MB)"; Expression={[math]::Round($_.Length / 1MB, 2)}}, LastWriteTime | Format-Table -AutoSize
