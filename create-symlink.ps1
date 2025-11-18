# Helper script to create symlink (run as Administrator)
# Usage: .\create-symlink.ps1 -VaultPath "C:\path\to\vault"

param(
    [Parameter(Mandatory=$true)]
    [string]$VaultPath
)

$ErrorActionPreference = "Stop"

# Get the script directory (project root)
$ScriptDir = Split-Path -Parent $MyInvocation.MyCommand.Path
$vaultPluginsPath = Join-Path $VaultPath ".obsidian\plugins\vertical-tabs"
$pluginsDir = Split-Path -Parent $vaultPluginsPath

Write-Host "Creating symlink..." -ForegroundColor Yellow
Write-Host "  Source: $ScriptDir\dist" -ForegroundColor Gray
Write-Host "  Target: $vaultPluginsPath" -ForegroundColor Gray
Write-Host ""

# Check if running as admin
$isAdmin = ([Security.Principal.WindowsPrincipal] [Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)

if (-not $isAdmin) {
    Write-Host "✗ This script must be run as Administrator!" -ForegroundColor Red
    Write-Host ""
    Write-Host "Right-click PowerShell and select 'Run as Administrator', then run this script again." -ForegroundColor Yellow
    exit 1
}

# Ensure plugins directory exists
if (-not (Test-Path $pluginsDir)) {
    Write-Host "Creating plugins directory..." -ForegroundColor Yellow
    New-Item -ItemType Directory -Path $pluginsDir -Force | Out-Null
}

# Remove existing symlink or directory if it exists
if (Test-Path $vaultPluginsPath) {
    $item = Get-Item $vaultPluginsPath
    if ($item.LinkType -eq "SymbolicLink") {
        Write-Host "Removing existing symlink..." -ForegroundColor Yellow
        Remove-Item $vaultPluginsPath -Force
    } else {
        Write-Host "⚠ Warning: $vaultPluginsPath already exists and is not a symlink." -ForegroundColor Yellow
        $overwrite = Read-Host "Do you want to remove it and create a symlink? (y/N)"
        if ($overwrite -eq "y" -or $overwrite -eq "Y") {
            Remove-Item $vaultPluginsPath -Recurse -Force
        } else {
            Write-Host "Cancelled." -ForegroundColor Yellow
            exit 0
        }
    }
}

# Create the symlink
try {
    New-Item -ItemType SymbolicLink -Path $vaultPluginsPath -Target "$ScriptDir\dist" -Force | Out-Null
    Write-Host "✓ Symlink created successfully!" -ForegroundColor Green
    Write-Host "  $vaultPluginsPath -> $ScriptDir\dist" -ForegroundColor Gray
} catch {
    Write-Host "✗ Failed to create symlink: $_" -ForegroundColor Red
    exit 1
}

