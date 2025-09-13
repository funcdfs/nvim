-- 测试诊断配置的文件
local test_var = "hello"

-- 故意的错误，用于测试诊断显示
local undefined_variable = some_undefined_var

function test_function()
    -- 另一个可能的错误
    return undefined_variable + 1
end