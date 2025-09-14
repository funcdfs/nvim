-- ============================================================================
-- Neovim Configuration Entry Point
-- ============================================================================

-- Load core configuration modules in order
require("core.options")   -- Basic vim options
require("core.keymaps")   -- Key mappings
require("core.autocmds")  -- Auto commands

-- Load plugin manager and plugins
require("plugins")

-- Load colorscheme configuration
require("core.colors")
