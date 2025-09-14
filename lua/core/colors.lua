-- ============================================================================
-- Theme Configuration
-- ============================================================================

-- Default theme: "catppuccin" or "gruvbox-material"
local current_theme = "gruvbox-material"

-- Theme configurations
local themes = {
    catppuccin = {
        setup = function()
            local ok, catppuccin = pcall(require, "catppuccin")
            if not ok then return false end
            
            catppuccin.setup({
                flavour = "mocha",
                background = { light = "latte", dark = "mocha" },
                transparent_background = false,
                show_end_of_buffer = false,
                term_colors = true,
                dim_inactive = { enabled = false },
                no_italic = true,
                no_bold = false,
            })
            return true
        end,
        colorscheme = "catppuccin"
    },
    ["gruvbox-material"] = {
        setup = function()
            vim.g.gruvbox_material_background = 'medium'
            vim.g.gruvbox_material_foreground = 'material'
            vim.g.gruvbox_material_transparent_background = 0
            vim.g.gruvbox_material_enable_italic = 0
            vim.g.gruvbox_material_enable_bold = 1
            vim.g.gruvbox_material_diagnostic_text_highlight = 1
            vim.g.gruvbox_material_diagnostic_line_highlight = 1
            vim.g.gruvbox_material_diagnostic_virtual_text = 'colored'
            return true
        end,
        colorscheme = "gruvbox-material"
    }
}

-- Apply theme function
local function apply_theme(theme_name)
    local theme = themes[theme_name]
    if not theme then
        vim.notify("Unknown theme: " .. theme_name, vim.log.levels.WARN)
        vim.cmd.colorscheme("default")
        return
    end
    
    if theme.setup() then
        local ok = pcall(vim.cmd.colorscheme, theme.colorscheme)
        if ok then
            vim.notify("Theme switched to: " .. theme_name, vim.log.levels.INFO)
        else
            vim.cmd.colorscheme("default")
        end
    else
        vim.cmd.colorscheme("default")
    end
end

-- Global theme switching functions
_G.switch_to_catppuccin = function()
    apply_theme("catppuccin")
end

_G.switch_to_gruvbox = function()
    apply_theme("gruvbox-material")
end

-- Apply the default theme on startup
pcall(apply_theme, current_theme)
