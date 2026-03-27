local S = core.get_translator(core.get_current_modname())

sbz_api.recipe.register_craft_type({
    type = "crystal_growing",
    description = S("Crystal Growing"),
    icon = "crystal_grower.png^[verticalframe:17:1",
    single = true
})

local function allow_metadata_inventory_put(pos, listname, index, stack, player)
    if listname == "dst" then
        return 0
    end
    return stack:get_count()
end

local function allow_metadata_inventory_move(pos, from_list, from_index, to_list, to_index, count, player)
    if to_list == "dst" then return 0 end
    return count
end

-- Proper handling needed for actual looping of a 2-second audio clip
local active_sounds = {}
local function pos_hash(pos)
    return core.hash_node_position(pos)
end

local function start_active_sound(pos)
    local key = pos_hash(pos)

    -- If already playing
    if active_sounds[key] then
        return
    end

    local handle = core.sound_play(
        { name = 'mix_active_hum_loop', gain = 0.1, pitch = 0.8 },
        {
            pos = pos,
            gain = 0.0, -- start silent to allow fade-in
            max_hear_distance = 8.0,
            loop = true,
        }
    )

    if handle then
        active_sounds[key] = handle
        core.sound_fade(handle, 0.5, 0.8)
    end
end

local function stop_active_sound(pos)
    local key = pos_hash(pos)
    local handle = active_sounds[key]

    if not handle then
        return
    end

    core.sound_fade(handle, -1.2, 0)

    -- Stop sound after fade finishes
    core.after(1.0, function()
        core.sound_stop(handle)
    end)

    active_sounds[key] = nil
end

sbz_api.register_stateful_machine("sbz_chem:crystal_grower", {
    description = S("Crystal Grower"),
    sounds = sbz_audio.machine(),
    info_power_consume = 120,
    tiles = {
        "crystal_grower_side.png",
        "crystal_grower_side.png",
        "crystal_grower_side.png",
        "crystal_grower_side.png",
        "crystal_grower_side.png",
        "crystal_grower.png^[verticalframe:17:1",
    },
    groups = { matter = 1 },
    paramtype2 = "4dir",
    allow_metadata_inventory_move = allow_metadata_inventory_move,
    allow_metadata_inventory_put = allow_metadata_inventory_put,

    input_inv = "src",
    output_inv = "dst",
    on_construct = function(pos)
        local meta = core.get_meta(pos)
        local inv = meta:get_inventory()
        inv:set_size("src", 4)
        inv:set_size("dst", 4)

        meta:set_string("formspec", [[
formspec_version[7]
size[8.2,9]
style_type[list;spacing=.2;size=.8]
list[current_player;main;0.2,5;8,4;]
list[context;src;1.5,1;2,2;]
listring[]
list[context;dst;4.5,1;2,2;]
listring[current_player;main]
listring[context;dst]
    ]])
    end,
    after_place_node = pipeworks.after_place,
    after_dig_node = pipeworks.after_dig,
    autostate = true,
    action = function(pos, _, meta, supply, demand)
        local power_needed = 120
        local inv = meta:get_inventory()

        if demand + power_needed > supply then
            meta:set_string("infotext", "Not enough power")
            stop_active_sound(pos)
            return power_needed, false
        else
            meta:set_string("infotext", "Growing...")

            local src = inv:get_list("src")

            local out, count, decremented, index = sbz_api.recipe.resolve_craft(src, "crystal_growing", true)
            if out == nil then
                meta:set_string("infotext", "Invalid/no recipe")
                stop_active_sound(pos)
                return 0
            end

            if not inv:room_for_item("dst", out) then
                meta:set_string("infotext", "Full")
                stop_active_sound(pos)
                return 0
            end
            local input = inv:get_stack("src", index)
            input:set_count(input:get_count() - decremented)
            inv:set_stack("src", index, input)
            inv:add_item("dst", out)
            start_active_sound(pos)
            core.sound_play({ name = 'mix_crystallization_effect', pitch = 1.2 }, { pos = pos, max_hear_distance = 8 })
            return power_needed
        end
    end,
}, {
    tiles = {
        "crystal_grower_side.png",
        "crystal_grower_side.png",
        "crystal_grower_side.png",
        "crystal_grower_side.png",
        "crystal_grower_side.png",
        { name = "crystal_grower.png", animation = { type = "vertical_frames", length = 2 } },
    },
    light_source = 14,
})

do -- Crystal Grower recipe scope
    local Crystal_Grower = 'sbz_chem:crystal_grower'
    local St = 'sbz_resources:stone'
    local An = 'sbz_meteorites:antineutronium'
    local RM = 'sbz_resources:reinforced_matter'
    local Ne = 'sbz_meteorites:neutronium'
    local TB = 'sbz_chem:titanium_block'
    core.register_craft({
        output = Crystal_Grower,
        recipe = {
            { St, An, St },
            { RM, Ne, RM },
            { St, TB, St },
        }
    })
end
