local HEAT_MAX = 30
local POWER_GEN = 800
--[[
local ghost_removal_delay = 5


minetest.register_entity("sbz_power:node_ghost", {
    initial_properties = {
        hp_max = 1,
        pointable = true,
        visual = "cube",
        use_texture_alpha = true,
        glow = 14,
        static_save = false,
    },
    on_activate = function(self, staticdata, dtime_s)
        staticdata = minetest.deserialize(staticdata)
        self.object:set_properties({ textures = staticdata })
        minetest.after(ghost_removal_delay, function()
            self.object:remove()
        end)
    end
})

local RS = "sbz_power:reactor_shell"
local rs_line = { RS, RS, RS }                                  -- z
sbz_api.emittrium_reactor_schem = {                             -- x
    { rs_line, rs_line,                              rs_line }, -- y
    { rs_line, { RS, "sbz_power:reactor_core", RS }, rs_line },
    { rs_line, rs_line,                              rs_line },
}



function sbz_api.render_ghost(pos, textures)
    if #textures == 1 then
        local tex = textures[1]
        textures = {
            tex, tex, tex, tex, tex, tex
        }
    end
    for k, v in ipairs(textures) do
        textures[k] = textures[k] .. "^[colorize:blue:10^[opacity:127"
    end
    minetest.add_entity(pos, "sbz_power:node_ghost", minetest.serialize(textures))
end

function sbz_api.render_schem_ghost(start_pos, schem)
    local xlen, ylen, zlen = #schem, #schem[1], #schem[1][1]
    local s_x, s_y, s_z = start_pos.x - 1, start_pos.y - 1, start_pos.z - 1

    for x = 1, xlen do
        for y = 1, ylen do
            for z = 1, zlen do
                local node = schem[x][y][z]
                local textures = minetest.registered_nodes[node].tiles
                local drawtype = minetest.registered_nodes[node].drawtype
                if drawtype == "glasslike_framed" then
                    textures = { textures[2] .. "^" .. textures[1] }
                end
                sbz_api.render_ghost({
                    x = x + s_x,
                    y = y + s_y,
                    z = z + s_z
                }, textures)
            end
        end
    end
end


local function show_reactor_builder_ghost(pos)
    sbz_api.render_schem_ghost(vector.add(pos, { x = -1, y = 1, z = -1 }), sbz_api.emittrium_reactor_schem)
end

minetest.register_node("sbz_power:reactor_builder", {
    description = "Reactor Builder",
    info_extra = "Builds an emittrium reactor",
    paramtype2 = "4dir",
    tiles = {
        "reactor_builder_top.png",
        "reactor_builder_side.png",
        "reactor_builder_side.png",
    },
    groups = { matter = 1 },
    on_punch = show_reactor_builder_ghost
})

-- dont remove maybe idk
--]]

local offset = vector.new(3, 3, 3)

local function try_linking(pos, meta)
    local nodes = minetest.find_nodes_in_area(vector.subtract(pos, offset), vector.add(pos, offset),
        { "sbz_power:reactor_core_off", "sbz_power:reactor_core_on" }, true)
    local firstpos
    if nodes["sbz_power:reactor_core_off"] ~= nil then
        firstpos = nodes["sbz_power:reactor_core_off"][1]
    elseif nodes["sbz_power:reactor_core_on"] ~= nil then
        firstpos = nodes["sbz_power:reactor_core_on"][1]
    else
        meta:set_string("infotext", "No reactor core nearby")
        meta:set_int("linked", 0)
        return false
    end
    meta:set_string("linked_pos", vector.to_string(firstpos))
    meta:set_int("linked", 1)
    return true
end

minetest.register_node("sbz_power:reactor_shell", {
    description = "Reactor Shell",
    info_extra = "Used for the emittrium reactor",
    tiles = {
        "reactor_shell.png", "blank.png^[invert:rgba^[multiply:#639bFF"
    },
    drawtype = "glasslike_framed",
    groups = { matter = 1, reactor_shell = 1, explody = 1 },
})

minetest.register_craft {
    output = "sbz_power:reactor_shell",
    recipe = {
        { "sbz_resources:compressed_core_dust", "sbz_resources:raw_emittrium",        "sbz_resources:compressed_core_dust" },
        { "sbz_resources:raw_emittrium",        "sbz_resources:compressed_core_dust", "sbz_resources:raw_emittrium" },
        { "sbz_resources:compressed_core_dust", "sbz_resources:raw_emittrium",        "sbz_resources:compressed_core_dust" },
    }
}

minetest.register_node("sbz_power:reactor_glass", {
    description = "Reactor Glass",
    info_extra = "Decorational, acts like a shell",
    tiles = {
        "reactor_shell.png", "blank.png"
    },
    drawtype = "glasslike_framed",
    paramtype = "light",
    groups = { matter = 1, reactor_shell = 1, explody = 1 },
})

minetest.register_craft {
    output = "sbz_power:reactor_glass",
    recipe = {
        { "sbz_power:simple_charged_field", "sbz_resources:emittrium_glass", "sbz_power:simple_charged_field" },
        { "sbz_resources:emittrium_glass",  "sbz_power:reactor_shell",       "sbz_resources:emittrium_glass" },
        { "sbz_power:simple_charged_field", "sbz_resources:emittrium_glass", "sbz_power:simple_charged_field" }
    }
}

local reactor_shell = "blank.png^[invert:rgba^[multiply:#639bFF^reactor_shell.png"

minetest.register_node("sbz_power:reactor_item_input", {
    description = "Reactor Emittrium Input",
    info_extra = "ONLY ONE can be used in an emittrium reactor, supplies emittrium to the reactor core",
    groups = { matter = 1, reactor_shell = 1, tubedevice = 1, tubedevice_receiver = 1, explody = 1 },

    tiles = {
        reactor_shell,
        reactor_shell,

        reactor_shell,
        reactor_shell,

        reactor_shell,
        "reactor_item_input.png",
    },
    paramtype2 = "4dir",
    after_place_node = pipeworks.after_place,
    after_dig_node = pipeworks.after_dig,
    on_construct = function(pos)
        local inv = minetest.get_meta(pos):get_inventory()
        inv:set_size("main", 1)
    end,
    tube = {
        insert_object = function(pos, node, stack, direction, owner)
            local inv = minetest.get_meta(pos):get_inventory()
            return inv:add_item("main", stack)
        end,
        can_insert = function(pos, node, stack, direction, owner)
            if stack:get_name() ~= "sbz_resources:raw_emittrium" then
                return false
            end
            local inv = minetest.get_meta(pos):get_inventory()
            stack:peek_item(1)
            return inv:room_for_item("main", stack)
        end,
        connect_sides = { left = 1, right = 1, top = 1, bottom = 1, back = 1, front = 1 }
    },
})

minetest.register_craft {
    output = "sbz_power:reactor_item_input",
    recipe = {
        { "pipeworks:tube_1", "sbz_resources:retaining_circuit", "sbz_power:reactor_shell" }
    }
}

sbz_api.register_stateful("sbz_power:reactor_core", {
    description = "Reactor Core",
    info_extra = "Don't let it explode!",
    tiles = {
        "reactor_core.png"
    },
    groups = { matter = 1, reactor_shell = 1, explody = 1 },
    after_place_node = function(pos, placer, itemstack, pointed_thing)
        minetest.get_meta(pos):set_string("owner", placer:get_player_name())
    end,
    on_turn_on = function(pos)
        minetest.get_meta(pos):set_int("tickcount", 0)
    end,
    on_turn_off = function(pos)
        minetest.get_meta(pos):set_int("tickcount", 0)
    end
}, {
    light_source = 14
})

minetest.register_craft {
    output = "sbz_power:reactor_core",
    recipe = {
        { "sbz_meteorites:neutronium", "sbz_meteorites:neutronium", "sbz_meteorites:neutronium", },
        { "sbz_meteorites:neutronium", "sbz_power:reactor_shell",   "sbz_meteorites:neutronium", },
        { "sbz_meteorites:neutronium", "sbz_meteorites:neutronium", "sbz_meteorites:neutronium", }
    }
}

local function make_infoscreen_on_formspec(meta)
    local function barchart_this_number(x, max)
        return 0.2 + (x / max) * 9
    end

    return string.format([[
formspec_version[7]
size[12,12]

label[0.2,1;Heat]
box[0.2,2;1,9;grey]
box[0.2,2;1,%s;red]

label[1.7,1;Coolant]
box[1.7,2;1,9;grey]
box[1.7,2;1,%s;blue]

label[3.2,1;Emittrium]
box[3.2,2;1,9;grey]
box[3.2,2;1,%s;cyan]
button[0.2,11;3,1;turn_off;Turn off the reactor]
button[3.2,11;3,1;relink;Re-Link]
tooltip[relink;Use if 2 infoscreens are linked to the same reactor core]
]],
        barchart_this_number(meta:get_int("heat"), HEAT_MAX),
        barchart_this_number(meta:get_int("water_level"), 100),
        barchart_this_number(meta:get_int("emittrium_level"), 256))
end

local function make_infoscreen_off_formspec(meta)
    local err = meta:get_string("err")
    if err ~= "" then
        err = "label[0,2.5;Error: " .. err .. "]"
    end
    return string.format([[
    formspec_version[7]
    size[6,3]
    button[0,0;6,2;turn_on;Turn on the reactor]
    %s
]], err)
end

minetest.register_node("sbz_power:reactor_infoscreen", {
    description = "Reactor Infoscreen",
    paramtype2 = "4dir",
    tiles = {
        reactor_shell,
        reactor_shell,

        reactor_shell,
        reactor_shell,

        reactor_shell,
        "reactor_infoscreen.png",
    },
    groups = { matter = 1, reactor_shell = 1, explody = 1 },
    on_rightclick = function(pos)
        local meta = minetest.get_meta(pos)
        if meta:get_int("linked") == 0 then
            if not try_linking(pos, meta) then
                meta:set_string("formspec", "")
                return
            end
        end

        local linkedpos = vector.from_string(meta:get_string("linked_pos"))
        if linkedpos == nil then
            meta:set_int("linked", 0)
            return
        end
        local linkedname = sbz_api.get_node_force(linkedpos)
        if linkedname == nil then
            if not try_linking(pos, meta) then
                meta:set_string("infotext", "No reactor nearby")
                meta:set_int("linked", 0)
                meta:set_string("formspec", "")
                return
            end
            return
        end

        ---@diagnostic disable-next-line: cast-local-type
        linkedname = linkedname.name
        if linkedname ~= "sbz_power:reactor_core_on" and linkedname ~= "sbz_power:reactor_core_off" then
            if not try_linking(pos, meta) then
                meta:set_string("infotext", "No reactor nearby")
                meta:set_int("linked", 0)
                meta:set_string("formspec", "")
                return
            end
        end

        if not sbz_api.is_on(linkedpos) then
            meta:set_string("infotext", "Linked but off")
            meta:set_string("formspec", make_infoscreen_off_formspec(meta))
        else
            meta:set_string("infotext", "Linked")
            meta:set_string("formspec", make_infoscreen_on_formspec(meta))
        end
    end,
    on_receive_fields = function(pos, formname, fields, sender)
        local meta = minetest.get_meta(pos)
        if meta:get_int("linked") == 0 then
            meta:set_string("formspec", "")
            return
        end
        local linkedpos = vector.from_string(meta:get_string("linked_pos"))
        local linkedname = sbz_api.get_node_force(linkedpos).name
        if linkedname ~= "sbz_power:reactor_core_on" and linkedname ~= "sbz_power:reactor_core_off" then
            minetest.log("Not linked, name " .. linkedname)
            meta:set_string("formspec", "")
            return
        end

        if fields.turn_on then
            sbz_api.turn_on(linkedpos)
            meta:set_string("infotext", "Linked but off")
            meta:set_string("formspec", make_infoscreen_on_formspec(meta))
        elseif fields.turn_off then
            meta:set_string("infotext", "Linked")
            sbz_api.turn_off(linkedpos)
            meta:set_string("formspec", make_infoscreen_off_formspec(meta))
        elseif fields.relink then
            try_linking(pos, meta)
            meta:set_string("formspec", "")
            meta:set_string("infotext", "")
        end
    end,
    on_reactor_update = function(pos)
        local meta = minetest.get_meta(pos)
        meta:set_string("formspec", make_infoscreen_on_formspec(meta))
    end,
})

minetest.register_craft {
    output = "sbz_power:reactor_infoscreen",
    recipe = {
        { "sbz_power:reactor_glass", "sbz_power:reactor_shell", "sbz_power:connector_off" }
    }
}

sbz_api.register_generator("sbz_power:reactor_power_port", {
    description = "Reactor Power Port",
    paramtype2 = "4dir",
    tiles = {
        reactor_shell,
        reactor_shell,

        reactor_shell,
        reactor_shell,

        reactor_shell,
        "reactor_powerport.png",
    },
    groups = { matter = 1, reactor_shell = 1, pipe_connects = 1, explody = 1 },
    connect_sides = { "front" },
    action = function(pos, node, meta, supply, demand)
        meta:set_string("infotext", "")
        local reactor_pos = vector.from_string(meta:get_string("linked_coords"))

        if reactor_pos == nil then return 0 end
        local state = sbz_api.is_on(reactor_pos)
        if state == true then
            return POWER_GEN
        else
            return 0
        end
    end,
    disallow_pipeworks = true,

})

minetest.register_craft {
    output = "sbz_power:reactor_power_port",
    recipe = {
        { "sbz_power:power_pipe", "sbz_power:reactor_shell", "sbz_power:simple_charged_field" }
    }
}

minetest.register_node("sbz_power:reactor_coolant_port", {
    description = "Reactor Coolant Port",
    info_extra = "Provide it water",
    paramtype2 = "4dir",
    tiles = {
        reactor_shell,
        reactor_shell,

        reactor_shell,
        reactor_shell,

        reactor_shell,
        "reactor_coolantport.png",
    },
    groups = { matter = 1, reactor_shell = 1, fluid_pipe_connects = 1, fluid_pipe_stores = 1, explody = 1 },
    connect_sides = { "front" },
    on_construct = function(pos)
        minetest.get_meta(pos):set_string("liquid_inv", minetest.serialize({
            max_count_in_each_stack = 100, -- 100 buckets
            [1] = {
                name = "sbz_resources:water_source",
                count = 0,
                can_change_name = false,
            },
        }))
    end,
    on_liquid_inv_update = function(pos, lqinv) end,
})
minetest.register_craft {
    output = "sbz_power:reactor_coolant_port",
    recipe = {
        { "sbz_power:fluid_pipe", "sbz_power:fluid_tank", "sbz_power:reactor_shell" }
    }
}

local function explode(pos)
    local owner = minetest.get_meta(pos):get_string("owner")
    --breaking nodes
    minetest.sound_play({ name = "distant-explosion-47562", gain = 0.4 })
    sbz_api.explode(pos, 32, 1.5, false, owner)
    --particle effects
    minetest.add_particlespawner({
        time = 1,
        amount = 9000,
        pos = pos,
        radius = 1,
        drag = 0.2,
        glow = 14,
        exptime = { min = 2, max = 10 },
        size = { min = 3, max = 6 },
        texture = "reactor_explosion_particle.png",
        attract = {
            kind = "point",
            origin = pos,
            strength = { min = -20, max = 0 }
        },
        acc = { x = 0, y = -3, z = 0 }, -- gravity
        collisiondetection = true,
    })
end

sbz_api.reactor_explode = explode

local CONSUME_EMITTRIUM_EVERY_X_SEC = 30

local function core_tick(pos)
    local meta = minetest.get_meta(pos)
    local tickcount = meta:get_int("tickcount") or 0
    if tickcount >= CONSUME_EMITTRIUM_EVERY_X_SEC then
        tickcount = 0
        meta:set_int("tickcount", 0)
    else
        meta:set_int("tickcount", tickcount + 1)
    end
    local err = nil
    local nodes = {
        info = nil,
        power = nil,
        emittrium = nil,
        coolant = nil,
        n_shells = 0,
    }
    local iter_start_pos = vector.subtract(pos, { x = 1, y = 1, z = 1 })
    for x = iter_start_pos.x, iter_start_pos.x + 2 do
        for y = iter_start_pos.y, iter_start_pos.y + 2 do
            for z = iter_start_pos.z, iter_start_pos.z + 2 do
                local vec = vector.new(x, y, z)
                local node = sbz_api.get_node_force(vec).name
                if node == "sbz_power:reactor_power_port" then
                    if nodes.power == nil then
                        nodes.power = vec
                    else
                        err = "You can't have more than 1 power port"
                    end
                    --                elseif node == "sbz_power:reactor_core" then
                    --                    err = "What is a core doing in your reactor shell?"
                    ---                end
                    --- -- no i think i can leave it in, people are going to make funny designs and im all for it!
                elseif node == "sbz_power:reactor_infoscreen" then
                    if nodes.info == nil then
                        nodes.info = vec
                    else
                        err = "You can't have more than 1 infoscreen"
                    end
                elseif node == "sbz_power:reactor_item_input" then
                    if nodes.emittrium == nil then
                        nodes.emittrium = vec
                    else
                        err = "You can't have more than 1 Emittrium Input"
                    end
                elseif node == "sbz_power:reactor_coolant_port" then
                    if nodes.coolant == nil then
                        nodes.coolant = vec
                    else
                        err = "You can't have more than 1 coolant port"
                    end
                end
                nodes.n_shells = nodes.n_shells + minetest.get_item_group(node, "reactor_shell")
            end
        end
    end
    if nodes.n_shells ~= 27 then
        err = "Not enough shells/glass"
        sbz_api.turn_off(pos)
    end

    if nodes.emittrium == nil then
        err = "No emittrium input?"
    end
    if nodes.coolant == nil then
        err = "No coolant input?"
    end
    if nodes.power == nil then
        err = "No power input/output?"
    end

    if nodes.info == nil then
        minetest.chat_send_player(meta:get_string("owner"),
            "You forgot to put up an infoscreen in this reactor (or somehow it wasn't detected)")
        sbz_api.turn_off(pos)
        return
    end
    local emittrium_stack, emittriummeta
    if nodes.emittrium then
        emittriummeta = minetest.get_meta(nodes.emittrium)
        emittrium_stack = emittriummeta:get_inventory():get_stack("main", 1)

        if tickcount == 0 then
            local newcount = emittrium_stack:get_count() - 16
            if newcount < 0 then
                err = "Not enough emittrium"
                meta:set_int("tickcount", CONSUME_EMITTRIUM_EVERY_X_SEC) -- resets
            else
                emittrium_stack:set_count(emittrium_stack:get_count() - 16)
                emittriummeta:get_inventory():set_stack("main", 1, emittrium_stack)
            end
        end
    end
    local infometa = minetest.get_meta(nodes.info)
    infometa:set_string("err", err or "")

    if not err then
        local heat = meta:get_int("heat")

        local powermeta = minetest.get_meta(nodes.power)
        powermeta:set_string("linked_coords", vector.to_string(pos))
        local water = nodes.coolant
        local watermeta = minetest.get_meta(water)
        local waterinv = minetest.deserialize(watermeta:get_string("liquid_inv"))
        if waterinv[1].count == 0 then
            heat = heat + 2
        else
            heat = math.max(heat - 1, 0)
        end

        waterinv[1].count = math.max(waterinv[1].count - 1, 0)
        watermeta:set_string("liquid_inv", minetest.serialize(waterinv))

        if heat > HEAT_MAX then
            explode(pos)
        end

        meta:set_int("heat", heat)

        infometa:set_int("heat", heat)
        infometa:set_int("water_level", waterinv[1].count)
        infometa:set_int("emittrium_level", emittrium_stack:get_count())
        minetest.registered_nodes["sbz_power:reactor_infoscreen"].on_reactor_update(nodes.info)
        unlock_achievement(meta:get_string("owner"), "Building the emittrium reactor and turning it on")
    else
        sbz_api.turn_off(pos)
    end
end

minetest.register_abm({
    nodenames = { "sbz_power:reactor_core_on" },
    action = core_tick,
    interval = 1,
    chance = 1,
})


mesecon.register_on_mvps_move(function(moved_nodes)
    for i = 1, #moved_nodes do
        local moved_node = moved_nodes[i]
        if moved_node.node.name == "sbz_power:reactor_power_port" then
            local meta = minetest.get_meta(moved_node.pos)
            local linked_coords = vector.from_string(meta:get_string("linked_coords"))
            linked_coords = (linked_coords - vector.copy(moved_node.oldpos)) + vector.copy(moved_node.pos)
            meta:set_string("linked_coords", vecotr.to_string(linked_coords))
        elseif moved_node.node.name == "sbz_power:reactor_infoscreen" then
            local meta = minetest.get_meta(moved_node.pos)
            local linked_coords = vector.from_string(meta:get_string("linked_pos"))
            linked_coords = (linked_coords - vector.copy(moved_node.oldpos)) + vector.copy(moved_node.pos)
            meta:set_string("linked_pos", vecotr.to_string(linked_coords))
        end
    end
end)
