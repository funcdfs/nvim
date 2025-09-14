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

-- 缩进配置（与 .clang-format 保持一致）
vim.opt.tabstop = 3      -- tab 显示为 3 个空格宽度
vim.opt.softtabstop = 3  -- 软 tab 宽度为 3
vim.opt.shiftwidth = 3   -- 缩进宽度为 3 空格
vim.opt.expandtab = true -- tab 转换为空格（与 clang-format UseTab: Never 一致）

-- UI 配置
vim.opt.number = true
vim.opt.relativenumber = false
vim.opt.cursorline = true
vim.opt.splitbelow = true
vim.opt.splitright = true
vim.opt.termguicolors = true
vim.opt.showmode = true
vim.opt.signcolumn = "no"   -- 无LSP，不需要signcolumn

-- 行显示配置 - 禁用换行
vim.opt.wrap = false         -- 禁用长行自动换行显示
vim.opt.linebreak = false    -- 禁用单词边界换行
vim.opt.textwidth = 0        -- 禁用自动文本换行

-- 搜索配置
vim.opt.incsearch = true
vim.opt.hlsearch = false
vim.opt.ignorecase = true
vim.opt.smartcase = true

-- 禁用备份文件
vim.o.backup = false
vim.o.writebackup = false
vim.o.swapfile = false

-- 折叠设置
vim.opt.foldmethod = "expr"     -- 使用表达式折叠
vim.opt.foldexpr = "nvim_treesitter#foldexpr()"  -- 如果没有 treesitter，会回退到 indent
vim.opt.foldlevel = 99          -- 默认展开所有折叠
vim.opt.foldcolumn = "0"        -- 不显示折叠列
vim.opt.foldenable = true       -- 启用折叠功能
