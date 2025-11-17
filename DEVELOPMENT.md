# Development Guide: Testing Vertical Tabs Plugin in Obsidian

This guide will help you set up and test the Vertical Tabs plugin in Obsidian.

## Prerequisites

-   Node.js installed (the project uses npm)
-   Obsidian installed on your system
-   An Obsidian vault where you want to test the plugin

## Step 1: Install Dependencies

First, install all the required dependencies:

```bash
npm install
```

## Step 2: Build the Plugin

You have three build options:

### Development Build (Recommended for Testing)

This builds the plugin in development mode with watch mode enabled (auto-rebuilds on file changes) and includes source maps for debugging:

```bash
npm run build:dev
```

This will:

-   Type-check the TypeScript code
-   Build the plugin with esbuild in watch mode
-   Output files to the `dist` folder
-   Include inline source maps for debugging

**Note:** The watch mode will keep running and rebuild automatically when you make changes. Keep this terminal open while developing.

### Beta Build

```bash
npm run build:beta
```

### Production Build

```bash
npm run build:production
```

## Step 3: Link the Plugin to Your Obsidian Vault

After building, you need to make the plugin available to Obsidian. You have two options:

### Option A: Symbolic Link (Recommended - Windows)

1. Find your Obsidian vault's plugins folder. It's typically located at:

    ```
    <YourVaultPath>\.obsidian\plugins\vertical-tabs
    ```

2. If the `vertical-tabs` folder already exists, delete or rename it first.

3. Create a symbolic link from your project's `dist` folder to the vault's plugins folder:

    **PowerShell (Run as Administrator):**

    ```powershell
    New-Item -ItemType SymbolicLink -Path "<YourVaultPath>\.obsidian\plugins\vertical-tabs" -Target "D:\projects\obsidian-vertical-tabs-paulsmithkc\dist"
    ```

    **Command Prompt (Run as Administrator):**

    ```cmd
    mklink /D "<YourVaultPath>\.obsidian\plugins\vertical-tabs" "D:\projects\obsidian-vertical-tabs-paulsmithkc\dist"
    ```

    **Note:** Replace `<YourVaultPath>` with your actual vault path, e.g., `C:\Users\YourName\Documents\MyVault`

### Option B: Copy Files (Alternative)

If you prefer not to use symbolic links, you can copy the files:

1. Copy the entire `dist` folder contents to:

    ```
    <YourVaultPath>\.obsidian\plugins\vertical-tabs\
    ```

2. You'll need to copy files again after each rebuild.

## Step 4: Enable the Plugin in Obsidian

1. Open Obsidian and navigate to your test vault
2. Go to **Settings** → **Community plugins**
3. Make sure "Safe mode" is **OFF**
4. Find "Vertical Tabs" in the installed plugins list
5. Toggle it **ON** to enable the plugin

## Step 5: Test and Debug

### Testing Workflow

1. **With `build:dev` running**: Make changes to your code, and the plugin will automatically rebuild
2. **Reload the plugin**: In Obsidian, go to Settings → Vertical Tabs → Debugging Tools → "Reload Vertical Tabs" (this reloads the plugin without restarting Obsidian)
3. **View console**: Use "Open dev console" in the debugging tools to see any errors or logs

### Debugging Tools

The plugin includes built-in debugging tools accessible via:

-   **Settings** → **Vertical Tabs** → **Debugging Tools**

Available tools:

-   **Copy plugin settings** - Copy current settings to clipboard
-   **Show debug info** - Display Obsidian debug information
-   **Open dev console** - Open the developer console (desktop only)
-   **Open sandbox vault** - Open Obsidian's sandbox vault (desktop only)
-   **Reload Vertical Tabs** - Reload the plugin without restarting Obsidian
-   **Reload Obsidian without saving** - Full app restart

### Developer Console

To access the developer console manually:

-   **Windows/Linux**: `Ctrl+Shift+I` or `Ctrl+Shift+J`
-   **Mac**: `Cmd+Option+I`

## Quick Start Script

Here's a PowerShell script you can use to automate the setup (save as `setup-dev.ps1`):

```powershell
# Set your vault path here
$VAULT_PATH = "C:\Users\YourName\Documents\MyVault"
$PLUGIN_PATH = "$VAULT_PATH\.obsidian\plugins\vertical-tabs"
# Automatically detect project directory (where this script is located)
$PROJECT_DIST = Join-Path $PSScriptRoot "dist"

# Install dependencies
Write-Host "Installing dependencies..." -ForegroundColor Green
npm install

# Build the plugin
Write-Host "Building plugin..." -ForegroundColor Green
npm run build:dev

# Create symbolic link
if (Test-Path $PLUGIN_PATH) {
    Write-Host "Removing existing plugin folder..." -ForegroundColor Yellow
    Remove-Item $PLUGIN_PATH -Recurse -Force
}

Write-Host "Creating symbolic link..." -ForegroundColor Green
New-Item -ItemType SymbolicLink -Path $PLUGIN_PATH -Target $PROJECT_DIST

Write-Host "Setup complete! Now:" -ForegroundColor Green
Write-Host "1. Open Obsidian" -ForegroundColor Cyan
Write-Host "2. Go to Settings → Community plugins" -ForegroundColor Cyan
Write-Host "3. Enable 'Vertical Tabs'" -ForegroundColor Cyan
```

**Note:** The `setup-dev.ps1` script in the project root already handles this automatically. Simply run:

```powershell
.\setup-dev.ps1 -VaultPath "C:\Users\YourName\Documents\MyVault"
```

## Troubleshooting

### Plugin doesn't appear in Obsidian

-   Make sure the `dist` folder contains `main.js` and `manifest.json`
-   Check that the symbolic link or copy was successful
-   Verify the folder structure: `<Vault>\.obsidian\plugins\vertical-tabs\main.js`

### Changes not reflecting

-   Make sure `build:dev` is running in watch mode
-   Use "Reload Vertical Tabs" in the plugin settings after rebuilding
-   Check the developer console for errors

### Build errors

-   Run `npm install` to ensure all dependencies are installed
-   Check that Node.js version is compatible (the project targets ES2018)
-   Verify TypeScript compilation: `npx tsc --noEmit`

## File Structure

After building, your `dist` folder should contain:

```
dist/
├── main.js          # Compiled plugin code
├── manifest.json    # Plugin manifest (copied from root)
└── styles.css       # Compiled styles (from styles.scss)
```

## Additional Notes

-   The `build:dev` script runs in watch mode, so it will automatically rebuild when you save changes
-   Source maps are included in dev mode for easier debugging
-   The plugin uses React, so you may see React DevTools in the console
-   For production builds, code is minified and source maps are excluded
