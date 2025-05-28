function libox.get_default_hook(max_time)
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

-- luacheck: push ignore

--[[
    PATH SHORTENING: from dbg
    Path shortening is licensed under the MIT license:

    Copyright 2022 Lars Müller

    Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the "Software"),
    to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute,
    sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:

    The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.

    THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
    FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY,
    WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
]]

-- luacheck: pop ignore

local modpath_trie = {}
for _, modname in pairs(minetest.get_modnames()) do
    local path = minetest.get_modpath(modname)
    local subtrie = modpath_trie
    for char in path:gmatch "." do
        subtrie[char] = subtrie[char] or {}
        subtrie = subtrie[char]
    end
    subtrie["\\"] = modname
    subtrie["/"] = modname
end

function libox.shorten_path(path)
    -- Search for a prefix (paths have at most one prefix)
    local subtrie = modpath_trie
    for i = 1, #path do
        if type(subtrie) == "string" then
            return subtrie .. ":" .. path:sub(i)
        end
        subtrie = subtrie[path:sub(i, i)]
        if not subtrie then return path end
    end
    return path
end

-- PATH SHORTENING END, rest is licensed as usual

if minetest.global_exists("dbg") then
    libox.shorten_path = dbg.shorten_path
end

local TRACEBACK_LIMIT = 20

function libox.traceback(errmsg)
    errmsg = tostring(errmsg) or ""

    local traceback = "Traceback: " .. "\n"
    local level = 1

    while level < TRACEBACK_LIMIT do
        local info = debug.getinfo(level, "nlS") -- can be quite slow actually, thats why TRACEBACK_LIMIT is in place
        if not info then break end
        local name = info.name
        local text
        if name ~= nil then
            text = "In function " .. name
        else
            text = "In " .. info.what
        end
        if info.source == "=(load)" then
            traceback = traceback .. text .. " at line " .. info.currentline .. "\n"
        end
        level = level + 1
    end

    if level == TRACEBACK_LIMIT then traceback = traceback .. "\n... and more" end
    return libox.shorten_path(errmsg) .. "\n" .. traceback
end

-- dont rely on this to sethook and
function libox.unsafe_traceback(errmsg)
    debug.sethook()
    getmetatable("").__index = string
    return libox.traceback(errmsg)
end

function libox.digiline_sanitize(input, allow_functions, wrap)
    --[[
		Parameters:
			1) input: the thing
			2) allow_functions: true/false, explains itself
			3) wrap: function, the function that wraps around the functions in this table
	]]

    wrap = wrap or function(f) return f end
    local function clean_and_weigh_digiline_message(msg, back_references)
        local t = type(msg)
        if t == "string" then
            -- Strings are immutable so can be passed by reference, and cost their
            -- length plus the size of the Lua object header (24 bytes on a 64-bit
            -- platform) plus one byte for the NUL terminator.
            return msg, #msg + 25
        elseif t == "number" then
            -- Numbers are passed by value so need not be touched, and cost 8 bytes
            -- as all numbers in Lua are doubles. NaN values are removed.
            if msg ~= msg then
                return nil, 0
            end
            return msg, 8
        elseif t == "boolean" then
            -- Booleans are passed by value so need not be touched, and cost 1
            -- byte.
            return msg, 1
        elseif t == "table" then
            -- Tables are duplicated. Check if this table has been seen before
            -- (self-referential or shared table); if so, reuse the cleaned value
            -- of the previous occurrence, maintaining table topology and avoiding
            -- infinite recursion, and charge zero bytes for this as the object has
            -- already been counted.
            back_references = back_references or {}
            local bref = back_references[msg]
            if bref then
                return bref, 0
            end
            -- Construct a new table by cleaning all the keys and values and adding
            -- up their costs, plus 8 bytes as a rough estimate of table overhead.
            local cost = 8
            local ret = {}
            back_references[msg] = ret
            for k, v in pairs(msg) do
                local k_cost, v_cost
                k, k_cost = clean_and_weigh_digiline_message(k, back_references)
                v, v_cost = clean_and_weigh_digiline_message(v, back_references)
                if k ~= nil and v ~= nil then
                    -- Only include an element if its key and value are of legal
                    -- types.
                    ret[k] = v
                end
                -- If we only counted the cost of a table element when we actually
                -- used it, we would be vulnerable to the following attack:
                -- 1. Construct a huge table (too large to pass the cost limit).
                -- 2. Insert it somewhere in a table, with a function as a key.
                -- 3. Insert it somewhere in another table, with a number as a key.
                -- 4. The first occurrence doesn’t pay the cost because functions
                --    are stripped and therefore the element is dropped.
                -- 5. The second occurrence doesn’t pay the cost because it’s in
                --    back_references.
                -- By counting the costs regardless of whether the objects will be
                -- included, we avoid this attack; it may overestimate the cost of
                -- some messages, but only those that won’t be delivered intact
                -- anyway because they contain illegal object types.
                cost = cost + k_cost + v_cost
            end
            return ret, cost
        elseif t == "function" and allow_functions then
            local success, bytecode = pcall(function()
                return string.dump(msg)
            end)
            if not success then
                return nil, 0
            else
                return wrap(msg), #bytecode + 25
            end
        else
            return nil, 0
        end
    end


    local msg, cost = clean_and_weigh_digiline_message(input)
    if not msg then
        return nil, 0
    else
        return msg, cost
    end
end

function libox.sandbox_lib_f(f, opt_str_limit)
    --[[
        Sandbox external functions, call this on functions that
            - don't run user code
            - use "":sub(1, 2, whatever) syntax and that syntax is critical or use pcall or xpcall
            - get laggy when supplied with gigantic sting inputs

        ]]
    return function(...)
        local args = { ... }
        for _, v in pairs(args) do
            if type(v) == "string" and #v > (opt_str_limit or 64000) then error("String too large", 2) end
        end

        local string_meta = getmetatable("")
        local sandbox = string_meta.__index

        string_meta.__index = string
        local retvalue = { f(...) }
        string_meta.__index = sandbox

        if not debug.gethook() then
            error("Code timed out! (Reason: external function erased the debug hook)", 2)
        end
        return unpack(retvalue)
    end
end

libox.safe_traceback = libox.sandbox_lib_f(libox.safe_traceback) -- make it work


-- strict type checking
--[[
    thing: any
    type_check: {
        key = function | table
    } | function
    note: recursive
    returns: boolean

]]
function libox.type_check(initial_thing, initial_check)
    local function internal(thing, check, seen)
        if seen[thing] == true then return true end
        if type(check) == "function" then
            seen[thing] = true
            return check(thing)
        end

        for k, v in pairs(check) do
            if thing[k] == nil then
                if type(v) == "function" then
                    if v(nil) == false then
                        return false, k
                    end
                else
                    return false
                end
            elseif type(v) == "table" then
                if (internal(thing[k], v, seen)) == false then return false, k end
                seen[thing[k]] = true
            elseif type(v) == "function" then
                if v(thing[k]) == false then return false, k end
                seen[thing[k]] = true
            else -- bad, just return false
                return false, "invalid params to initial_check probably"
            end
        end
        for k, _ in pairs(thing) do
            if check[k] == nil then return false, "un-needed: " .. k end
        end
        return true
    end
    return internal(initial_thing, initial_check, {})
end

function libox.type(x)
    return function(something)
        return type(something) == x
    end
end

function libox.type_vector(vec)
    if type(vec) ~= "table" then return false end

    if type(vec.x) ~= "number" then return false end
    if type(vec.y) ~= "number" then return false end
    if type(vec.z) ~= "number" then return false end
    return true
end
