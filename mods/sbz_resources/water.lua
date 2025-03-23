-- would slow you 0.8x
playereffects.register_effect_type("wet", "Wet", "fx_wet.png", { "speed" }, function(player)
        unlock_achievement(player:get_player_name(), "Wet")
        player_monoids.speed:add_change(player, 0.8, "sbz_resources:wet")
    end,
    function(fx, player)
        player_monoids.speed:del_change(player, "sbz_resources:wet")
    end, false, true)

local water_color = "#576ee180"

minetest.register_node("sbz_resources:water_source", {
    description = "Water Source",
    drawtype = "liquid",
    tiles = {
        { name = "water.png", backface_culling = false, },
        { name = "water.png", backface_culling = true, },
    },
    inventory_image = minetest.inventorycube "water.png",
    use_texture_alpha = "blend",
    groups = { liquid = 3, habitat_conducts = 1, transparent = 1, liquid_capturable = 1, water = 1, cold = 5 },
    post_effect_color = water_color,
    paramtype = "light",
    sunlight_propagates = true,
    walkable = false,
    pointable = false,
    buildable_to = true,
    liquidtype = "source",
    liquid_alternative_source = "sbz_resources:water_source",
    liquid_alternative_flowing = "sbz_resources:water_flowing",
    drop = "",
    liquid_viscosity = 1,
    drowning = 1,
    sbz_player_inside = function(_, player)
        playereffects.apply_effect_type("wet", 2, player)
    end
})

local animation = {
    type = "vertical_frames",
    aspect_w = 16,
    aspect_h = 16,
    length = 0.5,
}

minetest.register_node("sbz_resources:water_flowing", {
    description = "Flowing Water",
    drawtype = "flowingliquid",
    tiles = { "water.png" },
    special_tiles = {
        {
            name = "flowing_water.png",
            backface_culling = false,
            animation = animation
        },
        {
            name = "flowing_water.png",
            backface_culling = true,
            animation = animation
        }
    },
    use_texture_alpha = "blend",
    groups = { liquid = 3, habitat_conducts = 1, transparent = 1, not_in_creative_inventory = 1, water = 1, cold = 5 },
    post_effect_color = water_color,
    paramtype = "light",
    paramtype2 = "flowingliquid",
    walkable = false,
    pointable = false,
    diggable = false,
    buildable_to = true,
    liquidtype = "flowing",
    liquid_alternative_source = "sbz_resources:water_source",
    liquid_alternative_flowing = "sbz_resources:water_flowing",
    drop = "",
    liquid_viscosity = 1,
    drowning = 1,
    sbz_player_inside = function(_, player)
        playereffects.apply_effect_type("wet", 2, player)
    end
})
