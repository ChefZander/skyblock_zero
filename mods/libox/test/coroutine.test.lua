libox.test.describe("coroutine sandbox", function(it)
    it("Can yield", function(assert)
        local sandbox = libox.coroutine.create_sandbox({
            code = [[
local count = 0
repeat
    count = count+1
    coroutine.yield(count)
until false
]],
            env = {
                coroutine = {
                    yield = coroutine.yield
                }
            },
        })

        local values = {
            select(2, libox.coroutine.run_sandbox(sandbox)), -- 1
            select(2, libox.coroutine.run_sandbox(sandbox)), -- 2
            select(2, libox.coroutine.run_sandbox(sandbox)), -- 3
            select(2, libox.coroutine.run_sandbox(sandbox)), -- 4
        }

        local succ = (values[1] == 1) and (values[2] == 2)
            and (values[3] == 3) and (values[4] == 4)
        if not succ then
            minetest.debug(dump(values))
        end
        assert(succ)
    end)

    it("Limits time", function(assert)
        local sandbox = libox.coroutine.create_sandbox({
            code = "repeat until false",
            env = {},
        })
        local ok = libox.coroutine.run_sandbox(sandbox)
        assert(not ok)
    end)

    it("Limits environment size", function(assert)
        local sandbox = libox.coroutine.create_sandbox({
            code = "a = string.rep('a',1000); coroutine.yield()",
            env = {
                string = {
                    rep = string.rep,
                    -- Never let the user get arbitrary string.rep, or the user can create terabytes of strings...
                    -- we are giving it to the user here for testing
                },
            },
            size_limit = 1000

        })
        local _, errmsg = libox.coroutine.run_sandbox(sandbox)
        assert(errmsg == "Out of memory!")
    end)

    it("Limits circular references", function(_, success)
        local env = {}
        env._G = env
        env.f = function()
            --local a = env._G
            return env._G
        end
        local sandbox = libox.coroutine.create_sandbox({
            code = [[
            local e = _G -- Hehe i am an unsuspecting user and i am sure this won't be a mistake
            coroutine.yield()
        ]],
            -- When having _G as the environment
            -- it simply stack overflows? this is like... bad... yeah
            -- old comment, i fixed that actually, see down
            env = env,
            size_limit = 1000,
            time_limit = 1000000 -- 1 million microseconds, can you imagine that (that's definitely not 1 second)

        })

        libox.coroutine.run_sandbox(sandbox)
        success()
    end)

    it("Limits local variables", function(assert)
        --[[
        IMPORTANT: This fails when there is no access to debug.getlocal
        ]]

        local sandbox = libox.coroutine.create_sandbox({
            code = "local a = string.rep('a',1000); coroutine.yield(); coroutine.yield()",
            env = {
                string = {
                    rep = string.rep,
                },
                coroutine = {
                    yield = coroutine.yield
                },
            },
            size_limit = 1000,
            time_limit = 1000000,

        })
        local _, errmsg = libox.coroutine.run_sandbox(sandbox)
        assert(errmsg == "Out of memory!")
    end)

    it("Really limits local variables...", function(assert)
        --[[
            This fails when there is no access to debug.getlocal
        ]]

        local sandbox = libox.coroutine.create_sandbox({
            code = [[
        function evil()
            local a = string.rep('a',1000)
            coroutine.yield();
        end
        evil();
        coroutine.yield();
        coroutine.yield()
        ]],
            env = {
                string = {
                    rep = string.rep,
                },
                coroutine = {
                    yield = coroutine.yield
                },
            },
            size_limit = 1000,
            time_limit = 1000000

        })
        local _, errmsg = libox.coroutine.run_sandbox(sandbox)
        assert(errmsg == "Out of memory!")
    end)

    it("Limits upvalues", function(assert)
        --[[
        this fails when we cant look up upvalues
    ]]
        local sandbox = libox.coroutine.create_sandbox({
            code = [[
            function get_evil()
                local evil = string.rep('a', 60000000)
                return function()
                    return evil
                end
            end
            local evil = get_evil()
            coroutine.yield()
        ]],
            env = {
                string = {
                    rep = string.rep,
                },
                coroutine = {
                    yield = coroutine.yield
                },
            },
            size_limit = 1000,
            time_limit = 1000000

        })
        local _, errmsg = libox.coroutine.run_sandbox(sandbox)
        assert(errmsg == "Out of memory!")
    end)

    it(
        "Weighing _G",
        function(_, _, _, custom)
            local env = libox.create_basic_environment()
            libox.coroutine.get_size(env, {}, coroutine.create(function() end))
            -- JIT it up a little, idk man

            local sandbox = libox.coroutine.create_sandbox({
                code = [[
            local e = _G
            coroutine.yield()
        ]],
                -- yeah, it used to stack overflow but now with a minor rewrite it doesn't
                env = _G,
                size_limit = 1000,
                time_limit = 1000000
            })

            local t1 = minetest.get_us_time()
            libox.coroutine.run_sandbox(sandbox)
            local sandboxd = libox.coroutine.active_sandboxes[sandbox]
            custom("time:" ..
                (minetest.get_us_time() - t1) / 1000 .. "ms" ..
                " size:" .. libox.coroutine.get_size(sandboxd.env, {}, sandboxd.thread)
                ..
                " digiline sanitize thinks:" ..
                ({ libox.digiline_sanitize(env, true) })[2] .. " lua gc thinks: " .. collectgarbage("count") * 1024
            )
        end)
    it("Can detect if sandbox is dead", function(assert)
        local sandbox = libox.coroutine.create_sandbox({
            code = "return",
            env = {},
            size_limit = 1000,
            time_limit = 1000
        })
        libox.coroutine.run_sandbox(sandbox)
        assert(libox.coroutine.is_sandbox_dead(sandbox))
    end)
    it("Can collect garbage", function(_, _, _, custom)
        local sandboxes = {}
        local num = 50
        local activation_treshold = 10
        local env = libox.create_basic_environment()
        local fake_time_treshold = 50

        local response = "\n"

        response = response ..
            "Size of environment: "
            .. libox.coroutine.get_size(env, {}, coroutine.create(function() end), false) .. "\n"
        response = response .. "Number of sandboxes that will get created:" .. num .. "\n"
        response = response .. "Activation treshold (number of sandboxes):" .. activation_treshold .. "\n"
        response = response .. "Activation treshold (time, faked):" .. fake_time_treshold .. "s \n"

        local active = libox.coroutine.active_sandboxes

        local function map_bool(n)
            if n == 1 then return true else return false end
        end
        local function funny_if(c, t, f)
            if c then return t else return f end
        end

        for i = 1, num do
            sandboxes[i] = libox.coroutine.create_sandbox({
                code = "coroutine.yield()",
                env = env,
                size_limit = 10000,
                time_limit = 10000,
                is_garbage_collected = map_bool(math.random(0, 1))
            })

            local actual_sandbox = active[sandboxes[i]]
            actual_sandbox.last_ran = funny_if(math.random() < 0.5, 0, os.clock())
        end


        local function dumbcount(t)
            local count = 0
            for _ in pairs(t) do count = count + 1 end
            return count
        end

        response = response .. "number of sandboxes currently: " .. dumbcount(active) .. "\n"

        local original_settings = table.copy(libox.coroutine.settings)

        libox.coroutine.settings.gc.time_treshold = fake_time_treshold
        libox.coroutine.settings.gc.number_of_sandboxes = activation_treshold

        libox.coroutine.garbage_collect()

        libox.coroutine.settings = original_settings

        response = response ..
            "number of sandboxes after collection (it should remain high because their 'state' is random): " ..
            dumbcount(active) .. "\n"


        libox.coroutine.active_sandboxes = {}
        response = response .. "Cleared the mess"
        custom(response)
    end)
end, true)
