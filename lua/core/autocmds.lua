-- ============================================================================
-- Auto Commands for C++ Development
-- ============================================================================

local augroup = vim.api.nvim_create_augroup("CppDevelopment", { clear = true })

-- C++ file specific settings (match .clang-format)
vim.api.nvim_create_autocmd("FileType", {
    group = augroup,
    pattern = { "cpp", "c", "h", "hpp" },
    callback = function()
        local opt = vim.opt_local
        opt.tabstop = 3
        opt.shiftwidth = 3
        opt.softtabstop = 3
        opt.expandtab = true
    end,
    desc = "Set C++ specific indentation"
})

-- Auto-reload snippets when modified (optimized)
vim.api.nvim_create_autocmd("BufWritePost", {
    group = augroup,
    pattern = "*/snippets/*.json",
    callback = function(event)
        -- Only reload if it's actually in our config directory
        local config_dir = vim.fn.stdpath("config")
        if event.file:find(config_dir, 1, true) then
            -- Defer the reload to not block the write operation
            vim.defer_fn(function()
                local ok, loader = pcall(require, "luasnip.loaders.from_vscode")
                if ok then
                    loader.lazy_load({ paths = { config_dir .. "/snippets" } })
                    vim.notify("Snippets reloaded", vim.log.levels.INFO)
                end
            end, 100)
        end
    end,
    desc = "Auto-reload snippets on save"
})
