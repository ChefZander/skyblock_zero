minetest.register_craftitem("sbz_resources:simple_circuit", {
    description = "Simple Circuit",
    inventory_image = "simple_circuit.png",
    stack_max = 256,
})
minetest.register_craft({
    type = "shapeless",
    output = "sbz_resources:simple_circuit 2",
    recipe = { "sbz_resources:core_dust", "sbz_resources:matter_blob" }
})

minetest.register_craftitem("sbz_resources:retaining_circuit", {
    description = "Retaining Circuit",
    inventory_image = "retaining_circuit.png",
    stack_max = 256,
})
minetest.register_craft({
    type = "shapeless",
    output = "sbz_resources:retaining_circuit",
    recipe = { "sbz_resources:charged_particle", "sbz_resources:antimatter_dust", "sbz_resources:simple_circuit" }
})

minetest.register_craftitem("sbz_resources:emittrium_circuit", {
    description = "Emittrium Circuit",
    inventory_image = "emittrium_circuit.png",
    stack_max = 256,
})
minetest.register_craft({
    type = "shapeless",
    output = "sbz_resources:emittrium_circuit",
    recipe = { "sbz_resources:charged_particle", "sbz_resources:retaining_circuit", "sbz_resources:raw_emittrium", "sbz_resources:matter_plate" }
})

minetest.register_craftitem("sbz_resources:matter_plate", {
    description = "Matter Plate",
    inventory_image = "matter_plate.png",
    stack_max = 256,
})
minetest.register_craft({
    type = "shapeless",
    output = "sbz_resources:matter_plate 4",
    recipe = { "sbz_resources:matter_blob" }
})
minetest.register_craftitem("sbz_resources:antimatter_plate", {
    description = "Antimatter Plate",
    inventory_image = "antimatter_plate.png",
    stack_max = 256,
})
minetest.register_craft({
    type = "shapeless",
    output = "sbz_resources:antimatter_plate 4",
    recipe = { "sbz_resources:antimatter_blob" }
})

minetest.register_craftitem("sbz_resources:conversion_chamber", {
    description = "Conversion Chamber",
    inventory_image = "conversion_chamber.png",
    stack_max = 32,
})
minetest.register_craft({
    type = "shapeless",
    output = "sbz_resources:conversion_chamber",
    recipe = { "sbz_resources:matter_blob", "sbz_resources:retaining_circuit", "sbz_resources:matter_annihilator" }
})

minetest.register_craftitem("sbz_resources:pebble", {
    description = "Pebble",
    inventory_image = "pebble.png",
    stack_max = 32,
})
minetest.register_craft({
    type = "shapeless",
    output = "sbz_resources:pebble",
    recipe = { "sbz_resources:matter_blob", "sbz_resources:matter_blob", "sbz_resources:matter_blob" }
})

-- Angel's Wing
minetest.register_tool("sbz_resources:angels_wing", {
    description = "Angel's Wing",
    inventory_image = "angels_wing.png",
    stack_max = 1,
    tool_capabilities = {}, -- No specific tool capabilities, as it's not meant for digging

    on_use = function(itemstack, user, pointed_thing)
        -- Check if user is valid
        if not user then
            return itemstack
        end

        -- Get the player's current velocity
        local player_velocity = user:get_velocity()

        -- Apply a small upward velocity
        local new_velocity = { x = player_velocity.x, y = 10, z = player_velocity.z }
        user:add_velocity(new_velocity)

        -- Decrease item durability
        local wear = itemstack:get_wear()
        wear = wear +
            (65535 / 100) -- 65535 is the max wear value in Minetest. 100 uses means wear increases by 655.35 per use.

        if wear >= 65535 then
            itemstack:clear() -- Remove the item if it's worn out
            unlock_achievement(user:get_player_name(), "Fragile")
        else
            itemstack:set_wear(wear) -- Update the wear value
        end

        return itemstack
    end,
})

minetest.register_craft({
    output = "sbz_resources:angels_wing",
    recipe = {
        { "sbz_resources:stone", "sbz_resources:stone",             "sbz_resources:stone" },
        { "sbz_resources:stone", "sbz_resources:emittrium_circuit", "sbz_resources:stone" },
        { "sbz_resources:stone", "sbz_resources:stone",             "sbz_resources:stone" }
    }
})

minetest.register_node("sbz_resources:compressed_core_dust", {
    description = "Compressed core dust",
    tiles = {
        "compressed_core_dust.png"
    },
    groups = { matter = 1, explody = 10 },
    sounds = sbz_api.sounds.matter(),
})

minetest.register_craft({
    output = "sbz_resources:compressed_core_dust",
    recipe = {
        { "sbz_resources:core_dust", "sbz_resources:core_dust", "sbz_resources:core_dust" },
        { "sbz_resources:core_dust", "sbz_resources:core_dust", "sbz_resources:core_dust" },
        { "sbz_resources:core_dust", "sbz_resources:core_dust", "sbz_resources:core_dust" },
    }
})

minetest.register_craft {
    output = "sbz_resources:core_dust 9",
    recipe = {
        { "sbz_resources:compressed_core_dust" }
    }
}

core.register_craftitem("sbz_resources:warp_crystal", {
    description = "Warp Crystal",
    inventory_image = "warp_crystal.png",
})
