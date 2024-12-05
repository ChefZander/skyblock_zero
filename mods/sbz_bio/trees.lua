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

function sbz_api.can_tree_grow(pos)
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
        after_place_node = function(pos, placer, stack)
            local meta = minetest.get_meta(pos)
            meta:set_string("owner", placer:get_player_name())
            meta:set_int("immutable", stack:get_meta():get_int("immutable"))
            local dna = minetest.deserialize(stack:get_meta():get_string("dna")) or
                core.registered_items[sapling_name].dna
            meta:set_string("dna", minetest.serialize(dna))
            meta:set_string("item_meta", core.serialize(stack:get_meta():to_table()))
        end,
        on_timer = sbz_api.grow_sapling,
        grow = function(pos)
            if not sbz_api.can_tree_grow(pos) then
                return true -- re-run
            else
                local meta = minetest.get_meta(pos)
                local owner = meta:get_string("owner")
                unlock_achievement(owner, "Colorium Trees")
                local dna = minetest.deserialize(meta:get_string("dna")) or
                    core.registered_items[sapling_name].dna
                if not meta:get_int("immutable") == 1 then
                    sbz_api.mutate_dna(dna, nil, 20)
                end
                minetest.remove_node(pos)
                sbz_api.spawn_tree(pos, dna, owner)
            end
        end,
        preserve_metadata = function(pos, oldnode, oldmeta, drops)
            drops[1]:get_meta():from_table(minetest.deserialize(oldmeta.item_meta or ""))
        end
    } do
        sapling_def[k] = v
    end
    minetest.register_node(sapling_name, sapling_def)
end

-- leafdecay, again, for this function
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
local function leafdecay_after_destruct(pos, _, def)
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
            local drops = def.tree_drop
            for _, item in ipairs(drops) do
                if math.random() <= 1 / item.rarity then
                    item = item.item
                    if minetest.get_item_group(item, "sapling") then
                        local stack = ItemStack(item)
                        local own_dna = minetest.get_meta(pos):get_string("dna")
                        local stack_meta = stack:get_meta()
                        stack_meta:set_string("dna", own_dna)
                        stack_meta:set_string("description",
                            stack:get_description() .. "\nStack DNA hash: " .. sbz_api.hash_dna(own_dna))
                        item = stack:to_string()
                    else
                        local stack = ItemStack(item)
                        item = stack:get_name() -- nuke meta
                    end
                    if minetest.get_item_group(item, "sapling") then
                        local stack = ItemStack(item)
                        stack:get_meta():set_string("dna", minetest.serialize(minetest.get_meta(pos):get_string("dna")))
                        item = stack:to_string()
                    end
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
        end,
        on_dig = function(pos, node, digger)
            local drops = def.tree_drop
            for _, item in ipairs(drops) do
                if math.random() <= 1 / item.rarity then
                    local stack = ItemStack(item.item)
                    if minetest.get_item_group(item.item, "sapling") > 0 then
                        local own_dna = minetest.get_meta(pos):get_string("dna")
                        local stack_meta = stack:get_meta()
                        stack_meta:set_string("dna", own_dna)
                        stack_meta:set_string("description",
                            stack:get_description() .. "\nStack DNA hash: " .. sbz_api.hash_dna(own_dna))
                        item = stack:to_string()
                    else
                        item = stack:get_name() -- nuke meta
                    end
                    if digger and digger:is_player() then
                        local leftover = digger:get_inventory():add_item("main", item)
                        if leftover then
                            minetest.add_item({
                                x = pos.x - 0.5 + math.random(),
                                y = pos.y - 0.5 + math.random(),
                                z = pos.z - 0.5 + math.random(),
                            }, leftover)
                        end
                    else
                        minetest.add_item({
                            x = pos.x - 0.5 + math.random(),
                            y = pos.y - 0.5 + math.random(),
                            z = pos.z - 0.5 + math.random(),
                        }, item)
                    end
                    break
                end
            end

            minetest.remove_node(pos)
            minetest.check_for_falling(pos)
        end,
        drops = "",
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
    leaves = "sbz_bio:colorium_leaves",
    sounds = sbz_api.sounds.tree(),
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
    tree_drop = {
        {
            item = "sbz_bio:colorium_sapling",
            rarity = 5
        },
        {
            item = "sbz_bio:colorium_leaves",
            rarity = 1
        }
    },
    sounds = sbz_api.sounds.leaves(),
})

minetest.register_craft {
    output = "sbz_bio:colorium_sapling",
    recipe = {
        { "sbz_meteorites:neutronium" },
        { "sbz_resources:core_dust" },
        { "sbz_resources:core_dust" },
    }
}


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
    tree = "sbz_bio:colorium_tree",
    leaves = "sbz_bio:colorium_leaves",
    dna = {
        axiom = "TTTTcccccccccc[B]",
        trunk = "sbz_bio:colorium_tree",
        leaves = "sbz_bio:colorium_leaves",
        thin_branches = true,
        iterations = 3,
        random_level = 0,
        rules_a = "*", -- leaves
        rules_b = "FaBBBB",
        rules_c = "+",
        rules_d = "",
        angle = 25,
        max_size = 30 ^ 3, -- dont know if this is a good idea
    },
}
--,schems .. "colorium_tree.mts", { x = 5, y = 7, z = 5 }
)


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
