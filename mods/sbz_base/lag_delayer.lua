-- soo i saw https://github.com/HybridDog/function_delayer/blob/master/init.lua
-- i thought it would help the server be more stable when theres like 500 tnt exploding at once
-- but i guess not
-- so im making my own

local laggy = 1
local globalsteps_per_second = 5
laggy = laggy / globalsteps_per_second

local tasks = {}
sbz_api.delay_if_laggy = function(f)
    tasks[#tasks + 1] = f
end


core.register_globalstep(function(dtime)
    if dtime < laggy then
        local lag = 0 -- seconds
        while (lag + dtime) < laggy and #tasks > 0 do
            local t0 = os.clock()
            local task = table.remove(tasks)
            task()
            lag = lag + (os.clock() - t0)
        end
    else
        -- only execute one task... i know laggy
        local task = table.remove(tasks)
        if task ~= nil then
            task()
        end
    end
end)

-- boom! much simpler than function delayer
