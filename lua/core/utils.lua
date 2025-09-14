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

-- 下载并安装 C++ 头文件 (bits/stdc++.h 和 algo/dbg.h)
function M.download_cpp_headers()
    vim.notify("🔧 开始安装 C++ 调试头文件和万能头文件...", vim.log.levels.INFO)
    
    -- 检查是否在 macOS
    local uname = vim.fn.system("uname -s"):gsub("%s+", "")
    if uname ~= "Darwin" then
        vim.notify("⚠️ 此功能仅支持 macOS", vim.log.levels.WARN)
        return false
    end
    
    -- 目标路径
    local bits_dir = "/usr/local/include/bits"
    local algo_dir = "/usr/local/include/algo"
    local stdcpp_file = bits_dir .. "/stdc++.h"
    local dbg_file = algo_dir .. "/dbg.h"
    
    -- GitHub 原始文件链接 (使用正确的 URL)
    local stdcpp_url = "https://raw.githubusercontent.com/funcdfs/Algorithm/main/Faster/stdc%2B%2B_simplify.h"
    local dbg_url = "https://raw.githubusercontent.com/funcdfs/Algorithm/main/Faster/algo_dbg.h"
    
    -- 创建临时脚本
    local script = string.format([[
#!/bin/bash
set -e

GREEN="\033[0;32m"
RED="\033[0;31m"
RESET="\033[0m"

echo -e "${GREEN}🔧 开始安装 C++ 调试头文件和万能头文件...${RESET}"

# 创建目录
echo "📁 创建目录..."
sudo mkdir -p "%s"
sudo mkdir -p "%s"

# 下载头文件
echo "⬇️ 下载 bits/stdc++.h ..."
sudo curl -fsSL "%s" -o "%s"

echo "⬇️ 下载 algo/dbg.h ..."
sudo curl -fsSL "%s" -o "%s"

# 检查内容是否成功获取
if [[ -s "%s" && -s "%s" ]]; then
    echo -e "${GREEN}✅ 安装成功！${RESET}"
    echo -e "${GREEN}📄 bits/stdc++.h -> %s${RESET}"
    echo -e "${GREEN}📄 algo/dbg.h -> %s${RESET}"
    echo ""
    echo "现在可以使用："
    echo "  #include <bits/stdc++.h>  // 万能头文件"
    echo "  #include <algo/dbg.h>     // 调试专用头文件"
    echo ""
    echo "按任意键退出..."
    read -n 1
else
    echo -e "${RED}❌ 下载失败，可能是网络或路径问题。${RESET}"
    echo "按任意键退出..."
    read -n 1
    exit 1
fi
]], bits_dir, algo_dir, stdcpp_url, stdcpp_file, dbg_url, dbg_file, stdcpp_file, dbg_file, stdcpp_file, dbg_file)
    
    -- 写入临时脚本文件
    local temp_script = vim.fn.tempname() .. "_install_cpp_headers.sh"
    vim.fn.writefile(vim.split(script, "\n"), temp_script)
    vim.fn.system("chmod +x " .. vim.fn.shellescape(temp_script))
    
    -- 在终端分屏中执行
    vim.cmd("split | terminal " .. vim.fn.shellescape(temp_script))
    
    -- 注册自动命令删除临时文件
    vim.api.nvim_create_autocmd("TermClose", {
        pattern = temp_script,
        once = true,
        callback = function()
            vim.fn.delete(temp_script)
            -- 检查安装结果
            if vim.fn.filereadable(stdcpp_file) == 1 and vim.fn.filereadable(dbg_file) == 1 then
                vim.notify("✅ C++ 头文件安装成功！", vim.log.levels.INFO)
            end
        end
    })
    
    return true
end

-- 检查 C++ 头文件状态
function M.check_cpp_headers()
    local stdcpp_file = "/usr/local/include/bits/stdc++.h"
    local dbg_file = "/usr/local/include/algo/dbg.h"
    
    print("=== C++ 头文件状态 ===")
    print("")
    
    if vim.fn.filereadable(stdcpp_file) == 1 then
        print("✓ bits/stdc++.h: 已安装")
        local size = vim.fn.getfsize(stdcpp_file)
        print("  文件大小: " .. size .. " bytes")
    else
        print("✗ bits/stdc++.h: 未安装")
        print("  使用 \\dh 安装")
    end
    
    if vim.fn.filereadable(dbg_file) == 1 then
        print("✓ algo/dbg.h: 已安装")
        local size = vim.fn.getfsize(dbg_file)
        print("  文件大小: " .. size .. " bytes")
    else
        print("✗ algo/dbg.h: 未安装")
        print("  使用 \\dh 安装")
    end
    print("")
end

return M
