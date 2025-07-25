# nvim-tree-readme

A simple Neovim plugin that automatically opens README files when nvim-tree opens.

## Features

- **Automatic README Opening**: When nvim-tree opens, automatically finds and opens the README file in the current directory
- **Multiple README Formats**: Supports README.md, README.rst, README.txt, README, etc.
- **Smart Window Management**: Opens README in existing window or creates a new split
- **Zero Configuration**: Works out of the box with no setup required

## Requirements

- [nvim-tree.lua](https://github.com/nvim-tree/nvim-tree.lua) - Required dependency

## Installation

### Using [lazy.nvim](https://github.com/folke/lazy.nvim)

```lua
{
  '/Users/admin/dev/nvim-dashboard',
  dependencies = {
    'nvim-tree/nvim-tree.lua',
  },
}
```

### Using [packer.nvim](https://github.com/wbthomason/packer.nvim)

```lua
use {
  '/Users/admin/dev/nvim-dashboard',
  requires = {
    'nvim-tree/nvim-tree.lua',
  },
}
```

## How it Works

1. When nvim-tree opens (FileType 'NvimTree' event), the plugin is triggered
2. It looks for README files in the nvim-tree root directory
3. If a README is found, it automatically opens it:
   - In an existing non-nvim-tree window if available
   - In a new vertical split if no other window exists

## Supported README Files

The plugin searches for README files in this order:
- README.md
- readme.md  
- README.rst
- readme.rst
- README.txt
- readme.txt
- README
- readme

## Usage

No configuration needed! Just open nvim-tree and the README will automatically appear if one exists in the directory.

```bash
# Open nvim-tree manually
:NvimTreeOpen

# Or use nvim-tree's directory opening
nvim /path/to/project
```

## File Structure

```
nvim-tree-readme/
├── plugin/
│   └── nvim-tree-readme.lua     # Plugin entry point and autocommands
├── lua/
│   └── nvim-tree-readme/
│       └── init.lua             # README detection and opening logic
└── README.md                    # This file
```

## License

MIT