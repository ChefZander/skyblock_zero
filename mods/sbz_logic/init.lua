sbz_api.logic = {}
local MP = minetest.get_modpath("sbz_logic")

local logic = sbz_api.logic

dofile(MP .. "/mesecon_queue.lua")
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
    allow_metadata_inventory_put = function(pos, listname, index, stack, player)
        if listname == "disks" and minetest.get_item_group(stack:get_name(), "sbz_disk") ~= 1 then
            return 0
        else
            return stack:get_count()
        end
    end,

    action = logic.on_tick,
    action_subtick = function(pos, node, meta, supply, demand)
        return 0
    end,
    on_turn_off = logic.on_turn_off,
    after_dig = logic.on_turn_off,
    on_receive_fields = logic.on_receive_fields,
    groups = { sbz_luacontroller = 1, matter = 1 },

}, {
    light_source = 14
})
