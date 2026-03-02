local r = replacer

-- really overpowered tool... so... complicated recipe :D
do -- Bulk Placer Tool recipe scope
    local Bulk_Placer = 'replacer:replacer'
    local ME = 'sbz_resources:movable_emitter'
    local LB = 'sbz_logic_devices:builder' -- ("Lua Builder" in-game)
    local CE = 'sbz_bio:colorium_emitter'
    local VA = 'sbz_power:very_advanced_battery'
    core.register_craft({
        output = Bulk_Placer,
        recipe = {
            { ME, LB, CE },
            { '', VA, '' },
            { '', VA, '' },
        }
    })
end
