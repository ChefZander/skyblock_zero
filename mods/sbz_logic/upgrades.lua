local logic = sbz_api.logic

--[[
    def.action_in = function(stack, logic_pos, logic_meta) -- what will happen if the upgrade gets inserted
    def.action_out = function(stack, logic_pos, logic_meta) -- undo that ^
]]

logic.register_upgrade = function(name, def)
    def.groups = { sbz_logic_upgrade = 1, }
    minetest.register_craftitem(name, def)
end

logic.register_upgrade("sbz_logic:linking_upgrade", {
    info_extra = { "Upgrades linking radius by 8, you can have multiple of theese" },
    stack_max = 1,
    description = "Linking upgrade",
    action_in = function(stack, logic_pos, logic_meta)
        logic_meta:set_int("linking_range", logic_meta:get_int "linking_range" + 8)
    end,
    action_out = function(stack, logic_pos, logic_meta)
        logic_meta:set_int("linking_range", logic_meta:get_int "linking_range" - 8)
    end,
    inventory_image = "luacontroller_linking_upgrade.png"
})
