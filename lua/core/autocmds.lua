-- ============================================================================
-- 自动命令（专注 C++ 编辑）
-- ============================================================================

-- C++ 文件使用 3 空格缩进（与 .clang-format 一致）
vim.api.nvim_create_autocmd("FileType", {
    pattern = { "cpp", "c", "hpp", "h" },
    callback = function()
        vim.opt_local.tabstop = 3
        vim.opt_local.shiftwidth = 3
        vim.opt_local.softtabstop = 3
        vim.opt_local.expandtab = true
    end,
})

-- Auto-reload snippets when modified
vim.api.nvim_create_autocmd("BufWritePost", {
    pattern = vim.fn.stdpath("config") .. "/snippets/*.json",
    callback = function()
        vim.cmd("silent! lua require('luasnip.loaders.from_vscode').lazy_load({ paths = { vim.fn.stdpath('config') .. '/snippets' } })")
    end,
})