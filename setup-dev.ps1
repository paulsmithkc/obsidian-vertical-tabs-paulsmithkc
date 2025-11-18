# Setup script for Vertical Tabs plugin development (Windows)
# Run this script in PowerShell to set up the development environment

param(
    [string]$VaultPath = ""
)

$ErrorActionPreference = "Stop"

Write-Host "========================================" -ForegroundColor Cyan
Write-Host "Vertical Tabs - Development Setup" -ForegroundColor Cyan
Write-Host "========================================" -ForegroundColor Cyan
Write-Host ""

# Get the script directory (project root)
$ScriptDir = Split-Path -Parent $MyInvocation.MyCommand.Path
Set-Location $ScriptDir

# Display paths for verification
Write-Host "Path Information:" -ForegroundColor Cyan
Write-Host "  Script Directory: $ScriptDir" -ForegroundColor Gray
Write-Host "  Current Directory: $(Get-Location)" -ForegroundColor Gray
Write-Host "  Dist Folder: $(Join-Path $ScriptDir 'dist')" -ForegroundColor Gray
if ($VaultPath -ne "") {
    Write-Host "  Vault Path: $VaultPath" -ForegroundColor Gray
    Write-Host "  Target Plugins Path: $(Join-Path $VaultPath '.obsidian\plugins\vertical-tabs')" -ForegroundColor Gray
}
Write-Host ""

# Check prerequisites
Write-Host "Checking prerequisites..." -ForegroundColor Yellow

# Check Node.js
try {
    $nodeVersion = node --version
    Write-Host "✓ Node.js found: $nodeVersion" -ForegroundColor Green
} catch {
    Write-Host "✗ Node.js not found. Please install Node.js from https://nodejs.org/" -ForegroundColor Red
    exit 1
}

# Check npm
try {
    $npmVersion = npm --version
    Write-Host "✓ npm found: $npmVersion" -ForegroundColor Green
} catch {
    Write-Host "✗ npm not found. Please install npm." -ForegroundColor Red
    exit 1
}

Write-Host ""

# Install dependencies
Write-Host "Installing dependencies..." -ForegroundColor Yellow
if (Test-Path "node_modules") {
    Write-Host "node_modules already exists. Skipping npm install." -ForegroundColor Gray
    Write-Host "Run 'npm install' manually if you need to update dependencies." -ForegroundColor Gray
} else {
    npm install
    if ($LASTEXITCODE -ne 0) {
        Write-Host "✗ Failed to install dependencies" -ForegroundColor Red
        exit 1
    }
    Write-Host "✓ Dependencies installed" -ForegroundColor Green
}

Write-Host ""

# Build the plugin
Write-Host "Building plugin (production build)..." -ForegroundColor Yellow
npm run build:production
if ($LASTEXITCODE -ne 0) {
    Write-Host "✗ Build failed" -ForegroundColor Red
    exit 1
}
Write-Host "✓ Plugin built successfully" -ForegroundColor Green

# Verify dist folder exists
if (-not (Test-Path "dist\main.js")) {
    Write-Host "✗ dist\main.js not found. Build may have failed." -ForegroundColor Red
    exit 1
}

if (-not (Test-Path "dist\manifest.json")) {
    Write-Host "Copying manifest.json to dist..." -ForegroundColor Yellow
    Copy-Item "manifest.json" "dist\manifest.json"
}

Write-Host ""

# Set up symlink
Write-Host "Setting up Obsidian plugin symlink..." -ForegroundColor Yellow
Write-Host ""

# Determine vault path
$vaultPluginsPath = ""

if ($VaultPath -ne "") {
    $vaultPluginsPath = Join-Path $VaultPath ".obsidian\plugins\vertical-tabs"
} else {
    # Try to find common vault locations
    $commonVaultPaths = @(
        "$env:USERPROFILE\Documents\Obsidian Vault",
        "$env:USERPROFILE\Documents\MyVault",
        "$env:USERPROFILE\Vault",
        "$env:APPDATA\Obsidian\Plugins"
    )
    
    Write-Host "Please provide your Obsidian vault path." -ForegroundColor Cyan
    Write-Host "Common locations:" -ForegroundColor Gray
    foreach ($path in $commonVaultPaths) {
        if (Test-Path $path) {
            Write-Host "  - $path" -ForegroundColor Gray
        }
    }
    Write-Host ""
    
    $userInput = Read-Host "Enter your vault path (or press Enter to skip symlink setup)"
    
    if ($userInput -ne "") {
        $vaultPluginsPath = Join-Path $userInput ".obsidian\plugins\vertical-tabs"
        Write-Host ""
        Write-Host "Vault Path Information:" -ForegroundColor Cyan
        Write-Host "  Vault Path: $userInput" -ForegroundColor Gray
        Write-Host "  Target Plugins Path: $vaultPluginsPath" -ForegroundColor Gray
        Write-Host ""
    }
}

if ($vaultPluginsPath -ne "") {
    $vaultRoot = if ($VaultPath -ne "") { $VaultPath } else { $userInput }
    $obsidianDir = Join-Path $vaultRoot ".obsidian"
    $pluginsDir = Join-Path $obsidianDir "plugins"
    
    # Validate vault root exists
    if (-not (Test-Path $vaultRoot)) {
        Write-Host "✗ Vault directory not found: $vaultRoot" -ForegroundColor Red
        Write-Host "  Please ensure the vault path is correct." -ForegroundColor Yellow
        Write-Host ""
        Write-Host "You can create the symlink manually later with:" -ForegroundColor Cyan
        Write-Host "  New-Item -ItemType SymbolicLink -Path `"$vaultPluginsPath`" -Target `"$ScriptDir\dist`"" -ForegroundColor Gray
    } else {
        # Create .obsidian folder if it doesn't exist
        if (-not (Test-Path $obsidianDir)) {
            Write-Host "Creating .obsidian folder..." -ForegroundColor Yellow
            try {
                New-Item -ItemType Directory -Path $obsidianDir -Force | Out-Null
                Write-Host "✓ Created .obsidian folder" -ForegroundColor Green
            } catch {
                Write-Host "✗ Failed to create .obsidian folder: $_" -ForegroundColor Red
                Write-Host "  Please create it manually and run the script again." -ForegroundColor Yellow
                exit 1
            }
        }
        
        # Create plugins folder if it doesn't exist
        if (-not (Test-Path $pluginsDir)) {
            Write-Host "Creating .obsidian\plugins folder..." -ForegroundColor Yellow
            try {
                New-Item -ItemType Directory -Path $pluginsDir -Force | Out-Null
                Write-Host "✓ Created .obsidian\plugins folder" -ForegroundColor Green
            } catch {
                Write-Host "✗ Failed to create plugins folder: $_" -ForegroundColor Red
                Write-Host "  Please create it manually and run the script again." -ForegroundColor Yellow
                exit 1
            }
        }
        
        # Now proceed with symlink creation
        if (Test-Path $pluginsDir) {
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
                    Write-Host "Skipping symlink creation." -ForegroundColor Yellow
                    $vaultPluginsPath = ""
                }
            }
        }
        
        if ($vaultPluginsPath -ne "") {
            # Check if running as admin (required for symlinks on Windows)
            $isAdmin = ([Security.Principal.WindowsPrincipal] [Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)
            
            if (-not $isAdmin) {
                Write-Host ""
                Write-Host "========================================" -ForegroundColor Yellow
                Write-Host "⚠ Administrator Privileges Required" -ForegroundColor Yellow
                Write-Host "========================================" -ForegroundColor Yellow
                Write-Host ""
                Write-Host "Creating symlinks on Windows requires administrator privileges." -ForegroundColor White
                Write-Host ""
                Write-Host "Options:" -ForegroundColor Cyan
                Write-Host ""
                Write-Host "Option 1: Run as Administrator (Recommended)" -ForegroundColor Green
                Write-Host "  1. Right-click PowerShell and select 'Run as Administrator'" -ForegroundColor Gray
                Write-Host "  2. Navigate to: $ScriptDir" -ForegroundColor Gray
                Write-Host "  3. Run: .\setup-dev.ps1" -ForegroundColor Gray
                if ($VaultPath -ne "") {
                    Write-Host "     Or: .\setup-dev.ps1 -VaultPath `"$VaultPath`"" -ForegroundColor Gray
                } else {
                    Write-Host "     Or: .\setup-dev.ps1 -VaultPath `"<your-vault-path>`"" -ForegroundColor Gray
                }
                Write-Host ""
                Write-Host "Option 2: Create Symlink Manually (as Administrator)" -ForegroundColor Green
                Write-Host "  Run this command in PowerShell (as Administrator):" -ForegroundColor Gray
                Write-Host "  New-Item -ItemType SymbolicLink -Path `"$vaultPluginsPath`" -Target `"$ScriptDir\dist`" -Force" -ForegroundColor Yellow
                Write-Host ""
                Write-Host "  Your paths:" -ForegroundColor Gray
                Write-Host "    Vault plugins path: $vaultPluginsPath" -ForegroundColor Gray
                Write-Host "    Project dist path: $ScriptDir\dist" -ForegroundColor Gray
                Write-Host ""
                Write-Host "Option 3: Copy Files Instead (No Admin Required)" -ForegroundColor Green
                $copyChoice = Read-Host "  Would you like to copy files instead? This requires manual updates. (y/N)"
                if ($copyChoice -eq "y" -or $copyChoice -eq "Y") {
                    Write-Host "Copying files..." -ForegroundColor Yellow
                    try {
                        if (Test-Path $vaultPluginsPath) {
                            Remove-Item $vaultPluginsPath -Recurse -Force -ErrorAction SilentlyContinue
                        }
                        New-Item -ItemType Directory -Path $vaultPluginsPath -Force | Out-Null
                        Copy-Item -Path "$ScriptDir\dist\*" -Destination $vaultPluginsPath -Recurse -Force
                        Write-Host "✓ Files copied successfully!" -ForegroundColor Green
                        Write-Host "  Note: You'll need to copy files again after each build." -ForegroundColor Yellow
                        Write-Host "  Consider using the symlink option for development." -ForegroundColor Yellow
                    } catch {
                        Write-Host "✗ Failed to copy files: $_" -ForegroundColor Red
                    }
                } else {
                    Write-Host ""
                    Write-Host "Skipping symlink creation. Please use one of the options above." -ForegroundColor Yellow
                }
            } else {
                try {
                    New-Item -ItemType SymbolicLink -Path $vaultPluginsPath -Target "$ScriptDir\dist" -Force | Out-Null
                    Write-Host "✓ Symlink created successfully!" -ForegroundColor Green
                    Write-Host "  $vaultPluginsPath -> $ScriptDir\dist" -ForegroundColor Gray
                } catch {
                    Write-Host "✗ Failed to create symlink: $_" -ForegroundColor Red
                    Write-Host ""
                    Write-Host "Try creating it manually (as Administrator) with:" -ForegroundColor Cyan
                    Write-Host "  New-Item -ItemType SymbolicLink -Path `"$vaultPluginsPath`" -Target `"$ScriptDir\dist`" -Force" -ForegroundColor Gray
                }
            }
        }
        } else {
            Write-Host "✗ Failed to create or access plugins directory" -ForegroundColor Red
        }
    }
}

Write-Host ""
Write-Host "========================================" -ForegroundColor Cyan
Write-Host "Setup Complete!" -ForegroundColor Green
Write-Host "========================================" -ForegroundColor Cyan
Write-Host ""
Write-Host "Next steps:" -ForegroundColor Yellow
Write-Host "  1. Open Obsidian" -ForegroundColor White
Write-Host "  2. Go to Settings → Community plugins" -ForegroundColor White
Write-Host "  3. Enable 'Vertical Tabs' plugin" -ForegroundColor White
Write-Host "  4. Reload Obsidian (Ctrl+R)" -ForegroundColor White
Write-Host ""
Write-Host "For development:" -ForegroundColor Yellow
Write-Host "  Run 'npm run build:dev' to start watch mode" -ForegroundColor White
Write-Host "  This will auto-rebuild when you make changes" -ForegroundColor Gray
Write-Host ""

