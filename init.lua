-- load options
require("options")

-- load keymappings
require("keymaps")

-- load Lazy vim
require("plugins")

-- Set colorscheme
vim.o.background = "dark" -- or "light" for light mode
vim.cmd([[colorscheme gruvbox]])