minetest.register_craftitem("sbz_runes:meteoric_rune", {
    description = "¤ Meteoric Rune\nCosmetic: Surrounds you with meteorite particles.\n1/100k chance when breaking Meteoric Matter.",
    inventory_image = "flame_rune.png",
    stack_max = 1,
})

minetest.register_craftitem("sbz_runes:core_rune", {
    description = "¤ Core Rune\nCosmetic: Surrounds you with core particles like The Core.\n1/1m chance when punching The Core.",
    inventory_image = "core_rune.png",
    stack_max = 1,
})

minetest.register_craftitem("sbz_runes:firework_rune", {
    description = "¤ Firework Rune\nCosmetic: Occasionally fires off firework rockets on it's own.\n1/100k chance when firing off a firework rocket.",
    inventory_image = "firework_rune.png",
    stack_max = 1,
})

local timer = 0
minetest.register_globalstep(function(dtime)
    timer = timer + dtime
    if timer > 4 then timer = timer - 2 end

    for _, player in ipairs(minetest.get_connected_players()) do
        local inv = player:get_inventory()

        -- Flame Rune
        if inv:contains_item("main", "sbz_runes:meteoric_rune") then
            local pos = player:get_pos()
            local radius = 0.4

            local base_angle = (timer / 2) * math.pi * 2
            
            local angle = base_angle
            local offset_x = math.cos(angle) * radius
            local offset_z = math.sin(angle) * radius

            minetest.add_particle({
                pos = {x = pos.x + offset_x, y = pos.y + 0.1, z = pos.z + offset_z},
                velocity = {x = 0, y = 0.5, z = 0},
                acceleration = {x = 0, y = 0.2, z = 0},
                expirationtime = 0.6,
                size = 1,
                collisiondetection = false,
                vertical = false,
                glow = 14,
                texture = "meteorite_trail_matter_blob.png",
                animation = {
                    type = "vertical_frames",
                    aspect_width = 4,
                    aspect_height = 4,
                    length = 0.6
                },
            })

            local angle_2 = base_angle + math.pi
            local offset_x_2 = math.cos(angle_2) * radius
            local offset_z_2 = math.sin(angle_2) * radius

            minetest.add_particle({
                pos = {x = pos.x + offset_x_2, y = pos.y + 0.1, z = pos.z + offset_z_2},
                velocity = {x = 0, y = 0.1, z = 0},
                acceleration = {x = 0, y = 2, z = 0},
                expirationtime = 0.6,
                size = 1,
                collisiondetection = false,
                vertical = false,
                glow = 14,
                texture = "meteorite_trail_matter_blob.png",
                animation = {
                    type = "vertical_frames",
                    aspect_width = 4,
                    aspect_height = 4,
                    length = 0.6
                },
            })
        end

        -- Core Rune
        if inv:contains_item("main", "sbz_runes:core_rune") then
            local pos = player:get_pos()

            -- sbz_resources emitter.lua
            core.add_particlespawner({
                amount = 1,
                time = 1,
                minpos = { x = pos.x - 0.5, y = pos.y - 0.5, z = pos.z - 0.5 },
                maxpos = { x = pos.x + 0.5, y = pos.y + 0.5, z = pos.z + 0.5 },
                minvel = { x = -0.5, y = -0.5, z = -0.5 },
                maxvel = { x = 0.5, y = 0.5, z = 0.5 },
                minacc = { x = 0, y = 0, z = 0 },
                maxacc = { x = 0, y = 0, z = 0 },
                minexptime = 1,
                maxexptime = 2,
                minsize = 0.5,
                maxsize = 1.0,
                collisiondetection = false,
                vertical = false,
                texture = "core_particle.png",
                glow = 10
            })
        end

        -- Firework Rune
        if inv:contains_item("main", "sbz_runes:firework_rune") then
            if math.random(1, 300) == 1 then
                local pos = player:get_pos()
                pos.y = pos.y + 1
                sbz_api.fire_firework(pos)
            end
        end
    end
end)