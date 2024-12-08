-- matrix screen
-- named that because it accepts a matrix, of colors
-- very much inspired by https://cheapiesystems.com/git/digiscreen/tree/
-- it is kinda a fork of it soo...
-- ok so turns out its public domain (thanks cheapie) but still
--[[
    This is free and unencumbered software released into the public domain.

Anyone is free to copy, modify, publish, use, compile, sell, or
distribute this software, either in source code form or as a compiled
binary, for any purpose, commercial or non-commercial, and by any
means.

In jurisdictions that recognize copyright laws, the author or authors
of this software dedicate any and all copyright interest in the
software to the public domain. We make this dedication for the benefit
of the public at large and to the detriment of our heirs and
successors. We intend this dedication to be an overt act of
relinquishment in perpetuity of all present and future rights to this
software under copyright law.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND,
EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF
MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT.
IN NO EVENT SHALL THE AUTHORS BE LIABLE FOR ANY CLAIM, DAMAGES OR
OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE,
ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR
OTHER DEALINGS IN THE SOFTWARE.

For more information, please refer to <http://unlicense.org/>
]]


local DISP_MAX_RESOLUTION = 32
local function remove_entity(pos)
    local entitiesNearby = minetest.get_objects_inside_radius(pos, 0.5)
    for _, i in pairs(entitiesNearby) do
        if i:get_luaentity() and i:get_luaentity().name == "sbz_logic_devices:matrix_screen_entity" then
            i:remove()
        end
    end
end

local function generate_texture(pos, serdata)
    --The data *should* always be valid, but it pays to double-check anyway due to how easily this could crash if something did go wrong
    if type(serdata) ~= "string" then
        minetest.log("error",
            "[sbz_logic_devices] Serialized display data appears to be missing at " .. minetest.pos_to_string(pos, 0))
        return
    end
    local data = minetest.deserialize(serdata)
    if type(data) ~= "table" then
        minetest.log("error",
            "[sbz_logic_devices] Failed to deserialize display data at " .. minetest.pos_to_string(pos, 0))
        return
    end
    local bincolors = {}
    local index = #bincolors + 1
    local size = math.min(DISP_MAX_RESOLUTION, #data)

    for y = 1, size do
        if type(data[y]) ~= "table" then data[y] = {} end
        for x = 1, size do
            bincolors[index] = data[y][x] or
                minetest.colorspec_to_bytes("black") -- ive optimized it a lil to not be a warcrime
            index = index + 1
        end
    end

    local img
    local ok, errmsg = pcall(function()
        img = minetest.encode_png(size, size, table.concat(bincolors), 1)
    end)

    if not ok then
        core.log("error", errmsg)
        return
    end

    return "blank.png^[invert:a^[png:" .. minetest.encode_base64(img)
end

local function update_display(pos)
    remove_entity(pos)
    local meta = minetest.get_meta(pos)
    local data = meta:get_string("data")
    local entity = minetest.add_entity(pos, "sbz_logic_devices:matrix_screen_entity")
    local fdir = minetest.fourdir_to_dir(minetest.get_node(pos).param2)
    local etex = "blank.png^[invert:a"
    etex = generate_texture(pos, data) or etex
    entity:set_properties({ textures = { etex } })
    entity:set_yaw((fdir.x ~= 0) and math.pi / 2 or 0)
    entity:set_pos(vector.add(pos, vector.multiply(fdir, 0.39)))
end

minetest.register_entity("sbz_logic_devices:matrix_screen_entity", {
    initial_properties = {
        visual = "upright_sprite",
        physical = false,
        collisionbox = { 0, 0, 0, 0, 0, 0, },
        textures = { "blank.png^[invert:a" },
    },
})

minetest.register_node("sbz_logic_devices:matrix_screen", {
    description = "Matrix Screen",
    info_extra = {
        "Named that because it accepts a 2D matrix.",
        "Ok i just realised that techage had the exact same name, for a very similar thing... lol,\n but yea, this was forked from digiscreen. (But made better :>)",
        "You can put a backlight behind... to... yea... have the screen be brighter" },
    tiles = {
        "blank.png^[invert:rgba^[colorize:grey",
        "blank.png^[invert:rgba^[colorize:grey",
        "blank.png^[invert:rgba^[colorize:grey",
        "blank.png^[invert:rgba^[colorize:grey",
        "blank.png^[invert:rgba^[colorize:grey",
        "blank.png^[invert:rgba^[colorize:grey",
        --        { name = "blank.png", backface_culling = true }, -- todo: find a way to have alpha nicely
    },
    use_texture_alpha = "clip",
    drawtype = "nodebox",
    paramtype = "light",
    paramtype2 = "4dir",
    sunlight_propagates = true,
    on_construct = function(pos)
        local meta = minetest.get_meta(pos)
        local disp = { [1] = { [1] = minetest.colorspec_to_bytes("black") } }
        meta:set_string("data", minetest.serialize(disp))
        update_display(pos)
    end,
    on_destruct = remove_entity,
    on_punch = function(screenpos, _, player)
        if not player then return end
        if player.is_fake_player then return end

        local m = minetest.get_meta(screenpos)
        local disp = minetest.deserialize(m:get_string("data"))
        if type(disp) ~= "table" then return end
        local size = math.min(DISP_MAX_RESOLUTION, #disp)

        local subscribed = vector.from_string(m:get_string("subscribed"))
        if subscribed == nil then return end

        local eyepos = vector.add(player:get_pos(),
            vector.add(player:get_eye_offset(), vector.new(0, 1.5, --[[player:get_properties().eye_height]] 0))
        )
        local lookdir = player:get_look_dir()
        local distance = vector.distance(eyepos, screenpos)
        local endpos = vector.add(eyepos, vector.multiply(lookdir, distance + 1))
        local ray = minetest.raycast(eyepos, endpos, true, false)
        local pointed, screen, hitpos
        repeat
            pointed = ray:next()
            if pointed and pointed.type == "node" then
                local node = minetest.get_node(pointed.under)
                if node.name == "sbz_logic_devices:matrix_screen" then
                    screen = pointed.under
                    hitpos = vector.subtract(pointed.intersection_point, screen)
                end
            end
        until screen or not pointed
        if not hitpos then return end
        local fourdir = minetest.fourdir_to_dir(minetest.get_node(screen).param2)
        if fourdir.x > 0 then
            hitpos.x = -1 * hitpos.z
        elseif fourdir.x < 0 then
            hitpos.x = hitpos.z
        elseif fourdir.z < 0 then
            hitpos.x = -1 * hitpos.x
        end
        vector.add(hitpos, vector.multiply(fourdir, 0.39))
        hitpos.y = -1 * hitpos.y
        local hitpixel = {}
        hitpixel.x = math.floor((hitpos.x + 0.5) * size) + 1
        hitpixel.y = math.round((hitpos.y + 0.5 - (5 / 32)) * size) + 1
        -- dont ask why this is math.round and the other one is math.floor, its more accurate somehoww
        if hitpixel.x < 1 or hitpixel.x > size or hitpixel.y < 1 or hitpixel.y > size then return end
        local message = {
            x = hitpixel.x,
            y = hitpixel.y,
            player = player:get_player_name(),
        }

        sbz_logic.send(subscribed, message, screenpos)
    end,
    node_box = {
        type = "fixed",
        fixed = { -0.5, -0.5, 0.4, 0.5, 0.5, 0.5 },
    },
    on_rotate = function(pos, ...)
        local ret = screwdriver.rotate_simple(pos, ...)
        minetest.after(0, update_display, pos)
        return ret
    end,
    groups = { matter = 3, ui_logic = 1 },
    sounds = sbz_api.sounds.machine(),
    on_logic_send = function(pos, msg, from_pos)
        local meta = minetest.get_meta(pos)
        if msg == "subscribe" then
            meta:set_string("subscribed", vector.to_string(from_pos))
            return
        end

        if type(msg) ~= "table" then
            return
        end
        local data = {}

        local size = #msg;
        if size == 0 then
            return
        end

        for y = 1, size do
            data[y] = {}
            if type(msg[y]) ~= "table" then msg[y] = {} end
            for x = 1, size do
                local v = msg[y][x]
                local bytes = minetest.colorspec_to_bytes(v)
                if bytes == nil then
                    bytes = minetest.colorspec_to_bytes("black")
                end
                data[y][x] = bytes
            end
        end

        meta:set_string("data", minetest.serialize(data))
        update_display(pos)
    end
})

minetest.register_lbm({
    name = "sbz_logic_devices:matrix_screen_respawn",
    label = "Respawn matrix screen entities",
    nodenames = { "sbz_logic_devices:matrix_screen" },
    run_at_every_load = true,
    action = update_display,
})

unified_inventory.register_craft {
    type = "ele_fab",
    items = {
        "sbz_resources:lua_chip 2",
        "unifieddyes:colorium 32",
        "sbz_resources:emittrium_circuit 8",
        "sbz_resources:matter_plate 10"
    },
    output = "sbz_logic_devices:matrix_screen",
    width = 2,
    height = 2,
}
