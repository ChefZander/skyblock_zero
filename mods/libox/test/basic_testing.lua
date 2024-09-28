-- this is a very crappy testing framework i came up with
-- combine the best of mtt and mineunit i guess (mtt is able to test weird async easily, i love it)
-- with some terrible code of course
local api = {}
local tests = {}



local function core(test)
    local function get_success(name)
        return function() minetest.log(name .. " : success") end
    end
    local function get_failure(name)
        return function() minetest.log(name .. " : failure") end
    end
    local function get_custom(name)
        return function(str) minetest.log(name .. " : " .. str) end
    end

    local function get_assert(name)
        return function(cond)
            if cond then
                get_success(name)()
            else
                get_failure(name)()
            end
        end
    end

    test[2](get_assert(test[1]), get_success(test[1]), get_failure(test[1]), get_custom(test[1]))
end

function api.run_known_test(test)
    if not test.ignore_async then
        minetest.handle_async(core, function() end, test)
    end
    core(test)
end

function api.run_test(name, name2)
    local category = tests[name]

    local test
    for _, v in ipairs(category) do
        if v[1] == name2 then
            test = name2
            break
        end
    end
    assert(test, "Test not found")
    api.run_known_test(test)
end

function api.run_category(name)
    local category = tests[name]

    assert(category, "Category not found")
    for _, v in ipairs(category) do
        api.run_known_test(v)
    end
end

function api.run_tests()
    for k, _ in pairs(tests) do
        minetest.log("========" .. k .. "========")
        api.run_category(k)
    end
end

function api.get_it(name, ignore_async)                                           -- create test
    return function(name2, f)
        tests[name][#tests[name] + 1] = { name2, f, ignore_async = ignore_async } -- preserve order
    end
end

function api.describe(name, f, ignore_async) -- create category
    tests[name] = {}
    f(api.get_it(name, ignore_async))
end

libox.test = api
