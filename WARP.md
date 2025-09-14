# WARP.md

This file provides guidance to WARP (warp.dev) when working with code in this repository.

## Overview

This is a modern Neovim configuration designed for efficient development with strong C++/Go support. The configuration follows a modular approach with clear separation of concerns, uses Lazy.nvim for plugin management, and includes LSP integration for diagnostics and code navigation. Completion is simplified to focus on buffer keywords and custom snippets only.

## Architecture

The configuration is structured with the following key components:

- **`init.lua`**: Entry point that loads all core modules and handles Neovide-specific settings
- **`lua/core/`**: Core configuration directory
  - **`options.lua`**: Core Neovim options and settings (tab behavior, UI preferences, search settings)
  - **`keymaps.lua`**: All custom keybindings with leader key set to backslash (`\`)
  - **`colors.lua`**: Color scheme configuration with theme switching support
- **`lua/plugins/`**: Plugin management directory
  - **`init.lua`**: Plugin specifications using Lazy.nvim with automatic bootstrapping
  - **`configs/`**: Directory containing individual plugin configurations

### Plugin System

The configuration uses [Lazy.nvim](https://github.com/folke/lazy.nvim) for plugin management with:
- **Automatic installation**: Lazy.nvim bootstraps itself if not present
- **Lazy loading**: Plugins load based on events, commands, or file types
- **Lock file**: `lazy-lock.json` pins plugin versions (ignored in git)

Current plugins:
- **catppuccin**: Mocha flavor theme (reduced transparency)
- **gruvbox-material**: Material design inspired gruvbox theme (reduced transparency)
- **nvim-lspconfig**: LSP configuration for diagnostics and navigation (C++/Go/Lua)
- **mason.nvim**: Package manager for LSP servers (clangd, gopls, lua_ls)
- **nvim-cmp**: Simplified autocompletion (buffer + custom snippets only)
- **nvim-treesitter**: Advanced syntax highlighting and parsing
- **nvim-autopairs**: Automatic bracket/quote completion
- **indent-blankline**: Visual indentation guides
- **LuaSnip**: Custom snippet engine (VSCode format)
- **which-key**: Leader key management with infinite timeout (modern API)
- **nvim-web-devicons**: File type icons support

## Common Commands

### Plugin Management
```bash
# Open Neovim and run these commands inside Neovim:
# :Lazy                    # Open plugin manager interface
# :Lazy install           # Install missing plugins
# :Lazy update            # Update all plugins
# :Lazy clean             # Remove unused plugins
# :Lazy health            # Check plugin health
```

### Configuration Testing
```bash
# Test configuration
nvim

# Check health of configuration
# (run inside Neovim)
# :checkhealth

# Check Lazy plugin health specifically
# :checkhealth lazy
```

### Development Workflow
```bash
# Edit configuration files
nvim ~/.config/nvim/init.lua
nvim ~/.config/nvim/lua/core/keymaps.lua
nvim ~/.config/nvim/lua/core/options.lua

# Test changes immediately by reloading
# (run inside Neovim)
# :source %              # Reload current file
# :so ~/.config/nvim/init.lua  # Reload main config
```

### Theme Switching
```bash
# Switch themes during Neovim session (run inside Neovim):
# \thc                   # Switch to Catppuccin theme
# \thg                   # Switch to Gruvbox Material theme

# Or use Lua commands:
# :lua switch_to_catppuccin()
# :lua switch_to_gruvbox()

# To change default theme, edit lua/core/colors.lua:
# local current_theme = "gruvbox-material"  -- or "catppuccin"
```

### C++ Development Setup
```bash
# Install clangd (C++ LSP server) on macOS:
brew install llvm

# Or install via Xcode Command Line Tools (includes clangd):
xcode-select --install

# LSP servers will be automatically installed via Mason
# Check installation status:
# :Mason (run inside Neovim)

# Create a simple C++ project:
echo '#include <iostream>
int main() {
    std::cout << "Hello, World!" << std::endl;
    return 0;
}' > main.cpp

# Compile and run:
g++ -o main main.cpp && ./main
```


### C++ Snippets Usage (VSCode Format)
Snippets provide quick code templates that you can expand. This configuration supports C++ snippets only.

```bash
# Built-in C++ snippets (type prefix and press Tab):
# P        - Empty space (algorithm contests)
# dbg      - Debug print statement
# class_dsu - Disjoint Set Union class
# pbds     - Policy-based data structures
# sort     - Sort array
# unique   - Sort and remove duplicates
# ... (see cpp.json for full list)

# Snippet file location:
# ~/.config/nvim/snippets/cpp.json
```

#### Creating Custom Snippets
Create or edit `~/.config/nvim/snippets/cpp.json` in VSCode format:
```json
{
  "snippet name": {
    "prefix": "trigger",
    "body": [
      "line 1 with $1 placeholder",
      "line 2 with $0 final cursor position"
    ],
    "description": "Snippet description"
  }
}
```

**Usage**: Type the prefix and press `Tab` to expand. Use `Tab`/`Shift+Tab` to navigate between placeholders.

**Debugging C++ Snippets**:
```bash
# Check if snippets are loaded (run inside Neovim, C++ files only):
# :LuaSnipList                 # List all available C++ snippets
# :LuaSnipExpand              # Manually expand snippet at cursor

# Alternative expansion keys:
# <C-K>                       # Expand snippet
# <C-L>                       # Jump forward in snippet
# <C-H>                       # Jump backward in snippet
```

### Custom Code Formatting
This configuration includes a custom `.clang-format` file based on Google style with personal modifications.

#### Formatting Commands (Leader: `\`)
```bash
# Format C++ code:
# \f                      # Format current C/C++ buffer
# \F                      # Format and save C/C++ file
# \fi                     # Show formatting configuration info
# \scf                    # Copy .clang-format to current project

# The .clang-format file features:
# - Based on Google style
# - 3-space indentation (TabWidth & IndentWidth)
# - 110 column limit
# - Pointer alignment left
# - Custom brace wrapping
# - Optimized for competitive programming
```

#### Format Configuration Priority
The formatter uses the following priority order:
1. **Project .clang-format** - If exists in current directory
2. **Neovim .clang-format** - From `~/.config/nvim/.clang-format`
3. **Error** - No configuration found (prompts to use `\scf`)

#### Manual Project Setup
```bash
# For new C++ projects, copy the format file:
cp ~/.config/nvim/.clang-format ./

# Or use the keybinding in Neovim:
# \lcfg
```

## Key Configuration Details

### Custom Keybindings (Leader: `\`)

#### Base Operations
- **File operations**: `\w` (save), `\q` (quit)
- **Clipboard**: `\c` (copy all/selection to system clipboard)
- **Utility**: `\d` (delete all content), `\v` (paste and indent)
- **Search**: `\/` (remove highlights)
- **Quick escape**: `kj` in insert mode
- **Navigation**: `H` (line start), `L` (line end), `U` (redo)

#### Theme Switching (`\th` prefix)
- **Catppuccin**: `\thc` - Switch to Catppuccin Mocha theme
- **Gruvbox**: `\thg` - Switch to Gruvbox Material theme

#### LSP & Development Tools (`\l` prefix - semantic keybindings)
All LSP and development keybindings use semantic multi-letter commands for clarity:

**Navigation & Movement**
- `\lgo` - Go to definition
- `\ldec` - Go to declaration  
- `\limp` - Go to implementation
- `\lref` - Show references

**Information & Documentation**
- `\lhov` - Hover documentation
- `\lsig` - Signature help

**Code Actions & Editing**
- `\lren` - Rename symbol
- `\lact` - Code actions menu
- `\lfmt` - Format buffer (general LSP formatting)

**Diagnostics & Errors**
- `\lerr` - Show diagnostic float
- `\lpre` - Previous diagnostic
- `\lnxt` - Next diagnostic
- `\llis` - Diagnostic location list

**Tools Management & Debugging**
- `\lsta` - LSP status/debug info
- `\lres` - Restart LSP servers
- `\linsg` - Install Go tools (gopls)
- `\linsc` - Start clangd manually

**LSP Service Control**
- `\lon` - Start LSP services
- `\loff` - Stop LSP services  
- `\linfo` - Show LSP information

**C++ Specific Tools**
- `\lcpp` - Format C++ buffer with custom .clang-format style
- `\lcfg` - Copy .clang-format to current project directory

### Editor Behavior
- **Tabs**: 4 spaces globally, 3 spaces for C/C++ files (user preference)
- **UI**: Line numbers, cursor line highlight, split preferences
- **Search**: Case-insensitive with smart case, incremental search
- **No backup files**: Disabled swap, backup, and writebackup files
- **Diagnostics**: 1000ms delay before showing syntax errors
- **Leader key**: Infinite timeout (press \ and wait), other keys 500ms timeout

### Neovide Integration
The configuration includes specific optimizations for [Neovide](https://neovide.dev/):
- Custom font settings, animations, transparency
- macOS-specific clipboard shortcuts (`Cmd+V`, `Cmd+C`, etc.)

## Adding New Plugins

To add a new plugin, edit `lua/plugins/init.lua`:

```lua path=/Users/w/.config/nvim/lua/plugins/init.lua start=36
require("lazy").setup({
    -- Add new plugin here
    {
        "author/plugin-name",
        event = "VeryLazy",  -- or other lazy loading triggers
        config = function()
            require("plugins.configs.plugin-name")  -- if separate config needed
        end,
    },
    -- existing plugins...
})
```

If the plugin needs configuration, create `lua/plugins/configs/plugin-name.lua`.

## Troubleshooting

### Plugin Issues
1. Check `:Lazy` interface for errors
2. Run `:checkhealth lazy` for diagnostics
3. Run `:checkhealth which-key` to verify leader key setup
4. Clear plugin cache: remove `~/.local/share/nvim/lazy/` directory
5. Reinstall: `:Lazy clear` then `:Lazy install`

### Configuration Issues
1. Check syntax: `:luafile %` in the problematic file
2. Reset to defaults: backup and temporarily rename config directory
3. Check Neovim version compatibility (requires Neovim 0.9+)

### Snippet Issues
1. Run `:LuaSnipList` to see available snippets for current filetype
2. Check snippet files exist: `ls ~/.config/nvim/snippets/`
3. Test manual expansion: `:LuaSnipExpand`

### LSP and Formatting Issues
1. **Check LSP status**: `\lsta` - Debug LSP attachment and server status
2. **LSP service control**: `\lon` (start), `\loff` (stop), `\linfo` (info)
3. **Restart LSP**: `\lres` - Restart all LSP servers
4. **Manual clangd start**: `\linsc` - Start clangd manually for C++ files
6. **Formatting options**: `\lfmt` (general LSP), `\lcpp` (C++ with custom style)
7. **Install clang-format**: `brew install clang-format` (macOS)

## File Structure Patterns

When modifying this configuration:
- **Add options**: Edit `lua/core/options.lua`
- **Add keybindings**: Edit `lua/core/keymaps.lua`
- **Add plugins**: Edit `lua/plugins/init.lua`
- **Plugin-specific config**: Create `lua/plugins/configs/plugin-name.lua`
- **Theme changes**: Edit `lua/core/colors.lua`

The configuration follows Lua best practices with proper error handling (`pcall`) in plugin configurations and clear module separation.