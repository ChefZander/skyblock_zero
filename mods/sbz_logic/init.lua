sbz_api.logic = {}
local MP = minetest.get_modpath("sbz_logic")

local logic = sbz_api.logic

dofile(MP .. "/mesecon_queue.lua")
dofile(MP .. "/comm.lua")
dofile(MP .. "/upgrades.lua")

local render_links_delay = 1

local waypoint_ids = {}


function sbz_api.render_individual_link(pos, name)
    -- just put up their name, "simple" enough...
    if pos.x then
        waypoint_ids[#waypoint_ids + 1] = sbz_api.set_waypoint(pos, {
            name = name,
            dist = 0,
            precision = 0,
            image = "visualiser_trail.png^[verticalframe:3:0"
        })
    elseif pos[1] then
        for k, v in pairs(pos) do
            sbz_api.render_individual_link(v, k)
        end
    end
end

function sbz_api.render_links()
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
                    vizlib.draw_cube(linked_pos, radius, {
                        player = v,
                        color = vizlib.blue,
                        infinite = false,
                        time = render_links_delay + 0.1
                    })
                end
                local links = minetest.deserialize(linked_meta:get_string("links"))
                if type(links) == "table" then
                    for k, link in pairs(links) do
                        for _, position in pairs(link) do
                            sbz_api.render_individual_link(position, k)
                        end
                    end
                end
            end
        end
    end
    minetest.after(render_links_delay, sbz_api.render_links)
end

minetest.after(0, sbz_api.render_links) -- me elegant!

local function in_square_radius(pos1, pos2, rad)
    local x1, y1, z1 = pos1.x, pos1.y, pos1.z
    local x2, y2, z2 = pos2.x, pos2.y, pos2.z

    local a = math.abs
    local dx, dy, dz = a(x1 - x2), a(y1 - y2), a(z1 - z2)

    if dx > rad or dy > rad or dz > rad then
        return false
    end
    return true
end

logic.in_square_radius = in_square_radius

function logic.add_to_link(link, value)
    if link.x then
        return vector.add(link, value)
    else
        link = table.copy(link)
        for k, v in pairs(link) do
            link[k] = vector.add(v, value)
        end
        return link
    end
end

function logic.range_check(luac_pos, pos2)
    local M = minetest.get_meta
    local ret_value = true
    local meta = M(luac_pos)
    local linking_range = meta:get_int("linking_range")
    local owner = meta:get_string("owner")
    if not pos2.x then
        for k, v in pairs(pos2) do
            ret_value = ret_value and in_square_radius(luac_pos, v, linking_range)
                and not minetest.is_protected(v, owner)
        end
    else
        ret_value = ret_value and in_square_radius(luac_pos, pos2, linking_range) and
            not minetest.is_protected(pos2, owner)
    end
    return ret_value
end

function logic.type_link(x, or_pos)
    if libox.type_vector(x) and or_pos then return true end

    local ret = true
    for k, v in pairs(x) do
        ret = ret and libox.type_vector(v)
    end
    return ret
end

function logic.try_to_unpack(x)
    if #x == 1 then return x[1] end
    return x
end

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

    if not in_square_radius(linked_pos, pos, linked_range) then
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
    light_source = 14,
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
    end
})



dofile(MP .. "/env.lua")
dofile(MP .. "/sandbox.lua")
dofile(MP .. "/code_disks.lua")

sbz_api.register_stateful_machine("sbz_logic:lua_controller", {
    tiles = { "luacontroller_top.png", "luacontroller_top.png", "luacontroller.png" },
    description = "Lua Controller",
    info_extra = {
        "The most complex block in this game.",
        "No like actually...",
        "Punch with the basic editor disk to get started.",
    },
    disallow_pipeworks = true,
    autostate = false,
    on_construct = function(pos)
        local meta = minetest.get_meta(pos)
        local inv = meta:get_inventory()
        inv:set_size("disks", 8)
        inv:set_size("upgrades", 8)
    end,
    after_place_node = function(pos, placer, stack, pointed)
        minetest.get_meta(pos):set_string("owner", placer:get_player_name())
    end,
    allow_metadata_inventory_put = function(pos, listname, index, stack, player)
        if listname == "disks" and minetest.get_item_group(stack:get_name(), "sbz_disk") ~= 1 then
            return 0
        elseif listname == "upgrades" then
            if minetest.get_item_group(stack:get_name(), "sbz_logic_upgrade") ~= 1 then
                return 0
            else
                minetest.registered_craftitems[stack:get_name()].action_in(stack, pos, minetest.get_meta(pos))
                return stack:get_count()
            end
        else
            return stack:get_count()
        end
    end,

    -- all TODOs: Make UPGRADES AND DISKS GREAT AGAI- WORK...
    allow_metadata_inventory_take = function(pos, listname, index, stack, player)
        if listname == "upgrades" then
            minetest.registered_craftitems[stack:get_name()].action_out(stack, pos, minetest.get_meta(pos))
        end
        return stack:get_count()
    end,

    allow_metadata_inventory_move = function(pos, from_list, from_index, to_list, to_index, count, player)
        return count
    end,

    action = logic.on_tick,
    action_subtick = function(pos, node, meta, supply, demand)
        logic.send_event_to_sandbox(pos, { type = "subtick", supply = supply, demand = demand })
        return 0
    end,
    action_subticking = true,
    on_logic_send = function(pos, msg, from_pos)
        logic.send_event_to_sandbox(pos, {
            type = "receive",
            msg = msg,
            from_pos = from_pos,
        })
    end,
    can_link = true,


    on_turn_off = logic.on_turn_off,
    after_dig = logic.on_turn_off,
    on_receive_fields = logic.on_receive_fields,
    groups = { sbz_luacontroller = 1, matter = 1 },

}, {
    light_source = 14
})
