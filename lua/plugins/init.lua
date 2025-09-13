-- Install Lazy.nvim automatically if it's not installed(Bootstraping)
-- Hint: string concatenation is done by `..`
local lazypath = vim.fn.stdpath("data") .. "/lazy/lazy.nvim"
if not vim.loop.fs_stat(lazypath) then
	vim.fn.system({
		"git",
		"clone",
		"--filter=blob:none",
		"https://github.com/folke/lazy.nvim.git",
		"--branch=stable", -- latest stable release
		lazypath,
	})
end

vim.opt.rtp:prepend(lazypath)

-- After installation, run `checkhealth lazy` to see if everything goes right
-- Hints:
--     build: It will be executed when a plugin is installed or updated
--     config: It will be executed when the plugin loads
--     event: Lazy-load on event
--     dependencies: table
--                   A list of plugin names or plugin specs that should be loaded when the plugin loads.
--                   Dependencies are always lazy-loaded unless specified otherwise.
--     ft: Lazy-load on filetype
--     cmd: Lazy-load on command
--     init: Functions are always executed during startup
--     branch: string?
--             Branch of the repository
--     main: string?
--           Specify the main module to use for config() or opts()
--           , in case it can not be determined automatically.
--     keys: string? | string[] | LazyKeysSpec table
--           Lazy-load on key mapping
--     opts: The table will be passed to the require(...).setup(opts)
-- 配置 lazy.nvim 以禁用 luarocks 和 hererocks
require("lazy").setup({
	-- 禁用 luarocks 支持以避免警告
	rocks = { enabled = false },
	
	-- colors
	{ 
		"catppuccin/nvim", 
		name = "catppuccin",
		lazy = false,
		priority = 1000,
	},
	{
		"sainnhe/gruvbox-material",
		lazy = false,
		priority = 1000,
	},
	
	-- Autopairs: [], (), "", '', etc
	{
		"windwp/nvim-autopairs",
		event = "InsertEnter",
		config = function()
			require("plugins.configs.nvim-autopairs")
		end,
	},
	-- Show indentation and blankline
	{
		"lukas-reineke/indent-blankline.nvim",
		main = "ibl",
		config = function()
			require("plugins.configs.indent-blankline")
		end,
	},

	-- LSP 功能已移除，保持轻量配置

	-- Snippet engine (load before cmp)
	{
		"L3MON4D3/LuaSnip",
		version = "v2.*",
		build = "make install_jsregexp",
		config = function()
			require("plugins.configs.luasnip")
		end,
		-- No dependencies needed for custom snippets only
	},

	-- Autocompletion
	{
		"hrsh7th/nvim-cmp",
		event = "InsertEnter",
		config = function()
			require("plugins.configs.nvim-cmp")
		end,
		dependencies = {
			"hrsh7th/cmp-buffer",      -- buffer 补全
			"hrsh7th/cmp-path",        -- 路径补全
			"hrsh7th/cmp-cmdline",     -- 命令行补全
			"L3MON4D3/LuaSnip",        -- 代码片段引擎
			"saadparwaiz1/cmp_luasnip", -- LuaSnip 补全源
			-- LSP 相关依赖已移除
		},
	},

	-- Treesitter 已移除，使用 Neovim 内置语法高亮

	-- 图标功能已移除，保持轻量配置

	-- Which-key for leader key management
	{
		"folke/which-key.nvim",
		event = "VeryLazy", -- 较晚加载避免循环依赖
		config = function()
			require("plugins.configs.which-key")
		end,
	},
})
