--[=[
This file is part of player_monoids mod.

Original mod.
Copyright (C) 2015-2024 Original player_monoids Mod Contributors.

Modifications for Skyblock: Zero.
Copyright (C) 2024-2025 Skyblock: Zero areas Mod Contributors

Please see COPYRIGHT.md for names of authors and contributors.

Licensed under the Apache License, Version 2.0 (the "License");
you may not use this file except in compliance with the License.
You may obtain a copy of the License at

   http://www.apache.org/licenses/LICENSE-2.0

Unless required by applicable law or agreed to in writing, software
distributed under the License is distributed on an "AS IS" BASIS,
WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
See the License for the specific language governing permissions and
limitations under the License.
]=]

-- Any documentation here are internal details, please avoid using them in your
-- mod.

local modpath = minetest.get_modpath(minetest.get_current_modname()) .. '/'

player_monoids = {}

local mon_meta = {}

mon_meta.__index = mon_meta

local nop = function() end

-- A monoid object is a table with the following fields:
--   def: The monoid definition
--   player_map: A map from player names to their effect tables. Effect tables
--     are maps from effect IDs to values.
--   value_cache: A map from player names to the cached value for the monoid.
--   next_id: The next unique ID to assign an effect.

local function monoid(def)
    local mon = {}

    local actual_def = {}

    for k, v in pairs(def) do
        actual_def[k] = v
    end

    if not actual_def.apply then actual_def.apply = nop end

    if not actual_def.on_change then actual_def.on_change = nop end

    mon.def = actual_def

    local p_map = {}
    mon.player_map = p_map

    mon.next_id = 1

    local v_cache = {}
    mon.value_cache = v_cache

    setmetatable(mon, mon_meta)

    minetest.register_on_leaveplayer(function(player)
        local p_name = player:get_player_name()
        p_map[p_name] = nil
        v_cache[p_name] = nil
    end)

    return mon
end

player_monoids.make_monoid = monoid

function mon_meta:add_change(player, value, id)
    local p_name = player:get_player_name()

    local def = self.def

    local p_effects = self.player_map[p_name]
    if p_effects == nil then
        p_effects = {}
        self.player_map[p_name] = p_effects
    end

    local actual_id

    if id then
        actual_id = id
    else
        actual_id = self.next_id
        self.next_id = actual_id + 1
    end

    local old_total = self.value_cache[p_name]
    p_effects[actual_id] = value
    local new_total = def.fold(p_effects)
    self.value_cache[p_name] = new_total

    def.apply(new_total, player)
    def.on_change(old_total, new_total, player)

    return actual_id
end

function mon_meta:del_change(player, id)
    local p_name = player:get_player_name()

    local def = self.def

    local p_effects = self.player_map[p_name]
    if p_effects == nil then return end

    local old_total = self.value_cache[p_name]
    p_effects[id] = nil
    local new_total = def.fold(p_effects)
    self.value_cache[p_name] = new_total

    def.apply(new_total, player)
    def.on_change(old_total, new_total, player)
end

function mon_meta:value(player)
    local p_name = player:get_player_name()
    return self.value_cache[p_name] or self.def.identity
end

dofile(modpath .. 'standard_monoids.lua')
dofile(modpath .. 'test.lua')
