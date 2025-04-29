local active_sandboxes = {}
local api = {}


api.settings = {
    memory_treshold = 5,
    gc = {
        time_treshold = 10 * 60, -- if a sandbox has been untouched then collect it
        number_of_sandboxes = 60,
        auto = false,
        interval = 60
    }
}

local settings = minetest.settings

local function setting(v, thing)
    local t = type(v)
    local number = function(n) return n end -- noop
    if t == "number" then
        number = tonumber
    end

    if t ~= "boolean" then
        return number(settings:get(thing))
    else
        return settings:get_bool(thing)
    end
end

local function do_the_settings_thing(name, table)
    for k, v in pairs(table) do
        if type(v) == "table" then
            do_the_settings_thing(name .. "." .. k, v)
        else
            table[k] = setting(v, name .. "." .. k) or v
        end
    end
end

do_the_settings_thing("libox", api.settings)

local BYTE_A, BYTE_Z = string.byte("A"), string.byte("Z")
local function rand_text(n)
    local out = ""
    for _ = 1, n do
        out = out .. string.char(math.random(BYTE_A, BYTE_Z)) -- [A-Z]
    end
    return out
end



function api.create_sandbox(def)
    local ID = def.ID or rand_text(10)
    active_sandboxes[ID] = {
        code = def.code,
        is_garbage_collected = def.is_garbage_collected or true,
        env = def.env or {},
        in_hook = def.in_hook or libox.coroutine.get_default_hook(def.time_limit or 3000),
        function_wrap = def.function_wrap or function(f) return f end,
        last_ran = os.clock(),                         -- for gc and logging
        hook_time = def.hook_time or libox.default_hook_time,
        size_limit = def.size_limit or 1024 * 1024 * 5 -- 5 megabytes
    }
    return ID
end

function api.create_thread(sandbox)
    -- prohibited by mod security anyway, basically bytecode is fancy stuff that allows rce and we dont want that
    if sandbox.code:byte(1) == 27 then
        return false, "Bytecode was not allowed."
        -- *mod security would prevent it anyway* but just in case someone turned that off
    end

    local f, msg = loadstring(sandbox.code)
    if not f then
        return false, msg
    end


    setfenv(f, sandbox.env)

    if rawget(_G, "jit") then
        jit.off(f, true)
        -- turn jit off for that function and yes this is needed or the user can repeat until false, sorry
    end

    f = sandbox.function_wrap(f)
    sandbox.thread = coroutine.create(f)
    return true
end

function api.is_sandbox_dead(id)
    local sandbox = active_sandboxes[id]
    if sandbox == nil then return true end
    if sandbox.thread == nil then return false end -- api.run_sandbox will work just fine
    if coroutine.status(sandbox.thread) == "dead" then return true end
    return false
end

function api.locals(val, f_thread)
    local ret = {
        _F = "", -- the function itself, weighed and put using string.dump, if thread this is ignored
        _L = {}, -- Locals
        _U = {}  -- Upvalues
    }

    local getinfo, getlocal, getupvalue = debug.getinfo, debug.getlocal, debug.getupvalue

    local index
    if type(val) == "thread" then
        local level = getinfo(val, 1, "u")
        if level ~= nil then
            index = 1
            while true do
                local k, v = getlocal(val, 1, index)
                if k ~= nil then
                    ret._L[k] = v
                else
                    break
                end
                index = index + 1
            end

            if level.nups > 0 then
                index = 1
                local f = getinfo(val, 1, "f").func
                while true do
                    local k, v = getupvalue(f, index)
                    if k ~= nil then
                        ret._U[k] = v
                    else
                        break
                    end
                    index = index + 1
                end
            end
        end
    elseif type(val) == "function" then
        local func_info = getinfo(f_thread, val, "Su")
        if not func_info or func_info.what == "C" then
            -- C functions are not weighed because... well... they can't be
            return {}
        end
        local f_size = string.dump(val)
        ret._F = f_size
        index = 1
        while true do
            local k, v = getlocal(val, index)
            if k ~= nil then
                ret._L[k] = v
            else
                break
            end
            index = index + 1
        end
        if func_info.nups > 0 then
            index = 1
            while true do
                local k, v = getupvalue(val, index)
                if k ~= nil then
                    ret._U[k] = v
                else
                    break
                end
                index = index + 1
            end
        end
    end
    return ret
end

function api.get_size(env, seen, thread, recursed)
    local deferred_weigh_locals = {}
    if not recursed then
        deferred_weigh_locals[#deferred_weigh_locals + 1] = thread
    end

    local function internal(x, seen) -- luacheck: ignore
        local t = type(x)
        if t == "string" then
            return #x + 25
        elseif t == "number" then
            return 8
        elseif t == "boolean" then
            return 1
        elseif t == "table" and not seen[x] then
            local cost = 8
            seen[x] = true
            for k, v in pairs(x) do
                local k_cost = internal(k, seen)
                local v_cost = internal(v, seen)
                cost = cost + k_cost + v_cost
            end
            return cost
        elseif t == "function" and not seen[x] then
            -- oh the fun!
            seen[x] = true
            deferred_weigh_locals[#deferred_weigh_locals + 1] = x
            return 0 -- deffered
        elseif t == "thread" and not seen[x] then
            seen[x] = true
            deferred_weigh_locals[#deferred_weigh_locals + 1] = x
            return 0 -- deffered
        else
            return 0
        end
    end

    local retv = internal(env, seen)
    if debug.getlocal ~= nil and debug.getupvalue ~= nil then
        for i = 1, #deferred_weigh_locals do
            local v = deferred_weigh_locals[i]
            if not seen[v] then
                local their_locals = api.locals(v, thread)

                local size = api.get_size(their_locals, seen, thread, true)
                retv = retv + size
            end
        end
    end

    return retv
end

function api.size_check(env, lim, thread)
    if thread == nil then error("Thread is nil! you can't check the size!") end
    local size = api.get_size(env, {}, thread, false)
    return size < lim
end

function api.get_default_hook(max_time)
    return function()
        local time = minetest.get_us_time

        local start_time = time()
        return function()
            if time() - start_time > max_time then
                debug.sethook()
                error("Code timed out! Reason: Time limit exceeded, the limit:" ..
                    tostring(max_time / 1000) .. "ms, the program took:" .. ((time() - start_time) / 1000), 2)
            end
        end
    end
end

function api.run_sandbox(ID, value_passed)
    if libox.disabled then
        return false, "Libox is disabled. Please wait until the server admins re-enable it."
    end

    local sandbox = active_sandboxes[ID]
    if sandbox == nil then
        return false, "Sandbox not found. (Garbage collected?)"
    end

    sandbox.last_ran = os.clock()

    if sandbox.thread == nil then
        local ok, errmsg = api.create_thread(sandbox)
        if ok == false then
            return false, errmsg
        end
    end

    local thread = sandbox.thread
    if coroutine.status(thread) == "dead" then
        return false, "The coroutine is dead, nothing to do."
    end


    local ok, errmsg_or_value
    local pcall_ok, pcall_errmsg
    -- "nested pcall just in case" i knowww its bad and it sounds bad but yeah i had crashes when there wasnt a pcall adn yeaah
    local no_strange_bug_happened = pcall(function()
        pcall_ok, pcall_errmsg = pcall(function()
            debug.sethook(sandbox.in_hook(), "", sandbox.hook_time or libox.default_hook_time)
            getmetatable("").__index = sandbox.env.string
            ok, errmsg_or_value = coroutine.resume(thread, value_passed)
            debug.sethook()
        end)
        debug.sethook()
        getmetatable("").__index = string
    end)
    debug.sethook()
    getmetatable("").__index = string

    if not no_strange_bug_happened then
        return false, "Strange bug happened, but yes - the sandbox timed out."
    end

    local size_check = api.size_check(sandbox.env, sandbox.size_limit, thread)
    if not size_check then return false, "Out of memory!" end

    if not pcall_ok then
        return false, pcall_errmsg
    end

    if not ok then
        return false, errmsg_or_value
    else
        return true, errmsg_or_value
    end
end

function api.garbage_collect()
    local number_of_sandboxes = 0
    local to_be_collected = {}
    local current_time = os.clock()

    for k, v in pairs(active_sandboxes) do
        if v.is_garbage_collected then
            number_of_sandboxes = number_of_sandboxes + 1

            local difftime = current_time - v.last_ran
            if difftime > api.settings.gc.time_treshold then
                to_be_collected[#to_be_collected + 1] = k
            end
        end
    end

    if number_of_sandboxes < api.settings.gc.number_of_sandboxes then return false end
    for i = 1, #to_be_collected do
        active_sandboxes[to_be_collected[i]] = nil
    end

    return #to_be_collected
end

-- export
api.active_sandboxes = active_sandboxes
libox.coroutine = api

local function start_timer()
    minetest.after(api.settings.gc.interval, function()
        api.garbage_collect()
        start_timer()
    end)
end
if api.settings.gc.auto then
    start_timer()
end
