-- A VERY different, but still kinda copied from, verson of the digistuff gpu
-- Focus: be fast, at least faster than what digistuff does :>
-- https://github.com/mt-mods/digistuff/blob/reworkGPU/gpu.lua
-- License: LGPLv3 or later

local MP = minetest.get_modpath("sbz_logic_devices")

---@type function
local blend = loadfile(MP .. "/gpu_utils.lua")()

---@type function, function, function
local bresenham, xiaolin_wu, midpoint_circle = loadfile(core.get_modpath("sbz_logic_devices") .. "/gpu_line_algos.lua")()

---@type table<integer, table<integer,boolean>>
local fonts = loadfile(MP .. "/gpu_font.lua")()

---@type function, function
local transform_buffer, convolution_matrix = loadfile(MP .. "/gpu_matrix_operations.lua")()

---@type function
local apply_shaders = loadfile(MP .. "/gpu_shader.lua")()

local pos_buffers = setmetatable({}, {
    __index = function(t, k)
        if not rawget(t, k) then
            rawset(t, k, {})
        end
        return rawget(t, k)
    end
})
local h = minetest.hash_node_position


local a = 30
minetest.register_privilege("place_gpus_unlimited", {
    description = string.format("Place gpus closer than %s blocks from one another", a),
    give_to_admin = false,
    give_to_singleplayer = false,
})

local area_vec = vector.new(a, a, a)

local function after_place_node(pos, placer)
    if not placer then return end
    if minetest.check_player_privs(placer, "place_gpus_unlimited") then return end

    local nodes = minetest.find_nodes_in_area(vector.subtract(pos, area_vec), vector.add(pos, area_vec),
        "sbz_logic_devices:gpu")

    if #(nodes) > 1 then
        core.chat_send_player(placer:get_player_name(),
            ("2 Gpus can't be near eachother, they need to be %s blocks apart, or you have to have the place_gpus_unlimited privledge")
            :format(a))
        core.remove_node(pos)
        return true
    end
end

local max_buffers = 8
local max_buffer_size = 128
local max_commands_in_one_message = 32
local max_ms_use = 100

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

local function flood_fill(buffers, command)
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


    local x, y = validate_area(b, command.x, command.y, command.x, command.y)
    if x == nil then return end

    local checking_color = real_buffer[idx(x, y)]
    if checking_color == nil then return end
    checking_color = color2table(checking_color)

    local stack = {}
    local seen = {}
    stack[#stack + 1] = { x = x, y = y }

    local ruleset_4dir = {
        { x = 1,  y = 0 },
        { x = -1, y = 0 },
        { x = 0,  y = 1 },
        { x = 0,  y = -1 }
    }

    local hash = function(x1, y1)
        return y1 * max_buffer_size + x1
    end

    while #stack ~= 0 do
        local pos = table.remove(stack) -- dont worry this is an O(1)

        if not real_buffer[idx(pos.x, pos.y)] then
            return
        end

        local col = color2table(real_buffer[idx(pos.x, pos.y)])

        if similar(col, checking_color, tolerance) then
            real_buffer[idx(pos.x, pos.y)] = color
            for k, v in ipairs(ruleset_4dir) do
                local nx, ny = pos.x + v.x, pos.y + v.y
                if
                    (nx <= b.xsize) and (ny <= b.ysize) and (ny > 0) and (nx > 0)
                    and not seen[hash(nx, ny)]
                then
                    stack[#stack + 1] = { x = nx, y = ny }
                    seen[hash(nx, ny)] = true
                end
            end
        end
    end
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
            to_pos = type_any, --libox.type("table"),
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


            local should_fill = command.fill ~= nil
            command.edge = command.edge or command.fill
            local edge = transform_color(command.edge)
            local fill = transform_color(command.fill)

            local buffer = buf_t.buffer
            local size_x = buf_t.xsize

            if should_fill then
                for y = y1, y2 do
                    for x = x1, x2 do
                        buffer[((y - 1) * size_x) + x] = fill
                    end
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

            local x1, y1 = validate_area(buf_t, command.x, command.y, command.x, command.y)
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
            local sx1, sy1, sx2, sy2 = validate_area(src_buf,
                command.srcx, command.srcy,

                command.srcx + command.xsize,
                command.srcy + command.ysize
            )

            local dx1, dy1, dx2, dy2 = validate_area(dst_buf,
                command.dstx, command.dsty,

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

                    if px1 ~= nil and px2 ~= nil then
                        dst_buf_real[(dy1 + y - 1) * dst_buf.xsize + (dy1 + x)] =
                            blend(px1, px2, blend_mode, transparent_color)
                    end
                end
            end
        end
    },
    ["load"] = {
        type_checks = {
            index = type_index,
            buffer = libox.type("table")
        },
        f = function(buffers, command)
            local ysize = min(#command.buffer, max_buffer_size)
            if type(command.buffer[1]) ~= "table" then return end
            if ysize == 0 then return end
            local xsize = min(#command.buffer[1], max_buffer_size)

            buffers[command.index] = {
                ysize = ysize,
                xsize = xsize,
                buffer = {}
            }

            local buffer = buffers[command.index].buffer

            local src_buf = command.buffer
            local i = 0
            for y = 1, ysize do
                for x = 1, xsize do
                    i = i + 1
                    buffer[i] = transform_color((src_buf[y] or {})[x])
                end
            end
        end,
    },
    ["send_packed"] = {
        -- this packing works a little differently, and should be like a lot faster
        type_checks = {
            index = type_index,
            to_pos = type_any,
            base64 = libox.type("boolean")
        },
        f = function(buffers, command, pos, from_pos)
            if not libox.type_vector(command.to_pos) then
                command.to_pos = from_pos
            end
            local b = buffers[command.index]
            if b == nil then return end

            local buf = b.buffer
            local packed_data = {}
            for y = 1, b.ysize do
                for x = 1, b.xsize do
                    local px = buf[(y - 1) * b.xsize + x]
                    packed_data[#packed_data + 1] = px
                    -- 3 bytes, in the form of rgb, such that px:byte(1) == r, px:byte(2) == g, px:byte(3) == b
                end
            end
            local result = table.concat(packed_data)
            if command.base64 then
                result = minetest.encode_base64(result)
            end
            sbz_logic.send_l(command.to_pos, result, from_pos) -- send as if logic sent it
        end
    },
    ["send_png"] = { -- i guess this would be "send extra packed but yea good luck unpacking it"
        type_checks = {
            index = type_index,
            to_pos = type_any,
        },
        f = function(buffers, command, pos, from_pos)
            if not libox.type_vector(command.to_pos) then
                command.to_pos = from_pos
            end
            local b = buffers[command.index]
            if b ~= nil then
                local real_buf = b.buffer
                local data = {}
                for i = 1, (b.xsize * b.ysize) do
                    data[#data + 1] = real_buf[i] .. string.char(0xFF)
                end

                local png = core.encode_png(b.xsize, b.ysize, table.concat(data), 1)
                sbz_logic.send_l(command.to_pos, minetest.encode_base64(png), from_pos) -- send as if logic sent it
            end
        end
    },
    ["load_packed"] = {
        type_checks = {
            index = type_index,
            data = libox.type("string"),
            x1 = type_int,
            y1 = type_int,
            x2 = type_int,
            y2 = type_int,
            base64 = libox.type("boolean"),
        },
        f = function(buffers, command)
            local b = buffers[command.index]
            if b == nil then return end

            local x1, y1, x2, y2 = validate_area(b, command.x1, command.y1, command.x2, command.y2)
            if not x1 then return end

            local data = command.data
            if command.base64 then
                data = minetest.decode_base64(command.data)
            end
            if data == nil then return end -- can happen with base64

            local real_buf = b.buffer
            local idx = 1
            for y = y1, y2 do
                for x = x1, x2 do
                    local packed_data = string.sub(data, idx, idx + 2)
                    if packed_data and #packed_data == 3 then
                        real_buf[(y - 1) * b.xsize + x] = packed_data
                    end
                    idx = idx + 3
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
        f = flood_fill,
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
            min_y = type_int,
            max_x = type_int,
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
            if matrix_xsize % 2 == 0 then return end -- cannot have even matrices
            if matrix_ysize % 2 == 0 then return end -- cannot have even matrices

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
    ["shader"] = {
        type_checks = {
            index = type_index,
            shader = libox.type("string"),
        },
        f = function(buffers, command, pos, from_pos)
            local b = buffers[command.index]
            if b == nil then return end
            apply_shaders(b, command.shader, pos, from_pos)
        end
    }
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

    groups = { matter = 1, ui_logic = 1 },
    is_ground_content = false,
    tiles = {
        "gpu_bottom.png",
        "gpu_bottom.png",
        "gpu_side.png",
        "gpu_side.png",
        "gpu_side.png",
        "gpu_side.png"
    },
    sounds = sbz_api.sounds.machine(),

    on_logic_send = function(pos, msg, from_pos)
        if type(msg) ~= "table" then return end
        if type(msg[1]) ~= "table" then msg = { msg } end

        local meta = minetest.get_meta(pos)
        local lag = meta:get_int("lag") or 0

        local last_measured = meta:get_int("last_measured")
        if last_measured ~= os.time() then
            lag = 0
        end

        local buffers = pos_buffers[h(pos)]

        for i = 1, math.min(#msg, max_commands_in_one_message) do
            if lag > max_ms_use then -- sorry :/
                break
            end
            local t0 = minetest.get_us_time()
            exec_command(buffers, msg[i], pos, from_pos)
            lag = math.floor(lag + (minetest.get_us_time() - t0) / 1000)
        end

        if last_measured ~= os.time() then
            meta:set_string("infotext", ("Lag: %s/%sms"):format(lag, max_ms_use))
            meta:set_int("last_measured", os.time())
        end
        meta:set_int("lag", lag)
    end,
    after_place_node = after_place_node
})

mesecon.register_on_mvps_move(function(moved_nodes)
    for i = 1, #moved_nodes do
        local moved_node = moved_nodes[i]
        if rawget(pos_buffers, h(moved_node.oldpos)) then
            pos_buffers[h(moved_node.pos)] = pos_buffers[h(moved_node.oldpos)]
            pos_buffers[h(moved_node.oldpos)] = nil
        end
    end
end)


unified_inventory.register_craft {
    type = "ele_fab",
    items = {
        "sbz_resources:lua_chip 8",
        "unifieddyes:colorium 64",
        "sbz_resources:ram_stick_1mb 16",
        "sbz_resources:emittrium_circuit 3"
    },
    output = "sbz_logic_devices:gpu",
    width = 2,
    height = 2,
}
