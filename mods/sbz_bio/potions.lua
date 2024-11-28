minetest.register_craftitem("sbz_bio:screen_inverter_potion", {
    description = "Potion of inverting",
    on_use = function(stack, user, pointed)
        if not user then return stack end

        user:set_lighting({
            saturation = user:get_lighting().saturation * -1.1 -- :troll: its actually -1.1
        })
        stack:take_item()
        return stack
    end,
    info_extra = {
        "Doesn't actually invert your entire minetest, just changes saturation.",
        "Drink twice to negate the effects. Effects reset after re-join.",
        "Epilepsy Warning: Don't spam click, don't drink too often without rejoining.",
        "You may need to have post processing enabled for this to work."
    },
    groups = { ui_bio = 1 },
    inventory_image = "screen_inverter_potion.png"
})

minetest.register_craft {
    output = "sbz_bio:screen_inverter_potion",
    recipe = {
        { "unifieddyes:colorium_powder" },
        { "sbz_resources:emittrium_glass" }
    }
}
