--[[ 
register_sound_function('machine', {
    footstep = csound('step', 2),
    place = g1 'machine_build',
    rightclick = g1 'machine_open',
})
 ]]

sbz_api = sbz_api or {}

-- allow for a rightclick parameter too, so that its less annoying
core.register_on_mods_loaded(function()
    for k, v in pairs(core.registered_nodes) do
        -- If it has a sounds.rightclick specified...
        if v.sounds and v.sounds.rightclick then
            -- Save original handler (if any)
            local old_rightclick = v.on_rightclick

            local function new_rightclick(pos, node, clicker, stack, pointed)
                if core.get_meta(pos):get_string 'formspec' ~= '' then
                    core.sound_play(v.sounds.rightclick, {
                        pos = pos,
                    })
                end

                if old_rightclick then
                    return old_rightclick(pos, node, clicker, stack, pointed)
                end
            end

            core.override_item(k, {
                on_rightclick = new_rightclick,
            })
        end
    end
end)

sbz_api.sounds = sbz_api.sounds or {}

function sbz_api.sounds.machine()
    local sounds = {
        footstep = { name = 'mix_thunk_slightly_metallic', gain = 0.2, pitch = 0.5, fade = 0.0 },
        dig      = { name = 'mix_thunk_slightly_metallic', gain = 0.8, pitch = 1.0, fade = 0.0 },
        dug      = { name = 'mix_machine_dug', gain = 1.0, pitch = 0.8, fade = 0.0 },
        place    = { name = 'mix_metal_cabinet_hit', gain = 1.0, pitch = 1.0, fade = 0.0 },
    } return sounds
end

function sbz_api.sounds.matter()
    local sounds = {
        footstep = { name = 'foley_matter_hit_short', gain = 0.2, pitch = 1.0,},
        dig      = { name = 'foley_matter_hit_thunky', gain = 0.8, pitch = 0.8,},
        dug      = { name = 'mix_matter_dug', gain = 1.0, pitch = 1.0,},
        place    = { name = 'mix_matter_hit_weird', gain = 0.8, pitch = 1.0,},
    } return sounds
end

function sbz_api.sounds.leaves()
    local sounds = {
        footstep = { name = 'foley_leaf_step', gain = 0.4, pitch = 1.0,},
        dig      = { name = 'foley_leaf_step', gain = 0.6, pitch = 0.6,},
        dug      = { name = 'foley_leaf_step', gain = 1.0, pitch = 1.0,},
        place    = { name = 'foley_leaf_step', gain = 0.8, pitch = 0.8,},
    } return sounds
end

function sbz_api.play_sfx(spec, params, pitch_randomness)
    pitch_randomness = pitch_randomness or 0.035
    local pitch = 1 + (math.random() * pitch_randomness * 2) - pitch_randomness
    params.pitch = params.pitch or pitch
    core.sound_play(spec, params, true)
end

core.register_on_mods_loaded(function()
    local fallback_place_failed = { name = 'gen_error_fart', gain = 0.7, pitch = 1.0,}
    local fallback_fall         = { name = 'gen_pew_slow_fall', gain = 0.3, pitch = 1.1,}

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
            sbz_api.play_sfx("gen_chat_exclamation", { gain = 0.7, to_player = name })
        elseif message:find("[?]+") then
            sbz_api.play_sfx("gen_chat_question", { gain = 0.7, to_player = name })
        elseif message:find("\\[PM\\]|@") then
            sbz_api.play_sfx("gen_chat_pm_send", { gain = 0.7, to_player = name })
        else
            sbz_api.play_sfx("gen_chat_generic", { gain = 0.7, to_player = name })
        end
    end
)
