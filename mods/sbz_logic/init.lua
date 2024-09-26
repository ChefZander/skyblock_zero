sbz_api.logic = {}
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

minetest.register_craft {
    output = "sbz_logic:lua_controller",
    recipe = {
        { "sbz_resources:lua_chip", "sbz_logic:data_disk",         "sbz_resources:lua_chip" },
        { "sbz_resources:lua_chip", "sbz_resources:ram_stick_1kb", "sbz_resources:lua_chip" },
        { "sbz_resources:lua_chip", "sbz_resources:storinator",    "sbz_resources:lua_chip" },
    }
}

dofile(MP .. "/knowledge.lua")
