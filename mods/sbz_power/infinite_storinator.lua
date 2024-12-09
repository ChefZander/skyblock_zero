-- License for the function make_scrollbaroptions_for_scroll_container:
--[[
License of minetest: https://github.com/minetest/minetest/blob/master/LICENSE.txt

Minetest
Copyright (C) 2022 rubenwardy

This program is free software; you can redistribute it and/or modify
it under the terms of the GNU Lesser General Public License as published by
the Free Software Foundation; either version 2.1 of the License, or
(at your option) any later version.

This program is distributed in the hope that it will be useful,
but WITHOUT ANY WARRANTY; without even the implied warranty of
MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
GNU Lesser General Public License for more details.

You should have received a copy of the GNU Lesser General Public License along
with this program; if not, write to the Free Software Foundation, Inc.,
51 Franklin Street, Fifth Floor, Boston, MA 02110-1301 USA.

Only applies to the function below, everything else is licensed normally as in LICENSE.txt
]]
--- Creates a scrollbaroptions for a scroll_container
--
-- @param visible_l the length of the scroll_container and scrollbar
-- @param total_l length of the scrollable area
-- @param scroll_factor as passed to scroll_container
local function make_scrollbaroptions_for_scroll_container(visible_l, total_l, scroll_factor)
    assert(total_l >= visible_l)
    local max = total_l - visible_l
    local thumb_size = (visible_l / total_l) * max
    return ("scrollbaroptions[min=0;max=%f;thumbsize=%f]"):format(max / scroll_factor, thumb_size / scroll_factor)
end

local max_slots = 5000

local M = minetest.get_meta

local slots_per_1_power = 8

sbz_api.register_machine("sbz_power:infinite_storinator", {
    description = "Infinite Storinator (deprecated)",
    info_extra = {
        "If you loose power you will need to re-power it to get your items back",
        "For one power you can get " .. slots_per_1_power .. " slots"
    },
    tiles = {
        "infinite_storinator_side.png",
        "infinite_storinator_side.png",
        "infinite_storinator_side.png",
        "infinite_storinator_side.png",
        "infinite_storinator_side.png",
        { name = "infinite_storinator_front.png", animation = { type = "vertical_frames", length = 2 } }
    },
    paramtype2 = "facedir",
    on_construct = function(pos)
        local meta = minetest.get_meta(pos)
        local inv = meta:get_inventory()
        inv:set_size("inv", max_slots)
        meta:set_int("visible_slots", 0)
        meta:set_int("slots_set", 8)
    end,
    groups = { matter = 1, not_in_creative_inventory = 1 },
    action = function(pos, node, meta, supply, demand)
        -- time to nuke supply :D
        if supply <= demand then return 0 end

        local slots = 0
        local max_slots_allowed = math.floor((supply - demand) * slots_per_1_power)
        local slots_set = math.floor(meta:get_int("slots_set"))
        if max_slots_allowed < slots_set then
            slots = max_slots_allowed
        else
            slots = slots_set
        end
        local power_consumed = slots / slots_per_1_power

        meta:set_int("visible_slots", slots)
        meta:set_string("infotext", string.format("Infinite storinator, slots: %s, consuming: %s", slots, power_consumed))

        local max_width = 8

        local list_inv_w = max_width
        local list_inv_h = math.floor(slots / max_width)



        meta:set_string("formspec", string.format([[
            formspec_version[7]
            size[10.6,15.2]
            %s
            style_type[list;noclip=false;size=1,1;spacing=0.25,0.25]
            scrollbar[10,0.2;0.4,8.6;vertical;scrollbar;0]
            scroll_container[0.2,0.2;9.8,8.6;scrollbar;vertical;1]
            list[context;inv;0,0;%s,%s]
            scroll_container_end[]
            list[current_player;main;0.2,9;8,4;]
            field[0.2,14.4;3,0.5;set_slots;Amount of rows;%s]
            listring[]
    ]], make_scrollbaroptions_for_scroll_container(7.6, math.max(8, list_inv_h + list_inv_h / 4), 1), list_inv_w,
            list_inv_h,
            slots_set / 8))
        return power_consumed
    end,
    on_receive_fields = function(pos, _, fields)
        local meta = minetest.get_meta(pos)
        if fields.set_slots then
            local n_slots = math.abs(math.floor(tonumber(fields.set_slots) or 8)) * 8
            if n_slots > max_slots then
                n_slots = max_slots
            end
            meta:set_int("slots_set", n_slots)
        end
    end,
    allow_metadata_inventory_move = function(pos, from_list, from_index, to_list, to_index, count, player)
        local meta = M(pos)
        if (from_index <= meta:get_int("visible_slots") and to_index <= meta:get_int("visible_slots")) or (from_list == to_list == "main") then
            return count
        end
        return 0
    end,

    allow_metadata_inventory_put = function(pos, listname, index, stack, player)
        local meta = M(pos)
        if index <= meta:get_int("visible_slots") or listname == "main" then
            return stack:get_count()
        end
        return 0
    end,
    allow_metadata_inventory_take = function(pos, listname, index, stack, player)
        local meta = M(pos)
        if index <= meta:get_int("visible_slots") or listname == "main" then return stack:get_count() end
        return 0
    end,
    output_inv = "inv",
    input_inv = "inv",


    control_action_raw = true,
    disallow_pipeworks = false,
})

--[[
minetest.register_craft({
    output = "sbz_power:infinite_storinator",
    recipe = {
        { "sbz_resources:storinator", "sbz_resources:emittrium_circuit", "sbz_resources:storinator" },
        { "sbz_resources:storinator", "sbz_meteorites:neutronium",       "sbz_resources:storinator" },
        { "sbz_resources:storinator", "sbz_resources:emittrium_circuit", "sbz_resources:storinator" }
    }
})
--]]
