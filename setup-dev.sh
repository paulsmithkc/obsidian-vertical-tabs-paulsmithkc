#!/bin/bash

# Development Setup Script for Vertical Tabs Plugin
# This script handles the setup process for new developers
# Usage: ./setup-dev.sh [vault_path]

set -e  # Exit on any error

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

echo -e "${BLUE}🔧 Vertical Tabs Plugin - Development Setup${NC}"
echo -e "${BLUE}==========================================${NC}"

# Get vault path from command line argument
VAULT_PATH="$1"

# If no vault path provided, prompt the user
if [ -z "$VAULT_PATH" ]; then
    echo -e "${YELLOW}No vault path provided.${NC}"
    echo -e "${BLUE}Enter the path to your Obsidian vault (or press Enter to skip symlink creation):${NC}"
    read -r VAULT_PATH
fi

# Function to print colored output
print_step() {
    echo -e "\n${BLUE}$1. $2${NC}"
}

print_success() {
    echo -e "${GREEN}✅ $1${NC}"
}

print_error() {
    echo -e "${RED}❌ $1${NC}"
}

print_warning() {
    echo -e "${YELLOW}⚠️  $1${NC}"
}

# Check prerequisites
print_step "1" "Checking prerequisites"

if ! command -v node &> /dev/null; then
    print_error "Node.js not found. Please install Node.js 16 or higher."
    exit 1
fi

NODE_VERSION=$(node --version | cut -d'v' -f2 | cut -d'.' -f1)
if [ "$NODE_VERSION" -lt 16 ]; then
    print_error "Node.js $NODE_VERSION found. Version 16 or higher required."
    exit 1
fi
print_success "Node.js $(node --version) found"

if ! command -v npm &> /dev/null; then
    print_error "npm not found. Please install npm."
    exit 1
fi
print_success "npm $(npm --version) found"

# Install dependencies
print_step "2" "Installing dependencies"
echo -e "${BLUE}   Running: npm install${NC}"
if npm install; then
    print_success "Dependency installation completed"
else
    print_error "Failed to install dependencies. Please run 'npm install' manually."
    exit 1
fi

# Build plugin
print_step "3" "Building plugin for development"
echo -e "${BLUE}   Running: npm run build:beta${NC}"

# Check if we're on Windows and need to handle the copy command
if [[ "$OSTYPE" == "msys" || "$OSTYPE" == "cygwin" || "$OSTYPE" == "win32" ]]; then
    echo -e "${YELLOW}   Detected Windows environment, handling copy command...${NC}"
    
    # Run the build without the copy step first
    if npm run build:beta 2>/dev/null | grep -v "cp:" || true; then
        # Now copy the manifest file using Windows copy command
        echo -e "${BLUE}   Copying manifest.json${NC}"
        if command -v cmd &> /dev/null; then
            cmd //c "copy manifest.json dist\\manifest.json" >nul 2>&1 || {
                print_warning "Copy command failed, trying alternative method..."
                cp manifest.json dist/manifest.json 2>/dev/null || {
                    print_error "Failed to copy manifest.json"
                    exit 1
                }
            }
        else
            # Fallback to cp if cmd is not available
            cp manifest.json dist/manifest.json || {
                print_error "Failed to copy manifest.json"
                exit 1
            }
        fi
        print_success "Development build completed"
    else
        print_error "Development build failed"
        exit 1
    fi
else
    # Unix-like systems (macOS, Linux)
    if npm run build:beta; then
        print_success "Development build completed"
    else
        print_error "Development build failed"
        exit 1
    fi
fi

# Create symlink if vault path is provided
print_step "4" "Creating development symlink"

if [ -n "$VAULT_PATH" ]; then
    PLUGIN_DIR="$VAULT_PATH/.obsidian/plugins/vertical-tabs"
    DIST_PATH="$(pwd)/dist"
    
    echo -e "${BLUE}   Using vault path: $VAULT_PATH${NC}"
    
    if [ -d "dist" ]; then
        # Remove existing symlink/directory if it exists
        if [ -L "$PLUGIN_DIR" ]; then
            unlink "$PLUGIN_DIR"
            echo -e "${YELLOW}   Removed existing symlink${NC}"
        elif [ -d "$PLUGIN_DIR" ]; then
            print_warning "Directory exists at $PLUGIN_DIR. Please remove it manually."
        else
            # Create plugins directory if it doesn't exist
            mkdir -p "$(dirname "$PLUGIN_DIR")"
            
            # Create symlink
            if ln -sf "$DIST_PATH" "$PLUGIN_DIR"; then
                print_success "Symlink created: $PLUGIN_DIR -> $DIST_PATH"
            else
                print_error "Failed to create symlink"
            fi
        fi
    else
        print_error "dist folder not found. Build may have failed."
    fi
else
    print_warning "No vault path provided. Skipping symlink creation."
    echo -e "${YELLOW}   Next time, run: ./setup-dev.sh /path/to/your/vault${NC}"
fi

# Show next steps
echo -e "\n${BLUE}5. Setup complete! Next steps:${NC}"

echo -e "\n${GREEN}🚀 Development is ready!${NC}"
echo -e "\n${BLUE}To start developing:${NC}"
echo "1. Open Obsidian and enable the 'Vertical Tabs' plugin in Community Plugins settings"
echo "2. Run 'npm run build:dev' to start watch mode for automatic rebuilding"
echo "3. Make changes to source files in src/"
echo "4. Reload the plugin in Obsidian to see changes"

echo -e "\n${BLUE}📚 Useful commands:${NC}"
echo "• npm run build:dev    - Development build with watch mode"
echo "• npm run build:beta   - Beta build"
echo "• npm run build:prod   - Production build"

echo -e "\n${BLUE}🐛 Debugging:${NC}"
echo "• Open Obsidian developer console with Ctrl+Shift+I (Windows) or Cmd+Option+I (Mac)"
echo "• Check the DEVELOPMENT.md file for detailed debugging tips"

if [ -z "$VAULT_PATH" ]; then
    echo -e "\n${YELLOW}⚡ Pro tip:${NC}"
    echo "Provide your vault path as a command line argument to skip the prompt:"
    echo "./setup-dev.sh /path/to/your/vault"
fi

echo -e "\n${GREEN}🎉 Setup completed successfully!${NC}"
