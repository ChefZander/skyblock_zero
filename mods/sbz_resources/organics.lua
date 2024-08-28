minetest.register_node("sbz_resources:organic_converter", {
    description = "Organic Converter\n\nConverts Matter into Organic Matter.",
    tiles = { "organic_converter.png" },
    groups = { matter = 1 },
    sunlight_propagates = true,
    walkable = true,
    on_rightclick = function(pos, node, player, pointed_thing)
        local player_name = player:get_player_name()
        minetest.sound_play("machine_open", {
            to_player = player_name,
            gain = 1.0,
            pos = pos
        })

        -- check the item the player is holding, and craft something based from it
        -- if holding nothing, display info message
        displayDialougeLine(player_name, "I'm still working on this.")
    end,
    on_construct = function(pos)
        minetest.sound_play("machine_build", {
            to_player = player_name,
            gain = 1.0,
            pos = pos
        })
    end,
})

minetest.register_craft({
    output = "sbz_resources:organic_converter",
    recipe = {
        { "sbz_resources:simple_circuit", "sbz_resources:antimatter_dust",    "sbz_resources:simple_circuit" },
        { "sbz_resources:matter_blob",    "sbz_resources:conversion_chamber", "sbz_resources:matter_blob" },
        { "sbz_resources:simple_circuit", "sbz_resources:matter_blob",        "sbz_resources:simple_circuit" }
    }
})

minetest.register_node("sbz_resources:dirt", {
    description = "Dirt",
    tiles = { "dirt.png" },
    groups = { matter = 1 },
    sunlight_propagates = true,
    walkable = true,
})
minetest.register_node("sbz_resources:soil", {
    description = "Soil",
    tiles = { "soil.png" },
    groups = { matter = 1 },
    sunlight_propagates = true,
    walkable = true,
})
