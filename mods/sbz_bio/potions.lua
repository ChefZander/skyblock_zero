minetest.register_craftitem('sbz_bio:screen_inverter_potion', {
    description = 'Potion of inverting',
    on_use = function(stack, user, pointed)
        if not user then return stack end

        -- Exponential saturation nyehehehe
        player_monoids.saturation:add_change(user, -1.1)

        stack:take_item()
        return stack
    end,
    info_extra = {
        "Doesn't actually invert your entire minetest, just changes saturation.",
        'Drink twice to negate the effects. Effects reset after re-join.',
        "Epilepsy Warning: Don't spam click, don't drink too often without rejoining.",
        'You may need to have post processing enabled for this to work.',
    },
    groups = { ui_bio = 1 },
    inventory_image = 'screen_inverter_potion.png',
})

do -- Screen Inverter Potion recipe scope
    local Screen_Inverter_Potion = 'sbz_bio:screen_inverter_potion'
    local CP = 'unifieddyes:colorium_powder'
    local EG = 'sbz_resources:emittrium_glass'
    core.register_craft({
        output = Screen_Inverter_Potion,
        recipe = {
            { CP },
            { EG },
        },
    })
end
