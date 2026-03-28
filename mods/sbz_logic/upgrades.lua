local logic = sbz_api.logic

--[[
    def.action_in = function(stack, logic_pos, logic_meta) -- what will happen if the upgrade gets inserted
    def.action_out = function(stack, logic_pos, logic_meta) -- undo that ^
]]

minetest.register_craftitem("sbz_logic:upgrade_template", {
    description = "Logic Upgrade Template",
    inventory_image = "upgrade_template.png",
    groups = { ui_logic = 1 }
})

do -- Upgrade Template recipe scope
    local Upgrade_Template = 'sbz_logic:upgrade_template'
    local NI = 'sbz_chem:nickel_ingot'
    local EC = 'sbz_resources:emittrium_circuit'
    core.register_craft({
        output = Upgrade_Template,
        recipe = {
            { '', NI, '' },
            { NI, EC, NI },
            { '', NI, '' },
        }
    })
end

logic.register_upgrade = function(name, def)
    def.groups = { sbz_logic_upgrade = 1, ui_logic = 1 }
    minetest.register_craftitem(name, def)
end

logic.register_upgrade("sbz_logic:linking_upgrade", {
    info_extra = { "Upgrades linking radius by 8, you can have 3 of these", "Also it is needed for *any* sort of communication, or getting information about the world." },
    stack_max = 1,
    same_upgrade_max = 3,
    description = "Linking Upgrade",
    action_in = function(stack, logic_pos, logic_meta)
        logic_meta:set_int("linking_range", logic_meta:get_int "linking_range" + 8)
    end,
    action_reset = function(stack, logic_pos, logic_meta)
        logic_meta:set_int("linking_range", 0)
    end,
    inventory_image = "luacontroller_linking_upgrade.png"
})

do -- Linking Upgrade recipe scope
    local Linking_Upgrade = 'sbz_logic:linking_upgrade'
    local LL = 'sbz_logic:luacontroller_linker'
    local UT = 'sbz_logic:upgrade_template'
    core.register_craft({
        output = Linking_Upgrade,
        recipe = {
            { LL, UT }
        }
    })
end
