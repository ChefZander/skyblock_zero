local generator_power_production = 30
sbz_api.register_generator("sbz_power:simple_charge_generator", {
    description = "Simple Charge Generator\n\nGenerates: 30 power.\nRequires 1 Core Dust per 10 Seconds to run.",
    tiles = { "simple_charge_generator.png" },
    groups = { matter = 1, sbz_machine = 1, pipe_connects = 1 },
    sunlight_propagates = true,
    walkable = true,
    on_rightclick = function(pos, node, player, pointed_thing)
        local player_name = player:get_player_name()
        minetest.show_formspec(player_name, "sbz_power:simple_charge_generator_formspec",
            "formspec_version[7]" ..
            "size[8.2,9]" ..
            "style_type[list;spacing=.2;size=.8]" ..
            "list[nodemeta:" .. pos.x .. "," .. pos.y .. "," .. pos.z .. ";main;3.5,2;1,1;]" ..
            "list[current_player;main;0.2,5;8,4;]" ..
            "listring[]")

        minetest.sound_play("machine_open", {
            to_player = player_name,
            gain = 1.0,
        })
    end,
    on_construct = function(pos)
        local meta = minetest.get_meta(pos)
        local inv = meta:get_inventory()
        inv:set_size("main", 1)


        minetest.sound_play("machine_build", {
            to_player = player_name,
            gain = 1.0,
        })

        meta:set_int("count", 10)
    end,

    action = function(pos, node, meta)
        local count = meta:get_int("count")
        count = count - 1
        meta:set_int("count", count)
        local inv = meta:get_inventory()

        -- check if fuel is there
        if not inv:contains_item("main", "sbz_resources:core_dust") then
            minetest.add_particlespawner({
                amount = 10,
                time = 1,
                minpos = { x = pos.x - 0.5, y = pos.y - 0.5, z = pos.z - 0.5 },
                maxpos = { x = pos.x + 0.5, y = pos.y + 0.5, z = pos.z + 0.5 },
                minvel = { x = -0.5, y = -0.5, z = -0.5 },
                maxvel = { x = 0.5, y = 0.5, z = 0.5 },
                minacc = { x = 0, y = 0, z = 0 },
                maxacc = { x = 0, y = 0, z = 0 },
                minexptime = 5,
                maxexptime = 10,
                minsize = 0.5,
                maxsize = 1.0,
                collisiondetection = false,
                vertical = false,
                texture = "error_particle.png",
                glow = 10
            })
            meta:set_string("infotext", "Stopped")
            return 0
        end
        if count <= 0 then
            meta:set_int("count", 10)
            local stack = inv:get_stack("main", 1)
            if stack:is_empty() then
                meta:set_string("infotext", "Stopped")
                return 0
            end

            stack:take_item(1)
            inv:set_stack("main", 1, stack)

            minetest.add_particlespawner({
                amount = 25,
                time = 1,
                minpos = { x = pos.x - 0.5, y = pos.y - 0.5, z = pos.z - 0.5 },
                maxpos = { x = pos.x + 0.5, y = pos.y + 0.5, z = pos.z + 0.5 },
                minvel = { x = 0, y = 5, z = 0 },
                maxvel = { x = 0, y = 5, z = 0 },
                minacc = { x = 0, y = 0, z = 0 },
                maxacc = { x = 0, y = 0, z = 0 },
                minexptime = 1,
                maxexptime = 3,
                minsize = 0.5,
                maxsize = 1.0,
                collisiondetection = false,
                vertical = false,
                texture = "charged_particle.png",
                glow = 10
            })
        end
        meta:set_string("infotext", "Running")
        return generator_power_production
    end,
    input_inv = "main",
    output_inv = "main",
})


minetest.register_craft({
    output = "sbz_power:simple_charge_generator",
    recipe = {
        { "sbz_power:simple_charged_field", "sbz_resources:antimatter_dust",    "sbz_power:simple_charged_field" },
        { "sbz_resources:matter_blob",      "sbz_resources:matter_annihilator", "sbz_resources:matter_blob" },
        { "sbz_power:simple_charged_field", "sbz_resources:matter_blob",        "sbz_power:simple_charged_field" }
    }
})

sbz_api.register_generator("sbz_power:simple_charged_field", {
    description = "Simple Charged Field\n\nGenerates: 3 power.\nDecaying: 10% chance every 100s. (when placed)",
    drawtype = "glasslike",
    tiles = { "simple_charged_field.png" },
    groups = { matter = 1, cracky = 3, sbz_machine = 1 },
    sunlight_propagates = true,
    walkable = false,
    power_generated = 3,
    on_dig = function(pos, node, digger)
        minetest.sound_play("charged_field_shutdown", {
            gain = 5.0,
            max_hear_distance = 32,
            pos = pos,
        })
        minetest.node_dig(pos, node, digger)
    end,
})
minetest.register_craft({
    output = "sbz_power:simple_charged_field",
    recipe = {
        { "sbz_resources:charged_particle", "sbz_resources:charged_particle", "sbz_resources:charged_particle" },
        { "sbz_resources:charged_particle", "sbz_resources:charged_particle", "sbz_resources:charged_particle" },
        { "sbz_resources:charged_particle", "sbz_resources:charged_particle", "sbz_resources:charged_particle" }
    }
})
minetest.register_abm({
    label = "Simple Charged Field Particles",
    nodenames = { "sbz_power:simple_charged_field" },
    interval = 1,
    chance = 1,
    action = function(pos, node, active_object_count, active_object_count_wider)
        minetest.add_particlespawner({
            amount = 5,
            time = 1,
            minpos = { x = pos.x - 0.5, y = pos.y - 0.5, z = pos.z - 0.5 },
            maxpos = { x = pos.x + 0.5, y = pos.y + 0.5, z = pos.z + 0.5 },
            minvel = { x = -2, y = -2, z = -2 },
            maxvel = { x = 2, y = 2, z = 2 },
            minacc = { x = 0, y = 0, z = 0 },
            maxacc = { x = 0, y = 0, z = 0 },
            minexptime = 10,
            maxexptime = 20,
            minsize = 0.5,
            maxsize = 1.0,
            collisiondetection = false,
            vertical = false,
            texture = "charged_particle.png",
            glow = 10
        })
    end,
})
minetest.register_abm({
    label = "Simple Charged Field Decay",
    nodenames = { "sbz_power:simple_charged_field" },
    interval = 100,
    chance = 10,
    action = function(pos, node, active_object_count, active_object_count_wider)
        minetest.after(1, function()
            -- field decayed
            minetest.set_node(pos, { name = "sbz_power:charged_field_residue" })

            -- plop
            minetest.sound_play("decay", { pos = pos, gain = 1.0 })

            -- more particles!
            minetest.add_particlespawner({
                amount = 100,
                time = 1,
                minpos = { x = pos.x - 0.5, y = pos.y - 0.5, z = pos.z - 0.5 },
                maxpos = { x = pos.x + 0.5, y = pos.y + 0.5, z = pos.z + 0.5 },
                minvel = { x = -5, y = -5, z = -5 },
                maxvel = { x = 5, y = 5, z = 5 },
                minacc = { x = 0, y = 0, z = 0 },
                maxacc = { x = 0, y = 0, z = 0 },
                minexptime = 10,
                maxexptime = 20,
                minsize = 0.5,
                maxsize = 1.0,
                collisiondetection = false,
                vertical = false,
                texture = "charged_particle.png",
                glow = 10
            })
        end)
    end,
})

minetest.register_node("sbz_power:charged_field_residue", {
    description = "Charged Field Residue",
    drawtype = "glasslike",
    tiles = { "charged_field_residue.png" },
    groups = { unbreakable = 1 },
    sunlight_propagates = true,
    walkable = true,
    on_punch = function(pos, node, puncher, pointed_thing)
        displayDialougeLine(puncher:get_player_name(), "The residue is still decaying.")
    end,
})
minetest.register_abm({
    label = "Charged Field Residue Decay",
    nodenames = { "sbz_power:charged_field_residue" },
    interval = 100,
    chance = 10,
    action = function(pos, node, active_object_count, active_object_count_wider)
        -- residue decayed
        minetest.set_node(pos, { name = "air" })

        -- plop, again
        minetest.sound_play("decay", { pos = pos, gain = 1.0 })
    end,
})

-- Starlight Collector
sbz_api.register_generator("sbz_power:starlight_collector", {
    description = "Starlight Collector",
    drawtype = "nodebox",
    tiles = { "starlight_collector.png", "matter_blob.png", "matter_blob.png", "matter_blob.png", "matter_blob.png", "matter_blob.png" },
    groups = { matter = 1, pipe_connects = 1 },
    sunlight_propagates = true,
    walkable = true,
    node_box = {
        type = "fixed",
        fixed = { -0.5, -0.5, -0.5, 0.5, 0, 0.5 },
    },
    use_texture_alpha = "clip",

    power_generated = 1,
})

minetest.register_craft({
    output = "sbz_power:starlight_collector",
    recipe = {
        { "sbz_resources:raw_emittrium", "sbz_resources:raw_emittrium", "sbz_resources:raw_emittrium" },
        { "sbz_power:power_pipe",        "sbz_power:power_pipe",        "sbz_power:power_pipe" },
        { "sbz_resources:matter_blob",   "sbz_resources:matter_blob",   "sbz_resources:matter_blob" }
    }
})
minetest.register_abm({
    label = "Starlight Collector Particles",
    nodenames = { "sbz_power:starlight_collector" },
    interval = 1,
    chance = 0.5,
    action = function(pos, node, active_object_count, active_object_count_wider)
        minetest.add_particlespawner({
            amount = 2,
            time = 1,
            minpos = { x = pos.x - 0.5, y = pos.y + 0.5, z = pos.z - 0.5 },
            maxpos = { x = pos.x + 0.5, y = pos.y + 1, z = pos.z + 0.5 },
            minvel = { x = 0, y = -2, z = 0 },
            maxvel = { x = 0, y = -1, z = 0 },
            minacc = { x = 0, y = 0, z = 0 },
            maxacc = { x = 0, y = 0, z = 0 },
            minexptime = 1,
            maxexptime = 1,
            minsize = 0.5,
            maxsize = 1.0,
            collisiondetection = true,
            vertical = false,
            texture = "star.png",
            glow = 10
        })
    end,
})
