-- Theme configuration
-- Change this variable to switch themes: "catppuccin" or "gruvbox-material"
local current_theme = "gruvbox-material"  -- Default theme

-- Catppuccin configuration
local function setup_catppuccin()
    local is_ok, catppuccin = pcall(require, "catppuccin")
    if not is_ok then
        return false
    end
    
    catppuccin.setup({
        flavour = "mocha", -- latte, frappe, macchiato, mocha
        background = { -- :h background
            light = "latte",
            dark = "mocha",
        },
        transparent_background = false, -- disables setting the background color.
        show_end_of_buffer = false, -- shows the '~' characters after the end of buffers
        term_colors = true, -- sets terminal colors (e.g. `g:terminal_color_0`)
        dim_inactive = {
            enabled = false, -- dims the background color of inactive window
            shade = "dark",
            percentage = 0.15, -- percentage of the shade to apply to the inactive window
        },
        no_italic = true, -- Force no italic
        no_bold = false, -- Force no bold
        no_underline = false, -- Force no underline
    })
    return true
end

-- Gruvbox Material configuration
local function setup_gruvbox_material()
    -- Gruvbox Material settings (set before loading the theme)
    vim.g.gruvbox_material_background = 'medium'  -- 'hard', 'medium', 'soft'
    vim.g.gruvbox_material_foreground = 'material'  -- 'material', 'mix', 'original'
    vim.g.gruvbox_material_transparent_background = 0  -- Disable transparency
    vim.g.gruvbox_material_enable_italic = 0  -- Disable italic
    vim.g.gruvbox_material_enable_bold = 1    -- Enable bold
    vim.g.gruvbox_material_diagnostic_text_highlight = 1
    vim.g.gruvbox_material_diagnostic_line_highlight = 1
    vim.g.gruvbox_material_diagnostic_virtual_text = 'colored'
    return true
end

-- Theme switching function
local function apply_theme(theme_name)
    if theme_name == "catppuccin" then
        if setup_catppuccin() then
            pcall(vim.cmd.colorscheme, "catppuccin")
        end
    elseif theme_name == "gruvbox-material" then
        if setup_gruvbox_material() then
            local ok = pcall(vim.cmd.colorscheme, "gruvbox-material")
            if not ok then
                vim.cmd.colorscheme "default"
            end
        else
            vim.cmd.colorscheme "default"
        end
    else
        vim.cmd.colorscheme "default"
    end
end

-- Global theme switching functions
_G.switch_to_catppuccin = function()
    apply_theme("catppuccin")
end

_G.switch_to_gruvbox = function()
    apply_theme("gruvbox-material")
end

-- Apply the current theme
local ok = pcall(apply_theme, current_theme)
if not ok then
    vim.cmd.colorscheme "default"
end
