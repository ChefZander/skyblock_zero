minetest.register_craftitem("sbz_bio:screen_inverter_potion", {
    description = "Potion of inverting",
    on_use = function(stack, user, pointed)
        if not user then return stack end

        user:set_lighting({
            saturation = user:get_lighting().saturation * -1
        })
        stack:take_item()
        return stack
    end,
    info_extra = {
        "Doesn't actually invert your entire minetest... just sets saturation to -1",
        "Drink twice to negate the effects"
    },
    groups = { ui_bio = 1 },
    inventory_image = "screen_inverter_potion.png"
})

minetest.register_craft {
    output = "sbz_bio:screen_inverter_potion",
    recipe = {
        { "sbz_resources:warpshroom" },
        { "sbz_resources:emittrium_glass" }
    }
}
