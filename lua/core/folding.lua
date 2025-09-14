-- ============================================================================
-- 代码折叠功能配置
-- ============================================================================

local M = {}

-- 创建折叠标记（用于竞赛编程模板）
function M.create_fold_markers()
    -- 为 C++ 文件设置折叠标记
    vim.opt_local.foldmethod = "marker"
    vim.opt_local.foldmarker = "#pragma region,#pragma endregion"
    vim.opt_local.foldlevel = 0  -- 默认折叠 pragma region 块
end

-- 自动折叠 headers_and_definitions 区域
function M.auto_fold_headers()
    local bufnr = vim.api.nvim_get_current_buf()
    local lines = vim.api.nvim_buf_get_lines(bufnr, 0, -1, false)
    
    -- 查找 #pragma region headers_and_definitions
    for i, line in ipairs(lines) do
        if line:match("#pragma region headers_and_definitions") then
            -- 折叠这个区域
            vim.cmd(string.format("normal! %dGzc", i))
            break
        end
    end
end

-- 在 snippet 展开后自动折叠特定区域
function M.fold_after_snippet_expand()
    -- 延迟执行，确保 snippet 已经完全展开
    vim.defer_fn(function()
        local bufnr = vim.api.nvim_get_current_buf()
        local lines = vim.api.nvim_buf_get_lines(bufnr, 0, -1, false)
        
        -- 查找并折叠 headers_and_definitions 区域
        local start_line = nil
        local end_line = nil
        
        for i, line in ipairs(lines) do
            if line:match("#pragma region headers_and_definitions") then
                start_line = i
            elseif line:match("#pragma endregion headers_and_definitions") then
                end_line = i
                break
            end
        end
        
        if start_line and end_line then
            -- 移动到起始行并折叠
            vim.api.nvim_win_set_cursor(0, {start_line, 0})
            vim.cmd("normal! zc")
            
            -- 移动光标到 solve 函数内部
            for i = end_line, #lines do
                if lines[i]:match("void solve%(") or lines[i]:match("auto solve%(") then
                    -- 找到 solve 函数后，定位到函数内部
                    for j = i + 1, #lines do
                        if lines[j]:match("^%s*$") or lines[j]:match("^%s+%$0") then
                            vim.api.nvim_win_set_cursor(0, {j, 0})
                            break
                        end
                    end
                    break
                end
            end
        end
    end, 100) -- 延迟 100ms 执行
end

-- 设置 C++ 文件的折叠方法
function M.setup_cpp_folding()
    vim.api.nvim_create_autocmd("FileType", {
        pattern = { "cpp", "c" },
        callback = function()
            -- 使用 marker 折叠方法（支持 #pragma region）
            vim.opt_local.foldmethod = "marker"
            vim.opt_local.foldmarker = "#pragma region,#pragma endregion"
            vim.opt_local.foldlevel = 99  -- 默认展开所有
            
            -- 但对于 headers_and_definitions 区域，默认折叠
            vim.defer_fn(M.auto_fold_headers, 50)
        end,
        desc = "Setup C++ folding"
    })
end

-- 集成到 LuaSnip，当展开特定 snippet 时自动折叠
function M.integrate_with_luasnip()
    local ok, luasnip = pcall(require, "luasnip")
    if not ok then return end
    
    -- 监听 snippet 展开事件
    luasnip.config.setup({
        ext_opts = {
            [require("luasnip.util.types").choiceNode] = {
                active = {
                    virt_text = {{"●", "LuasnipChoice"}}
                }
            }
        },
        -- 在展开后执行回调
        snip_env = {
            post_expand = function(snippet, event_args)
                -- 检查是否是竞赛编程模板
                local trigger = snippet.trigger
                if trigger == "cp" or trigger == "tt" or trigger == "ttna" or 
                   trigger == "cps" or trigger == "old_cp" or trigger == "old_tt" then
                    M.fold_after_snippet_expand()
                end
            end
        }
    })
end

-- 初始化折叠功能
function M.setup()
    M.setup_cpp_folding()
    
    -- 延迟集成 LuaSnip（确保它已经加载）
    vim.defer_fn(function()
        M.integrate_with_luasnip()
    end, 500)
end

return M