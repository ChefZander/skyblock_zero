-- A VERY different, but still kinda copied from, verson of the digistuff gpu
-- Focus: be fast, at least faster than what digistuff does :>
-- https://github.com/mt-mods/digistuff/blob/reworkGPU/gpu.lua
-- License: LGPLv3 or later

local MP = minetest.get_modpath("sbz_logic_devices")

---@type function, function, function, function, function, function, function, function
local explodebits, implodebits, packpixel, unpackpixel, rgbtohsv, hsvtorgb, bitwiseblend, blend
= loadfile(MP .. "/gpu_utils.lua")()

---@type function, function, function
local bresenham, xiaolin_wu, midpoint_circle = loadfile(core.get_modpath("sbz_logic_devices") .. "/gpu_line_algos.lua")()

---@type table<integer, table<integer,boolean>>
local fonts = loadfile(MP .. "/gpu_font.lua")()

---@type function, function
local transform_buffer, convolution_matrix = loadfile(MP .. "/gpu_matrix_operations.lua")()

local pos_buffers = setmetatable({}, {
    __index = function(t, k)
        if not rawget(t, k) then
            rawset(t, k, {})
        end
        return rawget(t, k)
    end
})
local h = minetest.hash_node_position

local max_buffers = 8
local max_buffer_size = 128
local max_commands_in_one_message = 32

local min, abs = math.min, math.abs

local function type_index(x)
    if type(x) ~= "number" then return false end
    if not (x == x) then return end
    if x > max_buffers or x < 1 then return false end
    return true
end

local function type_any(x) return true end

local function validate_area(buffer, x1, y1, x2, y2)
    if not (buffer and buffer.xsize and buffer.ysize)
        or type(x1) ~= "number"
        or type(x2) ~= "number"
        or type(y1) ~= "number"
        or type(y2) ~= "number"
    then
        return
    end

    x1 = math.max(1, math.min(buffer.xsize, math.floor(x1)))
    x2 = math.max(1, math.min(buffer.xsize, math.floor(x2)))
    y1 = math.max(1, math.min(buffer.ysize, math.floor(y1)))
    y2 = math.max(1, math.min(buffer.ysize, math.floor(y2)))
    if x1 > x2 then
        x1, x2 = x2, x1
    end
    if y1 > y2 then
        y1, y2 = y2, y1
    end
    return x1, y1, x2, y2
end

local function transform_color(x)
    ---@diagnostic disable-next-line: param-type-mismatch
    return string.sub((core.colorspec_to_bytes(x) or core.colorspec_to_bytes("#00000000")), 1, 3)
end

local function transform_to_norm_color(x)
    return string.format("#%06x", (x:byte(1) * 0x10000) + (x:byte(2) * 0x100) + x:byte(3))
end

local function export(buf, x1, y1, x2, y2)
    local exported = {}
    local buffer = buf.buffer

    for y = y1, y2 do
        exported[y - y1 + 1] = {}
        for x = x1, x2 do
            exported[y - y1 + 1][x - x1 + 1] = transform_to_norm_color(buffer[(((y - 1) * buf.xsize) + x)])
        end
    end
    return exported
end

local function type_int(x)
    if type(x) ~= "number" then return false end
    if math.floor(x) ~= x then return false end
    return true
end

local commands = {
    ["create_buffer"] = {
        type_checks = {
            index = type_index,
            xsize = type_int,
            ysize = type_int,
            fill = type_any,
        },
        f = function(buffers, command)
            command.xsize = min(abs(command.xsize), max_buffer_size)
            command.ysize = min(abs(command.ysize), max_buffer_size)

            command.fill = transform_color(command.fill)

            command.fill = string.sub(command.fill, 1, 3) -- extract only RGB
            buffers[command.index] = {
                xsize = command.xsize,
                ysize = command.ysize,
                buffer = {}
            }
            local buffer = buffers[command.index].buffer
            for i = 1, command.xsize * command.ysize do
                buffer[i] = command.fill
            end
        end
    },
    ["send"] = {
        type_checks = {
            index = type_index,
            to_pos = libox.type("table"),
        },
        f = function(buffers, command, pos, from_pos)
            if not libox.type_vector(command.to_pos) then
                command.to_pos = from_pos
            end
            local b = buffers[command.index]
            if b ~= nil then
                local result = export(b, 1, 1, b.xsize, b.ysize)
                sbz_logic.send_l(command.to_pos, result, from_pos) -- send as if logic sent it
            end
        end
    },

    ["send_region"] = {
        type_checks = {
            index = type_index,
            x1 = type_int,
            y1 = type_int,

            x2 = type_int,
            y2 = type_int,

            to_pos = type_any,
        },
        f = function(buffers, command, pos, from_pos)
            local b = buffers[command.index]
            if b == nil then return end
            local x1, y1, x2, y2 = validate_area(b, command.x1, command.y1, command.x2, command.y2)
            if x1 == nil then return end

            if not libox.type_vector(command.to_pos) then
                command.to_pos = from_pos
            end
            local result = export(b, x1, y1, x2, y2)
            sbz_logic.send_l(command.to_pos, result, from_pos) -- send as if logic sent it
        end,
    },
    ["draw_rect"] = {
        type_checks = {
            index = type_index,
            x1 = type_int,
            y1 = type_int,

            x2 = type_int,
            y2 = type_int,

            fill = type_any,
            edge = type_any,

        },
        f = function(buffers, command)
            local buf_t = buffers[command.index]
            if buf_t == nil then return end

            local x1, y1, x2, y2 = validate_area(buf_t, command.x1, command.y1, command.x2, command.y2)
            if x1 == nil then return end

            command.edge = command.edge or command.fill

            local edge = transform_color(command.edge)
            local fill = transform_color(command.fill)

            local buffer = buf_t.buffer
            local size_x = buf_t.xsize
            for y = y1, y2 do
                for x = x1, x2 do
                    buffer[((y - 1) * size_x) + x] = fill
                end
            end

            if fill ~= edge then
                for x = x1, x2 do
                    buffer[((y1 - 1) * size_x) + x] = edge
                    buffer[((y2 - 1) * size_x) + x] = edge
                end
                for y = y1, y2 do
                    buffer[((y - 1) * size_x) + x1] = edge
                    buffer[((y - 1) * size_x) + x2] = edge
                end
            end
        end
    },
    ["draw_line"] = {
        type_checks = {
            index = type_index,
            x1 = type_int,
            y1 = type_int,

            x2 = type_int,
            y2 = type_int,

            antialias = libox.type("boolean"),
            color = type_any,
        },
        f = function(buffers, command)
            local buf_t = buffers[command.index]
            if buf_t == nil then return end

            local x1, y1, x2, y2 = validate_area(buf_t, command.x1, command.y1, command.x2, command.y2)
            if x1 == nil then return end

            local color = transform_color(command.color)

            if command.antialias then
                xiaolin_wu(buf_t, x1, y1, x2, y2, color)
            else
                bresenham(buf_t, x1, y1, x2, y2, color)
            end
        end
    },
    ["draw_point"] = {
        type_checks = {
            index = type_index,
            x = type_int,
            y = type_int,
            color = type_any,
        },
        f = function(buffers, command)
            local buf_t = buffers[command.index]
            if buf_t == nil then return end

            local x1, y1 = validate_area(buf_t, command.x1, command.y1, command.x1, command.y1)
            if x1 == nil then return end

            buf_t.buffer[((y1 - 1) * buf_t.xsize) + x1] = transform_color(command.color)
        end
    },
    ["copy"] = {
        type_checks = {
            src = type_index,
            dst = type_index,

            xsize = type_int,
            ysize = type_int,

            dstx = type_int,
            dsty = type_int,

            srcx = type_int,
            srcy = type_int,

            transparent_color = type_any,
            blend_mode = type_any,
        },
        f = function(buffers, command)
            local transparent_color = transform_color(command.transparent_color)
            local blend_mode = command.blend_mode or "normal"
            if type(blend_mode) ~= "string" then return end

            local src_buf = buffers[command.src]
            local dst_buf = buffers[command.dst]
            if src_buf == nil or dst_buf == nil then return end

            local sx1, sy1, sx2, sy2 = validate_area(src_buf, command.srcx, command.srcy,
                command.srcx + command.xsize,
                command.srcy + command.ysize
            )

            local dx1, dy1, dx2, dy2 = validate_area(dst_buf, command.dstx, command.dsty,
                command.dstx + command.xsize,
                command.dsty + command.ysize
            )

            if (sx1 == nil) or (dx1 == nil) then
                return
            end

            local px1, px2

            local src_buf_real = src_buf.buffer
            local dst_buf_real = dst_buf.buffer
            for y = 1, command.ysize do
                for x = 1, command.xsize do
                    px1 = src_buf_real[((sx1 + y - 1) * src_buf.xsize) + (sy1 + x)]
                    px2 = dst_buf_real[((dy1 + y - 1) * dst_buf.xsize) + (dy1 + x)]
                    dst_buf_real[(dy1 + y - 1) * src_buf.xsize + (dy1 + x)] = blend(px1, px2, blend_mode,
                        transparent_color)
                end
            end
        end
    },
    ["load"] = {
        type_check = {
            index = type_index,
            buffer_in_form_any = libox.type("table")
        },
        f = function(buffers, command)
            local xsize = min(#command.buffer_in_form_any, max_buffer_size)
            if type(command.buffer_in_form_any[1] ~= "table") then return end
            if xsize == 0 then return end
            local ysize = min(#command.buffer_in_form_any[1], max_buffer_size)

            buffers[command.index] = {
                xsize = xsize,
                ysize = ysize,
                buffer = {}
            }
            local buffer = buffers[command.index].buffer

            local src_buf = command.buffer_in_form_any
            local i = 0
            for y = 1, ysize do
                for x = 1, xsize do
                    i = i + 1
                    buffer[i] = transform_color((src_buf[y] or {})[x])
                end
            end
        end,
    },
    ["sendpacked"] = {
        type_check = {
            index = type_index,
            to_pos = libox.type("table"),
        },
        f = function(buffers, command, pos, from_pos)
            if not libox.type_vector(command.to_pos) then
                command.to_pos = from_pos
            end
            local b = buffers[command.index]
            if b ~= nil then
                local result = export(b, 1, 1, b.xsize, b.ysize)
                local packed_data = {}
                for y = 1, #result[1] do
                    for x = 1, #result do
                        packed_data[#packed_data + 1] = packpixel(string.sub(result[y][x], 2)) -- dont do the for i=1,1000 do x = x .. y end
                    end
                end
                sbz_logic.send_l(command.to_pos, table.concat(packed_data), from_pos) -- send as if logic sent it
            end
        end
    },
    ["send_png"] = { -- i guess this would be "send extra packed but yea good luck unpacking it"
        type_check = {
            index = type_index,
            to_pos = libox.type("table"),
        },
        f = function(buffers, command, pos, from_pos)
            if not libox.type_vector(command.to_pos) then
                command.to_pos = from_pos
            end
            local b = buffers[command.index]
            if b ~= nil then
                local real_buf = b.buffer
                local data = {}
                for i = 1, b.xsize * b.ysize do
                    data[#data + 1] = real_buf[i]
                end

                local png = core.encode_png(b.xsize, b.ysize, data, 1)
                sbz_logic.send_l(command.to_pos, minetest.encode_base64(png), from_pos) -- send as if logic sent it
            end
        end
    },
    ["loadpacked"] = {
        type = {
            index = type_index,
            packed = libox.type("string"),
            x1 = type_int,
            y1 = type_int,
            x2 = type_int,
            y2 = type_int,
        },
        f = function(buffers, command)
            local b = buffers[command.index]
            if b == nil then return end
            local x1, y1, x2, y2 = validate_area(b, command.x1, command.y1, command.x2, command.y2)
            if not x1 then return end

            local real_buf = b.buffer
            for y = y1, y2 do
                for x = x1, x2 do
                    local packed_idx = (y * command.xsize + x) * 4 + 1
                    local packed_data = string.sub(command.data, packed_idx, packed_idx + 3)
                    real_buf[((y * real_buf.xsize) - 1) + x] = transform_color(unpackpixel(packed_data))
                end
            end
        end
    },
    ["circle"] = {
        type_checks = {
            index = type_index,
            r = libox.type("number"),
            x = type_int,
            y = type_int,
            hollow = libox.type("boolean"),
            color = type_any,
        },
        f = function(buffers, command)
            local b = buffers[command.index]
            if b == nil then return end

            local color = transform_color(command.color)
            local r = math.min(math.abs(command.r), max_buffer_size * 3)
            local x1, y1, x2, y2 = validate_area(b, command.x - r, command.y - r, command.x + r, command.y + r)
            if x1 == nil then return end
            local x, y = command.x, command.y

            local real_buffer = b.buffer
            local r_squared = r ^ 2
            if command.hollow == false then
                for yi = -r, r do
                    for xi = -r, r do
                        if yi ^ 2 + xi ^ 2 <= r_squared then
                            real_buffer[(y + yi - 1) * b.xsize + x + xi] = color
                        end
                    end
                end
            else
                midpoint_circle(b, x, y, r, color)
            end
        end
    },
    ["fill"] = {
        type_checks = {
            index = type_index,
            tolerance = type_any,
            x = type_int,
            y = type_int,
            color = type_any,
        },
        f = function(buffers, command)
            local b = buffers[command.index]
            if b == nil then return end

            local tolerance = command.tolerance or 0
            if type(tolerance) ~= "number" then return end

            local real_buffer = b.buffer

            local function idx(x, y)
                return (y - 1) * b.xsize + x
            end
            local function color2table(c)
                return { r = c:byte(1), g = c:byte(2), b = c:byte(3) }
            end

            local function similar(target_color, compare_color, tolerance)
                return
                    (math.abs(target_color.r - compare_color.r) <= tolerance) and
                    (math.abs(target_color.g - compare_color.g) <= tolerance) and
                    (math.abs(target_color.b - compare_color.b) <= tolerance)
            end

            local color = transform_color(command.color)

            local queue = Queue.new()
            local seen = {}

            local x, y = validate_area(b, command.x, command.y, command.x, command.y)
            if x == nil then return end
            queue:enqueue({ x = x, y = y })
            local checking_color = real_buffer[idx(x, y)]
            if checking_color == nil then return end
            checking_color = color2table(checking_color)

            local ruleset_4dir = {
                { x = 1,  y = 0 },
                { x = -1, y = 0 },
                { x = 0,  y = 1 },
                { x = 0,  y = -1 }
            }
            local hash = core.hash_node_position
            while not queue:is_empty() do
                local pos = queue:dequeue()
                if not real_buffer[idx(pos.x, pos.y)] then
                    return
                end
                local col = color2table(real_buffer[idx(pos.x, pos.y)])
                if similar(col, checking_color, tolerance) then
                    real_buffer[idx(pos.x, pos.y)] = color
                    for k, v in pairs(ruleset_4dir) do
                        local nx, ny = math.max(0, pos.x + v.x), math.max(0, pos.y + v.y)
                        if not seen[hash(vector.new(nx, ny, 0))] then
                            if (nx <= b.xsize) and (ny <= b.ysize) then
                                queue:enqueue({ x = nx, y = ny })
                            end
                        end
                    end
                end
                seen[hash(vector.new(pos.x, pos.y, 0))] = true
            end
        end
    },
    ["text"] = {
        type_checks = {
            index = type_index,
            x = type_int,
            y = type_int,
            text = libox.type("string"),
            color = type_any,
            font = type_any, -- unused for now
        },
        f = function(buffers, command)
            local b = buffers[command.index]
            if b == nil then return end
            local x, y = validate_area(b, command.x, command.y, command.x, command.y)
            local color = transform_color(command.color)


            local font = command.font or "default"
            if type(font) ~= "string" then font = "default" end

            font = fonts[font]
            if font == nil then return end
            for i = 1, #command.text do
                local char = font[command.text:sub(i, i):byte()]
                if char == nil then break end
                for chary = 1, #char do
                    local xsize = #char[1]
                    for charx = 1, xsize do
                        local px = char[chary][charx]
                        if px == true then
                            local target_idx = ((y + chary - 1) * b.xsize) + (x + charx + (i * xsize) + 1)
                            if x > b.xsize then return end
                            if b.buffer[target_idx] ~= nil then
                                b.buffer[target_idx] = color
                            end
                        end
                    end
                end
            end
        end
    },
    ["transform"] = {
        type_checks = {
            index = type_index,
            x1 = type_int,
            y1 = type_int,
            x2 = type_int,
            y2 = type_int,

            min_x = type_int,
            max_x = type_int,
            min_y = type_int,
            max_y = type_int,

            transparent_color = type_any,
            matrix = libox.type("table"), -- either a 2x2 matrix (linear transform) or a 3x3 matrix (affine transform)
            origin_x = type_int,
            origin_y = type_int,
        },
        f = function(buffers, command)
            local b = buffers[command.index]
            if b == nil then return end
            local x1, y1, x2, y2 = validate_area(b, command.x1, command.y1, command.x2, command.y2)
            local mx1, my1, mx2, my2 = validate_area(b, command.min_x, command.min_y, command.max_x, command.max_y)
            if not x1 then return end
            if not mx1 then return end

            local is_3x3_matrix = false
            local is_2x2_matrix = false
            if libox.type_check(command.matrix, {
                    [1] = {
                        [1] = libox.type("number"),
                        [2] = libox.type("number"),
                    },
                    [2] = {
                        [1] = libox.type("number"),
                        [2] = libox.type("number"),
                    }
                }) == true then
                is_2x2_matrix = true
            elseif libox.type_check(command.matrix, {
                    [1] = {
                        [1] = libox.type("number"),
                        [2] = libox.type("number"),
                        [3] = libox.type("number"),
                    },
                    [2] = {
                        [1] = libox.type("number"),
                        [2] = libox.type("number"),
                        [3] = libox.type("number"),
                    },
                    [3] = {
                        [1] = libox.type("number"),
                        [2] = libox.type("number"),
                        [3] = libox.type("number"),
                    }
                }) == true then
                is_3x3_matrix = true
            end

            if not (is_3x3_matrix or is_2x2_matrix) then return end

            transform_buffer(b, command.matrix, x1, y1, x2, y2, mx1, my1, mx2, my2,
                transform_color(command.transparent_color), command.origin_x, command.origin_y, is_2x2_matrix)
        end
    },
    ["convolution_matrix"] = {
        type_checks = {
            x1 = type_int,
            x2 = type_int,
            y1 = type_int,
            y2 = type_int,
            index = type_index,
            matrix = libox.type("table"),
        },
        f = function(buffers, command)
            local b = buffers[command.index]
            if b == nil then return end
            local x1, y1, x2, y2 = validate_area(b, command.x1, command.y1, command.x2, command.y2)
            if x1 == nil then return end

            local matrix_copy = {}
            local matrix_ysize = #command.matrix
            if type(command.matrix[1]) ~= "table" then return end
            local matrix_xsize = #command.matrix[1]

            if matrix_ysize > 5 then return end
            if matrix_xsize > 5 then return end
            if matrix_xsize < 2 then return end
            if matrix_ysize < 2 then return end

            for y = 1, matrix_ysize do
                if type(command.matrix[y]) ~= "table" then return end
                matrix_copy[y] = {}
                for x = 1, matrix_xsize do
                    local n = command.matrix[y][x]
                    if type(n) ~= "number" then return end
                    matrix_copy[y][x] = n
                end
            end

            convolution_matrix(b, matrix_copy, x1, y1, x2, y2)
        end
    },

}

local function exec_command(buffers, command, pos, from_pos)
    local command_type = command.type
    local action = commands[command_type]
    if not action then return end
    local type_checks = action.type_checks
    type_checks.type = libox.type("string")

    local ok, faulty = libox.type_check(command, type_checks)
    if not ok then
        return
    end

    action.f(buffers, command, pos, from_pos)
end

core.register_node("sbz_logic_devices:gpu", {
    description = "GPU",

    groups = { cracky = 3, matter = 1, ui_logic = 1 },
    is_ground_content = false,
    tiles = {
        "gpu_bottom.png",
        "gpu_bottom.png",
        "gpu_side.png",
        "gpu_side.png",
        "gpu_side.png",
        "gpu_side.png"
    },

    paramtype = "light",
    sunlight_propagates = true,

    on_logic_send = function(pos, msg, from_pos)
        if type(msg) ~= "table" then return end
        if type(msg[1]) ~= "table" then msg = { msg } end

        local t0 = minetest.get_us_time()
        local buffers = pos_buffers[h(pos)]

        for i = 1, math.min(#msg, max_commands_in_one_message) do
            exec_command(buffers, msg[i], pos, from_pos)
        end

        local lag = (minetest.get_us_time() - t0) / 1000
        local meta = minetest.get_meta(pos)

        local old_lag = meta:get_int("lag")
        local last_measured = meta:get_int("last_measured")
        if last_measured ~= os.time() then
            meta:set_string("infotext", "Lag: " .. old_lag .. "ms")
            meta:set_int("lag", 0)
            old_lag = 0
            meta:set_int("last_measured", os.time())
        end
        local lag = old_lag + lag
        meta:set_int("lag", lag)
    end
})
