local action = function(pos, _, puncher)
    local itemstack = puncher:get_wielded_item()
    local tool_name = itemstack:get_name()
    local can_extract_from_emitter = minetest.get_item_group(tool_name, "core_drop_multi") > 0
    if not can_extract_from_emitter then
        minetest.sound_play("punch_core", {
            gain = 1,
            max_hear_distance = 32,
            pos = pos
        })
        if puncher.is_fake_player then return end
        displayDialougeLine(puncher:get_player_name(), "Colorium Emitters can only be mined using tools or machines.")
    end
    for _ = 1, minetest.get_item_group(tool_name, "core_drop_multi") do
        minetest.sound_play("punch_core", {
            gain = 1,
            max_hear_distance = 32,
            pos = pos
        })
        local items = { "sbz_bio:colorium_sapling", "sbz_bio:colorium_tree", "sbz_bio:colorium_leaves" }
        local item = items[math.random(#items)]

        if puncher and puncher:is_player() then
            local inv = puncher:get_inventory()
            if inv then
                local leftover = inv:add_item("main", item)
                if not leftover:is_empty() then
                    minetest.add_item(pos, leftover)
                end
            end

            unlock_achievement(puncher:get_player_name(), "Colorium Emitters")
        end
    end
end

minetest.register_node("sbz_bio:colorium_emitter", unifieddyes.def {
    description = "Colorium Emitter",
    tiles = { "colorium_emitter.png" },
    groups = { unbreakable = 1, transparent = 1, matter = 1, level = 2 },
    sunlight_propagates = true,
    paramtype = "light",
    light_source = 14,
    walkable = true,
    on_punch = action,
    on_rightclick = action
})
core.register_craft {
    output = "sbz_bio:colorium_emitter",
    recipe = {
        { "sbz_resources:phlogiston", "sbz_resources:phlogiston", "sbz_resources:phlogiston" },
        { "sbz_resources:phlogiston", "sbz_bio:colorium_sapling", "sbz_resources:phlogiston" },
        { "sbz_resources:phlogiston", "sbz_resources:phlogiston", "sbz_resources:phlogiston" }
    }
}


minetest.register_abm({
    label = "Colorium Emitter Particles",
    nodenames = { "sbz_bio:colorium_emitter" },
    interval = 1,
    chance = 1,
    action = function(pos, node, active_object_count, active_object_count_wider)
        minetest.add_particlespawner({
            amount = 20,
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
            texture = "colorium_emitter.png",
            glow = 12
        })
    end,
})
