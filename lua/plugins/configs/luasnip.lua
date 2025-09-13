local luasnip_ok, luasnip = pcall(require, "luasnip")
if not luasnip_ok then
    return
end

-- Configure LuaSnip
luasnip.config.setup({
    -- Enable autotriggered snippets
    enable_autosnippets = true,
    -- Use Tab (or some other key if you prefer) to trigger visual selection
    store_selection_keys = "<Tab>",
    -- Event on which to check for exiting a snippet's region
    region_check_events = 'InsertEnter',
    delete_check_events = 'InsertLeave',
})

-- Load VSCode style snippets from multiple sources
local vscode_loader = require("luasnip.loaders.from_vscode")

-- Custom snippets directory
local custom_snippets_path = vim.fn.stdpath("config") .. "/snippets"

-- Function to check if directory exists
local function dir_exists(path)
    local stat = vim.loop.fs_stat(path)
    return stat and stat.type == "directory"
end

-- Load custom snippets
if dir_exists(custom_snippets_path) then
    vscode_loader.lazy_load({ paths = { custom_snippets_path } })
end

-- Optionally load friendly-snippets as fallback (commented out to keep it minimal)
-- vscode_loader.lazy_load()

-- Key mappings for LuaSnip (备选，主要通过 nvim-cmp 管理)
-- Tab 键由 nvim-cmp 管理，这里只提供备选键位
vim.keymap.set({"i"}, "<C-K>", function() luasnip.expand() end, {silent = true})
vim.keymap.set({"i", "s"}, "<C-L>", function() luasnip.jump( 1) end, {silent = true})
vim.keymap.set({"i", "s"}, "<C-H>", function() luasnip.jump(-1) end, {silent = true}) -- 改为 C-H 防止与 cmp 冲突

vim.keymap.set({"i", "s"}, "<C-E>", function()
    if luasnip.choice_active() then
        luasnip.change_choice(1)
    end
end, {silent = true})

-- Debug function to list all available snippets
local function list_snippets()
    local ft = vim.bo.filetype
    local available_snippets = luasnip.get_snippets(ft)
    
    if available_snippets and #available_snippets > 0 then
        for i, snip in ipairs(available_snippets) do
            local trigger = snip.trigger or "unknown"
            local desc = snip.dscr or snip.description or "No description"
            if type(desc) == "table" then
                desc = table.concat(desc, " ")
            end
            print(i .. ". " .. trigger .. " - " .. desc)
        end
    end
end

-- Commands to debug snippets
vim.api.nvim_create_user_command('LuaSnipList', list_snippets, {})

-- Command to manually trigger snippet expansion
vim.api.nvim_create_user_command('LuaSnipExpand', function()
    if luasnip.expandable() then
        luasnip.expand()
    end
end, {})

-- Snippet reloading is handled in core/autocmds.lua
