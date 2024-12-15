sbz_api.logic = {}
sbz_logic = sbz_api.logic

local MP = minetest.get_modpath("sbz_logic")

local logic = sbz_api.logic
dofile(MP .. "/utils.lua")
dofile(MP .. "/mesecon_queue.lua")
dofile(MP .. "/comm.lua")
dofile(MP .. "/upgrades.lua")
dofile(MP .. "/link_tool.lua")

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
        pipeworks.after_place(pos)
    end,
    allow_metadata_inventory_put = function(pos, listname, index, stack, player)
        if listname == "disks" and minetest.get_item_group(stack:get_name(), "sbz_disk") ~= 1 then
            return 0
        elseif listname == "upgrades" then
            if minetest.get_item_group(stack:get_name(), "sbz_logic_upgrade") ~= 1 then
                return 0
            else
                local stackname = stack:get_name()
                local def = minetest.registered_craftitems[stackname]
                local meta = minetest.get_meta(pos)

                local same_upgrade_count = 0
                local inv = meta:get_inventory()
                for i, inv_stack in ipairs(inv:get_list("upgrades")) do
                    if inv_stack:get_name() == stackname then
                        same_upgrade_count = same_upgrade_count + 1
                    end
                end
                if same_upgrade_count < def.same_upgrade_max then
                    def.action_in(stack, pos, meta)
                    return stack:get_count()
                else
                    return 0
                end
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
        if to_list == "disks" and from_list == "disks" then return 0 end
        return count
    end,

    action = logic.on_tick,
    action_subtick = function(pos, node, meta, supply, demand)
        logic.send_event_to_sandbox(pos, { type = "subtick", supply = supply, demand = demand })
        return 0
    end,

    on_logic_send = function(pos, msg, from_pos)
        logic.send_event_to_sandbox(pos, {
            type = "receive",
            msg = msg,
            from_pos = from_pos,
        })
    end,
    can_link = true,

    on_turn_off = logic.on_turn_off,
    after_dig_node = logic.on_turn_off,
    on_receive_fields = logic.on_receive_fields,
    groups = {
        sbz_luacontroller = 1, matter = 1, ui_logic = 1, tubedevice = 1, tubedevice_receiver = 1, sbz_machine_subticking = 1
    },
    tube = {
        input_inventory = "disks",
        insert_object = function(pos, node, stack, direction)
            local meta = minetest.get_meta(pos)
            local inv = meta:get_inventory()
            if minetest.get_item_group(stack:get_name(), "sbz_disk") ~= 1 then return stack end
            return inv:add_item("disks", stack)
        end,
        can_insert = function(pos, node, stack, direction)
            local meta = minetest.get_meta(pos)
            local inv = meta:get_inventory()
            stack:peek_item(1)
            if minetest.get_item_group(stack:get_name(), "sbz_disk") ~= 1 then return false end
            return inv:room_for_item("disks", stack)
        end,
        connect_sides = { left = 1, right = 1, back = 1, front = 1, top = 1, bottom = 1 },
    },
}, {
    light_source = 14
})

mesecon.register_on_mvps_move(function(moved)
    for i = 1, #moved do
        local moved_node = moved[i]
        if moved_node.node.name == "sbz_logic:lua_controller_on" or moved_node.node.name == "sbz_logic:lua_controller_off" then
            minetest.after(0, function()
                local linked_meta = core.get_meta(moved_node.pos)
                local links = minetest.deserialize(linked_meta:get_string("links")) or {}

                for k, more_links in pairs(links) do
                    for kk, link in pairs(more_links) do
                        more_links[kk] = vector.copy(link) - vector.copy(moved_node.oldpos) + vector.copy(moved_node.pos)
                    end
                end

                linked_meta:set_string("links", minetest.serialize(links))
            end)
        end
    end
end)

minetest.register_craft {
    output = "sbz_logic:lua_controller",
    recipe = {
        { "sbz_resources:lua_chip", "sbz_logic:data_disk",         "sbz_resources:lua_chip" },
        { "sbz_resources:lua_chip", "sbz_resources:ram_stick_1mb", "sbz_resources:lua_chip" },
        { "sbz_resources:lua_chip", "sbz_resources:warp_crystal",  "sbz_resources:lua_chip" },
    }
}

dofile(MP .. "/knowledge.lua")
