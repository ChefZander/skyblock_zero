-- This file supplies the majority of Unified Dyes' API

unifieddyes.player_current_dye = {}
unifieddyes.player_selected_dye = {}
unifieddyes.player_last_right_clicked = {}
unifieddyes.palette_has_color = {}
unifieddyes.player_showall = {}

-- if a node with a palette is placed in the world,
-- but the itemstack used to place it has no palette_index (color byte),
-- create something appropriate to make it officially white.

minetest.register_on_placenode(function(pos, newnode, placer, oldnode, itemstack, pointed_thing)
    local def = minetest.registered_items[newnode.name]

    if not def or not def.palette or def.after_place_node or not placer then return false end

    if not string.find(itemstack:to_string(), 'palette_index') then
        local param2
        local color = 0

        if def.palette == 'unifieddyes_palette_extended.png' and def.paramtype2 == 'color' then
            param2 = 240
            color = 240
        elseif def.palette == 'unifieddyes_palette_colorwallmounted.png' and def.paramtype2 == 'colorwallmounted' then
            param2 = newnode.param2 % 8
        elseif string.find(def.palette, 'unifieddyes_palette_') and def.paramtype2 == 'colorfacedir' then -- it's a split palette
            param2 = newnode.param2 % 32
        end

        if param2 and not (core.get_item_group(newnode.name, 'falling_node') == 1) then
            minetest.swap_node(pos, { name = newnode.name, param2 = param2 })
            minetest.get_meta(pos):set_int('palette_index', color)
        end
    end
end)

-- The complementary function: strip-off the color if the node being dug is still white/neutral
-- adapted from
-- https://github.com/minetest/minetest/blob/fe8d04d0b3c2e3af7c406fb6527f1b5230a30137/builtin/game/item.lua#L460-L562
local function node_dig_without_color(pos, node, digger)
    if not digger then return false end
    local diggername = digger:get_player_name()

    local def = ItemStack(node.name):get_definition()
    -- Copy pos because the callback could modify it
    if not def.diggable or (def.can_dig and not def.can_dig(vector.copy(pos), digger)) then
        minetest.log(
            'info',
            diggername .. ' tried to dig ' .. node.name .. ' which is not diggable ' .. minetest.pos_to_string(pos)
        )
        return false
    end

    if minetest.is_protected(pos, diggername) then
        minetest.log(
            'action',
            diggername .. ' tried to dig ' .. node.name .. ' at protected position ' .. minetest.pos_to_string(pos)
        )
        minetest.record_protection_violation(pos, diggername)
        return false
    end

    minetest.log('action', diggername .. ' digs ' .. node.name .. ' at ' .. minetest.pos_to_string(pos))

    local wielded = digger and digger:get_wielded_item()
    local drops = { node.name } -- this is instead of asking minetest to generate the node drops

    if wielded then
        local wdef = wielded:get_definition()
        local tp = wielded:get_tool_capabilities()
        local dp = minetest.get_dig_params(def and def.groups, tp, wielded:get_wear())
        if wdef and wdef.after_use then
            wielded = wdef.after_use(wielded, digger, node, dp) or wielded
        else
            -- Wear out tool
            if not minetest.is_creative_enabled(diggername) then
                wielded:add_wear(dp.wear)
                if wielded:get_count() == 0 and wdef.sound and wdef.sound.breaks then
                    minetest.sound_play(wdef.sound.breaks, {
                        pos = pos,
                        gain = 0.5,
                    }, true)
                end
            end
        end
        digger:set_wielded_item(wielded)
    end

    -- Check to see if metadata should be preserved.
    if def and def.preserve_metadata then
        local oldmeta = minetest.get_meta(pos):to_table().fields
        -- Copy pos and node because the callback can modify them.
        local pos_copy = vector.copy(pos)
        local node_copy = { name = node.name, param1 = node.param1, param2 = node.param2 }
        local drop_stacks = {}
        for k, v in pairs(drops) do
            drop_stacks[k] = ItemStack(v)
        end
        drops = drop_stacks
        def.preserve_metadata(pos_copy, node_copy, oldmeta, drops)
    end

    -- Handle drops
    minetest.handle_node_drops(pos, drops, digger)

    local oldmetadata
    if def and def.after_dig_node then oldmetadata = minetest.get_meta(pos):to_table() end

    -- Remove node and update
    minetest.remove_node(pos)

    -- Play sound if it was done by a player
    if diggername ~= '' and def and def.sounds and def.sounds.dug then
        minetest.sound_play(def.sounds.dug, {
            pos = pos,
            exclude_player = diggername,
        }, true)
    end

    -- Run callback
    if def and def.after_dig_node then
        -- Copy pos and node because callback can modify them
        local pos_copy = vector.copy(pos)
        local node_copy = { name = node.name, param1 = node.param1, param2 = node.param2 }
        def.after_dig_node(pos_copy, node_copy, oldmetadata, digger)
    end

    -- Run script hook
    for _, callback in ipairs(minetest.registered_on_dignodes) do
        local origin = minetest.callback_origins[callback]
        minetest.set_last_run_mod(origin.mod)

        -- Copy pos and node because callback can modify them
        local pos_copy = vector.copy(pos)
        local node_copy = { name = node.name, param1 = node.param1, param2 = node.param2 }
        callback(pos_copy, node_copy, digger)
    end

    return true
end

function unifieddyes.on_dig(pos, node, digger)
    local param2 = minetest.get_node(pos).param2
    local def = minetest.registered_items[node.name]
    local del_color

    if def.paramtype2 == 'color' and param2 == 240 and def.palette == 'unifieddyes_palette_extended.png' then
        del_color = true
    elseif
        (def.paramtype2 == 'colorwallmounted' or def.paramtype2 == 'colorfacedir')
        and minetest.strip_param2_color(param2, def.paramtype2) == 0
        and string.find(def.palette, 'unifieddyes_palette_')
    then
        del_color = true
    end

    if del_color then
        return node_dig_without_color(pos, node, digger)
    else
        return minetest.node_dig(pos, node, digger)
    end
end

-- just stubs to keep old mods from crashing when expecting auto-coloring
-- or getting back the dye on dig.

function unifieddyes.recolor_on_place(foo) end

function unifieddyes.after_dig_node(foo) end

-- This helper function creates multiple copies of the passed node,
-- for the split palette - one per hue, plus grey - and assigns
-- proper palettes and other attributes

function unifieddyes.generate_split_palette_nodes(name, def, drop)
    for _, color in ipairs(unifieddyes.HUES_WITH_GREY) do
        local def2 = table.copy(def)
        local desc_color = string.gsub(string.upper(string.sub(color, 1, 1)) .. string.sub(color, 2), '_', ' ')
        if string.sub(def2.description, -1) == ')' then
            def2.description = string.sub(def2.description, 1, -2) .. ', ' .. desc_color .. ' shades)'
        else
            def2.description = def2.description .. '(' .. desc_color .. ' shades)'
        end
        def2.palette = 'unifieddyes_palette_' .. color .. 's.png'
        def2.paramtype2 = 'colorfacedir'
        def2.groups.ud_param2_colorable = 1
        def2.is_ground_content = false

        if drop then
            def2.drop = {
                items = {
                    { items = { drop .. '_' .. color }, inherit_color = true },
                },
            }
        end

        minetest.register_node(':' .. name .. '_' .. color, def2)
    end
end

-- This helper function creates a colored itemstack

function unifieddyes.make_colored_itemstack(item, palette, color)
    local paletteidx = unifieddyes.getpaletteidx(color, palette)
    local stack = ItemStack(item)
    stack:get_meta():set_int('palette_index', paletteidx)
    return stack:to_string(), paletteidx
end

-- these helper functions register all of the recipes needed to create colored
-- nodes with any of the dyes supported by that node's palette.

local function register_c(craft, h, sat, val)
    local hue = (type(h) == 'table') and h[1] or h
    local color
    if val then
        if craft.palette == 'wallmounted' then
            color = val .. hue .. sat
        else
            color = val .. hue .. sat
        end
    else
        color = hue -- if val is nil, then it's grey.
    end

    local dye = 'dye:' .. color
    local recipe = minetest.serialize(craft.recipe)
    recipe = string.gsub(recipe, 'MAIN_DYE', dye)
    recipe = string.gsub(recipe, 'NEUTRAL_NODE', craft.neutral_node)
    local newrecipe = minetest.deserialize(recipe)

    local coutput = craft.output or ''
    local output = coutput
    if craft.output_prefix then
        if craft.palette ~= 'split' then
            output = craft.output_prefix .. color .. craft.output_suffix .. coutput
        else
            if hue == 'white' or hue == 'black' or string.find(hue, 'grey') then
                output = craft.output_prefix .. 'grey' .. craft.output_suffix .. coutput
            elseif hue == 'pink' then
                dye = 'dye:light_red'
                output = craft.output_prefix .. 'red' .. craft.output_suffix .. coutput
            else
                output = craft.output_prefix .. hue .. craft.output_suffix .. coutput
            end
        end
    end

    local colored_itemstack = unifieddyes.make_colored_itemstack(output, craft.palette, dye)

    minetest.register_craft {
        output = colored_itemstack,
        type = craft.type,
        recipe = newrecipe,
    }
end

function unifieddyes.register_color_craft(craft)
    local hues_table = unifieddyes.HUES_EXTENDED
    local sats_table = unifieddyes.SATS
    local vals_table = unifieddyes.VALS_SPLIT
    local greys_table = unifieddyes.GREYS

    if craft.palette == 'wallmounted' then
        register_c(craft, 'green', '', 'light_')
        register_c(craft, 'blue', '', 'light_')
        hues_table = unifieddyes.HUES_WALLMOUNTED
        sats_table = { '' }
        vals_table = unifieddyes.VALS
    elseif craft.palette == 'extended' then
        vals_table = unifieddyes.VALS_EXTENDED
        greys_table = unifieddyes.GREYS_EXTENDED
    end

    for _, hue in ipairs(hues_table) do
        for _, val in ipairs(vals_table) do
            for _, sat in ipairs(sats_table) do
                if sat == '_s50' and val ~= '' and val ~= 'medium_' and val ~= 'dark_' then break end
                register_c(craft, hue, sat, val)
            end
        end
    end

    for _, grey in ipairs(greys_table) do
        register_c(craft, grey)
    end

    register_c(craft, 'pink')
end

-- code borrowed from homedecor
-- call this function to reset the rotation of a "wallmounted" object on place

function unifieddyes.fix_rotation(pos, placer, itemstack, pointed_thing)
    local node = minetest.get_node(pos)
    local colorbits = node.param2 - (node.param2 % 8)

    local yaw = placer:get_look_horizontal()
    local dir = minetest.yaw_to_dir(yaw) -- -1.5)
    local pitch = placer:get_look_vertical()

    local fdir = minetest.dir_to_wallmounted(dir)

    if pitch < -(math.pi / 8) then
        fdir = 0
    elseif pitch > math.pi / 8 then
        fdir = 1
    end
    minetest.swap_node(pos, { name = node.name, param2 = fdir + colorbits })
end

-- use this when you have a "wallmounted" node that should never be oriented
-- to floor or ceiling...

function unifieddyes.fix_rotation_nsew(pos, placer, itemstack, pointed_thing)
    local node = minetest.get_node(pos)
    local colorbits = node.param2 - (node.param2 % 8)
    local yaw = placer:get_look_horizontal()
    local dir = minetest.yaw_to_dir(yaw + 1.5)
    local fdir = minetest.dir_to_wallmounted(dir)

    minetest.swap_node(pos, { name = node.name, param2 = fdir + colorbits })
end

-- ... and use this one to force that kind of node off of floor/ceiling
-- orientation after the screwdriver rotates it.

function unifieddyes.fix_after_screwdriver_nsew(pos, node, user, mode, new_param2)
    local new_fdir = new_param2 % 8
    local color = new_param2 - new_fdir
    if new_fdir < 2 then
        new_fdir = 2
        minetest.swap_node(pos, { name = node.name, param2 = new_fdir + color })
        return true
    end
end

function unifieddyes.is_buildable_to(placer_name, ...)
    for _, pos in ipairs { ... } do
        local node = minetest.get_node_or_nil(pos)
        local def = node and minetest.registered_nodes[node.name]
        if not (def and def.buildable_to) or minetest.is_protected(pos, placer_name) then return false end
    end
    return true
end

function unifieddyes.get_hsv(name) -- expects a node/item name
    local hue = ''
    local a
    for _, i in ipairs(unifieddyes.HUES_EXTENDED) do
        a, _ = string.find(name, '_' .. i[1])
        if a then
            hue = i[1]
            break
        end
    end

    if string.find(name, '_light_grey') then
        hue = 'light_grey'
    elseif string.find(name, '_lightgrey') then
        hue = 'light_grey'
    elseif string.find(name, '_dark_grey') then
        hue = 'dark_grey'
    elseif string.find(name, '_darkgrey') then
        hue = 'dark_grey'
    elseif string.find(name, '_grey') then
        hue = 'grey'
    elseif string.find(name, '_white') then
        hue = 'white'
    elseif string.find(name, '_black') then
        hue = 'black'
    end

    local sat = ''
    if string.find(name, '_s50') then sat = '_s50' end

    local val = ''
    if string.find(name, 'dark_') then val = 'dark_' end
    if string.find(name, 'medium_') then val = 'medium_' end
    if string.find(name, 'light_') then val = 'light_' end

    return hue, sat, val
end

-- code partially borrowed from cheapie's plasticbox mod

-- in the function below, color is just a color string, while
-- palette_type can be:
--
-- "extended" = 256 color palette
-- "split" = 200 color palette split into pieces for colorfacedir
-- "wallmounted" = 32-color abridged palette

function unifieddyes.getpaletteidx(color, palette_type)
    if string.sub(color, 1, 4) == 'dye:' then
        color = string.sub(color, 5, -1)
    elseif string.sub(color, 1, 12) == 'unifieddyes:' then
        color = string.sub(color, 13, -1)
    else
        return
    end

    if palette_type == 'wallmounted' then
        if unifieddyes.gpidx_grayscale_wallmounted[color] then
            return (unifieddyes.gpidx_grayscale_wallmounted[color] * 8), 0
        end
    elseif palette_type == 'split' then
        if unifieddyes.gpidx_grayscale[color] then return (unifieddyes.gpidx_grayscale[color] * 32), 0 end
    elseif palette_type == 'extended' then
        if unifieddyes.gpidx_grayscale_extended[color] then
            return unifieddyes.gpidx_grayscale_extended[color] + 240, 0
        end
    end

    local shade = '' -- assume full
    if string.sub(color, 1, 6) == 'faint_' then
        shade = 'faint'
        color = string.sub(color, 7, -1)
    elseif string.sub(color, 1, 7) == 'pastel_' then
        shade = 'pastel'
        color = string.sub(color, 8, -1)
    elseif string.sub(color, 1, 6) == 'light_' then
        shade = 'light'
        color = string.sub(color, 7, -1)
    elseif string.sub(color, 1, 7) == 'bright_' then
        shade = 'bright'
        color = string.sub(color, 8, -1)
    elseif string.sub(color, 1, 7) == 'medium_' then
        shade = 'medium'
        color = string.sub(color, 8, -1)
    elseif string.sub(color, 1, 5) == 'dark_' then
        shade = 'dark'
        color = string.sub(color, 6, -1)
    end
    if string.sub(color, -4, -1) == '_s50' then
        shade = shade .. 's50'
        color = string.sub(color, 1, -5)
    end

    if palette_type == 'wallmounted' then
        if color == 'green' and shade == 'light' then
            return 48, 3
        elseif color == 'brown' then
            return 17, 1
        elseif color == 'pink' then
            return 56, 7
        elseif color == 'blue' and shade == 'light' then
            return 40, 5
        elseif unifieddyes.gpidx_hues_wallmounted[color] and unifieddyes.gpidx_shades_wallmounted[shade] then
            return (unifieddyes.gpidx_shades_wallmounted[shade] * 64 + unifieddyes.gpidx_hues_wallmounted[color] * 8),
                unifieddyes.gpidx_hues_wallmounted[color]
        end
    else
        if color == 'brown' then
            color = 'orange'
            shade = 'medium'
        elseif color == 'pink' then
            color = 'red'
            shade = 'light'
        end
        if palette_type == 'split' then -- it's colorfacedir
            if unifieddyes.gpidx_hues_extended[color] and unifieddyes.gpidx_shades_split[shade] then
                return (unifieddyes.gpidx_shades_split[shade] * 32), unifieddyes.gpidx_hues_extended[color] + 1
            end
        elseif palette_type == 'extended' then
            if unifieddyes.gpidx_hues_extended[color] and unifieddyes.gpidx_shades_extended[shade] then
                return (unifieddyes.gpidx_hues_extended[color] + unifieddyes.gpidx_shades_extended[shade] * 24),
                    unifieddyes.gpidx_hues_extended[color]
            end
        end
    end
end

function unifieddyes.get_color_from_dye_name(name)
    if name == 'dye:black' then
        return '000000'
    elseif name == 'dye:white' then
        return 'ffffff'
    end
    local item = minetest.registered_items[name]
    if not item then return end
    local inv_image = item.inventory_image
    if not inv_image then return end
    return string.match(inv_image, 'colorize:#(......):200')
end

-- get a node's dye color based on its palette and param2

function unifieddyes.color_to_name(param2, def)
    if not param2 or not def or not def.palette then return end

    if def.palette == 'unifieddyes_palette_extended.png' then
        local color = param2

        local v = 0
        local s = 1
        if color < 24 then
            v = 1
        elseif color > 23 and color < 48 then
            v = 2
        elseif color > 47 and color < 72 then
            v = 3
        elseif color > 71 and color < 96 then
            v = 4
        elseif color > 95 and color < 120 then
            v = 5
        elseif color > 119 and color < 144 then
            v = 5
            s = 2
        elseif color > 143 and color < 168 then
            v = 6
        elseif color > 167 and color < 192 then
            v = 6
            s = 2
        elseif color > 191 and color < 216 then
            v = 7
        elseif color > 215 and color < 240 then
            v = 7
            s = 2
        end

        if color > 239 then
            if color == 240 then
                return 'white'
            elseif color == 244 then
                return 'light_grey'
            elseif color == 247 then
                return 'grey'
            elseif color == 251 then
                return 'dark_grey'
            elseif color == 255 then
                return 'black'
            else
                return 'grey_' .. 15 - (color - 240)
            end
        else
            local h = color - math.floor(color / 24) * 24
            return unifieddyes.VALS_EXTENDED[v] .. unifieddyes.HUES_EXTENDED[h + 1][1] .. unifieddyes.SATS[s]
        end
    elseif def.palette == 'unifieddyes_palette_colorwallmounted.png' then
        local color = math.floor(param2 / 8)
        if color == 0 then
            return 'white'
        elseif color == 1 then
            return 'light_grey'
        elseif color == 2 then
            return 'grey'
        elseif color == 3 then
            return 'dark_grey'
        elseif color == 4 then
            return 'black'
        elseif color == 5 then
            return 'light_blue'
        elseif color == 6 then
            return 'light_green'
        elseif color == 7 then
            return 'pink'
        end
        local v = math.floor(color / 8)
        local h = color - v * 8
        return unifieddyes.VALS[v] .. unifieddyes.HUES_WALLMOUNTED[h + 1]
    elseif string.find(def.palette, 'unifieddyes_palette') then -- it's the split palette
        -- palette names in this mode are always "unifieddyes_palette_COLORs.png"

        local s = string.sub(def.palette, 21)
        local color = string.sub(s, 1, string.find(s, 's.png') - 1)

        local v = math.floor(param2 / 32)
        if color ~= 'grey' then
            if v == 0 then
                return 'faint_' .. color
            elseif v == 1 then
                return color
            elseif v == 2 then
                return color .. '_s50'
            elseif v == 3 then
                return 'light_' .. color
            elseif v == 4 then
                return 'medium_' .. color
            elseif v == 5 then
                return 'medium_' .. color .. '_s50'
            elseif v == 6 then
                return 'dark_' .. color
            elseif v == 7 then
                return 'dark_' .. color .. '_s50'
            end
        else
            if v > 0 and v < 6 then
                return unifieddyes.GREYS[v]
            else
                return 'white'
            end
        end
    end
end

unifieddyes.palettes = {
    ['colorfacedir'] = 'unifieddyes_palette_colorfacedir.png',
    ['colorwallmounted'] = 'unifieddyes_palette_colorwallmounted.png',
    ['color'] = 'unifieddyes_palette_extended.png',
}

function unifieddyes.def(d, on_dig)
    d.paramtype2 = d.paramtype2 or 'color'
    d.palette = unifieddyes.palettes[d.paramtype2]

    core.after(0, function()
        if d.on_dig == nil or on_dig == false and d.drop == nil then d.on_dig = node_dig_without_color end
    end)
    return d
end
