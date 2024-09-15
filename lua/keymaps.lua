-- define common options
local opts = {
    noremap = true,      -- non-recursive
    silent = true,       -- do not show message
}
-- 普通模式映射

-- 用于处理 'kj' 组合键转义为 Esc 的函数
local esc_j_lasttime = 0
local esc_k_lasttime = 0

local function JKescape(key)
    if key == 'j' then
        esc_j_lasttime = vim.fn.reltimefloat(vim.fn.reltime())
    elseif key == 'k' then
        esc_k_lasttime = vim.fn.reltimefloat(vim.fn.reltime())
    end
    local timediff = math.abs(esc_j_lasttime - esc_k_lasttime)
    if timediff <= 0.05 and timediff >= 0.001 then
        return "<Esc>"
    else
        return key
    end
end

-- 插入模式映射
vim.api.nvim_set_keymap('i', 'j', 'v:lua.JKescape("j")', {expr = true, noremap = true})
vim.api.nvim_set_keymap('i', 'k', 'v:lua.JKescape("k")', {expr = true, noremap = true})
vim.api.nvim_set_keymap('i', 'kj', '<Esc>', {noremap = true, nowait = true})

vim.api.nvim_set_keymap('n', '<TAB>', '%', {noremap = true})
vim.api.nvim_set_keymap('n', 'H', '^', {noremap = true})
vim.api.nvim_set_keymap('n', 'L', '$', {noremap = true})
vim.api.nvim_set_keymap('n', ';', ':', {noremap = true})
vim.api.nvim_set_keymap('n', '<leader>q', ':q<CR>', {noremap = true})
vim.api.nvim_set_keymap('n', '<leader>w', ':w<CR>', {noremap = true})
vim.api.nvim_set_keymap('n', '<Leader>s', 'ggVG+y', {noremap = true})
vim.api.nvim_set_keymap('n', '<Leader>d', 'ggdG', {noremap = true})
vim.api.nvim_set_keymap('n', 'n', 'nzz', {noremap = true, silent = true})
vim.api.nvim_set_keymap('n', 'N', 'Nzz', {noremap = true, silent = true})
vim.api.nvim_set_keymap('n', '*', '*zz', {noremap = true, silent = true})
vim.api.nvim_set_keymap('n', '#', '#zz', {noremap = true, silent = true})
vim.api.nvim_set_keymap('n', 'g*', 'g*zz', {noremap = true, silent = true})

-- 可视模式映射
vim.api.nvim_set_keymap('v', '<', '<gv', {noremap = true})
vim.api.nvim_set_keymap('v', '>', '>gv', {noremap = true})

-- 将 Y 映射到 y$，使其行为与其他大写字母一致
vim.api.nvim_set_keymap('n', 'Y', 'y$', {noremap = true})
