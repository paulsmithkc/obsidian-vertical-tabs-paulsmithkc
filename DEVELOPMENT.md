# Development Guide

## Prerequisites

-   Node.js (v16 or higher recommended)
-   npm (comes with Node.js)
-   Obsidian installed on your system

## Initial Setup

### Automated Setup (Recommended)

We provide setup scripts that automate the entire setup process:

**Windows (PowerShell):**

```powershell
.\setup-dev.ps1
```

**macOS/Linux:**

```bash
chmod +x setup-dev.sh
./setup-dev.sh
```

The script will:

-   Check prerequisites (Node.js, npm)
-   Install dependencies
-   Build the plugin
-   Help you set up a symlink to your Obsidian vault

You can also pass your vault path as an argument:

```bash
# Windows
.\setup-dev.ps1 -VaultPath "C:\Users\YourName\Documents\MyVault"

# macOS/Linux
./setup-dev.sh "/path/to/your/vault"
```

### Manual Setup

If you prefer to set up manually:

1. **Install dependencies:**
    ```bash
    npm install
    ```

## Building the Plugin

The plugin has three build modes:

### Development Mode (with watch)

```bash
npm run build:dev
```

-   Runs TypeScript type checking
-   Builds with esbuild in watch mode (auto-rebuilds on file changes)
-   Includes source maps for debugging
-   Outputs to `dist/` folder

### Beta Mode

```bash
npm run build:beta
```

-   Production build without minification
-   Useful for testing before release

### Production Mode

```bash
npm run build:production
```

-   Minified production build
-   Optimized for release

## Testing in Obsidian

### Option 1: Symlink (Recommended for Development)

1. **Build the plugin:**

    ```bash
    npm run build:dev
    ```

    Keep this running in watch mode - it will rebuild automatically when you make changes.

2. **Find your Obsidian vault's plugins folder:**

    - Windows: `%APPDATA%\Obsidian\Plugins\` or `[YourVault]\.obsidian\plugins\`
    - macOS: `~/Library/Application Support/obsidian/Plugins/` or `[YourVault]/.obsidian/plugins/`
    - Linux: `~/.config/obsidian/Plugins/` or `[YourVault]/.obsidian/plugins/`

3. **Create a symlink:**

    - **Windows (PowerShell as Administrator):**

        ```powershell
        New-Item -ItemType SymbolicLink -Path "[YourVault]\.obsidian\plugins\vertical-tabs" -Target "<project-path>\dist"
        ```

        Replace `<project-path>` with the path to this project directory.

    - **macOS/Linux:**

        ```bash
        ln -s <project-path>/dist [YourVault]/.obsidian/plugins/vertical-tabs
        ```

        Replace `<project-path>` with the path to this project directory.

4. **Enable the plugin in Obsidian:**
    - Open Obsidian
    - Go to Settings → Community plugins
    - Find "Vertical Tabs" and enable it
    - Reload Obsidian if needed

### Option 2: Manual Copy (Alternative)

1. **Build the plugin:**

    ```bash
    npm run build:production
    ```

2. **Copy files to Obsidian:**

    - Create folder: `[YourVault]/.obsidian/plugins/vertical-tabs/`
    - Copy `dist/main.js` → `[YourVault]/.obsidian/plugins/vertical-tabs/main.js`
    - Copy `dist/manifest.json` → `[YourVault]/.obsidian/plugins/vertical-tabs/manifest.json`
    - Copy `dist/styles.css` → `[YourVault]/.obsidian/plugins/vertical-tabs/styles.css` (if exists)

3. **Enable the plugin in Obsidian** (same as above)

## Development Workflow

1. **Start the dev build in watch mode:**

    ```bash
    npm run build:dev
    ```

2. **Make changes to your code** in the `src/` folder

3. **The plugin will auto-rebuild** - you'll see output in the terminal

4. **Reload Obsidian** to see your changes:
    - Press `Ctrl+R` (or `Cmd+R` on Mac) in Obsidian, or
    - Go to Settings → Community plugins → Disable and re-enable the plugin

## Troubleshooting

### Plugin not appearing in Obsidian

-   Make sure the `dist/` folder contains `main.js` and `manifest.json`
-   Check that the plugin folder name matches the plugin ID in `manifest.json` ("vertical-tabs")
-   Ensure the plugin is enabled in Obsidian settings

### Changes not reflecting

-   Make sure the dev build is running and completed
-   Reload Obsidian (Ctrl+R / Cmd+R)
-   Check the browser console (View → Toggle Developer Tools) for errors

### Build errors

-   Run `npm install` to ensure all dependencies are installed
-   Check that TypeScript types are correct: `npx tsc --noEmit`
-   Verify Node.js version compatibility

## File Structure

-   `src/` - Source TypeScript/React files
-   `dist/` - Built plugin files (generated, not in git)
-   `manifest.json` - Plugin metadata
-   `esbuild.config.mjs` - Build configuration

## Quick Reference

### Common Commands

```bash
# Initial setup (one-time)
.\setup-dev.ps1              # Windows
./setup-dev.sh               # macOS/Linux

# Development workflow
npm run build:dev            # Start watch mode (auto-rebuilds)
npm run build:beta           # Build for beta testing
npm run build:production     # Production build

# Type checking
npx tsc --noEmit             # Check TypeScript without building
```

### Project Structure

-   `src/` - Source TypeScript/React files
-   `dist/` - Built plugin files (generated, not in git)
-   `manifest.json` - Plugin metadata
-   `esbuild.config.mjs` - Build configuration
-   `setup-dev.ps1` / `setup-dev.sh` - Automated setup scripts

## Notes

-   The `dist/` folder is gitignored and contains the compiled plugin
-   For development, use `build:dev` which includes source maps and watch mode
-   The plugin uses React 19 and modern TypeScript features
-   Make sure your Obsidian version meets the minimum requirement (1.6.2+)
-   The setup scripts handle symlink creation, but you may need administrator privileges on Windows
