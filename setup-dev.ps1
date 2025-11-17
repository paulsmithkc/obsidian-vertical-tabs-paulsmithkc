# Development Setup Script for Vertical Tabs Plugin
# This script helps set up the development environment for testing in Obsidian

param(
    [Parameter(Mandatory=$true)]
    [string]$VaultPath,
    # Automatically detect project directory (where this script is located)
    # Can be overridden if needed, but defaults to the script's directory
    [string]$ProjectPath = $PSScriptRoot
)

$PluginPath = Join-Path $VaultPath ".obsidian\plugins\vertical-tabs"
$ProjectDist = Join-Path $ProjectPath "dist"

Write-Host "========================================" -ForegroundColor Cyan
Write-Host "Vertical Tabs Plugin - Dev Setup" -ForegroundColor Cyan
Write-Host "========================================" -ForegroundColor Cyan
Write-Host ""

# Display parameters and paths for verification
Write-Host "Configuration:" -ForegroundColor Yellow
Write-Host "  Vault Path:    $VaultPath" -ForegroundColor White
Write-Host "  Plugin Path:   $PluginPath" -ForegroundColor White
Write-Host "  Project Path:  $ProjectPath" -ForegroundColor White
Write-Host "  Dist Path:     $ProjectDist" -ForegroundColor White
Write-Host ""

# Check if vault exists
if (-not (Test-Path $VaultPath)) {
    Write-Host "Error: Vault path does not exist: $VaultPath" -ForegroundColor Red
    exit 1
}

# Check if .obsidian folder exists
$ObsidianPath = Join-Path $VaultPath ".obsidian"
if (-not (Test-Path $ObsidianPath)) {
    Write-Host "Warning: .obsidian folder not found. Creating it..." -ForegroundColor Yellow
    New-Item -ItemType Directory -Path $ObsidianPath -Force | Out-Null
}

# Check if plugins folder exists
$PluginsPath = Join-Path $ObsidianPath "plugins"
if (-not (Test-Path $PluginsPath)) {
    Write-Host "Creating plugins folder..." -ForegroundColor Yellow
    New-Item -ItemType Directory -Path $PluginsPath -Force | Out-Null
}

# Install dependencies
Write-Host "Step 1: Installing dependencies..." -ForegroundColor Green
Set-Location $ProjectPath
npm install
if ($LASTEXITCODE -ne 0) {
    Write-Host "Error: Failed to install dependencies" -ForegroundColor Red
    exit 1
}

# Build the plugin (one-time build, not watch mode)
Write-Host ""
Write-Host "Step 2: Building plugin (initial build)..." -ForegroundColor Green
Write-Host "Note: This is a one-time build. Watch mode will be started separately." -ForegroundColor Yellow

# Run TypeScript check and esbuild (the cp command will fail on Windows, we'll handle it)
& npx tsc -noEmit -skipLibCheck
if ($LASTEXITCODE -ne 0) {
    Write-Host "Error: TypeScript compilation failed" -ForegroundColor Red
    exit 1
}

& node esbuild.config.mjs beta
if ($LASTEXITCODE -ne 0) {
    Write-Host "Error: Build failed" -ForegroundColor Red
    exit 1
}

# Copy manifest.json (Windows-compatible)
Write-Host "Copying manifest.json..." -ForegroundColor Gray
$manifestSource = Join-Path $ProjectPath "manifest.json"
$manifestDest = Join-Path $ProjectDist "manifest.json"
Copy-Item -Path $manifestSource -Destination $manifestDest -Force

# Check if dist folder exists
if (-not (Test-Path $ProjectDist)) {
    Write-Host "Error: dist folder not found. Build may have failed." -ForegroundColor Red
    exit 1
}

# Remove existing plugin folder or link
if (Test-Path $PluginPath) {
    Write-Host ""
    Write-Host "Step 3: Removing existing plugin installation..." -ForegroundColor Yellow
    Remove-Item $PluginPath -Recurse -Force
}

# Create symbolic link
Write-Host ""
Write-Host "Step 4: Creating symbolic link..." -ForegroundColor Green
try {
    $link = New-Item -ItemType SymbolicLink -Path $PluginPath -Target $ProjectDist -Force
    Write-Host "Symbolic link created successfully!" -ForegroundColor Green
} catch {
    Write-Host "Error: Failed to create symbolic link. You may need to run as Administrator." -ForegroundColor Red
    Write-Host "Error details: $_" -ForegroundColor Red
    Write-Host ""
    Write-Host "Alternative: You can manually copy the dist folder to:" -ForegroundColor Yellow
    Write-Host "  $PluginPath" -ForegroundColor Yellow
    exit 1
}

# Verify the link
Write-Host ""
Write-Host "Step 5: Verifying installation..." -ForegroundColor Green
$manifestPath = Join-Path $PluginPath "manifest.json"
$mainJsPath = Join-Path $PluginPath "main.js"

if (Test-Path $manifestPath) {
    Write-Host "✓ manifest.json found" -ForegroundColor Green
} else {
    Write-Host "✗ manifest.json not found" -ForegroundColor Red
}

if (Test-Path $mainJsPath) {
    Write-Host "✓ main.js found" -ForegroundColor Green
} else {
    Write-Host "✗ main.js not found" -ForegroundColor Red
}

Write-Host ""
Write-Host "========================================" -ForegroundColor Cyan
Write-Host "Setup Complete!" -ForegroundColor Green
Write-Host "========================================" -ForegroundColor Cyan
Write-Host ""
Write-Host "Next steps:" -ForegroundColor Yellow
Write-Host "1. Open Obsidian and navigate to your vault: $VaultPath" -ForegroundColor Cyan
Write-Host "2. Go to Settings → Community plugins" -ForegroundColor Cyan
Write-Host "3. Make sure 'Safe mode' is OFF" -ForegroundColor Cyan
Write-Host "4. Find 'Vertical Tabs' and toggle it ON" -ForegroundColor Cyan
Write-Host ""
Write-Host "To enable watch mode (auto-rebuild on file changes):" -ForegroundColor Yellow
Write-Host "  Run: npm run build:dev" -ForegroundColor Cyan
Write-Host "  (Keep that terminal open while developing)" -ForegroundColor Gray
Write-Host ""

