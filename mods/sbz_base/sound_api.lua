--[[ 
register_sound_function('machine', {
    footstep = csound('step', 2),
    place = g1 'machine_build',
    rightclick = g1 'machine_open',
})
 ]]
-- allow for a rightclick parameter too, so that its less annoying
core.register_on_mods_loaded(function()
    for k, v in pairs(core.registered_nodes) do
        -- If it has a sounds.rightclick specified...
        if v.sounds and v.sounds.rightclick then
            -- Take what is specified and save it as old_rightclick
            local old_rightclick = v.on_rightclick or function(pos, node, clicker, itemstack, pointed_thing) end
            local function new_rightclick(pos, node, clicker, stack, pointed)
                if core.get_meta(pos):get_string 'formspec' ~= '' then
                    core.sound_play(v.sounds.rightclick, {
                        pos = pos,
                    })
                end
                return old_rightclick(pos, node, clicker, stack, pointed)
            end
            core.override_item(k, {
                on_rightclick = new_rightclick,
            })
        end
    end
end)

function sbz_api.play_sfx(spec, params, pitch_randomness)
    pitch_randomness = pitch_randomness or 0.035
    local pitch = 1 + (math.random() * pitch_randomness * 2) - pitch_randomness
    params.pitch = params.pitch or pitch
    core.sound_play(spec, params, true)
end

core.register_on_mods_loaded(function()
    local fallback_place_failed = { name = 'gen_error_fart', gain = 0.7, pitch = 1.0, fade = 0.0 }
    local fallback_fall         = { name = 'gen_pew_slow_fall', gain = 0.3, pitch = 1.1, fade = 0.0 }

    for name, def in pairs(core.registered_nodes) do
        local s = def.sounds or {}
        if not s.place_failed or not s.fall then
            core.override_item(name, {
                sounds = table.override(table.copy(s), {
                    place_failed = s.place_failed or fallback_place_failed,
                    fall         = s.fall or fallback_fall,
                }),
            })
        end
    end
end)

core.register_on_chat_message(
    function(name, message)
        if message:find("[!]+") then
            sbz_api.play_sfx("gen_chat_exclamation", { to_player = name })
        elseif message:find("[?]+") then
            sbz_api.play_sfx("gen_chat_question", { to_player = name })
        else
            sbz_api.play_sfx("gen_chat_generic", { to_player = name })
        end
    end
)
