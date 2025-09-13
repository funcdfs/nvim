-- 简化的 autopairs 配置（不依赖 treesitter）
local is_ok, npairs = pcall(require, "nvim-autopairs")
if not is_ok then return end

npairs.setup({
	map_cr = true,  -- 回车键支持
	check_ts = false, -- 不使用 treesitter
})
