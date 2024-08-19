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

local slots_per_1_power = 7

sbz_api.register_machine("sbz_resources:infinite_storinator", {
    description = "Infinite storinator",
    on_construct = function(pos)
        local meta = minetest.get_meta(pos)
        local inv = meta:get_inventory()
        inv:set_size("inv", max_slots)
        meta:set_int("visible_slots", 0)
        meta:set_int("slots_set", 1)
    end,
    groups = { matter = 1 },
    action = function(pos, node, meta, supply, demand)
        -- time to nuke supply :D
        if supply <= demand then return 0 end

        local slots = 0
        local max_slots_allowed = (supply - demand) * slots_per_1_power
        local slots_set = meta:get_int("slots_set")
        if max_slots_allowed < slots_set then
            slots = max_slots_allowed
        else
            slots = slots_set
        end
        local power_consumed = slots / slots_per_1_power

        meta:set_int("visible_slots", slots)

        meta:set_string("infotext", string.format("Infinite storinator, slots: %s, consuming: %s", slots, power_consumed))

        local max_height = 7

        local list_inv_w = slots / max_height
        local list_inv_h = max_height

        if list_inv_w < 1 then
            list_inv_w = slots
            list_inv_h = 1
        end

        meta:set_string("formspec", string.format([[
            formspec_version[7]
            size[20,14.2]
            %s
            scrollbar[0.2,9.2;19.6,0.6;horizontal;scrollbar;0]
            scroll_container[0.2,0.2;19.6,9;scrollbar;horizontal;1]
            list[context;inv;0.2,0.2;%s,%s]
            scroll_container_end[]
            list[current_player;main;0.2,10;19,2;]
            field[0.2,13.1;3,0.5;set_slots;Amount of rows (needs power);%s]
            listring[]
    ]], make_scrollbaroptions_for_scroll_container(19.6, math.max(20, list_inv_w), 1), list_inv_w, list_inv_h,
            slots_set / 7))
        return power_consumed
    end,
    on_receive_fields = function(pos, _, fields)
        local meta = minetest.get_meta(pos)
        if fields.set_slots then
            meta:set_int("slots_set", tonumber(math.abs(math.floor(fields.set_slots))) * 7 or 7)
        end
        local slots = meta:get_int("visible_slots")
        local slots_set = meta:get_int("slots_set")
        local max_height = 7

        local list_inv_w = slots / max_height
        local list_inv_h = max_height

        if list_inv_w < 1 then
            list_inv_w = slots
            list_inv_h = 1
        end

        meta:set_string("formspec", string.format([[
            formspec_version[7]
            size[20,14.2]
            %s
            scrollbar[0.2,9.2;19.6,0.6;horizontal;scrollbar;0]
            scroll_container[0.2,0.2;19.6,9;scrollbar;horizontal;1]
            list[context;inv;0.2,0.2;%s,%s]
            scroll_container_end[]
            list[current_player;main;0.2,10;19,2;]
            field[0.2,13.1;3,0.5;set_slots;Amount of rows (needs power);%s]
            listring[]
    ]], make_scrollbaroptions_for_scroll_container(19.6, math.max(20, list_inv_w), 1), list_inv_w, list_inv_h,
            slots_set / 7))
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

    control_action_raw = true,
})
