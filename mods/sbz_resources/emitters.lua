-- Emitter Node

local action = function(pos, _, puncher)
    local itemstack = puncher:get_wielded_item()
    local tool_name = itemstack:get_name()
    local can_extract_from_emitter = core.get_item_group(tool_name, "core_drop_multi") > 0
    if can_extract_from_emitter then
        core.sound_play({ name = 'mix_rubber_hit_noisy_gassy' }, { pos = pos })
    else
        core.sound_play({ name = 'foley_annoying_honk', gain = 0.8, pitch = 0.9 }, { pos = pos })
        if puncher.is_fake_player then return end
        sbz_api.displayDialogLine(puncher:get_player_name(), "Emitters can only be mined using tools or machines.")
    end
    for _ = 1, core.get_item_group(tool_name, "core_drop_multi") do
        if math.random(1, 10) == 1 then
            puncher:get_inventory():add_item("main", "sbz_resources:raw_emittrium")

            if not puncher.is_fake_player then
                core.add_particlespawner({
                    amount = 50,
                    time = 1,
                    minpos = { x = pos.x - 0.5, y = pos.y - 0.5, z = pos.z - 0.5 },
                    maxpos = { x = pos.x + 0.5, y = pos.y + 0.5, z = pos.z + 0.5 },
                    minvel = { x = -1, y = -1, z = -1 },
                    maxvel = { x = 1, y = 1, z = 1 },
                    minacc = { x = 0, y = 0, z = 0 },
                    maxacc = { x = 0, y = 0, z = 0 },
                    minexptime = 3,
                    maxexptime = 5,
                    minsize = 0.5,
                    maxsize = 1.0,
                    collisiondetection = false,
                    vertical = false,
                    texture = "raw_emittrium.png",
                    glow = 10
                })
                unlock_achievement(puncher:get_player_name(), "Obtain Emittrium")
            end
        else
            local items = { "sbz_resources:core_dust", "sbz_resources:matter_dust", "sbz_resources:charged_particle" }
            local item = items[math.random(#items)]

            local inv = puncher:get_inventory()
            if inv then
                local leftover = inv:add_item("main", item)
                if not leftover:is_empty() then
                    core.add_item(pos, leftover)
                end
            end
            if not puncher.is_fake_player then
                unlock_achievement(puncher:get_player_name(), "Introduction")
            end
        end
    end
end

core.register_node("sbz_resources:emitter", {
    description = "Emitter",
    tiles = { "emitter.png" },
    groups = { gravity = 25, unbreakable = 1, transparent = 1, not_in_creative_inventory = 1 },
    sounds = {
        footstep = { name = 'mix_gassy_quack_hit', gain = 0.2, pitch = 0.5, fade = 0.0 },
        dug      = { name = 'gen_fried_noise_explode', gain = 1.0, pitch = 1.0, fade = 0.0 },
        place    = { name = 'mix_gassy_quack_hit', gain = 1.0, pitch = 1.0, fade = 0.0 },
    },
    drop = "",
    sunlight_propagates = true,
    paramtype = "light",
    light_source = 14,
    walkable = true,
    on_punch = action,
    on_rightclick = action,
    diggable = false,
})

core.register_node("sbz_resources:movable_emitter", {
    description = "Movable Emitter",
    tiles = { "movable_emitter.png" },
    groups = { transparent = 1, matter = 1, level = 2 },
    sounds = {
        footstep = { name = 'mix_gassy_quack_hit', gain = 0.2, pitch = 0.5, fade = 0.0 },
        dug      = { name = 'gen_fried_noise_explode', gain = 1.0, pitch = 1.0, fade = 0.0 },
        place    = { name = 'mix_gassy_quack_hit', gain = 1.0, pitch = 1.0, fade = 0.0 },
    },
    sunlight_propagates = true,
    paramtype = "light",
    light_source = 14,
    walkable = true,
    on_punch = action,
    on_rightclick = action
})

do -- Movable Emitter duplication recipe scope
    local ME = 'sbz_resources:movable_emitter'
    local amount = 2
    local Ph = 'sbz_resources:phlogiston'
    core.register_craft({
        output = ME .. ' ' .. tostring(amount),
        recipe = {
            { Ph, Ph, Ph },
            { Ph, ME, Ph },
            { Ph, Ph, Ph },
        }
    })
end

core.register_abm({
    label = "Emitter Particles",
    nodenames = { "sbz_resources:emitter" },
    interval = 1,
    chance = 1,
    action = function(pos, node, active_object_count, active_object_count_wider)
        core.add_particlespawner({
            amount = 5,
            time = 1,
            minpos = { x = pos.x - 0.5, y = pos.y - 0.5, z = pos.z - 0.5 },
            maxpos = { x = pos.x + 0.5, y = pos.y + 0.5, z = pos.z + 0.5 },
            minvel = { x = -5, y = -5, z = -5 },
            maxvel = { x = 5, y = 5, z = 5 },
            minacc = { x = 0, y = 0, z = 0 },
            maxacc = { x = 0, y = 0, z = 0 },
            minexptime = 30,
            maxexptime = 50,
            minsize = 0.5,
            maxsize = 1.0,
            collisiondetection = false,
            vertical = false,
            texture = "star.png",
            glow = 10
        })
    end,
})

-- Emitter Resources
core.register_craftitem("sbz_resources:raw_emittrium", {
    description = "Raw Emittrium",
    inventory_image = "raw_emittrium.png",
    stack_max = 256,
})

unified_inventory.register_craft {
    output = "sbz_resources:raw_emittrium",
    type = "punching",
    items = {
        "sbz_resources:emitter"
    }
}

-- THE CORE!!! interaction...
local function core_interact(pos, node, puncher, itemstack, pointed_thing)
    if not pointed_thing then --this is on_punch instead, which doesn't use itemstack
        pointed_thing = itemstack
        itemstack = nil
    end

    itemstack = puncher:get_wielded_item()
    local tool_name = itemstack:get_name()

    local multi = core.get_item_group(tool_name, "core_drop_multi")
    local n = 1

    if not puncher then return end
    if not puncher:is_player() then return end

    core.sound_play(
        { name = 'mix_weird_hit', gain = 0.5, pitch = math.random(50, 100) / 100 },
        { pos = pos, max_hear_distance = 16 }
    )
    if multi and multi ~= 0 then n = multi end
    for _ = 1, n do
        local items = { "sbz_resources:core_dust", "sbz_resources:matter_dust", "sbz_resources:charged_particle" }
        local item = items[math.random(#items)]
        unlock_achievement(puncher:get_player_name(), "Introduction")

        local inv = puncher:get_inventory()

        if inv then
            core.after(0, function() -- engine bug makes things weird... if you remove this, troubles may arise
                local leftover = inv:add_item("main", item)
                if not leftover:is_empty() then
                    core.add_item(pos, leftover)
                end

                if math.random(1, 10000000) == 1 then -- 1/10m
                    local rune = ItemStack("sbz_runes:core_rune")
                    local rune_leftover = inv:add_item("main", rune)
                    
                    if not rune_leftover:is_empty() then
                        core.add_item(pos, rune_leftover)
                    end

                    core.chat_send_all("⌠ Crazy Rare Drop: " .. puncher:get_player_name() .. " just dropped a Core Rune! ⌡")
                end
            end)
        end
    end
end

-- THE CORE!!!
core.register_node("sbz_resources:the_core", {
    description = "The Core",
    sounds = sbz_api.sounds.matter(),
    tiles = { "the_core.png" },
    groups = { gravity = 25, unbreakable = 1, not_in_creative_inventory = 1 },
    drop = "",
    sunlight_propagates = true,
    paramtype = "light",
    light_source = 14,
    walkable = true,
    on_punch = core_interact,
    on_rightclick = core_interact,
    diggable = false,
})

-- Core Particles
core.register_abm({
    label = "Core Particles",
    nodenames = { "sbz_resources:the_core" },
    interval = 1,
    chance = 1,
    action = function(pos, node, active_object_count, active_object_count_wider)
        core.add_particlespawner({
            amount = 1,
            time = 1,
            minpos = { x = pos.x - 0.5, y = pos.y - 0.5, z = pos.z - 0.5 },
            maxpos = { x = pos.x + 0.5, y = pos.y + 0.5, z = pos.z + 0.5 },
            minvel = { x = -0.5, y = -0.5, z = -0.5 },
            maxvel = { x = 0.5, y = 0.5, z = 0.5 },
            minacc = { x = 0, y = 0, z = 0 },
            maxacc = { x = 0, y = 0, z = 0 },
            minexptime = 10,
            maxexptime = 20,
            minsize = 0.5,
            maxsize = 1.0,
            collisiondetection = false,
            vertical = false,
            texture = "core_particle.png",
            glow = 10
        })
    end,
})

mesecon.register_mvps_stopper("sbz_resources:the_core")
-- mesecon.register_mvps_stopper("sbz_resources:emitter") -- :3
