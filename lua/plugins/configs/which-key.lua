-- ============================================================================
-- which-key 插件配置
-- ============================================================================

local wk_ok, wk = pcall(require, "which-key")
if not wk_ok then 
    vim.notify("which-key failed to load", vim.log.levels.ERROR)
    return 
end

-- ============================================================================
-- which-key 基础配置
-- ============================================================================

wk.setup({
    preset = "classic",
    delay = function(ctx)
        -- Plugin mappings: instant popup
        if ctx.plugin then
            return 0
        end
        -- Leader key: instant popup
        if ctx.keys and ctx.keys:find(vim.g.mapleader or "\\") then
            return 0
        end
        -- Other keys: wait 1 second (more reasonable)
        return 1000
    end,
    notify = true,
    -- Auto-detect all possible key combinations
    triggers = {
        { "<auto>", mode = "nxso" },
    },
    plugins = {
        marks = true,
        registers = true,
        spelling = {
            enabled = true,
            suggestions = 20,
        },
        presets = {
            operators = true,    -- help for d, y, c, etc.
            motions = true,      -- help for w, b, e, etc.  
            text_objects = true, -- help for iw, aw, etc.
            windows = true,      -- help for <c-w>
            nav = true,          -- help for navigation
            z = true,            -- help for z commands
            g = true,            -- help for g commands
        },
    },
    icons = {
        mappings = false,
    },
})

-- ============================================================================
-- 注册leader键映射
-- ============================================================================

wk.add({
    -- 文件操作
    { "<leader>w", desc = "保存文件" },
    { "<leader>q", desc = "退出" },
    { "<leader>x", desc = "保存并退出" },
    
    -- 编辑操作
    { "<leader>c", desc = "复制内容" },
    { "<leader>p", desc = "粘贴内容" },
    { "<leader>d", desc = "删除全部" },
    { "<leader>s", desc = "清除高亮" },
    
    -- C/C++ 格式化
    { "<leader>f", desc = "C/C++ 格式化" },
    { "<leader>F", desc = "格式化并保存" },
    { "<leader>fi", desc = "格式化配置信息" },
    
    -- 主题切换
    { "<leader>t", group = "主题" },
    { "<leader>tc", desc = "Catppuccin 主题" },
    { "<leader>tg", desc = "Gruvbox 主题" },
    
    -- 工具设置
    { "<leader>sc", group = "设置" },
    { "<leader>scf", desc = "复制 .clang-format" },
    
    -- 代码折叠
    { "<leader>z", desc = "切换代码折叠" },
    { "<leader>Z", desc = "递归切换折叠" },
    { "<leader>zc", desc = "关闭折叠" },
    { "<leader>zo", desc = "打开折叠" },
    { "<leader>zm", desc = "关闭所有折叠" },
    { "<leader>zr", desc = "打开所有折叠" },
    
    -- C++ 头文件管理
    { "<leader>dh", desc = "下载 C++ 头文件" },
    { "<leader>ch", desc = "检查头文件状态" },
})
