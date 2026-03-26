local S = core.get_translator(core.get_current_modname())

-- Proper handling needed for actual looping of a 2-second audio clip
local decay_sounds = {}
local function pos_hash(pos)
    return core.hash_node_position(pos)
end

local function start_decay_sound(pos)
    local key = pos_hash(pos)

    -- If already playing
    if decay_sounds[key] then
        return
    end

    local handle = core.sound_play(
        { name = "mix_decay_crackle_loop", pitch = 1.0 },
        {
            pos = pos,
            gain = 0.0, -- start silent to allow fade-in
            max_hear_distance = 8,
            loop = true,
        }
    )

    if handle then
        decay_sounds[key] = handle
        core.sound_fade(handle, 0.5, 0.8)
    end
end

local function stop_decay_sound(pos)
    local key = pos_hash(pos)
    local handle = decay_sounds[key]

    if not handle then
        return
    end

    core.sound_fade(handle, -1.2, 0)

    -- Stop sound after fade finishes
    core.after(1.0, function()
        core.sound_stop(handle)
    end)

    decay_sounds[key] = nil
end

sbz_api.register_stateful_machine("sbz_chem:decay_accel", {
    description = S("Decay Accelerator"),
    tiles = {
        "decay_accel.png",
        "decay_accel.png",
        "decay_accel.png",
        "decay_accel.png",
        "decay_accel.png",
        "decay_accel_front.png",
    },
    groups = { matter = 1 },
    sounds = {
        footstep = { name = 'mix_thunk_slightly_metallic', gain = 0.2, pitch = 0.5, fade = 0.0 },
        dig      = { name = 'mix_thunk_slightly_metallic', gain = 0.8, pitch = 1.0, fade = 0.0 },
        dug      = { name = 'mix_machine_dug', gain = 1.0, pitch = 0.8, fade = 0.0 },
        place    = { name = 'foley_heavy_metal_ting', gain = 1.0, pitch = 0.8, fade = 0.0 },
    },
    info_extra = "It doesn't just accelerate decay, it may throw in some neutrons.",
    on_construct = function(pos)
        local meta = core.get_meta(pos)
        local inv = meta:get_inventory()
        inv:set_size("input", 1)
        inv:set_size("output", 16)

        meta:set_string("formspec", [[
formspec_version[7]
size[8.2,9]
style_type[list;spacing=.2;size=.8]
list[context;output;3.5,0.5;4,4;]
list[context;input;1,2;1,1;]
list[current_player;main;0.2,5;8,4;]
listring[current_player;main]listring[context;input]listring[current_player;main]listring[context;output]listring[current_player;main]
]])
    end,
    info_power_consume = 64,
    autostate = true,
    action = function(pos, node, meta, supply, demand)
        local power_needed = 64
        local inv = meta:get_inventory()

        local out, count, decremented = sbz_api.recipe.resolve_craft(inv:get_stack("input", 1), "decay_accelerating",
            false)

        if out == nil then
            meta:set_string("infotext", "Inactive")
            stop_decay_sound(pos)
            return 0
        end

        if demand + power_needed > supply then
            meta:set_string("infotext", "Not enough power")
            stop_decay_sound(pos)
            return power_needed, false
        end

        meta:set_string("infotext", "Active")
        start_decay_sound(pos)

        if inv:room_for_item("output", out) then
            local input = inv:get_stack("input", 1)
            input:set_count(input:get_count() - decremented)
            inv:set_stack("input", 1, input)
            inv:add_item("output", out)
            return power_needed
        else
            meta:set_string("infotext", "Output inventory full")
            stop_decay_sound(pos)
            return 0
        end
    end,
    on_destruct = function(pos)
        stop_decay_sound(pos)
    end,
    input_inv = "input",
    output_inv = "output",
}, {
    tiles = {
        "decay_accel.png",
        "decay_accel.png",
        "decay_accel.png",
        "decay_accel.png",
        "decay_accel.png",
        { name = "decay_accel_front_on.png", animation = { type = "vertical_frames", length = 1 } },
    },
    light_source = 14,
})

do -- Decay Accel Off recipe scope
    local Decay_Accel = 'sbz_chem:decay_accel_off'
    local UC = 'sbz_chem:uranium_crystal'
    local MB = 'sbz_resources:matter_blob'
    local TC = 'sbz_chem:thorium_crystal'
    local RM = 'sbz_resources:reinforced_matter'
    local PC = 'sbz_resources:phlogiston_circuit'
    local Ne = 'sbz_meteorites:neutronium'
    core.register_craft({
        output = Decay_Accel,
        recipe = {
            { UC, MB, TC },
            { RM, '', RM },
            { PC, Ne, PC }
        }
    })
end
