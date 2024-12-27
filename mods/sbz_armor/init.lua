-- Maybe the simplest armor mod out of all of them?
--[[
    IDEA:
    each armor has these callbacks:
        - on_punched(...) - yes
          - if it returns true, no damage will be taken
        - on_equip(player) - yes
        - on_unequip(player) - yes

    each armor can add/remove to an armor group
        - armor_groups = {} or function(player, stack) end // yes, STACK

    each armor piece is in player meta
    each armor piece overrides the player skin
    each armor piece is visible, in a interface inventory
]]

local armor = {
    piece_types = {
        by_id = {},
        by_name = {},
    },

    -- matter weaponery: standard swords n crap
    -- light weaponery: lasers, fairly easy to make them not effective, hard to completely get rid of
    -- antimatter weaponery: more powerful than matter, get your armor
    -- strange weaponery: either it kills you instantly, or it does no damage
    -- force: explosions or charges
    armor_groups = { fall_damage_add_percent = -100, matter = 100, light = 100, antimatter = 100, strange = 100, },
    armor_group_descriptions = {
        matter = "Matter Protection",
        light = "Laser Protection",
        antimatter = "Antimatter Protection",
        strange = "Strange Protection",
    }
}

local piece_types = armor.piece_types

sbz_api.armor = armor

---@return table
armor.get_armor_pieces = function(ref)
    local meta = ref:get_meta()
    local armor_data = core.deserialize(meta:get_string("armor")) or {}
    return armor_data
end

local texture_index = {}
-- does texture and armor group stuff
armor.load_armor_pieces = function(ref, data)
    local armor_groups = table.copy(armor.armor_groups)
    local texture_mod = ""
    for k, v in pairs(data) do
        local stack = ItemStack(v)
        local def = stack:get_definition()
        local groups
        if type(def.armor_groups) == "function" then
            groups = def.armor_groups(ref, stack)
        else
            groups = def.armor_groups
        end

        for groupname, groupval in pairs(groups) do
            armor_groups[groupname] = (armor_groups[groupname] or 0) - groupval
        end

        -- texture...
        texture_mod = texture_mod .. "^" .. def.armor_texture
    end
    local name = ref:get_player_name()
    local props = ref:get_properties()
    local calculated_texture_index = texture_index[name] or #props.textures[1]
    props.textures[1] = string.sub(props.textures[1], 1, texture_index[name]) .. texture_mod
    ref:set_properties(props)

    texture_index[name] = calculated_texture_index
    ref:set_armor_groups(armor_groups)
    armor.pieces_to_inventory(data, core.get_inventory { type = "detached", name = "sbz_armor:" .. name })

    -- nice trick directly copied from https://github.com/minetest-mods/3d_armor/blob/c224a73df74ae8559507421ee50e82bc1f85b61f/3d_armor_ui/init.lua#L17C1-L20C5
    if unified_inventory.current_page[name] == "armor" then
        unified_inventory.set_inventory_formspec(ref, "armor")
    end
end

armor.pieces_to_inventory = function(data, inv)
    local mainlist = inv:get_list("main")
    for id, piece_def in pairs(piece_types.by_id) do
        if not data[piece_def.name] then
            mainlist[id] = ItemStack("")
        else
            mainlist[id] = ItemStack(data[piece_def.name])
        end
    end
    inv:set_list("main", mainlist)
end

armor.pieces_from_inventory = function(ref, inv)
    local data = {}
    local mainlist = inv:get_list("main")
    for _, piece_stack in pairs(mainlist) do
        local def = piece_stack:get_definition()
        if def.armor_type then
            data[def.armor_type] = piece_stack:to_string()
        end
    end
    armor.set_armor_pieces(ref, data)
end

armor.set_armor_pieces = function(ref, armor_data)
    local meta = ref:get_meta()
    meta:set_string("armor", core.serialize(armor_data))
    armor.load_armor_pieces(ref, armor_data)
end

armor.register = function(name, def)
    -- pick up armor
    def.on_secondary_use = function(stack, user, pointed)
        local data = armor.get_armor_pieces(user)
        if data[def.armor_type] == nil then
            data[def.armor_type] = stack:take_item(1):to_string()
            if def.on_equip then
                def.on_equip(stack, user)
            end
        else
            local data_at_that = data[def.armor_type]
            data[def.armor_type] = stack:take_item(1):to_string()
            stack = ItemStack(data_at_that)
            if stack:get_definition().on_unequip then
                stack:get_definition().on_unequip(user, stack)
            end
            if def.on_equip then
                def.on_equip(ItemStack(data[def.armor_type]), user)
            end
        end
        armor.set_armor_pieces(user, data)
        return stack
    end
    core.register_tool(name, def)
end

armor.register_piecetype = function(def)
    piece_types.by_id[#piece_types.by_id + 1] = def
    def.id = #piece_types.by_id
    piece_types.by_name[def.name] = def
end

core.register_on_joinplayer(function(player)
    local inv = core.create_detached_inventory("sbz_armor:" .. player:get_player_name(), {
            allow_move = function(inv, from_list, from_index, to_list, to_index, count, callback_player)
                if callback_player:get_player_name() ~= player:get_player_name() then
                    return 0
                else
                    if callback_player:get_inventory():get_stack(from_index, from_index):get_definition().armor_type then
                        return count
                    else
                        return 0
                    end
                end
            end,
            allow_put = function(inv, listname, index, stack, callback_player)
                if callback_player:get_player_name() ~= player:get_player_name() then
                    return 0
                end
                local trigger_method = "on_equip"
                local stack_def = stack:get_definition()
                if not stack_def.armor_type then return 0 end -- thats not armor

                local data = armor.get_armor_pieces(player)
                if data[stack_def.armor_type] or not ItemStack(data[stack_def.armor_type]):is_empty() then return 0 end

                if stack_def[trigger_method] then
                    stack_def[trigger_method](player, stack)
                end
                return stack:get_count()
            end,
            allow_take = function(inv, listname, index, stack, callback_player)
                if callback_player:get_player_name() ~= player:get_player_name() then
                    return 0
                end
                local trigger_method = "on_unequip"
                local stack_def = stack:get_definition()
                if not stack_def.armor_type then return 0 end -- thats not armor

                --local data = armor.get_armor_pieces(player)
                --if data[stack_def.armor_type] or ItemStack(data[stack_def.armor_type]):is_empty() then return 0 end

                if stack_def[trigger_method] then
                    stack_def[trigger_method](player, stack)
                end
                return stack:get_count()
            end,

            on_move = function(inv, from_list, from_index, to_list, to_index, count, player)
                armor.pieces_from_inventory(player, inv)
            end,
            on_put = function(inv, listname, index, stack, player)
                armor.pieces_from_inventory(player, inv)
            end,
            on_take = function(inv, listname, index, stack, player)
                armor.pieces_from_inventory(player, inv)
            end,
        },
        player:get_player_name())
    inv:set_size("main", #piece_types.by_id)
    armor.load_armor_pieces(player, armor.get_armor_pieces(player))
end)

core.register_on_leaveplayer(function(player)
    core.remove_detached_inventory("sbz_armor:" .. player:get_player_name())
end)

local max_wear = 65535

core.register_on_punchplayer(function(player, hitter, time_from_last_punch, tool_capabilities, dir, damage)
    local no_damage = false
    local data = armor.get_armor_pieces(player)
    for k, v in pairs(data) do
        local stack = ItemStack(v)
        local def = stack:get_definition()
        if def.on_punched then
            no_damage = no_damage or
                def.on_punched(data, player, hitter, time_from_last_punch, tool_capabilities, dir, damage)
        end
    end

    -- apply wear
    for k, v in pairs(data) do
        local stack = ItemStack(v)
        local def = stack:get_definition()
        if not def.custom_wear then
            stack:set_wear(stack:get_wear() + ((max_wear / def.durability) * damage))
            data[k] = stack:to_string()
        end
    end

    armor.set_armor_pieces(player, data)
end)


-- piece types

armor.register_piecetype({ -- helmet
    name = "head",
})

armor.register_piecetype({ -- chestplate
    name = "torso",
})

armor.register_piecetype({ -- leggings
    name = "legs",
})
armor.register_piecetype({ -- boots
    name = "feet",
})

-- NOW the inventory!

unified_inventory.register_button("armor", {
    type = "image",
    image = "armor_icon.png",
    tooltip = "Armor",
})

-- todo: bars for what is protected against, and
unified_inventory.register_page("armor", {
    get_formspec = function(player)
        local hyper_text = {} -- hypertext text, got it?
        local player_armor = player:get_armor_groups()
        for group, desc in pairs(armor.armor_group_descriptions) do
            local protection = (1 - ((player_armor[group] or 0) / armor.armor_groups[group])) * 100
            hyper_text[#hyper_text + 1] = ("%s%% %s"):format(protection, desc) -- HEY THERE!!!! SOMEONE!!! if you don't understand what the hell that format string was, please learn how to use string.format, it's important!!! Its not that difficult like regex
        end
        local name = player:get_player_name()
        local props = player:get_properties()
        return {
            formspec = string.format([[
list[detached:sbz_armor:%s;main;0.2,0.2;2,10;]
listring[detached:sbz_armor:%s;main]
listring[current_player;main]
model[3.3,0.2;3,5;model;%s;%s;0,180]
hypertext[6.5,0.2;3,5;htext;%s]
        ]], name, name, props.mesh, props.textures[1], core.formspec_escape(table.concat(hyper_text, "\n"))),
        }
    end,
})

local modpath = core.get_modpath("sbz_armor")
dofile(modpath .. "/armor_recipes.lua")
dofile(modpath .. "/armor_types.lua")
