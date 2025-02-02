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

core.register_entity("sbz_resources:warp_crystal_entity", {
    initial_properties = {
        visual = "sprite",
        visual_size = { x = 1, y = 1, z = 1 },
        pointable = false,
        collide_with_objects = true,
        physical = true,
        textures = { "warp_crystal.png" },
        glow = 14,
        static_save = false,
    },
    on_activate = function(self, staticdata, dtime_s)
        staticdata = core.deserialize(staticdata)
        self.object:set_armor_groups { matter = 100, antimatter = 100 }
        self.owner = staticdata.owner
        self.direction = staticdata.direction
        self.object:set_acceleration(vector.new(0, -sbz_api.gravity, 0))
        self.object:set_velocity(vector.multiply(vector.add(vector.new(30, 30, 30), staticdata.vel), self.direction))
    end,
    on_punch = function(self)
        -- looks like your throwing got interrupted, teleport the owner
        if core.get_player_by_name(self.owner) then
            core.get_player_by_name(self.owner):set_pos(self.object:get_pos())
        end
        self.object:remove()
    end,
    on_death = function(self, killer)
        if core.get_player_by_name(self.owner) then
            core.get_player_by_name(self.owner):set_pos(self.object:get_pos())
        end
        self.object:remove()
    end,
    on_step = function(self, dtime, moveresult)
        if moveresult.collides then
            local player = core.get_player_by_name(self.owner)
            if player and player:is_valid() then
                for k, v in pairs(moveresult.collisions) do
                    if v.type == "object" and sbz_api.can_move_object(v.object:get_armor_groups()) then
                        local objpos = v.object:get_pos()
                        local playerpos = player:get_pos()
                        player:set_pos(objpos)
                        v.object:set_pos(playerpos)
                        self.object:remove()
                        return
                    end
                end
                player:set_pos(self.object:get_pos())

                self.object:remove()
            end
        end
    end
})

core.register_craftitem("sbz_resources:warp_crystal", {
    description = "Warp Crystal",
    inventory_image = "warp_crystal.png",
    info_extra = "You can throw it. Also if you throw it at an entity you will swap places.",
    on_use = function(stack, placer, pointed)
        local look_dir = placer:get_look_dir()
        local name = placer:get_player_name()
        if placer.is_fake_player then name = "" end
        core.add_entity(
            vector.add(sbz_api.get_pos_with_eye_height(placer), vector.multiply(look_dir, 0.1)),
            "sbz_resources:warp_crystal_entity",
            core.serialize { owner = name, direction = look_dir, vel = placer:get_velocity() })
        stack:set_count(stack:get_count() - 1)
        return stack
    end
})


core.register_craftitem("sbz_resources:phlogiston", {
    description = "Phlogiston",
    inventory_image = "phlogiston.png"
})

core.register_craftitem("sbz_resources:phlogiston_circuit", {
    description = "Phlogiston Circuit",
    inventory_image = "phlogiston_circuit.png"
})

core.register_craft {
    type = "shapeless",
    output = "sbz_resources:phlogiston_circuit 4",
    recipe = {
        "sbz_resources:emittrium_circuit", "sbz_resources:emittrium_circuit", "sbz_resources:phlogiston",
        "sbz_resources:emittrium_circuit", "sbz_resources:emittrium_circuit", "sbz_resources:phlogiston",
        "sbz_power:simple_charged_field", "sbz_resources:antimatter_blob", "sbz_resources:compressed_core_dust",
    }
}

-- used in meteorite radars and weapons
core.register_craftitem("sbz_resources:prediction_circuit", {
    description = "Prediction Circuit",
    inventory_image = "prediction_circuit.png",
})

core.register_craft {
    type = "shapeless",
    output = "sbz_resources:prediction_circuit",
    recipe = {
        "sbz_resources:emittrium_circuit", "sbz_resources:emittrium_circuit", "sbz_chem:titanium_alloy_ingot",
        "sbz_resources:raw_emittrium", "sbz_resources:raw_emittrium", "sbz_resources:raw_emittrium"
    }
}
