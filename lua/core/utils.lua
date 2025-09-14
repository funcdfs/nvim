-- Utility functions for Neovim configuration

local M = {}

-- Function to copy .clang-format from nvim config to current project directory
function M.setup_clang_format()
    local config_path = vim.fn.stdpath("config")
    local clang_format_source = config_path .. "/.clang-format"
    local cwd = vim.fn.getcwd()
    local clang_format_dest = cwd .. "/.clang-format"
    
    -- Check if source .clang-format exists
    if vim.fn.filereadable(clang_format_source) == 0 then
        print("✗ Source .clang-format not found at: " .. clang_format_source)
        return false
    end
    
    -- Check if destination already exists
    if vim.fn.filereadable(clang_format_dest) == 1 then
        local choice = vim.fn.input("'.clang-format' already exists. Overwrite? (y/N): ")
        if choice:lower() ~= "y" and choice:lower() ~= "yes" then
            print("⚠️ Operation cancelled")
            return false
        end
    end
    
    -- Copy the file
    local cmd = string.format("cp %s %s", 
                             vim.fn.shellescape(clang_format_source), 
                             vim.fn.shellescape(clang_format_dest))
    
    local result = vim.fn.system(cmd)
    local exit_code = vim.v.shell_error
    
    if exit_code == 0 then
        print("✓ .clang-format copied to project directory")
        print("📄 Using your custom .clang-format configuration")
        return true
    else
        print("✗ Failed to copy .clang-format: " .. result)
        return false
    end
end

-- Function to format current buffer with C++ specific formatting using .clang-format config
function M.format_cpp_buffer()
    if vim.bo.filetype ~= "cpp" and vim.bo.filetype ~= "c" then
        print("⚠️ Not a C/C++ file (current: " .. vim.bo.filetype .. ")")
        return false
    end
    
    -- Check if clang-format is available
    if vim.fn.executable("clang-format") == 0 then
        print("✗ clang-format not found. Install with: brew install clang-format")
        return false
    end
    
    -- Check if buffer is modified and warn user
    if vim.bo.modified then
        print("⚠️ Buffer has unsaved changes. Save first for best results.")
    end
    
    local config_path = vim.fn.stdpath("config") .. "/.clang-format"
    local cwd = vim.fn.getcwd()
    local local_config = cwd .. "/.clang-format"
    
    -- Determine which config to use (priority: local > nvim config > fallback)
    local style_arg, config_source
    
    if vim.fn.filereadable(local_config) == 1 then
        -- Use local .clang-format in current directory
        style_arg = "--style=file"
        config_source = "local .clang-format"
    elseif vim.fn.filereadable(config_path) == 1 then
        -- Use nvim config .clang-format
        style_arg = "--style=file:" .. vim.fn.shellescape(config_path)
        config_source = "your .clang-format config"
    else
        print("✗ No .clang-format found. Use \\scf to copy nvim config to project")
        return false
    end
    
    print("🔧 Formatting with " .. config_source .. "...")
    
    -- Save current cursor position and buffer state
    local cursor_pos = vim.api.nvim_win_get_cursor(0)
    local original_lines = vim.api.nvim_buf_get_lines(0, 0, -1, false)
    
    -- Create a temporary file to avoid shell escaping issues
    local temp_file = vim.fn.tempname() .. ".cpp"
    
    -- Write buffer content to temp file
    vim.fn.writefile(original_lines, temp_file)
    
    -- Format the temp file using clang-format
    local cmd = string.format("clang-format %s --fallback-style=none %s", 
                             style_arg, vim.fn.shellescape(temp_file))
    
    local formatted_content = vim.fn.system(cmd)
    local exit_code = vim.v.shell_error
    
    -- Clean up temp file
    vim.fn.delete(temp_file)
    
    if exit_code == 0 and formatted_content ~= "" then
        -- Split the formatted content back into lines
        local formatted_lines = {}
        for line in formatted_content:gmatch("([^\n]*)\n?") do
            table.insert(formatted_lines, line)
        end
        
        -- Remove the last empty line if it exists
        if formatted_lines[#formatted_lines] == "" then
            table.remove(formatted_lines)
        end
        
        -- Replace buffer content with formatted version
        vim.api.nvim_buf_set_lines(0, 0, -1, false, formatted_lines)
        
        -- Restore cursor position (with bounds checking)
        local total_lines = #formatted_lines
        if cursor_pos[1] > total_lines then
            cursor_pos[1] = total_lines
        end
        if formatted_lines[cursor_pos[1]] then
            local line_length = #formatted_lines[cursor_pos[1]]
            if cursor_pos[2] > line_length then
                cursor_pos[2] = line_length
            end
        end
        pcall(vim.api.nvim_win_set_cursor, 0, cursor_pos)
        
        print("✓ C++ formatted successfully")
        return true
    else
        print("✗ clang-format error (code " .. exit_code .. "): " .. (formatted_content or "unknown error"))
        return false
    end
end

-- LSP 相关函数已移除，保持轻量配置

return M
