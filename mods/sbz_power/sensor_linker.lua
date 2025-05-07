local render_links_delay = 1
local waypoint_ids = {}
local sbz_serialize = sbz_api.serialize
local sbz_deserialize = sbz_api.deserialize

local function happy_particles(pos)
    local vel = vector.new(-3, -3, -3)
    minetest.add_particlespawner({
        amount = 1000,
        time = 0.1,
        exptime = 3,
        collisiondetection = true,
        collision_removal = true,
        texture = "vizlib_particle.png^[colorize:green:255",
        glow = 14,
        pos = pos,
        vel = { min = -vel, max = vel }
    })
end

local function render_individual_link(pos, name)
    waypoint_ids[#waypoint_ids + 1] = sbz_api.set_waypoint(pos, {
        name = name,
        dist = 0,
        max_dist = 100,
        precision = 0,
        image = "visualiser_trail.png^[colorize:red:100^[verticalframe:3:0"
    })
end

local timer = 0
local function render_links(dtime)
    timer = timer + dtime
    if timer < render_links_delay then return end
    timer = 0

    for k, v in pairs(waypoint_ids) do
        sbz_api.remove_waypoint(v)
    end
    waypoint_ids = {}

    for k, v in pairs(minetest.get_connected_players()) do
        local wielded_item = v:get_wielded_item()
        if wielded_item:get_name() == "sbz_power:sensor_linker" then
            local itemmeta = wielded_item:get_meta()
            local linked_pos_data = itemmeta:get_string("linked")
            if linked_pos_data ~= "" then
                local linked_pos = sbz_deserialize.vec3_32bit(linked_pos_data)
                local linked_node = sbz_api.get_or_load_node(linked_pos)
                local linked_meta = minetest.get_meta(linked_pos)
                local radius = core.registered_nodes[linked_node.name].linking_range or
                    linked_meta:get_int("linking_range")

                vizlib.draw_cube(linked_pos, radius + 0.5, {
                    player = v,
                    color = "blue",
                    infinite = false,
                    time = render_links_delay + 0.1
                })
                local links = core.deserialize(linked_meta:get_string("links"))
                if type(links) == "table" then
                    for name, vector_array in pairs(links) do
                        for _, position in pairs(vector_array) do
                            render_individual_link(position, name)
                        end
                    end
                end
            end
        end
    end
end

core.register_globalstep(render_links)

local function try_to_link_to_tool(stack, pos, placer)
    local meta = stack:get_meta()
    local name = placer:get_player_name()
    local node = sbz_api.get_node_force(pos)
    if not node then return end
    node = node.name
    local ndef = minetest.registered_nodes[node]
    if not ndef then return end
    if not ndef.can_sensor_link then return displayDialogueLine(name, "Can't link with that.") end
    -- ok yeah it can link
    meta:set_string("linked", sbz_serialize.vec3_32bit(pos))
    minetest.chat_send_player(name, "Succesfully linked to the sensor.")
    happy_particles(pos)
end

local function err_link_invalid(placer)
    minetest.chat_send_player(placer:get_player_name(),
        "Link is invalid, please link the tool to your sensor again.")
end

local function make_link(meta, pos, placer)
    local linked = meta:get_string("linked")
    local placer_name = placer:get_player_name()
    if linked == "" then
        return core.chat_send_player(placer_name, "Tool isn't linked to any machine.")
    end

    local linked_pos = sbz_deserialize.vec3_32bit(linked)
    local linked_node = sbz_api.get_or_load_node(linked_pos)
    linked_node = linked_node.name

    local ndef = minetest.registered_nodes[linked_node]
    if ndef == nil then return err_link_invalid(placer) end
    if not ndef.can_sensor_link then
        return core.chat_send_player(placer_name,
            "The node that the tool is linked with doesn't support linking with the sensor linker.")
    end

    local linked_meta = minetest.get_meta(linked_pos)
    local linked_range = ndef.linking_range or linked_meta:get_int("linking_range")

    if linked_range == 0 then
        minetest.chat_send_player(placer:get_player_name(), "Can't link anything in that sensor, linked range is 0.")
        return
    end

    if not logic.in_square_radius(linked_pos, pos, linked_range) then
        minetest.chat_send_player(placer:get_player_name(), "Outside of the radius")
        return
    end

    local name = meta:get_string "name"
    if name == "" then
        minetest.chat_send_player(placer:get_player_name(), "You need to set a name first (Left click)")
        return
    end

    if ndef.add_link then
        ndef.add_link(meta, pos, placer)
    else
        local links = minetest.deserialize(linked_meta:get_string("links")) or {}
        links[name] = links[name] or {}
        links[name][#links[name] + 1] = pos

        -- Hmm... WTF WAS I THINKING WHEN I WROTE THIS
        -- it works
        -- don't touch it
        -- dupe check
        local names = {}
        for lname, lpos in pairs(links) do
            for lname_2, lpos_2 in ipairs(lpos) do
                if vector.equals(pos, lpos_2) then
                    names[#names + 1] = { lname, lname_2 }
                end
            end
        end
        if #names >= 2 then
            local tables_to_fix = {}
            for _, v in pairs(names) do
                links[v[1]][v[2]] = nil
                tables_to_fix[#tables_to_fix + 1] = v[1]
            end
            for _, t in ipairs(tables_to_fix) do
                local new_t = {}
                for k, v in pairs(links[t]) do
                    new_t[#new_t + 1] = v
                end
                links[t] = new_t
            end
        end
        for k, v in pairs(links) do
            if #v == 0 then links[k] = nil end
        end
        linked_meta:set_string("links", minetest.serialize(links))
    end
end

minetest.register_on_player_receive_fields(function(player, formname, fields)
    if formname ~= "sbz_power:sensor_linker_form" then
        return
    end
    local name = fields.set_name
    local wield_item = player:get_wielded_item()
    if wield_item:get_name() ~= "sbz_power:sensor_linker" then
        return true, "sus"
    end

    wield_item:get_meta():set_string("name", (name or ""):trim())
    if player:get_meta():get_string("target") then
        local target = player:get_meta():get_string("target")
        local target_pos = vector.from_string(target)
        if target_pos == nil then return true, "???" end
        make_link(wield_item:get_meta(), target_pos, player)
        player:set_wielded_item(wield_item)
    end
    return true
end)


minetest.register_craftitem("sbz_power:sensor_linker", {
    description = "Sensor Linker",
    info_extra = {
        "Right click: asks for a name, if a block is pointed to, links to the to the sensor.",
        "Left click: uses the previous name from when you right clicked, links it to the sensor.",
        "Aux1 + right click/left click: Links the tool to the sensor.",
        "If you hold it, it should show all the links and the sensor's linking radius."
    },
    inventory_image = "sensor_linker.png",
    range = 10,
    liquids_pointable = true,
    on_place = function(stack, placer, pointed)
        if pointed.type ~= "node" then return end
        if core.is_protected(pointed.under, placer:get_player_name()) then
            core.record_protection_violation(pointed.under, placer:get_player_name())
            return
        end

        if placer:get_player_control().aux1 == false then
            local target = pointed.under
            minetest.show_formspec(placer:get_player_name(), "sbz_power:sensor_linker_form",
                "field[set_name;The name of the link;]")
            if pointed.type ~= "node" then
                placer:get_meta():set_string("target", "")
                return
            end
            placer:get_meta():set_string("target", vector.to_string(target))
        else
            if pointed.type ~= "node" then return end
            try_to_link_to_tool(stack, pointed.under, placer)
        end
        return stack
    end,
    on_use = function(stack, placer, pointed)
        if pointed.type ~= "node" then return end
        if core.is_protected(pointed.under, placer:get_player_name()) then
            core.record_protection_violation(pointed.under, placer:get_player_name())
            return
        end
        local target = pointed.under
        if placer:get_player_control().aux1 == false then
            make_link(stack:get_meta(), target, placer)
        else
            try_to_link_to_tool(stack, target, placer)
        end
        return stack
    end,
    groups = {},
    stack_max = 1,
})

minetest.register_craft {
    output = "sbz_power:sensor_linker",
    recipe = {
        { "sbz_resources:warp_crystal", },
        { "sbz_resources:stone", },
        { "sbz_resources:stone", },
    }
}
