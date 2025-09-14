-- ============================================================================
-- nvim-cmp 补全配置（重新设计）
-- ============================================================================
-- 优化的补全配置，确保 buffer text 和 snippets 正常工作

-- 加载插件
local cmp_ok, cmp = pcall(require, "cmp")
if not cmp_ok then return end

local luasnip_ok, luasnip = pcall(require, "luasnip")
if not luasnip_ok then luasnip = nil end

-- LSP 相关依赖已移除，保持轻量配置

-- ============================================================================
-- 补全配置
-- ============================================================================

cmp.setup({
    -- 代码片段展开配置
    snippet = {
        expand = function(args)
            if luasnip then
                luasnip.lsp_expand(args.body)
            else
                -- 如果 LuaSnip 不可用，使用 vim 内置 snippet
                vim.fn["vsnip#anonymous"](args.body)
            end
        end,
    },
    
    -- 窗口外观
    window = {
        completion = {
            border = "rounded",
            winhighlight = "Normal:Pmenu,FloatBorder:Pmenu,Search:None",
            col_offset = -3,
            side_padding = 0,
        },
        documentation = {
            border = "rounded",
            winhighlight = "Normal:Pmenu,FloatBorder:Pmenu,Search:None",
        },
    },
    
    -- 实验性功能
    experimental = {
        ghost_text = true, -- 显示 ghost text
    },
    
    -- 键位映射（修改为 VSCode 风格）
    mapping = cmp.mapping.preset.insert({
        -- 使用上下箭头选择补全项（像 VSCode）
        ["<Up>"] = cmp.mapping.select_prev_item({ behavior = cmp.SelectBehavior.Insert }),
        ["<Down>"] = cmp.mapping.select_next_item({ behavior = cmp.SelectBehavior.Insert }),
        
        -- 保留 Ctrl+j/k 作为备选
        ["<C-k>"] = cmp.mapping.select_prev_item({ behavior = cmp.SelectBehavior.Insert }),
        ["<C-j>"] = cmp.mapping.select_next_item({ behavior = cmp.SelectBehavior.Insert }),
        
        -- 文档滚动
        ["<C-b>"] = cmp.mapping.scroll_docs(-4),
        ["<C-f>"] = cmp.mapping.scroll_docs(4),
        
        -- 补全控制
        ["<C-Space>"] = cmp.mapping.complete(),
        ["<C-e>"] = cmp.mapping.abort(),
        
        -- 确认选择
        ["<CR>"] = cmp.mapping.confirm({
            behavior = cmp.ConfirmBehavior.Replace,
            select = true,
        }),
        
        -- Tab 专用于 snippet placeholder 跳转（不用于补全选择）
        ["<Tab>"] = cmp.mapping(function(fallback)
            if luasnip and luasnip.expand_or_locally_jumpable() then
                luasnip.expand_or_jump()
            else
                fallback()
            end
        end, { "i", "s" }),
        
        ["<S-Tab>"] = cmp.mapping(function(fallback)
            if luasnip and luasnip.locally_jumpable(-1) then
                luasnip.jump(-1)
            else
                fallback()
            end
        end, { "i", "s" }),
    }),
    
    -- 补全源配置（按优先级排序）
    sources = cmp.config.sources({
        -- 高优先级源
        { 
            name = "luasnip", 
            priority = 1000,
            option = { 
                show_autosnippets = true,
                use_show_condition = false 
            } 
        },
        { 
            name = "buffer", 
            priority = 750,
            option = {
                get_bufnrs = function()
                    -- 从所有可见缓冲区获取关键字
                    local bufs = {}
                    for _, win in ipairs(vim.api.nvim_list_wins()) do
                        bufs[vim.api.nvim_win_get_buf(win)] = true
                    end
                    return vim.tbl_keys(bufs)
                end,
                keyword_length = 2, -- 最少 2 个字符才触发
            },
        },
    }),
    
    -- 简化格式化配置（移除 LSP 依赖）
    formatting = {
        fields = { "abbr", "kind", "menu" },
        format = function(entry, vim_item)
            -- 简单的补全源标识
            local menu_map = {
                buffer = "[Buffer]",
                luasnip = "[Snippet]",
                path = "[Path]",
                cmdline = "[CMD]",
            }
            
            vim_item.menu = menu_map[entry.source.name] or string.format("[%s]", entry.source.name)
            
            -- 简单的 kind 显示
            vim_item.kind = vim_item.kind or "Text"
            
            return vim_item
        end,
    },
    
    -- 补全行为配置
    completion = {
        completeopt = "menu,menuone,noinsert",
        keyword_length = 1, -- 1 个字符开始补全
    },
    
    -- 确认行为
    confirm_opts = {
        behavior = cmp.ConfirmBehavior.Replace,
        select = false,
    },
    
    -- 性能优化（平衡响应速度和性能）
    performance = {
        debounce = 100,        -- 减少延迟到 100ms，提高响应速度
        throttle = 30,         -- 节流 30ms
        fetching_timeout = 500,
        confirm_resolve_timeout = 80,
        async_budget = 1,
        max_view_entries = 50,  -- 减少最大显示条目提高性能
    },
})

-- ============================================================================
-- 命令行补全
-- ============================================================================

-- `/` cmdline 补全
if cmp_ok then
    cmp.setup.cmdline('/', {
        mapping = cmp.mapping.preset.cmdline(),
        sources = {
            { name = 'buffer' }
        }
    })
    
    -- `:` cmdline 补全
    cmp.setup.cmdline(':', {
        mapping = cmp.mapping.preset.cmdline(),
        sources = cmp.config.sources({
            { name = 'path' }
        }, {
            { 
                name = 'cmdline',
                option = {
                    ignore_cmds = { 'Man', '!' }
                }
            }
        })
    })
end
