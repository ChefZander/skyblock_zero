local render_links_delay = 1

local waypoint_ids = {}

local logic = sbz_api.logic

function logic.happy_particles(pos)
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
    -- just put up their name, "simple" enough...
    if pos.x then
        waypoint_ids[#waypoint_ids + 1] = sbz_api.set_waypoint(pos, {
            name = name,
            dist = 0,
            precision = 0,
            image = "visualiser_trail.png^[verticalframe:3:0"
        })
    else
        for k, v in pairs(pos) do
            render_individual_link(v, k)
        end
    end
end

local function render_links()
    for k, v in pairs(waypoint_ids) do
        sbz_api.remove_waypoint(v)
    end
    for k, v in pairs(minetest.get_connected_players()) do
        local wielded_item = v:get_wielded_item()
        if wielded_item:get_name() == "sbz_logic:luacontroller_linker" then
            local itemmeta = wielded_item:get_meta()
            local linked_pos = vector.from_string(itemmeta:get_string("linked"))
            if linked_pos ~= nil then -- ahh ok lua kinda needs a continue statement :/
                local linked_meta = minetest.get_meta(linked_pos)
                local radius = linked_meta:get_int("linking_range")
                if radius ~= 0 then
                    vizlib.draw_cube(linked_pos, radius + 0.5, {
                        player = v,
                        color = "blue",
                        infinite = false,
                        time = render_links_delay + 0.1
                    })
                end
                local links = minetest.deserialize(linked_meta:get_string("links"))
                if type(links) == "table" then
                    for k, link in pairs(links) do
                        for _, position in pairs(link) do
                            render_individual_link(position, k)
                        end
                    end
                end
            end
        end
    end
    minetest.after(render_links_delay, render_links)
end

minetest.after(0, render_links) -- me elegant!

local function try_to_link_to_luac(stack, pos, placer)
    local meta = stack:get_meta()
    local name = placer:get_player_name()
    local node = sbz_api.get_node_force(pos)
    if not node then return end
    node = node.name
    local ndef = minetest.registered_nodes[node]
    if not ndef then return end
    if not ndef.can_link then return minetest.chat_send_player(name, "Can't link") end
    -- ok yeah it can link
    meta:set_string("linked", vector.to_string(pos))
    minetest.chat_send_player(name, "Luacontroller succesfully linked to the luacontroller linking tool!")
    logic.happy_particles(pos)
end

local function err_link_invalid(placer)
    minetest.chat_send_player(placer:get_player_name(),
        "Link is invalid, please link the luacontroller linker to a luacontroller again.")
end

local function make_link(meta, pos, placer)
    local linked = meta:get_string("linked")
    local linked_pos = vector.from_string(linked)
    if not linked_pos then
        return err_link_invalid(placer)
    end
    local linked_node = sbz_api.get_node_force(linked_pos)
    if not linked_node then
        return err_link_invalid(placer)
    end
    linked_node = linked_node.name

    local ndef = minetest.registered_nodes[linked_node]
    if ndef == nil then return err_link_invalid(placer) end
    if not ndef.can_link then return err_link_invalid(placer) end

    local linked_meta = minetest.get_meta(linked_pos)
    local linked_range = linked_meta:get_int("linking_range")

    if linked_range == 0 then
        minetest.chat_send_player(placer:get_player_name(), "The luacontroller doesn't have a linking upgrade.")
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
    -- ok HOPEFULLY thats enough checks holy crap

    local links = minetest.deserialize(linked_meta:get_string("links")) or {}

    links[name] = links[name] or {}
    links[name][#links[name] + 1] = pos

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

minetest.register_on_player_receive_fields(function(player, formname, fields)
    if formname ~= "sbz_logic:luacontroller_linker_form" then
        return
    end
    local name = fields.set_name
    local wield_item = player:get_wielded_item()
    if wield_item:get_name() ~= "sbz_logic:luacontroller_linker" then
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


minetest.register_craftitem("sbz_logic:luacontroller_linker", {
    description = "Luacontroller Linker",
    short_description = "Luacontroller Linker",
    info_extra = {
        "Right click: ask for a name, if a block is pointed to, link the block",
        "Left click: use the previous name, and link the block",
        "Aux1 + right click/left click: link to that luacontroller",
        "If you hold it, it should show all the links and the luacontroller's radius"
    },
    inventory_image = "luacontroller_linker.png",
    range = 10,
    liquids_pointable = true,
    on_place = function(stack, placer, pointed)
        if placer:get_player_control().aux1 == false then
            local target = pointed.under
            minetest.show_formspec(placer:get_player_name(), "sbz_logic:luacontroller_linker_form",
                "field[set_name;The name of the link;]")
            if pointed.type ~= "node" then
                placer:get_meta():set_string("target", "")
                return
            end
            placer:get_meta():set_string("target", vector.to_string(target))
        else
            if pointed.type ~= "node" then return end
            try_to_link_to_luac(stack, pointed.under, placer)
        end
        return stack
    end,
    on_use = function(stack, placer, pointed)
        if pointed.type ~= "node" then return end
        if placer:get_player_control().aux1 == false then
            local target = pointed.under
            make_link(stack:get_meta(), target, placer)
        else
            try_to_link_to_luac(stack, pointed.under, placer)
        end
        return stack
    end,
    groups = { ui_logic = 1 },
    stack_max = 1,
})

minetest.register_craft {
    output = "sbz_logic:luacontroller_linker",
    recipe = {
        { "sbz_resources:compressed_core_dust", "sbz_resources:compressed_core_dust", "sbz_resources:compressed_core_dust", },
        { "sbz_resources:compressed_core_dust", "sbz_resources:warp_crystal",         "sbz_resources:compressed_core_dust", },
        { "sbz_resources:compressed_core_dust", "sbz_resources:compressed_core_dust", "sbz_resources:compressed_core_dust", },
    }
}
