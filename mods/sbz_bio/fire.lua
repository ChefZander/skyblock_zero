--[[
License of source code
----------------------

GNU Lesser General Public License, version 2.1
Copyright (C) 2012-2016 celeron55, Perttu Ahola <celeron55@gmail.com>
Copyright (C) 2012-2016 Various Minetest Game developers and contributors

This program is free software; you can redistribute it and/or modify it under the terms
of the GNU Lesser General Public License as published by the Free Software Foundation;
either version 2.1 of the License, or (at your option) any later version.

This program is distributed in the hope that it will be useful, but WITHOUT ANY WARRANTY;
without even the implied warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.
See the GNU Lesser General Public License for more details:
https://www.gnu.org/licenses/old-licenses/lgpl-2.1.html
--]]

-- Alr, so this has been *very* modified to work with habitat regulators

-- Items
-- Flood flame function

-- Flame nodes
local fire_node = {
    description = "Fire",
    drawtype = "firelike",
    tiles = { {
        name = "fire.png",
        animation = {
            type = "vertical_frames",
            aspect_w = 16,
            aspect_h = 16,
            length = 1
        }
    }
    },
    paramtype = "light",
    light_source = core.LIGHT_MAX,
    walkable = false,
    buildable_to = true,
    sunlight_propagates = true,
    floodable = true,
    damage_per_second = 4,
    groups = {
        igniter = 2,
        dig_immediate = 3,
        fire = 1,
        not_in_creative_inventory = 1,
        co2_source = 1,
    },
    drop = "",
    on_timer = function(pos)
        if not minetest.find_node_near(pos, 1, { "group:igniter" }) then
            minetest.remove_node(pos)
            return
        end
        -- Restart timer
        return true
    end,

    air = true,
    co2_action = function(start_pos)
        local meta = minetest.get_meta(start_pos)
        local co2 = meta:get_int("co2")
        if is_node_within_radius(start_pos, "group:water", 1) then
            core.remove_node(start_pos)
            return co2
        end
        iterate_around_radius(start_pos, function(pos)
            local node = core.get_node(pos).name
            local co2_produced = core.get_item_group(node, "burn")
            ---@type function|nil
            local on_burn = (minetest.registered_nodes[node] or {}).on_burn
            if co2_produced > 0 then
                if on_burn then
                    on_burn(pos)
                else
                    core.set_node(pos, { name = "sbz_bio:fire" })
                    core.get_meta(pos):set_int("co2", co2_produced)
                    minetest.get_node_timer(pos):start(math.random(30, 60))
                end
            end
        end)
        core.remove_node(start_pos)
        return co2
    end,
}

core.register_node("sbz_bio:fire", fire_node)

-- Flint and Steel
core.register_tool("sbz_bio:igniter", {
    description = "Igniter",
    inventory_image = "igniter.png",

    on_use = function(itemstack, user, pointed_thing)
        local player_name = user:get_player_name()
        if pointed_thing.type == "node" then
            local node_under = minetest.get_node(pointed_thing.under).name
            local nodedef = minetest.registered_nodes[node_under]
            if not nodedef then
                return
            end
            if minetest.is_protected(pointed_thing.under, player_name) then
                minetest.record_protection_violation(pointed_thing.under, player_name)
                return
            end

            if nodedef.on_ignite then
                nodedef.on_ignite(pointed_thing.under, user)
            elseif minetest.get_item_group(node_under, "burn") >= 1
                and minetest.get_node(pointed_thing.above).name == "air" then
                if minetest.is_protected(pointed_thing.above, player_name) then
                    minetest.record_protection_violation(pointed_thing.above, player_name)
                    return
                end

                minetest.set_node(pointed_thing.above, { name = "sbz_bio:fire" })
            end
        end
        -- Wear tool
        itemstack:add_wear_by_uses(66)

        return itemstack
    end
})

minetest.register_craft({
    output = "sbz_bio:igniter",
    recipe = {
        { "sbz_bio:pyrograss" },
        { "sbz_resources:matter_dust" },
        { "sbz_resources:matter_dust" }
    }
})


minetest.register_abm({
    label = "Remove fire",
    interval = 10,
    chance = 3,
    nodenames = { "sbz_bio:fire" },
    action = function(pos)
        minetest.remove_node(pos)
    end
})
