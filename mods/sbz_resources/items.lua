minetest.register_craftitem("sbz_resources:matter_plate", {
    description = "Matter Plate",
    inventory_image = "matter_plate.png",
    stack_max = 256,
})

do -- Matter Plate recipe scope
    local Matter_Plate = 'sbz_resources:matter_plate'
    local amount = 4
    local MB = 'sbz_resources:matter_blob'
    core.register_craft({
        type = 'shapeless',
        output = Matter_Plate .. ' ' .. tostring(amount),
        recipe = { MB }
    })
end

minetest.register_craftitem("sbz_resources:antimatter_plate", {
    description = "Antimatter Plate",
    inventory_image = "antimatter_plate.png",
    stack_max = 256,
})

do -- Antimatter Plate recipe scope
    local Antimatter_Plate = 'sbz_resources:antimatter_plate'
    local amount = 4
    local AB = 'sbz_resources:antimatter_blob'
    core.register_craft({
        type = 'shapeless',
        output = Antimatter_Plate .. ' ' .. tostring(amount),
        recipe = { AB }
    })
end

minetest.register_craftitem("sbz_resources:conversion_chamber", {
    description = "Conversion chamber (!! DEPRECATED !! Throw it away!)",
    inventory_image = "conversion_chamber.png",
    stack_max = 1,
    groups = { not_in_creative_inventory = 1, }
})

minetest.register_craftitem("sbz_resources:pebble", {
    description = "Pebble",
    inventory_image = "pebble.png",
    stack_max = 128,
})

do -- Pebble recipe scope
    local Pebble = 'sbz_resources:pebble'
    local MB = 'sbz_resources:matter_blob'
    core.register_craft({
        type = 'shapeless',
        output = Pebble,
        recipe = { MB, MB, MB }
    })
end

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

do -- Angels Wing recipe scope
    local Angels_Wing = 'sbz_resources:angels_wing'
    local St = 'sbz_resources:stone'
    local EC = 'sbz_resources:emittrium_circuit'
    core.register_craft({
        output = Angels_Wing,
        recipe = {
            { St, St, St },
            { St, EC, St },
            { St, St, St }
        }
    })
end

core.register_craftitem("sbz_resources:phlogiston", {
    description = "Phlogiston",
    inventory_image = "phlogiston.png"
})

core.register_node("sbz_resources:phlogiston_blob", {
    description = "Phlogiston Blob",
    tiles = { "phlogiston_blob.png" },
    groups = { matter = 1, charged = 1 },
    light_source = 14
})

do -- Phlogiston Blob recipe scope
    local Phlogiston_Blob = 'sbz_resources:phlogiston_blob'
    local Ph = 'sbz_resources:phlogiston'
    core.register_craft({
        output = Phlogiston_Blob,
        recipe = {
            { Ph, Ph, Ph },
            { Ph, Ph, Ph },
            { Ph, Ph, Ph },
        }
    })
end

core.register_craftitem("sbz_resources:heating_element", {
    description = "Heating Element",
    inventory_image = "heating_element.png",
})

do -- Heating Element recipe scope
    local Heating_Element = 'sbz_resources:heating_element'
    local CI = 'sbz_chem:copper_ingot'
    local II = 'sbz_chem:invar_ingot'
    local EC = 'sbz_resources:emittrium_circuit'
    core.register_craft({
        output = Heating_Element,
        recipe = {
            { CI, CI, CI },
            { II, II, II },
            { EC, EC, EC },
        }
    })
end

core.register_craftitem("sbz_resources:sensor_casing_plate", {
    description = "Sensor Casing Plate",
    inventory_image = "sensor_casing_plate.png"
})
