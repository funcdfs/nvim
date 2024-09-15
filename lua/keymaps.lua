-- define common options
local opts = {
    noremap = true,      -- non-recursive
    silent = true,       -- do not show message
}

-- 插入模式映射
vim.api.nvim_set_keymap('i', 'kj', '<Esc>', {noremap = true, nowait = true})

-- 普通模式映射

vim.api.nvim_set_keymap('n', '<TAB>', '%', {noremap = true})
vim.api.nvim_set_keymap('n', 'H', '^', {noremap = true})
vim.api.nvim_set_keymap('n', 'L', '$', {noremap = true})
vim.api.nvim_set_keymap('n', ';', ':', {noremap = true})

vim.api.nvim_set_keymap('n', '<leader>q', ':q<CR>', {noremap = true})
vim.api.nvim_set_keymap('n', '<leader>w', ':w<CR>', {noremap = true})
vim.api.nvim_set_keymap('n', '<Leader>v', 'ggVG', {noremap = true})
vim.api.nvim_set_keymap('n', '<Leader>y', 'ggyG', {noremap = true})
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