#!/bin/bash
# Setup script for Vertical Tabs plugin development (macOS/Linux)
# Run this script to set up the development environment

set -e

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
CYAN='\033[0;36m'
GRAY='\033[0;90m'
NC='\033[0m' # No Color

echo -e "${CYAN}========================================${NC}"
echo -e "${CYAN}Vertical Tabs - Development Setup${NC}"
echo -e "${CYAN}========================================${NC}"
echo ""

# Get the script directory (project root)
SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
cd "$SCRIPT_DIR"

# Display paths for verification
echo -e "${CYAN}Path Information:${NC}"
echo -e "  ${GRAY}Script Directory: $SCRIPT_DIR${NC}"
echo -e "  ${GRAY}Current Directory: $(pwd)${NC}"
echo -e "  ${GRAY}Dist Folder: $SCRIPT_DIR/dist${NC}"
if [ -n "$1" ]; then
    echo -e "  ${GRAY}Vault Path: $1${NC}"
    echo -e "  ${GRAY}Target Plugins Path: $1/.obsidian/plugins/vertical-tabs${NC}"
fi
echo ""

# Check prerequisites
echo -e "${YELLOW}Checking prerequisites...${NC}"

# Check Node.js
if command -v node &> /dev/null; then
    NODE_VERSION=$(node --version)
    echo -e "${GREEN}✓ Node.js found: $NODE_VERSION${NC}"
else
    echo -e "${RED}✗ Node.js not found. Please install Node.js from https://nodejs.org/${NC}"
    exit 1
fi

# Check npm
if command -v npm &> /dev/null; then
    NPM_VERSION=$(npm --version)
    echo -e "${GREEN}✓ npm found: $NPM_VERSION${NC}"
else
    echo -e "${RED}✗ npm not found. Please install npm.${NC}"
    exit 1
fi

echo ""

# Install dependencies
echo -e "${YELLOW}Installing dependencies...${NC}"
if [ -d "node_modules" ]; then
    echo -e "${GRAY}node_modules already exists. Skipping npm install.${NC}"
    echo -e "${GRAY}Run 'npm install' manually if you need to update dependencies.${NC}"
else
    npm install
    if [ $? -ne 0 ]; then
        echo -e "${RED}✗ Failed to install dependencies${NC}"
        exit 1
    fi
    echo -e "${GREEN}✓ Dependencies installed${NC}"
fi

echo ""

# Build the plugin
echo -e "${YELLOW}Building plugin (production build)...${NC}"
npm run build:production
if [ $? -ne 0 ]; then
    echo -e "${RED}✗ Build failed${NC}"
    exit 1
fi
echo -e "${GREEN}✓ Plugin built successfully${NC}"

# Verify dist folder exists
if [ ! -f "dist/main.js" ]; then
    echo -e "${RED}✗ dist/main.js not found. Build may have failed.${NC}"
    exit 1
fi

if [ ! -f "dist/manifest.json" ]; then
    echo -e "${YELLOW}Copying manifest.json to dist...${NC}"
    cp manifest.json dist/manifest.json
fi

echo ""

# Set up symlink
echo -e "${YELLOW}Setting up Obsidian plugin symlink...${NC}"
echo ""

# Determine vault path
VAULT_PLUGINS_PATH=""

if [ -n "$1" ]; then
    VAULT_PLUGINS_PATH="$1/.obsidian/plugins/vertical-tabs"
else
    # Try to find common vault locations
    COMMON_VAULT_PATHS=(
        "$HOME/Documents/Obsidian Vault"
        "$HOME/Documents/MyVault"
        "$HOME/Vault"
        "$HOME/.config/obsidian/Plugins"
    )
    
    echo -e "${CYAN}Please provide your Obsidian vault path.${NC}"
    echo -e "${GRAY}Common locations:${NC}"
    for path in "${COMMON_VAULT_PATHS[@]}"; do
        if [ -d "$path" ]; then
            echo -e "${GRAY}  - $path${NC}"
        fi
    done
    echo ""
    
    read -p "Enter your vault path (or press Enter to skip symlink setup): " USER_INPUT
    
    if [ -n "$USER_INPUT" ]; then
        VAULT_PLUGINS_PATH="$USER_INPUT/.obsidian/plugins/vertical-tabs"
        echo ""
        echo -e "${CYAN}Vault Path Information:${NC}"
        echo -e "  ${GRAY}Vault Path: $USER_INPUT${NC}"
        echo -e "  ${GRAY}Target Plugins Path: $VAULT_PLUGINS_PATH${NC}"
        echo ""
    fi
fi

if [ -n "$VAULT_PLUGINS_PATH" ]; then
    VAULT_ROOT="${1:-$USER_INPUT}"
    OBSIDIAN_DIR="$VAULT_ROOT/.obsidian"
    PLUGINS_DIR="$OBSIDIAN_DIR/plugins"
    
    # Validate vault root exists
    if [ ! -d "$VAULT_ROOT" ]; then
        echo -e "${RED}✗ Vault directory not found: $VAULT_ROOT${NC}"
        echo -e "${YELLOW}  Please ensure the vault path is correct.${NC}"
        echo ""
        echo -e "${CYAN}You can create the symlink manually later with:${NC}"
        echo -e "${GRAY}  ln -s \"$SCRIPT_DIR/dist\" \"$VAULT_PLUGINS_PATH\"${NC}"
    else
        # Create .obsidian folder if it doesn't exist
        if [ ! -d "$OBSIDIAN_DIR" ]; then
            echo -e "${YELLOW}Creating .obsidian folder...${NC}"
            if mkdir -p "$OBSIDIAN_DIR" 2>/dev/null; then
                echo -e "${GREEN}✓ Created .obsidian folder${NC}"
            else
                echo -e "${RED}✗ Failed to create .obsidian folder${NC}"
                echo -e "${YELLOW}  Please create it manually and run the script again.${NC}"
                exit 1
            fi
        fi
        
        # Create plugins folder if it doesn't exist
        if [ ! -d "$PLUGINS_DIR" ]; then
            echo -e "${YELLOW}Creating .obsidian/plugins folder...${NC}"
            if mkdir -p "$PLUGINS_DIR" 2>/dev/null; then
                echo -e "${GREEN}✓ Created .obsidian/plugins folder${NC}"
            else
                echo -e "${RED}✗ Failed to create plugins folder${NC}"
                echo -e "${YELLOW}  Please create it manually and run the script again.${NC}"
                exit 1
            fi
        fi
        
        # Now proceed with symlink creation
        if [ -d "$PLUGINS_DIR" ]; then
            # Remove existing symlink or directory if it exists
            if [ -e "$VAULT_PLUGINS_PATH" ]; then
                if [ -L "$VAULT_PLUGINS_PATH" ]; then
                    echo -e "${YELLOW}Removing existing symlink...${NC}"
                    rm "$VAULT_PLUGINS_PATH"
                else
                    echo -e "${YELLOW}⚠ Warning: $VAULT_PLUGINS_PATH already exists and is not a symlink.${NC}"
                    read -p "Do you want to remove it and create a symlink? (y/N): " OVERWRITE
                    if [ "$OVERWRITE" = "y" ] || [ "$OVERWRITE" = "Y" ]; then
                        rm -rf "$VAULT_PLUGINS_PATH"
                    else
                        echo -e "${YELLOW}Skipping symlink creation.${NC}"
                        VAULT_PLUGINS_PATH=""
                    fi
                fi
            fi
            
            if [ -n "$VAULT_PLUGINS_PATH" ]; then
                ln -s "$SCRIPT_DIR/dist" "$VAULT_PLUGINS_PATH"
                if [ $? -eq 0 ]; then
                    echo -e "${GREEN}✓ Symlink created successfully!${NC}"
                    echo -e "${GRAY}  $VAULT_PLUGINS_PATH -> $SCRIPT_DIR/dist${NC}"
                else
                    echo -e "${RED}✗ Failed to create symlink${NC}"
                    echo ""
                    echo -e "${CYAN}You can create it manually with:${NC}"
                    echo -e "${GRAY}  ln -s \"$SCRIPT_DIR/dist\" \"$VAULT_PLUGINS_PATH\"${NC}"
                fi
            fi
        else
            echo -e "${RED}✗ Failed to create or access plugins directory${NC}"
        fi
    fi
fi

echo ""
echo -e "${CYAN}========================================${NC}"
echo -e "${GREEN}Setup Complete!${NC}"
echo -e "${CYAN}========================================${NC}"
echo ""
echo -e "${YELLOW}Next steps:${NC}"
echo -e "  ${NC}1. Open Obsidian"
echo -e "  ${NC}2. Go to Settings → Community plugins"
echo -e "  ${NC}3. Enable 'Vertical Tabs' plugin"
echo -e "  ${NC}4. Reload Obsidian (Cmd+R / Ctrl+R)"
echo ""
echo -e "${YELLOW}For development:${NC}"
echo -e "  ${NC}Run 'npm run build:dev' to start watch mode"
echo -e "  ${GRAY}This will auto-rebuild when you make changes${NC}"
echo ""

