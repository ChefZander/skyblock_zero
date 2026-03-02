local action = function(pos, _, puncher)
    local itemstack = puncher:get_wielded_item()
    local tool_name = itemstack:get_name()
    local can_extract_from_emitter = minetest.get_item_group(tool_name, "core_drop_multi") > 0
    if not can_extract_from_emitter then
        minetest.sound_play("punch_core", {
            gain = 1,
            max_hear_distance = 6,
            pos = pos
        })
        if puncher.is_fake_player then return end
        sbz_api.displayDialogLine(puncher:get_player_name(),
            "Colorium Emitters can only be mined using tools or machines.")
    end
    for _ = 1, minetest.get_item_group(tool_name, "core_drop_multi") do
        minetest.sound_play("punch_core", {
            gain = 1,
            max_hear_distance = 6,
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

do -- Colorium Emitter recipe scope
    local CE = 'sbz_bio:colorium_emitter'
    local amount = 2
    local Ph = 'sbz_resources:phlogiston'
    core.register_craft({
        output = CE .. ' ' .. tostring(amount),
        recipe = {
            { Ph, Ph, Ph },
            { Ph, CE, Ph },
            { Ph, Ph, Ph },
        }
    })
end
