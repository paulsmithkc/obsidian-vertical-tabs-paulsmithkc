# Developer Documentation - Vertical Tabs for Obsidian

## Quick Start

### Prerequisites

- **Node.js** (v16 or higher) with **npm**
- **Obsidian** (for testing)
- **TypeScript** knowledge
- **React** knowledge (for UI components)

### Setup

**Automated Setup (Recommended):**
```bash
# Clone the repository
git clone <repository-url>
cd <repository-name>

# Run the setup script
# On Windows, use Git Bash or WSL to run the script
./setup-dev.sh /path/to/your/vault

# Hot reload for development
npm run build:dev
```

**Manual Setup:**
```bash
# Install dependencies
npm install
# Hot reload for development
npm run build:dev
```

**Manual Installation Steps:**
1. **Copy built files to your Obsidian vault:**
   ```bash
   # Copy the entire dist folder
   cp -r dist/ "path/to/your/vault/.obsidian/plugins/vertical-tabs/"
   ```

2. **Enable the plugin in Obsidian:**
   - Open Obsidian
   - Go to Settings → Community Plugins
   - Turn on "Community plugins"
   - Search for "Vertical Tabs" and enable it
   - Or if using local files, make sure "Safe mode" is off

3. **For development (recommended):**
   - Create a symlink instead of copying files:
   ```bash
   # Windows (run as Administrator)
   mklink /D "path/to/vault/.obsidian/plugins/vertical-tabs" "path/to/project/dist"
   
   # macOS/Linux
   ln -s "path/to/project/dist" "path/to/vault/.obsidian/plugins/vertical-tabs"
   ```

## Project Structure

```
src/
├── components/          # React UI components
├── constants/           # Application constants
├── history/             # Data migration logic
├── hooks/               # Custom React hooks
├── models/              # Data models and types
├── services/            # Business logic and utilities
├── stores/              # State management (Zustand)
├── styles/              # SCSS stylesheets
├── types/               # TypeScript type definitions
├── utils/               # Utility functions
├── views/               # Obsidian view classes
├── main.ts              # Plugin entry point
└── styles.scss          # Main stylesheet
```

## Architecture Overview

### Plugin Entry Point (`src/main.ts`)

The main plugin class `ObsidianVerticalTabs` extends Obsidian's `Plugin` class and handles:

- Plugin initialization and lifecycle
- View registration (`VERTICAL_TABS_VIEW`)
- Command registration
- Settings management
- View patching (monkey-patching Obsidian internals)
- Event handling

### React Integration

The plugin uses React for its UI:

- **VerticalTabsView**: Obsidian `ItemView` that hosts a React application
- **PluginContext**: React Context providing plugin instance to components
- **StrictMode**: React Strict Mode enabled for development

### State Management

Uses **Zustand** for state management:

- **useSettings**: Plugin settings and configuration
- **useViewState**: UI state and tab management
- **LinkTaskStore**: Link processing and task management

## Development Workflow

### Build Commands

```bash
# Development build with watch mode and sourcemaps
npm run build:dev

# Beta build
npm run build:beta

# Production build (minified)
npm run build:production

# Version bumping
npm run version
npm run version:beta
```

### Development Mode

Run `npm run build:dev` to:
- Compile TypeScript and SCSS
- Enable watch mode for automatic rebuilding
- Generate inline sourcemaps
- Copy manifest.json to dist/

### Hot Reloading

Changes to source files automatically rebuild the plugin. Restart Obsidian or reload the plugin to see changes.

## Key Components

### NavigationContainer (`src/components/NavigationContainer.tsx`)

Main React component that:
- Renders the vertical tab interface
- Handles drag-and-drop operations
- Manages tab groups and organization
- Coordinates with Obsidian's workspace

### Tab Component (`src/components/Tab.tsx`)

Represents an individual tab with:
- Drag and drop functionality
- Tab actions (close, pin, etc.)
- Visual states (active, hovered, etc.)
- Integration with Obsidian leaf state

### Group Component (`src/components/Group.tsx`)

Manages tab groups with:
- Collapsible functionality
- Group-specific actions
- Drag and drop for reorganization
- Visual hierarchy

## State Management

### Settings Store (`src/models/PluginContext.ts`)

```typescript
interface Settings {
  showActiveTabs: boolean;
  hideSidebars: boolean;
  enableTabZoom: boolean;
  ephemeralTabs: boolean;
  // ... many more settings
}
```

### View State Store (`src/models/ViewState.ts`)

Manages:
- Active tab tracking
- UI state (expanded/collapsed groups)
- Tab navigation history
- Modal states

## Styling

### SCSS Architecture

Styles are organized in `src/styles/` with modular SCSS files:

```scss
// Main styles.scss imports all modules
@use "styles/ShowActiveTabs.scss";
@use "styles/ZenMode.scss";
@use "styles/Tab.scss";
// ... etc
```

### CSS Variables

Uses Obsidian's CSS custom properties for theming:
- `var(--font-ui-small)`
- `var(--size-4-3)`
- `var(--icon-xs)`
- `var(--text-faint)`

### Class Naming Convention

- `vt-` prefix for plugin-specific classes
- BEM-inspired naming: `vt-feature-element--modifier`
- Body classes for feature toggles: `body.vt-hide-sidebars`

## Building and Testing

### Build Process (ESBuild)

Configuration in `esbuild.config.mjs`:
- TypeScript compilation with React JSX
- SCSS processing via esbuild-sass-plugin
- External dependencies (Obsidian API)
- Different modes: dev/beta/production

### Testing in Obsidian

1. **Manual Testing**
   - Install built plugin in test vault
   - Test various features and edge cases
   - Check mobile compatibility

2. **Debug Mode**
   - Use Obsidian's developer console
   - Enable debug logging in plugin settings
   - Use browser dev tools for React components

## Common Patterns

### Plugin Patching

The plugin uses `monkey-around` to patch Obsidian internals:

```typescript
import { around } from "monkey-around";

// Patch ItemView prototype
this.register(
  around(ItemView.prototype, {
    setEphemeralState(old) {
      return function (eState: object) {
        // Custom logic
        return old.call(this, modifiedEState);
      };
    },
  })
);
```

### Event Registration

```typescript
// Register workspace events
this.registerEvent(
  this.app.workspace.on("active-leaf-change", (leaf) => {
    // Handle leaf change
  })
);
```

### React Component Pattern

```typescript
// Component with plugin context
const MyComponent = () => {
  const plugin = useContext(PluginContext);
  const { settings } = useSettings();
  
  return <div>{/* JSX */}</div>;
};
```

## Debugging Tips

### Console Debugging

Add console logs with descriptive prefixes:

```typescript
console.log("VerticalTabs: Debug message", data);
```

### React DevTools

Install React DevTools browser extension to inspect component hierarchy and state.

### Obsidian Developer Console

1. Open Obsidian
2. Press `Ctrl+Shift+I` (Windows) or `Cmd+Option+I` (Mac)
3. Use Console tab for debugging
4. Check Network tab for API calls

### Common Issues

- **Plugin not loading**: Check manifest.json version compatibility
- **Styles not applying**: Verify SCSS compilation and CSS class names
- **React errors**: Check component props and state management
- **Memory leaks**: Ensure proper cleanup in onUnload()

## Contributing

1. Fork the repository
2. Create a feature branch
3. Make changes with proper testing
4. Update documentation as needed
5. Submit a pull request with clear description

## Resources

- [Obsidian Plugin API Documentation](https://docs.obsidian.md/Plugins/Getting+started/Build+a+plugin)
- [React Documentation](https://react.dev/)
- [Zustand Documentation](https://docs.pmnd.rs/zustand/)
- [TypeScript Handbook](https://www.typescriptlang.org/docs/)
- [ESBuild Documentation](https://esbuild.github.io/)
