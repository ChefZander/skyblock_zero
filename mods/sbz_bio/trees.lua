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
                --if not meta:get_int("immutable") == 1 then
                sbz_api.mutate_dna(dna, nil, 10)
                --end
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
            timer:start(math.random(10, 100))
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
            if not core.is_protected(pos, digger:get_player_name()) then
                local drops = def.tree_drop
                for _, item in ipairs(drops) do
                    if math.random() <= 1 / item.rarity then
                        if digger and digger:is_player() then
                            local leftover = digger:get_inventory():add_item("main", item.item)
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
                            }, ItemStack(item.item))
                        end
                        break
                    end
                end

                minetest.remove_node(pos)
                minetest.check_for_falling(pos)
            end
        end,
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

sbz_api.register_trunk("sbz_bio:colorium_tree", unifieddyes.def {
    description = "Colorium Tree",
    groups = {
        matter = 3,
        oddly_breakable_by_hand = 3,
        burn = 4,
        transparent = 1,
        explody = 10,
        tree = 1,
        ui_bio = 1
    },
    radius = 3,
    paramtype2 = "colorwallmounted",
    tiles = {
        "colorium_tree_top.png",
        "colorium_tree_top.png",
        "colorium_tree_side.png"
    },
    leaves = "sbz_bio:colorium_leaves",
    sounds = sbz_api.sounds.tree(),
})

sbz_api.register_leaves("sbz_bio:colorium_leaves", unifieddyes.def {
    description = "Colorium Leaves",
    groups = {
        matter = 3,
        oddly_breakable_by_hand = 3,
        burn = 2,
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
    drop = {
        max_items = 1,
        items = {
            {
                items = { "sbz_bio:colorium_sapling" },
                rarity = 5
            },
            {
                items = { "sbz_bio:colorium_leaves" },
                rarity = 1
            }
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
    inventory_image = "colorium_sapling.png",
    use_texture_alpha = "clip",
    walkable = false,
    climbable = true,
    move_resistance = 1,
    floodable = true,
    tree = "sbz_bio:colorium_tree",
    leaves = "sbz_bio:colorium_leaves",
    core = "sbz_bio:colorium_tree_core",
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
        max_size = 4000,
        tree_core = "sbz_bio:colorium_tree_core"
    },
})
sbz_api.register_tree("sbz_bio:giant_colorium_sapling", {
    description = "Giant Colorium Sapling",
    paramtype = "light",
    drawtype = "plantlike",
    tiles = {
        "giant_colorium_sapling.png"
    },
    inventory_image = "giant_colorium_sapling.png",
    use_texture_alpha = "clip",
    walkable = false,
    climbable = true,
    move_resistance = 1,
    floodable = true,
    tree = "sbz_bio:colorium_tree",
    leaves = "sbz_bio:colorium_leaves",
    core = "sbz_bio:colorium_tree_core",
    dna = {
        axiom = "FFFFFFFAFFFFFFFFA",
        trunk = "sbz_bio:colorium_tree",
        leaves = "sbz_bio:colorium_leaves",
        thin_branches = true,
        random_level = 0,
        rules_a = "[&[+FFFFFFFFFFFFFA-/FFFFFFFFFFFA*]^b]", -- makes branches
        rules_b = "[A+A&A^A/A]A",                          -- branch bomb
        rules_c = "*F",
        rules_d = "FFFFF",
        iterations = 7,
        angle = 50,
        max_size = 10000,
        tree_core = "sbz_bio:colorium_tree",
        random = true,
    },
})

core.register_craft {
    output = "sbz_bio:giant_colorium_sapling",
    recipe = {
        { "sbz_resources:phlogiston_blob", "sbz_resources:phlogiston_blob", "sbz_resources:phlogiston_blob", },
        { "sbz_resources:phlogiston_blob", "sbz_bio:colorium_sapling",      "sbz_resources:phlogiston_blob", },
        { "sbz_resources:phlogiston_blob", "sbz_resources:phlogiston_blob", "sbz_resources:phlogiston_blob", },
    }
}

-- purely decor
minetest.register_node("sbz_bio:colorium_planks", unifieddyes.def {
    description = "Colorium Planks",
    tiles = { "colorium_planks.png" },
    paramtype2 = "color",
    groups = { matter = 3, oddly_breakable_by_hand = 2, burn = 1, transparent = 1, explody = 10, },
    sounds = sbz_api.sounds.tree(),
})

core.register_craft({
    type = "shapeless",
    recipe = { "sbz_bio:colorium_tree" },
    output = "sbz_bio:colorium_planks 4",
})

stairs.register("sbz_bio:colorium_planks")

local vowels = "aeiyou"                        -- 6
local everything_else = "bcdfghjklmnpqrstvwxz" -- 20
local function get_hash_name(string)
    -- string of any size => human readable word
    local sha = core.sha1(string, true)
    -- 20 bytes... => 20 letters? lol
    -- ok ill cut it to 8
    sha = sha:sub(1, 8)
    -- now...
    local do_vowels = false
    local name = ""
    for i = 1, #sha do
        if do_vowels then
            local index = string.byte(string.sub(sha, i, i)) % #vowels
            name = name .. string.sub(vowels, index, index)
        else
            local index = string.byte(string.sub(sha, i, i)) % #everything_else
            name = name .. string.sub(everything_else, index, index)
        end
        do_vowels = not do_vowels
    end
    return name
end

core.register_node("sbz_bio:colorium_tree_core", {
    description = "Colorium Tree Core",
    info_extra = "Contains the tree's dna.",
    groups = {
        matter = 3,
        oddly_breakable_by_hand = 3,
        burn = 40,
        transparent = 1,
        explody = 10,
        tree = 1,
        ui_bio = 1,
        tree_core = 1,
    },
    radius = 3,
    paramtype2 = "wallmounted",
    tiles = {
        "colorium_tree_top.png",
        "colorium_tree_top.png",
        { name = "colorium_tree_core_side.png", animation = { type = "vertical_frames", length = 12 } }
    },
    sounds = sbz_api.sounds.tree(),
    drop = "",
    on_dig = function(pos, node, digger)
        local item = "sbz_bio:colorium_tree_core"
        item = ItemStack(item)
        item:get_meta():set_string("dna", core.get_meta(pos):get_string("dna"))
        item:get_meta():set_string("description",
            item:get_description() .. "\nName: " .. get_hash_name(core.get_meta(pos):get_string("dna")))
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

        minetest.remove_node(pos)
        minetest.check_for_falling(pos)
    end,
})


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

local power_needed = 85
sbz_api.register_stateful_machine("sbz_bio:dna_extractor", {
    description = "DNA extractor",
    info_extra = "Copies DNA from tree cores, puts it into saplings",
    paramtype2 = "facedir",
    tiles = {
        "dna_extractor_side.png",
        "dna_extractor_side.png",
        "dna_extractor_side.png",
        "dna_extractor_side.png",
        "dna_extractor_side.png",
        "dna_extractor.png",
    },
    groups = { matter = 1 },
    on_construct = function(pos)
        local meta = core.get_meta(pos)
        local inv = meta:get_inventory()
        inv:set_size("input", 2)
        inv:set_size("output", 1)
        meta:set_string("formspec", [[
formspec_version[7]
size[8.2,9]
style_type[list;spacing=.2;size=.8]
list[context;output;6,2;1,1;]
list[context;input;1,2;2,1;]
list[current_player;main;0.2,5;8,4;]
listring[current_player;main]listring[context;input]listring[current_player;main]listring[context;output]listring[current_player;main]
]])
    end,
    input_inv = "input",
    output_inv = "output",
    action = function(pos, node, meta, supply, demand)
        if supply < demand + power_needed then
            meta:set_string("infotext", "Not enough power")
            return power_needed, false
        end

        local inv = meta:get_inventory()
        local input_list = inv:get_list("input")
        local dna
        local num_tree_cores = 0
        local num_saplings = 0
        local sapling_stack, sapling_index
        for i = 1, #input_list do
            local stack = ItemStack(input_list[i])
            if core.get_item_group(stack:get_name(), "tree_core") ~= 0 then
                num_tree_cores = num_tree_cores + 1
                dna = stack:get_meta():get_string("dna")
            elseif core.get_item_group(stack:get_name(), "sapling") ~= 0 then
                num_saplings = num_saplings + 1
                sapling_stack = stack
                sapling_index = i
            end
        end
        if num_tree_cores > 1 then
            meta:set_string("infotext", "Too many unique tree cores")
            return 0, false
        end
        if num_tree_cores == 0 then
            meta:set_string("infotext", "Need 1 tree core")
            return 0, false
        end
        if num_saplings == 0 then
            meta:set_string("infotext", "Need saplings")
            return 0, false
        end
        local deserialized_dna = core.deserialize(dna)
        if not deserialized_dna then
            meta:set_string("infotext", "Corrupted dna (how did you do this?)")
            return 0, false
        end
        local new_sapling_stack = ItemStack(sapling_stack)
        new_sapling_stack:get_meta():set_string("dna", dna)
        new_sapling_stack:get_meta():set_string("description", "")
        new_sapling_stack:get_meta():set_string("description",
            new_sapling_stack:get_description() ..
            "\nName: " .. get_hash_name(new_sapling_stack:get_meta():get_string("dna")))
        new_sapling_stack:set_count(1)
        if not inv:room_for_item("output", new_sapling_stack) then
            meta:set_string("infotext", "No room in output.")
            return 0, false
        end
        -- ok... enough checks
        sapling_stack:set_count(sapling_stack:get_count() - new_sapling_stack:get_count())
        inv:set_stack("input", sapling_index, sapling_stack)
        inv:add_item("output", new_sapling_stack)
        meta:set_string("infotext", "Working")
        return power_needed, true
    end,
}, {
    light_source = 14,
    tiles = {
        "dna_extractor_side.png",
        "dna_extractor_side.png",
        "dna_extractor_side.png",
        "dna_extractor_side.png",
        "dna_extractor_side.png",
        { name = "dna_extractor_on.png", animation = { type = "vertical_frames", length = 1 } },
    },
})
core.register_craft {
    output = "sbz_bio:dna_extractor",
    recipe = {
        { "sbz_bio:colorium_tree",              "sbz_bio:colorium_tree",           "sbz_bio:colorium_tree" },
        { "sbz_resources:storinator_stemfruit", "sbz_resources:emittrium_circuit", "sbz_resources:storinator_stemfruit" },
        { "sbz_bio:colorium_tree",              "sbz_bio:colorium_tree",           "sbz_bio:colorium_tree" }
    }
}
