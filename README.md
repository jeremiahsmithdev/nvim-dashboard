# nvim-dashboard

A Neovim plugin that provides a project dashboard with directory overview when opening directories.

## Features

- **Dashboard View**: Automatically opens when starting Neovim with a directory
- **README Display**: Shows project README in the main buffer
- **Smart File Tree**: Uses nvim-tree when available, falls back to built-in tree
- **File Navigation**: Open files and expand directories directly from the tree
- **Project Overview**: Displays project information when no README is found

## Installation

### Using [packer.nvim](https://github.com/wbthomason/packer.nvim)

```lua
use '/Users/admin/dev/nvim-dashboard'
```

### Using [lazy.nvim](https://github.com/folke/lazy.nvim)

```lua
{
  '/Users/admin/dev/nvim-dashboard',
  config = function()
    require('nvim-dashboard').setup()
  end
}
```

## Usage

### Automatic Dashboard

The dashboard automatically opens when you start Neovim with a directory:

```bash
nvim /path/to/project
```

### Manual Dashboard

You can also open the dashboard manually with the `:Dashboard` command:

```vim
:Dashboard
```

## Configuration

```lua
require('nvim-dashboard').setup({
  width = 0.8,        -- Dashboard width as fraction of screen
  height = 0.8,       -- Dashboard height as fraction of screen
  show_tree = true,   -- Show file tree panel
  show_readme = true, -- Show README in main buffer
  tree_width = 30,    -- Width of the file tree panel
})
```

## nvim-tree Integration

This plugin automatically detects and integrates with [nvim-tree](https://github.com/nvim-tree/nvim-tree.lua) when available:

- **Automatic Detection**: If nvim-tree is installed, it will be used for the file tree
- **Fallback Support**: If nvim-tree is not available, uses a built-in tree implementation
- **Native Keybindings**: When using nvim-tree, all native nvim-tree keybindings are available
- **Seamless Integration**: The dashboard layout adapts automatically to the tree type being used

### Benefits of nvim-tree Integration

- **Rich Features**: Full nvim-tree functionality including git integration, file operations, and custom icons
- **Familiar Interface**: If you're already using nvim-tree, the same keybindings work
- **No Configuration Required**: Integration is automatic when nvim-tree is detected

## Keybindings

### In File Tree

**When using nvim-tree:**
- All standard nvim-tree keybindings are available
- Refer to [nvim-tree documentation](https://github.com/nvim-tree/nvim-tree.lua#keybindings) for complete list

**When using built-in tree:**
- `<CR>` or `o`: Open file or expand directory
- `q`: Close dashboard

### In Main Buffer

- `q`: Close dashboard

## File Structure

```
nvim-dashboard/
├── plugin/
│   └── nvim-dashboard.lua          # Plugin entry point
├── lua/
│   └── nvim-dashboard/
│       ├── init.lua                # Main module
│       ├── dashboard.lua           # Dashboard UI logic
│       ├── tree.lua                # Built-in tree component
│       ├── navigation.lua          # Navigation handlers
│       ├── integrations.lua        # nvim-tree integration
│       ├── state.lua               # State management
│       └── utils.lua               # Utility functions
└── README.md                       # This file
```

## License

MIT