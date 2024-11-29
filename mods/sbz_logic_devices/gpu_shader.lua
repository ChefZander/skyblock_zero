--[[
Alright so.. yea.. what if the gpu had a crappy version of fragment shaders...

So umm, i want it to be:
- multithreaded (4 threads)
- no strings, they cause trouble
- optional extra data as a number or 2D number array matched by buffer size
- _G immutable
- _G shared to prevent severe lag...
- 100 instructions for each pixel...
]]

local threads = 4
local function apply_shader(buffer, shader, pos, from_pos)
    local thread_data = {}

    local notify = sbz_logic.get_notify(from_pos, pos)
    for i = 1, threads do thread_data[i] = {} end
    -- alright... now... validate shader code so that there are no strings
    -- yeah... i know... im sooo lame
    if #shader > 1000 then return end
    if string.find(shader, "\"", 1, true) and not sbz_api.debug then
        return notify({
            type = "shader_error",
            err = "Shader must not have strings"
        })
    end
    if string.find(shader, "'", 1, true) and not sbz_api.debug then
        return notify({
            type = "shader_error",
            err = "Shader must not have strings"
        })
    end
    if string.find(shader, "[[", 1, true) and not sbz_api.debug then
        return notify({
            type = "shader_error",
            err = "Shader must not have strings (or blocky comments... sorry :p)"
        })
    end

    -- launch the threads
    for thread = 1, threads do
        minetest.handle_async(
            function(buffer, shader, thread, max_threads)
                local t0 = minetest.get_us_time()
                local new_buffer = {}

                local function make_immutable(t)
                    return setmetatable({}, {
                        __newindex = {},
                        __index = t
                    })
                end


                local function make_safe(x)
                    x.randomseed = nil
                    return x
                end
                local env = setmetatable({}, {
                    __newindex = {},
                    __index = {
                        math = setmetatable({}, {
                            __index = make_safe(table.copy(math)),
                            __newindex = {}
                        }),
                        buffer = setmetatable({}, {
                            __newindex = {},
                            __index = function(t, k)
                                local px = buffer.buffer[k]
                                if px then
                                    return {
                                        r = string.byte(px, 1),
                                        g = string.byte(px, 2),
                                        b = string.byte(px, 3),
                                    }
                                else
                                    return { r = 0, g = 0, b = 0 }
                                end
                            end,
                        }),
                        index = function(x, y)
                            return (y - 1) * buffer.xsize + x
                        end,
                    }
                })

                local env_index = getmetatable(env).__index

                local f, errmsg = loadstring(shader)
                if f == nil then
                    return nil, nil, false
                end
                setfenv(f, env)
                jit.off(f, true)

                local xsize, ysize, rbuf = buffer.xsize, buffer.ysize, buffer.buffer

                local string_meta = getmetatable("")
                string_meta.__index = {}

                local segment = math.ceil(ysize / max_threads)
                local ystart = ((thread - 1) * segment) + 1

                local function index(x, y)
                    return (y - 1) * buffer.xsize + x
                end

                for y = ystart, math.min(ysize, ystart + segment) do
                    for x = 1, xsize do
                        env_index.x = x
                        env_index.y = y
                        local ok, result = pcall(function()
                            debug.sethook(function()
                                debug.sethook()
                                error(
                                    "Code instruction'd out. You will never see this anyway, good luck debugging your shaders.")
                            end, "", 500)
                            local ok, result = pcall(f)
                            debug.sethook()
                            return result
                        end)
                        debug.sethook()

                        if ok == false or type(result) ~= "table" then
                            return nil, minetest.get_us_time() - t0, false, result
                        end

                        if type(result) ~= "table" then return nil, nil, false end
                        local r, g, b = result.r, result.g, result.b
                        if type(r) ~= "number" or minetest.is_nan(r) then
                            return nil, nil, false,
                                "return format must be in { r=int,g=int,b=int }"
                        end
                        if type(g) ~= "number" or minetest.is_nan(g) then
                            return nil, nil, false,
                                "return format must be in { r=int,g=int,b=int }"
                        end
                        if type(b) ~= "number" or minetest.is_nan(b) then
                            return nil, nil, false,
                                "return format must be in { r=int,g=int,b=int }"
                        end

                        local floor, max, min = math.floor, math.max, math.min
                        r, g, b = floor(min(255, max(0, r))), floor(min(255, max(0, g))), floor(min(255, max(0, b)))

                        local color = string.char(r) .. string.char(g) .. string.char(b)
                        new_buffer[index(x, y)] = color
                    end
                end
                string_meta.__index = string -- not needed really
                return new_buffer, minetest.get_us_time() - t0, true
            end,
            function(new_buffer, lag, success, error)
                thread_data[thread].finished = true
                thread_data[thread].success = success
                thread_data[thread].buffer = new_buffer
                thread_data[thread].lag = lag
                thread_data[thread].error = error

                -- checks if all finished, if not, return
                for i = 1, threads do
                    if not thread_data[i].finished then
                        return
                    end
                end

                -- alright now... if all are successful

                local all_successful = true

                for i = 1, threads do
                    if thread_data[i].success == false then
                        all_successful = false
                    end
                end

                -- todo: apple lag to pos

                local lag_sum = 0
                for i = 1, threads do
                    lag_sum = lag_sum + (thread_data[i].lag or 0)
                end

                local meta = minetest.get_meta(pos)
                local node = minetest.get_node(pos)
                if node.name ~= "sbz_logic_devices:gpu" then
                    return
                end
                local lag = meta:get_int("lag")
                lag = lag + (lag_sum / 1000)
                meta:set_int("lag", lag)

                local errors = {}
                for i = 1, threads do
                    errors[#errors + 1] = thread_data[i].error
                end
                if #errors == 0 then
                    errors = nil
                end

                notify {
                    type = "shader_complete",
                    err = errors,
                }

                if all_successful == false then return end

                -- now... apply the buffer

                local new_buffer = {}
                local segment = math.ceil(buffer.ysize / threads)

                local function index(x, y)
                    return (y - 1) * buffer.xsize + x
                end
                for i = 1, threads do
                    local ystart = ((i - 1) * segment) + 1
                    for y = ystart, math.min(buffer.ysize, ystart + segment) do
                        for x = 1, buffer.xsize do
                            new_buffer[index(x, y)] = thread_data[i].buffer[index(x, y)]
                        end
                    end
                end
                buffer.buffer = new_buffer
            end, buffer, shader, thread, threads)
    end
end

return apply_shader
