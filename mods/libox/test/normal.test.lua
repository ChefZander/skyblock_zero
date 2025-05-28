libox.test.describe("Normal sandbox (tests the environment, mostly)", function(it)
    it("Doesn't do bytecode", function(assert)
        -- mod security prevents it anyway
        assert(not libox.normal_sandbox({
            code = string.dump(assert),
            env = {},
            in_hook = function() end,
        }))
    end)
    it("Limits time", function(assert)
        assert(not libox.normal_sandbox({
            code = "repeat until false ",
            env = {},
            max_time = 1000
        }))
    end)
    it("Handles pcall correctly", function(assert)
        assert(not libox.normal_sandbox({
            code = "pcall(function() repeat until false end)",
            env = libox.create_basic_environment(),
            max_time = 1000
        }))
    end)
    it("Handles xpcall correctly", function(assert)
        assert(not libox.normal_sandbox({
            code = "xpcall(function() error('yeh') end,function() repeat until false end)",
            env = libox.create_basic_environment(),
            max_time = 1000
        }))
    end)
    it("Isn't vurnable to severe trollery", function(_, _, bad, custom)
        local t1 = minetest.get_us_time()
        local ok, err = libox.normal_sandbox({
            code = [[
                local x = "."
                repeat
                    x = x .. x
                until false
            ]],
            env = {},
            max_time = 10000, -- 10 milis for this
        })
        local t2 = minetest.get_us_time()
        if ok then
            bad()
        else
            custom("took " .. (t2 - t1) .. "us, sandbox was given 10 000 us, for debug: the error was: " .. dump(err))
        end
    end)
    it("Can loadstring", function(assert)
        assert(libox.normal_sandbox({
            code = [[
                assert(
                    loadstring(
                        "return 'hi'"
                    )
                )
                ]],
            env = libox.create_basic_environment(),
            max_time = 1000,
        }))
    end)
    it("Can loadstring securely", function(assert)
        assert(not libox.normal_sandbox({
            code = [[
                loadstring('assert(debug)')()
                -- we don't use minetest as an example
                -- because libox.create_basic_environment already creates a global with that name
            ]],
            env = libox.create_basic_environment(),
            max_time = 1000,
        }))
    end)
    it("Can handle weird recursive shenanigans (that mostly exploit traceback)", function(_, _, bad, custom)
        --[[
            This attempts to abuse libox.traceback to create a gigantic
            error message and force several executions of debug.getinfo

            (Now fixed, the limit is 20 debug.getinfo's before just stopping)
        ]]
        local code = [[
            pcall(loadstring(code)())
        ]]
        local env = libox.create_basic_environment()
        env.code = code

        local t1 = minetest.get_us_time()
        local ok, _ = libox.normal_sandbox({
            code = code,
            env = env,
            max_time = 10000
        })
        local t2 = minetest.get_us_time()
        if ok then
            bad()
        else
            custom("took: " .. (t2 - t1) .. "us, sandbox was given 10 000 us")
        end
    end)
    it("Can't abuse string.rep", function(assert, _, _, _)
        assert(not libox.normal_sandbox({
            code = "string.rep('a',9999999)",
            env = libox.create_basic_environment(),
            max_time = 10000,
        }))
    end)
    it("Can limit string length on functions that probably need it", function(assert)
        assert(not libox.normal_sandbox({
            code = [[
                local str = string.rep(":",64000)
                str = str .. str
                minetest.urlencode(str)
            ]],
            max_time = 10000,
            env = libox.create_basic_environment()
        }))
    end)

    it("Can check types (basic)", function(assert)
        local type_string = function(x) return type(x) == "string" end
        local result1 = libox.type_check({
            a = "lol",
            b = {
                c = "lol"
            }
        }, {
            a = type_string,
            b = {
                c = type_string
            }
        }) == true

        local result2 = libox.type_check({
            a = "lol",
            b = {
                c = "lol",
                d = "funny (i am not supposed to be here)",
            }
        }, {
            a = type_string,
            b = {
                c = type_string
            }
        }) == false

        local result3 = libox.type_check({
            a = "fine",
            b = "fine also",
            c = ItemStack(""), -- not fine
            d = {}
        }, {
            a = type_string,
            b = type_string,
            c = type_string,
            d = type_string,
        }) == false

        local result4 = libox.type_check("moo", type_string) == true
        local result5 = libox.type_check("b", {
            a = type_string
        }) == false

        local result7 = not libox.type_check({
            a = "b",
        }, {
            a = type_string,
            b = type_string,
            c = {
                a = type_string,
                b = type_string,
            }
        })

        local result6 = libox.type_check({
            a = ItemStack("")
        }, {
            a = type_string,
        }) == false

        assert(result1 and result2 and result3 and result4 and result5 and result6 and result7)
    end)
    it("Can check types (recursive)", function(assert)
        local table = {
            f = function() end
        }
        table["k"] = table
        assert(not libox.type_check(table, {
            f = function(x) return type(x) == "function" end,
            k = {
                x = function(_) return "lol" end
            }
        }))
    end)

    it("Userdata propertly type checked - PerlinNoise", function(assert)
        local perlin = libox.safe.PerlinNoise
        debug.sethook(function() end, "", 1000) -- make it so sandbox_lib_f wont get mad
        local result1 = perlin({
            offset = 0,
            scale = 1,
            spread = { x = 384, y = 192, z = 384 },
            seed = 5900033,
            octaves = 5,
            persist = 0.63,
            lacunarity = 2.0,
            --flags = ""
        }) ~= false
        local result2 = perlin({}) == false
        local result3 = perlin({
            offset = 0,
            scale = 1,
            spread = { x = 384, y = 192, z = 384 },
            seed = 5900033,
            octaves = 50,
            persist = 0.63,
            lacunarity = 50.0,
            --flags = ""
        }) ~= false
        --[[
            So, about octaves/lacunarity
            when i make those values huge, nothing really seems to happen other than timeout
            i think its fine tbh
        ]]
        debug.sethook()
        assert(result1 and result2 and result3)
    end)
end)
