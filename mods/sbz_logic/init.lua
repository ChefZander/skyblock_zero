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
    on_construct = function(pos)
        local meta = minetest.get_meta(pos)
        local inv = meta:get_inventory()
        inv:set_size("disks", 16)
    end,
    action = function(pos, node, meta, supply, demand)
        return 0
    end,
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
