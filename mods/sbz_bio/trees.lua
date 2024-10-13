-- yes some of this has been inspired by minetest_game's trees

-- https://github.com/minetest/minetest_game/blob/df8159436c65db7940077dda28f4d1ad5a9c0811/mods/default/trees.lua#L455
--[[
Specifically for this function,

GNU Lesser General Public License, version 2.1
Copyright (C) 2011-2018 celeron55, Perttu Ahola <celeron55@gmail.com>
Copyright (C) 2011-2018 Various Minetest developers and contributors

This program is free software; you can redistribute it and/or modify it under the terms
of the GNU Lesser General Public License as published by the Free Software Foundation;
either version 2.1 of the License, or (at your option) any later version.

This program is distributed in the hope that it will be useful, but WITHOUT ANY WARRANTY;
without even the implied warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.
See the GNU Lesser General Public License for more details:
https://www.gnu.org/licenses/old-licenses/lgpl-2.1.html
]]
function sbz_api.can_grow(pos)
    local node_under = minetest.get_node_or_nil({ x = pos.x, y = pos.y - 1, z = pos.z })
    if not node_under then
        return false
    end
    if minetest.get_item_group(node_under.name, "soil") == 0 then
        return false
    end
    local light_level = minetest.get_node_light(pos)
    if not light_level or light_level < 8 then
        return false
    end
    return true
end

sbz_api.grow_sapling = function(pos)
    minetest.registered_nodes[minetest.get_node(pos).name].grow(pos)
end
-- now its normally licensed:
sbz_api.register_tree = function(sapling_name, sapling_def, schem_path, size)
    for k, v in pairs {
        drawtype = "plantlike",
        paramtype = "light",
        sunlight_propagates = true,
        walkable = false,
        selection_box = {
            type = "fixed",
            fixed = { -4 / 16, -0.5, -4 / 16, 4 / 16, 7 / 16, 4 / 16 }
        },
        groups = { snappy = 2, dig_immediate = 3, burn = 1,
            attached_node = 1, sapling = 1, explody = 100, matter = 1, ui_bio = 1 },
        on_construct = function(pos)
            minetest.get_node_timer(pos):start(math.random(300, 1500))
        end,
        on_place = function(stack, placer, pointed)
            -- https://github.com/minetest/minetest_game/blob/df8159436c65db7940077dda28f4d1ad5a9c0811/mods/default/trees.lua#L455
            --[[
Specifically for this function,

GNU Lesser General Public License, version 2.1
Copyright (C) 2011-2018 celeron55, Perttu Ahola <celeron55@gmail.com>
Copyright (C) 2011-2018 Various Minetest developers and contributors

This program is free software; you can redistribute it and/or modify it under the terms
of the GNU Lesser General Public License as published by the Free Software Foundation;
either version 2.1 of the License, or (at your option) any later version.

This program is distributed in the hope that it will be useful, but WITHOUT ANY WARRANTY;
without even the implied warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.
See the GNU Lesser General Public License for more details:
https://www.gnu.org/licenses/old-licenses/lgpl-2.1.html
]]
            local name = placer:get_player_name()
            local pos = pointed.under
            local node = minetest.get_node(pos)
            local pdef = minetest.registered_nodes[node.name]

            if pdef and pdef.on_rightclick and
                not (placer and placer:is_player() and
                    placer:get_player_control().sneak) then
                return pdef.on_rightclick(pos, node, placer, stack, stack)
            end
            if not pdef or not pdef.buildable_to then
                pos = pointed.above
                node = minetest.get_node(pos)
                pdef = minetest.registered_nodes[node.name]
                if not pdef or not pdef.buildable_to then
                    return stack
                end
            end
            if minetest.is_area_protected(vector.subtract(pos, size), vector.add(pos, size), name, 4) then
                minetest.record_protection_violation(pos, name)
                -- Print extra information to explain
                minetest.chat_send_player(name,
                    string.format("%s will intersect protection on growth.", stack:get_definition().description))
                return stack
            end

            local take_item = not minetest.is_creative_enabled(name)
            local newnode = { name = sapling_name }
            local ndef = minetest.registered_nodes[sapling_name]
            minetest.set_node(pos, newnode)

            -- Run callback
            if ndef and ndef.after_place_node then
                -- Deepcopy place_to and pointed_thing because callback can modify it
                if ndef.after_place_node(table.copy(pos), placer, stack, table.copy(pointed)) then
                    take_item = false
                end
            end

            -- Run script hook
            for _, callback in ipairs(minetest.registered_on_placenodes) do
                -- Deepcopy pos, node and pointed_thing because callback can modify them
                if callback(table.copy(pos), table.copy(newnode),
                        placer, table.copy(node or {}),
                        stack, table.copy(pointed)) then
                    take_item = false
                end
            end

            if take_item then
                stack:take_item()
            end
            minetest.get_meta(pos):set_string("owner", name)
            return stack
        end,
        on_timer = sbz_api.grow_sapling,
        grow = function(pos)
            if not sbz_api.can_grow(pos) then
                return true -- re-run
            else
                unlock_achievement(minetest.get_meta(pos):get_string("owner"), "Colorium Trees")
                minetest.remove_node(pos)

                -- prepare
                local xh, zh = size.x / 2, size.z / 2
                for x = -xh, xh do
                    for y = 0, size.y do
                        for z = -zh, zh do
                            local p = vector.new(x + pos.x, y + pos.y, z + pos.z)
                            if minetest.registered_nodes[minetest.get_node(p).name or ""].air then
                                minetest.remove_node(p)
                            end
                        end
                    end
                end
                -- do
                minetest.place_schematic(
                    { x = pos.x - (size.x / 2), y = pos.y, z = pos.z - (size.z / 2) },
                    schem_path, "random", nil, false)
            end
        end,
    } do
        sapling_def[k] = v
    end
    minetest.register_node(sapling_name, sapling_def)
end

-- leafdecay, again,
--[[
GNU Lesser General Public License, version 2.1
Copyright (C) 2011-2018 celeron55, Perttu Ahola <celeron55@gmail.com>
Copyright (C) 2011-2018 Various Minetest developers and contributors

This program is free software; you can redistribute it and/or modify it under the terms
of the GNU Lesser General Public License as published by the Free Software Foundation;
either version 2.1 of the License, or (at your option) any later version.

This program is distributed in the hope that it will be useful, but WITHOUT ANY WARRANTY;
without even the implied warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.
See the GNU Lesser General Public License for more details:
https://www.gnu.org/licenses/old-licenses/lgpl-2.1.html
]]
local function leafdecay_after_destruct(pos, oldnode, def)
    for _, v in pairs(minetest.find_nodes_in_area(vector.subtract(pos, def.radius),
        vector.add(pos, def.radius), def.leaves)) do
        local node = minetest.get_node(v)
        local timer = minetest.get_node_timer(v)
        if node.param2 ~= 1 and not timer:is_started() then
            timer:start(math.random(5, 10) / 10)
        end
    end
end

function sbz_api.register_leaves(name, def)
    for k, v in pairs {
        after_place_node = function(pos, placer, itemstack, pointed_thing)
            if placer and placer:is_player() then
                local node = minetest.get_node(pos)
                node.param2 = 1
                minetest.set_node(pos, node)
            end
        end,
        paramtype = "light",
        drawtype = "allfaces_optional",
        waving = 1,
        walkable = false,
        climbable = true,
        move_resistance = 1,
        floodable = true,
        on_timer = function(pos)
            if minetest.find_node_near(pos, def.radius, def.tree) then
                return false
            end

            local node = minetest.get_node(pos)
            local drops = minetest.get_node_drops(node.name)
            for _, item in ipairs(drops) do
                local is_leaf = minetest.get_item_group(item, "leaves")

                if (minetest.get_item_group(item, "leafdecay_drop") ~= 0) or not is_leaf then
                    minetest.add_item({
                        x = pos.x - 0.5 + math.random(),
                        y = pos.y - 0.5 + math.random(),
                        z = pos.z - 0.5 + math.random(),
                    }, item)
                end
            end

            minetest.remove_node(pos)
            minetest.check_for_falling(pos)

            -- spawn a few particles for the removed node
            minetest.add_particlespawner({
                amount = 12,
                time = 0.001,
                expirationtime = 10,
                minpos = vector.subtract(pos, { x = 0.5, y = 0.5, z = 0.5 }),
                maxpos = vector.add(pos, { x = 0.5, y = 0.5, z = 0.5 }),
                minvel = vector.new(-0.5, -1, -0.5),
                maxvel = vector.new(0.5, 0, 0.5),
                minacc = vector.new(0, -0.5, 0),
                maxacc = vector.new(0, -0.5, 0),
                minsize = 0,
                maxsize = 0,
                node = node,
            })
        end
    } do
        def[k] = v
    end
    minetest.register_node(name, def)
end

-- normal licensed code again
function sbz_api.register_trunk(name, def)
    for k, v in pairs {
        after_destruct = function(pos)
            leafdecay_after_destruct(pos, nil, def)
        end
    } do
        def[k] = v
    end
    minetest.register_node(name, def)
end

sbz_api.register_trunk("sbz_bio:colorium_tree", {
    description = "Colorium Tree",
    groups = {
        matter = 3,
        oddly_breakable_by_hand = 3,
        burn = 10,
        habitat_conducts = 1,
        transparent = 1,
        explody = 10,
        tree = 1,
        ui_bio = 1
    },
    radius = 3,
    paramtype2 = "wallmounted",
    tiles = {
        "colorium_tree_top.png",
        "colorium_tree_top.png",
        "colorium_tree_side.png"
    },
    leaves = "sbz_bio:colorium_leaves"

})
sbz_api.register_leaves("sbz_bio:colorium_leaves", {
    description = "Colorium Leaves",
    groups = {
        matter = 3,
        oddly_breakable_by_hand = 3,
        burn = 3,
        habitat_conducts = 1,
        transparent = 1,
        explody = 10,
        leaves = 1,
        leafdecay = 1,
        leafdecay_drop = 0,
        cracky = 3,
        dig_immediate = 3,
        ui_bio = 1
    },

    tiles = {
        "colorium_leaves.png"
    },
    light_source = 1,
    post_effect_color = "#ffc0cb5F",
    radius = 3,
    tree = "sbz_bio:colorium_tree",
    drop = {
        max_items = 1,
        items = {
            {
                items = { "sbz_bio:colorium_sapling" },
                rarity = 5
            },
            {
                items = { "sbz_bio:colorium_leaves" },
            }
        }
    }
})

minetest.register_craft {
    output = "sbz_bio:colorium_sapling",
    recipe = {
        { "sbz_meteorites:neutronium" },
        { "sbz_resources:core_dust" },
        { "sbz_resources:core_dust" },
    }
}

local schems = minetest.get_modpath("sbz_bio") .. "/schematics/"

sbz_api.register_tree("sbz_bio:colorium_sapling", {
    description = "Colorium Sapling",
    paramtype = "light",
    drawtype = "plantlike",
    tiles = {
        "colorium_sapling.png"
    },
    use_texture_alpha = "clip",
    walkable = false,
    climbable = true,
    move_resistance = 1,
    floodable = true,
}, schems .. "colorium_tree.mts", { x = 5, y = 7, z = 5 })


unified_inventory.register_craft {
    type = "crushing",
    output = "unifieddyes:colorium_powder",
    items = { "sbz_bio:colorium_leaves" }
}

unified_inventory.register_craft {
    type = "crushing",
    output = "sbz_bio:colorium_leaves 4",
    items = { "sbz_bio:colorium_tree" }
}
