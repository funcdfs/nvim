local luasnip_ok, luasnip = pcall(require, "luasnip")
if not luasnip_ok then
    vim.notify("LuaSnip not loaded", vim.log.levels.ERROR)
    return
end

-- Configure LuaSnip for C++ development
luasnip.config.setup({
    enable_autosnippets = true,
    store_selection_keys = "<Tab>",
    region_check_events = 'InsertEnter',
    delete_check_events = 'InsertLeave',
})

-- Load VSCode style snippets
local vscode_loader = require("luasnip.loaders.from_vscode")

-- Custom snippets directory
local snippets_dir = vim.fn.stdpath("config") .. "/snippets"
local cpp_snippets_file = snippets_dir .. "/cpp.json"
local package_json_file = snippets_dir .. "/package.json"

-- Load C++ snippets if they exist
if vim.fn.filereadable(cpp_snippets_file) == 1 and vim.fn.filereadable(package_json_file) == 1 then
    -- 使用VSCode加载器加载整个目录（包含package.json）
    vscode_loader.load({ paths = { snippets_dir } })
    print("✓ C++ snippets loaded from: " .. snippets_dir)
else
    print("⚠️ C++ snippets directory incomplete: " .. snippets_dir)
end

-- ============================================================================
-- Key mappings for LuaSnip
-- ============================================================================
-- Tab 键由 nvim-cmp 管理，这里提供备选键位

vim.keymap.set({"i"}, "<C-K>", function() luasnip.expand() end, {silent = true})
vim.keymap.set({"i", "s"}, "<C-L>", function() luasnip.jump( 1) end, {silent = true})
vim.keymap.set({"i", "s"}, "<C-H>", function() luasnip.jump(-1) end, {silent = true})

vim.keymap.set({"i", "s"}, "<C-E>", function()
    if luasnip.choice_active() then
        luasnip.change_choice(1)
    end
end, {silent = true})

-- ============================================================================
-- Debug functions for C++ snippets
-- ============================================================================

local function list_cpp_snippets()
    local ft = vim.bo.filetype
    if ft ~= "cpp" and ft ~= "c" then
        print("⚠️ Not a C/C++ file (current: " .. ft .. ")")
        return
    end
    
    local available_snippets = luasnip.get_snippets(ft)
    
    if available_snippets and #available_snippets > 0 then
        print("📋 Available C++ snippets:")
        for i, snip in ipairs(available_snippets) do
            local trigger = snip.trigger or "unknown"
            local desc = snip.dscr or snip.description or "No description"
            if type(desc) == "table" then
                desc = table.concat(desc, " ")
            end
            print(string.format("  %2d. %-15s - %s", i, trigger, desc))
        end
    else
        print("⚠️ No C++ snippets available")
    end
end

-- Commands
vim.api.nvim_create_user_command('LuaSnipList', list_cpp_snippets, 
    { desc = "List available C++ snippets" })

vim.api.nvim_create_user_command('LuaSnipExpand', function()
    if luasnip.expandable() then
        luasnip.expand()
    else
        print("⚠️ No expandable snippet at cursor")
    end
end, { desc = "Manually expand snippet at cursor" })
