sbz_audio = sbz_audio or {}

-- sbz_api.sounds is deprecated now.  Replace with sbz_audio wherever used.
sbz_api = sbz_api or {}
sbz_api.sounds = sbz_audio -- old calls link to new namespace

-- Use as a template (include fade if needed on any)
function sbz_audio.blank()
    local sounds = {
        footstep = { name = '', gain = 0.2, pitch = 1.0 },
        dig      = { name = '', gain = 0.8, pitch = 1.0 },
        dug      = { name = '', gain = 1.0, pitch = 1.0 },
        place    = { name = '', gain = 0.8, pitch = 1.0 },
    }
    return sounds
end

function sbz_audio.machine()
    local sounds = {
        footstep = { name = 'mix_thunk_slightly_metallic', gain = 0.2, pitch = 0.5 },
        dig      = { name = 'mix_metal_cabinet_hit', gain = 0.8, pitch = 1.0 },
        dug      = { name = 'mix_machine_dug', gain = 1.0, pitch = 0.8 },
        place    = { name = 'mix_metal_cabinet_place', gain = 1.0, pitch = 1.0 },
    }
    return sounds
end

function sbz_audio.matter()
    local sounds = {
        footstep = { name = 'mix_choppy_rubber_step', gain = 0.1, pitch = 0.5 },
        dig      = { name = 'foley_matter_hit_thunky', gain = 0.8, pitch = 0.8 },
        dug      = { name = 'mix_matter_dug', gain = 1.0, pitch = 1.0 },
        place    = { name = 'mix_matter_hit_weird', gain = 0.8, pitch = 1.0 },
    }
    return sounds
end

function sbz_audio.dirt()
    local sounds = {
        footstep = { name = 'mix_dirt_step', gain = 0.2, pitch = 0.8 },
        dig      = { name = 'mix_dirt_dig', gain = 0.6, pitch = 1.1 },
        dug      = { name = 'mix_dirt_dug', gain = 1.0, pitch = 0.9 },
        place    = { name = 'mix_dirt_dig', gain = 0.6, pitch = 0.8 },
    }
    return sounds
end

function sbz_audio.antimatter()
    local sounds = {
        footstep = { name = 'foley_antimatter_hum', gain = 0.2, pitch = 0.8 },
        dig      = { name = 'foley_antimatter_hit', gain = 0.8, pitch = 1.0 },
        dug      = { name = 'foley_antimatter_dug', gain = 1.0, pitch = 1.0 },
        place    = { name = 'foley_antimatter_step', gain = 0.6, pitch = 1.0 },
    }
    return sounds
end

function sbz_audio.wood_planks()
    local sounds = {
        footstep = { name = 'gen_wump_wood', gain = 0.3, pitch = 0.9 },
        dig      = { name = 'foley_wood_thud_shallow', gain = 0.6, pitch = 0.8 },
        dug      = { name = 'mix_wood_chop', gain = 1.0, pitch = 0.75 },
        place    = { name = 'foley_wood_thud_thick', gain = 0.5, pitch = 1.0 }
    }
    return sounds
end

function sbz_audio.wood_solid()
    local sounds = {
        footstep = { name = 'mix_choppy_rubber_step', gain = 0.2, pitch = 0.8 },
        dig      = { name = 'mix_matter_hit_weird', gain = 0.8, pitch = 1.2 },
        dug      = { name = 'mix_wood_chop', gain = 0.8, pitch = 0.9 },
        place    = { name = 'foley_wood_thud_thick', gain = 1.0, pitch = 0.6 },
    }
    return sounds
end

function sbz_audio.leaves()
    local sounds = {
        footstep = { name = 'foley_leaf_step', gain = 0.1, pitch = 0.8 },
        dig      = { name = 'foley_leaf_step', gain = 0.2, pitch = 0.5 },
        dug      = { name = 'foley_leaf_step', gain = 0.3, pitch = 0.9 },
        place    = { name = 'foley_leaf_step', gain = 0.4, pitch = 0.8 },
    }
    return sounds
end

function sbz_audio.glass()
    local sounds = {
        footstep = { name = 'foley_matter_hit_light', gain = 0.1, pitch = 1.1 },
        dig      = { name = 'gen_soft_glass_bump', gain = 0.8, pitch = 1.2 },
        dug      = { name = 'mix_ambiguous_hard_hit', gain = 1.0, pitch = 0.8 },
        place    = { name = 'mix_ambiguous_hard_hit', gain = 0.8, pitch = 1.2 },
    }
    return sounds
end

function sbz_audio.snow()
    local sounds = {
        footstep = { name = 'gen_snow_crunch_abrupt', gain = 0.2, pitch = 1.0 },
        dig      = { name = 'foley_snow_hit', gain = 0.5, pitch = 1.0 },
        dug      = { name = 'mix_soft_harsh_explosion', gain = 1.0, pitch = 0.6 },
        place    = { name = 'gen_snow_crunch_slow', gain = 0.8, pitch = 0.5 },
    }
    return sounds
end

function sbz_audio.ice()
    local sounds = {
        footstep = { name = 'foley_solid_step_soft', gain = 0.2, pitch = 1.0 },
        dig      = { name = 'gen_ice_chip', gain = 0.8, pitch = 1.0 },
        dug      = { name = 'gen_ice_break', gain = 1.0, pitch = 1.0 },
        place    = { name = 'foley_ambiguous_solid_hit', gain = 0.7, pitch = 1.0 },
    }
    return sounds
end

function sbz_audio.sand()
    local sounds = {
        footstep = { name = 'gen_sand_generic', gain = 0.1, pitch = 0.8 },
        dig      = { name = 'gen_sand_generic_hit', gain = 0.2, pitch = 0.6 },
        dug      = { name = 'gen_sand_smoothed', gain = 0.5, pitch = 0.8 },
        place    = { name = 'gen_sand_generic_hit', gain = 0.2, pitch = 0.8 },
    }
    return sounds
end

-- Global default node sounds
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

-- Sounds triggered by chat
core.register_on_chat_message(
    function(name, message)
        -- Yo, you write a lot, cuz.
        if #message >= 450 then -- 500 characters is the server-specified default maximum
            core.sound_play("paperflip2", { gain = 1.0, to_player = name })
            return
        end

        if message:find("[!]+") then
            core.sound_play("gen_chat_exclamation", { gain = 0.7, to_player = name })
        elseif message:find("[?]+") then
            core.sound_play("gen_chat_question", { gain = 0.7, to_player = name })
        elseif message:find("\\[PM\\]|@") then
            core.sound_play("gen_chat_pm_send", { gain = 0.7, to_player = name })
        else
            core.sound_play("gen_chat_generic", { gain = 0.7, to_player = name })
        end
    end
)
