-- Utility functions for Neovim configuration

local M = {}

-- Function to copy .clang-format to current project directory
function M.setup_clang_format()
    local config_path = vim.fn.stdpath("config")
    local clang_format_source = config_path .. "/.clang-format"
    local cwd = vim.fn.getcwd()
    local clang_format_dest = cwd .. "/.clang-format"
    
    if vim.fn.filereadable(clang_format_source) == 0 then
        return false
    end
    
    if vim.fn.filereadable(clang_format_dest) == 1 then
        local choice = vim.fn.input("'.clang-format' already exists. Overwrite? (y/N): ")
        if choice:lower() ~= "y" and choice:lower() ~= "yes" then
            return false
        end
    end
    
    local success = vim.fn.system("cp " .. vim.fn.shellescape(clang_format_source) .. " " .. vim.fn.shellescape(clang_format_dest))
    return vim.v.shell_error == 0
end

-- Function to format current buffer with C++ specific formatting (strict 3-space config)
function M.format_cpp_buffer()
    if vim.bo.filetype ~= "cpp" and vim.bo.filetype ~= "c" then
        print("Not a C/C++ file")
        return
    end
    
    -- 强制使用 clang-format 和自定义配置（不使用 LSP）
    if vim.fn.executable("clang-format") == 1 then
        local filename = vim.api.nvim_buf_get_name(0)
        local config_path = vim.fn.stdpath("config") .. "/.clang-format"
        
        -- 强制使用配置文件，优先级：本地 > nvim 配置 > 错误
        local cmd
        if vim.fn.filereadable("./.clang-format") == 1 then
            cmd = string.format("clang-format -style=file -i %s", vim.fn.shellescape(filename))
            print("🔧 Using local .clang-format")
        elseif vim.fn.filereadable(config_path) == 1 then
            cmd = string.format("clang-format -style=file:%s -i %s", 
                               vim.fn.shellescape(config_path), 
                               vim.fn.shellescape(filename))
            print("🔧 Using nvim .clang-format (3 spaces)")
        else
            print("✗ No .clang-format found, using default")
            cmd = string.format("clang-format -i %s", vim.fn.shellescape(filename))
        end
        
        local result = vim.fn.system(cmd)
        
        if vim.v.shell_error == 0 then
            vim.cmd("edit!") -- 重新加载文件
            print("✓ C++ formatted with 3-space indentation")
        else
            print("✗ clang-format error: " .. result)
        end
    else
        print("✗ clang-format not found, install with: brew install clang-format")
    end
end

-- LSP 相关函数已移除，保持轻量配置

return M
