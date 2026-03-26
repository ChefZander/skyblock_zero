local S = core.get_translator(core.get_current_modname())

local action = function(pos, _, puncher)
    local itemstack = puncher:get_wielded_item()
    local tool_name = itemstack:get_name()
    local can_extract_from_emitter = core.get_item_group(tool_name, "core_drop_multi") > 0
    if not can_extract_from_emitter then
        core.sound_play({ name = 'gen_colorium_emitter_denied' }, { pos = pos })
        if puncher.is_fake_player then return end
        sbz_api.displayDialogLine(puncher:get_player_name(),
            "Colorium Emitters can only be mined using tools or machines.")
    end
    for _ = 1, core.get_item_group(tool_name, "core_drop_multi") do
        local items = { "sbz_bio:colorium_sapling", "sbz_bio:colorium_tree", "sbz_bio:colorium_leaves" }
        local item = items[math.random(#items)]

        if puncher and puncher:is_player() then
            local inv = puncher:get_inventory()
            if inv then
                local leftover = inv:add_item("main", item)
                if not leftover:is_empty() then
                    core.add_item(pos, leftover)
                end
            end

            unlock_achievement(puncher:get_player_name(), "Colorium Emitters")
        end

        -- Halo Rune drop
        if math.random(1, 10000000) == 1 then -- 1/10m
            local rune = ItemStack("sbz_runes:halo_rune")
            local inv = puncher:get_inventory()
            local rune_leftover = inv:add_item("main", rune)
            
            if not rune_leftover:is_empty() then
                core.add_item(pos, rune_leftover)
            end

            core.chat_send_all("⌠ Crazy Rare Drop: " .. puncher:get_player_name() .. " just dropped a Halo Rune! ⌡")
        end
    end
end

core.register_node("sbz_bio:colorium_emitter", unifieddyes.def {
    description = S("Colorium Emitter"),
    tiles = { "colorium_emitter.png" },
    groups = { unbreakable = 1, transparent = 1, matter = 1, level = 2 },
    sounds = {
        footstep = { name = 'mix_choppy_rubber_step', gain = 0.5, pitch = 1.0, fade = 0.0 },
        dig      = { name = 'mix_choppy_rubber_hit', gain = 1.0, pitch = 0.5, fade = 0.0 },
        dug      = { name = 'mix_rubber_noise_hit_short', gain = 1.0, pitch = 0.8, fade = 0.0 },
        place    = { name = 'mix_choppy_rubber_place', gain = 1.0, pitch = 1.0, fade = 0.0 },
    },
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
