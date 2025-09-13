-- ============================================================================
-- Neovim 配置（专注 C++ 编辑）
-- ============================================================================

-- 禁用不需要的语言提供者
vim.g.loaded_node_provider = 0
vim.g.loaded_perl_provider = 0
vim.g.loaded_python3_provider = 0
vim.g.loaded_ruby_provider = 0

-- 补全和编辑配置
vim.opt.completeopt = { "menu", "menuone", "noselect" }
vim.opt.mouse = "a"
vim.opt.scrolloff = 8

-- 缩进配置（主要用于 C++）
vim.opt.tabstop = 4
vim.opt.softtabstop = 4
vim.opt.shiftwidth = 4
vim.opt.expandtab = true

-- UI 配置
vim.opt.number = true
vim.opt.relativenumber = false
vim.opt.cursorline = true
vim.opt.splitbelow = true
vim.opt.splitright = true
vim.opt.termguicolors = true
vim.opt.showmode = true
vim.opt.signcolumn = "yes"  -- 防止闪动

-- 搜索配置
vim.opt.incsearch = true
vim.opt.hlsearch = false
vim.opt.ignorecase = true
vim.opt.smartcase = true

-- 禁用备份文件
vim.o.backup = false
vim.o.writebackup = false
vim.o.swapfile = false
