-- ============================================================================
-- Plugin Manager Configuration (Lazy.nvim)
-- ============================================================================

-- Bootstrap lazy.nvim if not installed
local lazypath = vim.fn.stdpath("data") .. "/lazy/lazy.nvim"
if not vim.loop.fs_stat(lazypath) then
	vim.fn.system({
		"git",
		"clone",
		"--filter=blob:none",
		"https://github.com/folke/lazy.nvim.git",
		"--branch=stable",
		lazypath,
	})
end

vim.opt.rtp:prepend(lazypath)

-- Configure and load plugins
require("lazy").setup({
	-- 禁用 luarocks 支持以避免警告
	rocks = { enabled = false },
	
	-- ========== Colorschemes ==========
	{ 
		"catppuccin/nvim", 
		name = "catppuccin",
		lazy = false,  -- Load immediately for UI
		priority = 1000,  -- Load before other plugins
	},
	{
		"sainnhe/gruvbox-material",
		lazy = false,
		priority = 1000,
	},
	
	-- ========== Editor Enhancement ==========
	{
		"windwp/nvim-autopairs",
		event = "InsertEnter",  -- Lazy load on insert
		config = function()
			require("plugins.configs.nvim-autopairs")
		end,
	},
	
	{
		"lukas-reineke/indent-blankline.nvim",
		main = "ibl",
		event = "BufReadPost",  -- Lazy load after buffer read
		config = function()
			require("plugins.configs.indent-blankline")
		end,
	},

	-- ========== Snippets ==========
	{
		"L3MON4D3/LuaSnip",
		version = "v2.*",
		build = "make install_jsregexp",
		event = "InsertEnter",  -- Lazy load
		config = function()
			require("plugins.configs.luasnip")
		end,
	},

	-- ========== Completion ==========
	{
		"hrsh7th/nvim-cmp",
		event = { "InsertEnter", "CmdlineEnter" },  -- Load for insert and command mode
		config = function()
			require("plugins.configs.nvim-cmp")
		end,
		dependencies = {
			"hrsh7th/cmp-buffer",
			"hrsh7th/cmp-path",
			"hrsh7th/cmp-cmdline",
			"L3MON4D3/LuaSnip",
			"saadparwaiz1/cmp_luasnip",
		},
	},

	-- ========== UI Enhancement ==========
	{
		"folke/which-key.nvim",
		event = "VeryLazy",
		config = function()
			require("plugins.configs.which-key")
		end,
	},
})
