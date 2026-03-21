core.register_craftitem("sbz_runes:meteoric_rune", {
    description = "¤ Meteoric Rune\n" .. 
        core.colorize("#00FFFF", "Cosmetic: Surrounds you with meteorite particles.") .. "\n" .. 
        core.colorize("#BF00FF", "1/100k chance when breaking Meteoric Matter."),
    inventory_image = "meteoric_rune.png",
    stack_max = 1,
})

core.register_craftitem("sbz_runes:core_rune", {
    description = "¤ Core Rune\n" .. 
        core.colorize("#00FFFF", "Cosmetic: Surrounds you with core particles like The Core.") .. "\n" .. 
        core.colorize("#BF00FF", "1/10m chance when punching The Core."),
    inventory_image = "core_rune.png",
    stack_max = 1,
})

core.register_craftitem("sbz_runes:firework_rune", {
    description = "¤ Firework Rune\n" .. 
        core.colorize("#00FFFF", "Cosmetic: Occasionally fires off firework rockets on it's own.") .. "\n" .. 
        core.colorize("#BF00FF", "1/1m chance when firing off a firework rocket."),
    inventory_image = "firework_rune.png",
    stack_max = 1,
})

core.register_craftitem("sbz_runes:halo_rune", {
    description = "¤ Halo Rune\n" .. 
        core.colorize("#00FFFF", "Cosmetic: A divine ring of light floats above you.") .. "\n" .. 
        core.colorize("#BF00FF", "1/10m chance when punching a Colorium Emitter."),
    inventory_image = "halo_rune.png",
    stack_max = 1,
})

core.register_craftitem("sbz_runes:singularity_rune", {
    description = "¤ Singularity Rune\n" .. 
        core.colorize("#00FFFF", "Cosmetic: Reality bends around you.") .. "\n" .. 
        core.colorize("#BF00FF", "1/50k chance when falling into the Void."),
    inventory_image = "singularity_rune.png",
    stack_max = 1,
})

local timer = 0
core.register_globalstep(function(dtime)
    timer = timer + dtime
    if timer > 4 then timer = timer - 2 end

    for _, player in ipairs(core.get_connected_players()) do
        local inv = player:get_inventory()

        -- Flame Rune
        if inv:contains_item("main", "sbz_runes:meteoric_rune") then
            local pos = player:get_pos()
            local radius = 0.4

            local base_angle = (timer / 2) * math.pi * 2
            
            local angle = base_angle
            local offset_x = math.cos(angle) * radius
            local offset_z = math.sin(angle) * radius

            core.add_particle({
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

            core.add_particle({
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
                pos.y = pos.y + 2
                sbz_api.fire_firework(pos)
            end
        end

        -- Halo RUne
        if inv:contains_item("main", "sbz_runes:halo_rune") then
            local pos = player:get_pos()
            local radius = 0.2
            local eight = 1.85
            local points = 21 -- any less and it looks bad

            for i = 1, points do
                local angle = (i / points) * (math.pi * 2) + (timer / 4)
                local dx = math.cos(angle) * radius
                local dz = math.sin(angle) * radius

                core.add_particle({
                    pos = {x = pos.x + dx, y = pos.y + eight, z = pos.z + dz},
                    velocity = {x = 0, y = 0, z = 0},
                    acceleration = {x = 0, y = 0, z = 0},
                    expirationtime = dtime + 0.01,
                    size = 1.5,
                    collisiondetection = false,
                    vertical = false,
                    glow = 14,
                    texture = "halo_particle.png",
                })
            end
        end
        
        -- Singularity Rune
        if inv:contains_item("main", "sbz_runes:singularity_rune") then
            local pos = player:get_pos()
            pos.y = pos.y + 1.2
            local yaw = player:get_look_horizontal()
            
            local back_x = math.sin(yaw)
            local back_z = -math.cos(yaw)

            for i = 1, 3 do
                local arc = (math.random() - 0.5) * (math.pi * 0.75) -- wtf
                local angle = yaw + arc
                
                local dist = 1.2
                local dx = math.sin(angle) * dist
                local dz = -math.cos(angle) * dist
                local dy = (math.random() - 0.5) * 1.5

                core.add_particle({
                    pos = {x = pos.x + dx, y = pos.y + dy, z = pos.z + dz},
                    velocity = {x = -dx * 1.5, y = -dy * 1.5, z = -dz * 1.5},
                    acceleration = {x = 0, y = 0, z = 0},
                    expirationtime = 0.5,
                    size = 1,
                    collisiondetection = false,
                    vertical = false,
                    glow = 12,
                    texture = "singularity_particle.png",
                })
            end
        end
    end
end)