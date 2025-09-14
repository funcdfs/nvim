-- ============================================================================
-- Neovim 键位映射配置 (统一管理所有快捷键)
-- ============================================================================
-- 这个文件是所有键位映射的统一管理中心
-- 其他配置文件不应该定义键位映射，只能在这里定义

-- ============================================================================
-- 基础设置
-- ============================================================================

-- 设置 Leader 键为反斜杠
vim.g.mapleader = '\\'

-- 键位映射选项
local opts = {
    noremap = true,    -- 非递归映射
    silent = false,     -- 显示命令信息
}

-- 键位映射函数
local keymap = vim.keymap.set

-- 超时设置
vim.o.timeout = true
vim.o.timeoutlen = 500  -- 非Leader键超时时间 500ms
vim.o.ttimeoutlen = 50  -- 键码超时时间 50ms
-- Leader 键无超时限制（由 which-key 管理）

-- ============================================================================
-- 基础编辑快捷键 (不使用 Leader) - 最少必要的基础操作
-- ============================================================================

-- 快速退出插入模式
keymap('i', 'kj', '<Esc>', { noremap = true, nowait = true })

-- 改进的行首/行尾跳转 (Shift+H/L)
keymap('n', 'H', '^', opts)  -- 跳转到行首（非空字符）
keymap('n', 'L', '$', opts)  -- 跳转到行尾
keymap('v', 'H', '^', opts)  -- 可视模式
keymap('v', 'L', '$', opts)
keymap('o', 'H', '^', opts)  -- 操作待定模式
keymap('o', 'L', '$', opts)
keymap('x', 'H', '^', opts)  -- 选择模式
keymap('x', 'L', '$', opts)

-- 重做
keymap('n', 'U', '<C-r>', opts)

-- Tab 括号匹配
keymap('n', '<TAB>', '%', opts)

-- Y 命令行为与其他大写命令一致
keymap('n', 'Y', 'y$', opts)

-- 搜索时保持结果在屏幕中央
keymap('n', 'n', 'nzz', opts)
keymap('n', 'N', 'Nzz', opts)
keymap('n', '*', '*zz', opts)
keymap('n', '#', '#zz', opts)

-- 缩进保持选中
keymap('v', '<', '<gv', opts)
keymap('v', '>', '>gv', opts)

-- ============================================================================
-- Leader 快捷键 - 所有功能性操作都用 Leader
-- ============================================================================

-- 文件操作
keymap('n', '<Leader>w', ':w<CR>', { desc = '保存文件' })
keymap('n', '<Leader>q', ':q<CR>', { desc = '退出' })
keymap('n', '<Leader>x', ':x<CR>', { desc = '保存并退出' })

-- 编辑操作
keymap('n', '<Leader>c', 'ggVG"+y', { desc = '复制全部内容' })
keymap('v', '<Leader>c', '"+y', { desc = '复制选中内容' })
keymap('n', '<Leader>p', '"+p', { desc = '粘贴系统剪贴板' })
keymap('n', '<Leader>d', 'ggdG', { desc = '删除全部内容' })
keymap('n', '<Leader>s', ':nohls<CR>', { desc = '清除搜索高亮' })

-- C/C++ 格式化相关
keymap('n', '<Leader>f', function()
    require('core.utils').format_cpp_buffer()
end, { desc = 'C/C++ 格式化' })

keymap('n', '<Leader>F', function()
    require('core.utils').format_and_save()
end, { desc = 'C/C++ 格式化并保存' })

keymap('n', '<Leader>fi', function()
    require('core.utils').show_format_info()
end, { desc = '显示格式化配置信息' })

-- 主题切换
keymap('n', '<Leader>tc', '<cmd>lua switch_to_catppuccin()<CR>', { desc = '切换到 Catppuccin 主题' })
keymap('n', '<Leader>tg', '<cmd>lua switch_to_gruvbox()<CR>', { desc = '切换到 Gruvbox Material 主题' })

-- 工具功能
keymap('n', '<Leader>scf', function()
    require('core.utils').setup_clang_format()
end, { desc = 'C++: 复制 .clang-format 配置' })

-- 代码折叠
keymap('n', '<Leader>z', 'za', { desc = '切换代码折叠' })
keymap('n', '<Leader>Z', 'zA', { desc = '递归切换折叠' })
keymap('n', '<Leader>zc', 'zc', { desc = '关闭折叠' })
keymap('n', '<Leader>zo', 'zo', { desc = '打开折叠' })
keymap('n', '<Leader>zm', 'zM', { desc = '关闭所有折叠' })
keymap('n', '<Leader>zr', 'zR', { desc = '打开所有折叠' })

-- C++ 头文件管理
keymap('n', '<Leader>dh', function()
    require('core.utils').download_cpp_headers()
end, { desc = '下载 C++ 头文件 (bits/stdc++.h, algo/dbg.h)' })

keymap('n', '<Leader>ch', function()
    require('core.utils').check_cpp_headers()
end, { desc = '检查 C++ 头文件状态' })

-- ============================================================================
-- 自动命令和特殊设置
-- ============================================================================

-- 离开插入模式时自动关闭 paste 模式
vim.api.nvim_create_autocmd("InsertLeave", {
    pattern = "*",
    command = "set nopaste"
})
