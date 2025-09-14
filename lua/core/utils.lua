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
        vim.notify("✗ Source .clang-format not found at: " .. clang_format_source, vim.log.levels.ERROR)
        return false
    end
    
    -- Check if destination already exists
    if vim.fn.filereadable(clang_format_dest) == 1 then
        local choice = vim.fn.input("'.clang-format' already exists. Overwrite? (y/N): ")
        if choice:lower() ~= "y" and choice:lower() ~= "yes" then
            vim.notify("⚠️ Operation cancelled", vim.log.levels.WARN)
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
        vim.notify("✓ .clang-format copied to project directory", vim.log.levels.INFO)
        vim.notify("📄 Using your custom .clang-format configuration", vim.log.levels.INFO)
        return true
    else
        vim.notify("✗ Failed to copy .clang-format: " .. result, vim.log.levels.ERROR)
        return false
    end
end

-- 新的稳定格式化函数
function M.format_cpp_buffer()
    local bufnr = vim.api.nvim_get_current_buf()
    local filetype = vim.bo[bufnr].filetype
    
    -- 检查文件类型
    if filetype ~= "cpp" and filetype ~= "c" and filetype ~= "h" and filetype ~= "hpp" then
        vim.notify("⚠️ 格式化仅支持 C/C++ 文件 (当前: " .. filetype .. ")", vim.log.levels.WARN)
        return false
    end
    
    -- 检查 clang-format 是否安装
    if vim.fn.executable("clang-format") == 0 then
        vim.notify("✗ clang-format 未安装。请运行: brew install clang-format", vim.log.levels.ERROR)
        return false
    end
    
    -- 获取配置文件路径
    local nvim_config = vim.fn.stdpath("config") .. "/.clang-format"
    local current_dir = vim.fn.getcwd()
    local project_config = current_dir .. "/.clang-format"
    
    -- 确定使用哪个配置文件
    local config_file = nil
    local config_source = ""
    
    -- 优先使用项目目录的配置
    if vim.fn.filereadable(project_config) == 1 then
        config_file = project_config
        config_source = "项目 .clang-format"
    -- 其次使用 nvim 配置目录的配置
    elseif vim.fn.filereadable(nvim_config) == 1 then
        config_file = nvim_config
        config_source = "Neovim .clang-format"
    else
        vim.notify("✗ 未找到 .clang-format 配置文件", vim.log.levels.ERROR)
        vim.notify("提示: 使用 \\scf 复制配置到项目目录", vim.log.levels.INFO)
        return false
    end
    
    -- 保存当前视图状态
    local view = vim.fn.winsaveview()
    
    -- 获取当前缓冲区内容
    local lines = vim.api.nvim_buf_get_lines(bufnr, 0, -1, false)
    local content = table.concat(lines, "\n")
    
    -- 如果内容为空，直接返回
    if content == "" then
        vim.notify("⚠️ 缓冲区为空，无需格式化", vim.log.levels.WARN)
        return false
    end
    
    -- 使用 clang-format 格式化
    -- 明确指定配置文件路径，避免歧义
    local cmd = string.format(
        "clang-format --style=file:%s --assume-filename=%s.cpp",
        vim.fn.shellescape(config_file),
        vim.fn.tempname()
    )
    
    -- 执行格式化
    local formatted = vim.fn.system(cmd, content)
    local exit_code = vim.v.shell_error
    
    -- 检查格式化是否成功
    if exit_code ~= 0 then
        vim.notify("✗ clang-format 执行失败 (错误代码: " .. exit_code .. ")", vim.log.levels.ERROR)
        if formatted and formatted ~= "" then
            vim.notify("错误信息: " .. formatted, vim.log.levels.ERROR)
        end
        return false
    end
    
    -- 检查格式化结果是否为空
    if not formatted or formatted == "" then
        vim.notify("✗ 格式化结果为空", vim.log.levels.ERROR)
        return false
    end
    
    -- 将格式化后的内容分割成行
    local new_lines = {}
    for line in formatted:gmatch("([^\n]*)\n?") do
        if line ~= nil then
            table.insert(new_lines, line)
        end
    end
    
    -- 移除最后的空行（保留一个）
    while #new_lines > 1 and new_lines[#new_lines] == "" do
        table.remove(new_lines)
    end
    
    -- 检查是否有实际变化
    local changed = false
    if #lines ~= #new_lines then
        changed = true
    else
        for i = 1, #lines do
            if lines[i] ~= new_lines[i] then
                changed = true
                break
            end
        end
    end
    
    if not changed then
        vim.notify("✓ 代码已经格式化，无需更改", vim.log.levels.INFO)
        return true
    end
    
    -- 应用格式化后的内容
    vim.api.nvim_buf_set_lines(bufnr, 0, -1, false, new_lines)
    
    -- 恢复视图（光标位置等）
    vim.fn.winrestview(view)
    
    -- 显示成功消息
    vim.notify("✓ 格式化成功 (使用 " .. config_source .. ")", vim.log.levels.INFO)
    
    -- 如果缓冲区之前未修改，标记为已修改
    if not vim.bo[bufnr].modified then
        vim.bo[bufnr].modified = true
    end
    
    return true
end

-- 格式化并保存
function M.format_and_save()
    local success = M.format_cpp_buffer()
    if success then
        vim.cmd('write')
        vim.notify("✓ 格式化并保存成功", vim.log.levels.INFO)
    end
end

-- 显示当前格式化配置信息
function M.show_format_info()
    local nvim_config = vim.fn.stdpath("config") .. "/.clang-format"
    local project_config = vim.fn.getcwd() .. "/.clang-format"
    
    print("=== 格式化配置信息 ===")
    print("")
    
    if vim.fn.filereadable(project_config) == 1 then
        print("✓ 项目配置: " .. project_config)
    else
        print("✗ 项目配置: 未找到")
    end
    
    if vim.fn.filereadable(nvim_config) == 1 then
        print("✓ Neovim 配置: " .. nvim_config)
    else
        print("✗ Neovim 配置: 未找到")
    end
    
    if vim.fn.executable("clang-format") == 1 then
        local version = vim.fn.system("clang-format --version")
        print("✓ clang-format: " .. vim.trim(version))
    else
        print("✗ clang-format: 未安装")
    end
end

return M
