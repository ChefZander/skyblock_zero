local BYTECODE_CHAR = 27




local function wrap(f, obj)
    return function(...)
        return f(obj, ...)
    end
end

function libox.safe.rep(str, n)
    if #str * n > 64000 then
        error("string length overflow", 2)
    end
    return string.rep(str, n)
end

function libox.safe.PcgRandom(seed, seq)
    if seq and #seq > 1000 then error("Sequence too large, size limit is 1000", 2) end
    local pcg = PcgRandom(seed, seq)

    -- now make the interface
    local interface = {
        next = wrap(pcg.next, pcg),
        rand_normal_dist = function(min, max, num_trials)
            if num_trials and num_trials > 50 then
                error("too many trials", 2)
            end
            return pcg:rand_normal_dist(min, max, num_trials)
        end
    }
    return interface
end

function libox.safe.PerlinNoise(noiseparams)
    if type(noiseparams) ~= "table" then return false, "noiseparams is a table, deprecated syntax is not supported." end

    noiseparams.persistence = noiseparams.persistence or noiseparams.persist
    noiseparams.persist = nil
    local check, element = libox.type_check(noiseparams, {
        offset = libox.type("number"),
        scale = libox.type("number"),
        spread = libox.type_vector,
        seed = libox.type("number"),
        octaves = libox.type("number"),
        persistence = libox.type("number"),
        lacunarity = libox.type("number"),
        flags = function(x)
            if x ~= nil then
                return type(x) == "string"
            else
                return true
            end
        end,
    })

    if not check then
        return false, element
    end

    local core = PerlinNoise(noiseparams)
    local interface = {
        get_2d = wrap(core.get_2d, core),
        get_3d = wrap(core.get_3d, core)
    }
    return interface
end

function libox.safe.pcall(f, ...)
    local ret_values = { pcall(f, ...) }
    if not debug.gethook() then
        error("Code timed out!", 2)
    end
    return unpack(ret_values)
end

function libox.safe.xpcall(f, handler, ...)
    local ret_values = {
        xpcall(f, function(...)
            if not debug.gethook() then
                error("Code timed out!", 2)
                return
            end
            return handler(...)
        end, ...)
    }

    if not debug.gethook() then
        error("Code timed out!", 2)
    end

    return unpack(ret_values)
end

function libox.safe.get_loadstring(env) -- chunkname is ignored
    return function(code, chunkname)
        if chunkname ~= nil then
            error("Adding a chunkname is forbidden", 2)
        end
        if type(code) == "string" and #code > 64000 then error("Code too long :/", 2) end
        if string.byte(code, 1) == BYTECODE_CHAR then
            error("dont sneak in bytecode (mod security will prevent you anyway)", 2)
        end
        local f, errmsg = loadstring(code)
        if f == nil then
            return nil, errmsg
        end
        setfenv(f, env)

        if rawget(_G, "jit") then
            jit.off(f, true)
        end

        return f, errmsg
    end
end

--[[
    safe_date is from the mooncontroller mod
    licensed under LGPLv3, by OgelGames
]]
-- Wraps os.date to only replace valid formats,
-- ignoring invalid ones that would cause a hard crash.
local TIME_MAX = 32535244800 -- 01/01/3001
-- todo: change on 01/01/3001
local function safe_date(str, time)
    if type(time) ~= "number" then
        time = os.time()
    elseif time < 0 or time >= TIME_MAX then
        return nil
    end

    if type(str) ~= "string" then
        return os.date("%c", time)
    end
    if str == "*t" then
        return os.date("*t", time)
    end
    str = string.gsub(str, "%%[aAbBcdHImMpSwxXyY]", function(s)
        return os.date(s, time)
    end)
    return str
end

local function datetable()
    return os.date("*t")
end

function libox.create_basic_environment()
    --[[
        get the safest, least strict lua environment
        *for the "normal" sandbox, when using the "coroutine" sandbox you will need to add coroutine.yield
        and edit pcall/xpcall to run coroutine.yield instead of erroring

    ]]

    -- INCLUDES: basic lib (minus coroutine, add that yourself if you need to), string, table, math, bit, os, a bit of minetest, some minetest classes
    -- is meant to be added on top of
    local env = {
        assert = assert,
        error = error,
        collectgarbage = function(arg)
            if arg ~= "count" then error("The only valid mode to collectgarbage is count") end
            return collectgarbage("count")
        end,
        ipairs = ipairs,
        pairs = pairs,
        next = next,
        pcall = libox.safe.pcall,
        xpcall = libox.safe.xpcall,
        select = select,
        unpack = function(t, a, b) -- from mooncontroller
            assert(not b or b < 2 ^ 30)
            return unpack(t, a, b)
        end,

        tonumber = tonumber,
        tostring = tostring,
        type = type,

    }
    env.loadstring = libox.safe.get_loadstring(env)
    env._G = env

    env.string = {
        byte = string.byte,
        char = string.char,
        dump = string.dump,
        find = function(s, pattern, init, plain)
            if not plain then
                error(
                    "string.find: the fourth parameter (plain) must be true, if you need patterns, use pat.find instead",
                    2)
            end
            return string.find(s, pattern, init, true)
        end,
        format = string.format,
        len = string.len,
        lower = string.lower,
        rep = libox.safe.rep,
        reverse = string.reverse,
        sub = string.sub,
        upper = string.upper,
        -- minetest helpers
        trim = string.trim,
        split = function(str, delim, include_empty, max_splits, sep_is_pattern)
            if sep_is_pattern == true then
                error("The fourth argument (sep_is_pattern) must be false", 2)
            end
            return string.split(str, delim, include_empty, max_splits, false)
        end,
    }

    env.table = {
        insert = table.insert,
        maxn = table.maxn,
        remove = table.remove,
        sort = table.sort,
        concat = table.concat,
        -- minetest helpers:
        indexof = table.indexof,
        copy = table.copy,
        insert_all = table.insert_all,
        key_value_swap = table.key_value_swap,
        shuffle = table.shuffle,

        -- luajit only helpers
        move = table.move,
        -- deprecated stuff
        foreach = table.foreach,
        foreachi = table.foreachi,
    }


    env.math = {}
    for _, v in ipairs({
        "abs", "acos", "asin", "atan", "atan2", "ceil", "cos", "cosh", "deg", "exp", "floor",
        "fmod", "frexp", "huge", "ldexp", "log", "log10", "max", "min", "modf", "pi", "pow",
        "rad", "random", "sin", "sinh", "sqrt", "tan", "tanh",

        -- minetest helpers
        "hypot", "sign", "factorial", "round"
    }) do
        env.math[v] = math[v]
    end

    env.bit = table.copy(bit)

    env.vector = table.copy(vector)
    env.vector.metatable = nil -- it's useless to add it, and it's undocumented
    env.os = {
        clock = os.clock,
        datetable = datetable,
        difftime = os.difftime,
        time = os.time,
        date = safe_date,
    }

    env.minetest = {
        hash_node_position = minetest.hash_node_position,
        get_position_from_hash = minetest.get_position_from_hash,
        formspec_escape = libox.sandbox_lib_f(minetest.formspec_escape),
        explode_table_event = libox.sandbox_lib_f(minetest.explode_table_event),
        explode_textlist_event = libox.sandbox_lib_f(minetest.explode_textlist_event),
        explode_scrollbar_event = libox.sandbox_lib_f(minetest.explode_scrollbar_event),
        inventorycube = libox.sandbox_lib_f(minetest.inventorycube),
        urlencode = libox.sandbox_lib_f(minetest.urlencode),
        rgba = libox.sandbox_lib_f(minetest.rgba),
        encode_base64 = libox.sandbox_lib_f(minetest.encode_base64),
        decode_base64 = libox.sandbox_lib_f(minetest.decode_base64),
        get_us_time = libox.sandbox_lib_f(minetest.get_us_time),
    } -- safe minetest functions


    -- extra global environment stuff
    for _, v in ipairs({
        "dump", "dump2"
    }) do
        env[v] = libox.sandbox_lib_f(_G[v])
    end

    -- oh yeah who could forget...
    -- some random minetest stuffs
    env.PcgRandom = libox.sandbox_lib_f(libox.safe.PcgRandom)
    env.PerlinNoise = libox.sandbox_lib_f(libox.safe.PerlinNoise)

    env.traceback = libox.traceback
    env.pat = {
        find = wrap(libox.pat.find, libox.pat),
        match = wrap(libox.pat.match, libox.pat),
        gmatch = wrap(libox.pat.gmatch, libox.pat),
    }

    libox.supply_additional_environment(env) -- for mods to use
    return env
end
