sbz_api.register_generator("sbz_resources:simple_charge_generator", {
    description = "Simple Charge Generator\n\nGenerates: 10 power.\nRequires 1 Core Dust per 10 Seconds to run.",
    tiles = { "simple_charge_generator.png" },
    groups = { matter = 1, sbz_machine = 1 },
    sunlight_propagates = true,
    walkable = true,
    on_rightclick = function(pos, node, player, pointed_thing)
        local player_name = player:get_player_name()
        minetest.show_formspec(player_name, "sbz_resources:simple_charge_generator_formspec",
            "formspec_version[7]" ..
            "size[8,9]" ..
            "style_type[list;spacing=.2;size=.8]" ..
            "list[nodemeta:" .. pos.x .. "," .. pos.y .. "," .. pos.z .. ";main;3.5,2;1,1;]" ..
            "list[current_player;main;0,5;8,4;]" ..
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
    end,

    generation_condition = function(pos, node, meta)
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
            return false
        end

        local stack = inv:get_stack("main", 1)
        if stack:is_empty() then
            return false
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
        return true
    end,
    power_generated = 10,
})


minetest.register_craft({
    output = "sbz_resources:simple_charge_generator",
    recipe = {
        { "sbz_resources:simple_charged_field", "sbz_resources:antimatter_dust",    "sbz_resources:simple_charged_field" },
        { "sbz_resources:matter_blob",          "sbz_resources:matter_annihilator", "sbz_resources:matter_blob" },
        { "sbz_resources:simple_charged_field", "sbz_resources:matter_blob",        "sbz_resources:simple_charged_field" }
    }
})