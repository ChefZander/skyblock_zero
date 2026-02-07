--[[
    This file contains code from https://github.com/minetest-mods/technic/blob/3bece9cec5807a73dc764bdf43ad0d1d3441904e/technic/radiation.lua#L202
    The code has been modified.
    License:
            Minetest Mod: technic
        Copyright (C) 2012-2022  RealBadAngel and contributors

        This library is free software; you can redistribute it and/or
        modify it under the terms of the GNU Lesser General Public
        License as published by the Free Software Foundation; either
        version 2.1 of the License, or (at your option) any later version.

        This library is distributed in the hope that it will be useful,
        but WITHOUT ANY WARRANTY; without even the implied warranty of
        MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU
        Lesser General Public License for more details.

        You should have received a copy of the GNU Lesser General Public
        License along with this library; if not, write to the Free Software
        Foundation, Inc., 51 Franklin Street, Fifth Floor, Boston, MA  02110-1301  USA
]]

--[[
#DOCS
implements functions to groups: radioactive, weak_radioactive
weak_radioactive is 100 times weaker than the radioactive group
the radiation group's strength is the same as technic's radiation strength
]]

--[[
Radioactivity

Radiation resistance represents the extent to which a material
attenuates radiation passing through it; i.e., how good a radiation
shield it is.  This is identified per node type.  For materials that
exist in real life, the radiation resistance value that this system
uses for a node type consisting of a solid cube of that material is the
(approximate) number of halvings of ionising radiation that is achieved
by a meter of the material in real life.  This is approximately
proportional to density, which provides a good way to estimate it.
Homogeneous mixtures of materials have radiation resistance computed
by a simple weighted mean.  Note that the amount of attenuation that
a material achieves in-game is not required to be (and is not) the
same as the attenuation achieved in real life.

Radiation resistance for a node type may be specified in the node
definition, under the key "radiation_resistance".  As an interim
measure, until node definitions widely include this, this code
knows a bunch of values for particular node types in several mods,
and values for groups of node types.  The node definition takes
precedence if it specifies a value.  Nodes for which no value at
all is known are taken to provide no radiation resistance at all;
this is appropriate for the majority of node types.  Only node types
consisting of a fairly homogeneous mass of material should report
non-zero radiation resistance; anything with non-uniform geometry
or complex internal structure should show no radiation resistance.
Fractional resistance values are permitted.
--]]

local rad_resistance_node = {}
local rad_resistance_group = {
    matter = 512,
    antimatter = 512,
    charged_field = 1024,
}

local cache_radiation_resistance = {}

local function node_radiation_resistance(node_name)
    local resistance = cache_radiation_resistance[node_name]
    if resistance then return resistance end
    local def = minetest.registered_nodes[node_name]
    if not def then
        cache_radiation_resistance[node_name] = 0
        return 0
    end
    resistance = def.radiation_resistance or rad_resistance_node[node_name]
    if resistance == nil and def.groups ~= nil then resistance = def.groups.radiation_resistance end
    if not resistance then
        resistance = 0
        for g, v in pairs(def.groups) do
            if v > 0 and rad_resistance_group[g] then resistance = resistance + rad_resistance_group[g] end
        end
    end
    resistance = math.sqrt(resistance)
    cache_radiation_resistance[node_name] = resistance
    return resistance
end

--[[
Radioactive nodes cause damage to nearby players.  The damage
effect depends on the intrinsic strength of the radiation source,
the distance between the source and the player, and the shielding
effect of the intervening material.  These determine a rate of damage;
total damage caused is the integral of this over time.

In the absence of effective shielding, for a specific source the
damage rate varies realistically in inverse proportion to the square
of the distance.  (Distance is measured to the player's abdomen,
not to the nominal player position which corresponds to the foot.)
However, if the player is inside a non-walkable (liquid or gaseous)
radioactive node, the nominal distance could go to zero, yielding
infinite damage.  In that case, the player's body is displacing the
radioactive material, so the effective distance should remain non-zero.
We therefore apply a lower distance bound of sqrt(0.75), which is
the maximum distance one can get from the node center within the node.

A radioactive node is identified by being in the "radioactive" group,
and the group value signifies the strength of the radiation source.
The group value is the distance from a node at which an unshielded
player will be damaged by 1 HP/s.  Or, equivalently, it is the square
root of the damage rate in HP/s that an unshielded player one node
away will take.

Shielding is assessed by adding the shielding values of all nodes
between the source node and the player, ignoring the source node itself.
As in reality, shielding causes exponential attenuation of radiation.
However, the effect is scaled down relative to real life.  A node with
radiation resistance value R yields attenuation of sqrt(R) * 0.1 nepers.
(In real life it would be about R * 0.69 nepers, by the definition
of the radiation resistance values.)  The sqrt part of this formula
scales down the differences between shielding types, reflecting the
game's simplification of making expensive materials such as gold
readily available in cubes.  The multiplicative factor in the
formula scales down the difference between shielded and unshielded
safe distances, avoiding the latter becoming impractically large.

Damage is processed at rates down to 0.2 HP/s, which in the absence of
shielding is attained at the distance specified by the "radioactive"
group value.  Computed damage rates below 0.2 HP/s result in no
damage at all to the player.  This gives the player an opportunity
to be safe, and limits the range at which source/player interactions
need to be considered.
--]]
local abdomen_offset = 1
local rad_dmg_cutoff = 0.2

local function apply_fractional_damage(o, dmg)
    local dmg_int = math.floor(dmg)
    -- The closer you are to getting one more damage point,
    -- the more likely it will be added.
    if math.random() < dmg - dmg_int then dmg_int = dmg_int + 1 end
    if dmg_int > 0 then
        local new_hp = math.max(o:get_hp() - dmg_int, 0)
        o:set_hp(new_hp)
        return new_hp == 0
    end
    return false
end

local function calculate_base_damage(node_pos, object_pos, strength)
    local shielding = 0
    local dist = vector.distance(node_pos, object_pos)

    for ray_pos in Raycast(node_pos, vector.multiply(vector.direction(node_pos, object_pos), dist), false, false) do
        ray_pos = ray_pos.under
        local shield_name = minetest.get_node(ray_pos).name
        shielding = shielding + node_radiation_resistance(shield_name) * 0.025
    end

    local dmg = (strength * strength) / (math.max(0.75, dist * dist) * math.exp(shielding))

    if dmg < rad_dmg_cutoff then return end
    return dmg
end

local function calculate_damage_multiplier(object)
    local ag = object.get_armor_groups and object:get_armor_groups()
    if not ag then return 0 end
    if ag.immortal then return 0 end
    if ag.light then return 0.01 * ag.light end
    return 0
end

local function calculate_object_center(object)
    if object:is_player() then return { x = 0, y = abdomen_offset, z = 0 } end
    return { x = 0, y = 0, z = 0 }
end

local function dmg_object(pos, object, strength)
    local obj_pos = vector.add(object:get_pos(), calculate_object_center(object))
    local mul
    -- we need to check may the object be damaged even if armor is disabled
    mul = calculate_damage_multiplier(object)
    if mul == 0 then return end

    local dmg = calculate_base_damage(pos, obj_pos, strength)
    if not dmg then return end
    dmg = dmg * mul
    apply_fractional_damage(object, dmg)
end

local rad_dmg_mult_sqrt = math.sqrt(1 / rad_dmg_cutoff)
local function dmg_abm(pos, node)
    local strength = minetest.get_item_group(node.name, 'radioactive')
        + (minetest.get_item_group(node.name, 'weak_radioactive') / 100)
    local max_dist = math.min(strength * rad_dmg_mult_sqrt, 10)
    for _, o in pairs(minetest.get_objects_inside_radius(pos, max_dist + abdomen_offset)) do
        if (o:is_player()) and o:get_hp() > 0 then dmg_object(pos, o, strength) end
    end
end

if minetest.settings:get_bool('enable_damage') then
    minetest.register_abm({
        label = 'Radiation damage',
        nodenames = { 'group:radioactive' },
        interval = 1,
        chance = 1,
        action = dmg_abm,
    })
    minetest.register_abm({
        label = 'Radiation damage (Weak, mostly radon)',
        nodenames = { 'group:weak_radioactive' },
        interval = 1,
        chance = 3,
        action = dmg_abm,
    })
end

-- RADON!!!
core.register_node('sbz_chem:radon', {
    description = 'radon',
    drawtype = 'glasslike',
    paramtype = 'light',
    drop = '',
    tiles = { 'radon.png' },
    light_source = 10,
    use_texture_alpha = 'blend',
    diggable = false,
    groups = {
        not_in_creative_inventory = 1,
        habitat_conducts = 1,
        explody = 10000, --[[weak_radioactive = 50,--]]
    }, -- not radioactive so that maybe its more performant?
    sunlight_propagates = true,
    post_effect_color = '#6abe3032',
    walkable = false,
    buildable_to = true,
    pointable = false,
    is_ground_content = true,
    air = true,
    air_equivalent = true, -- deprecated
    floodable = true,
})

-- 20% chance of going away each move if not surrounded by radioactivity
core.register_abm({
    label = 'Radon gas move',
    nodenames = { 'sbz_chem:radon' },
    neighbors = { 'air', 'group:airlike' },
    interval = 1,
    chance = 1,
    action = function(spos, node)
        local should_go_away_with_chance = true
        local air_nodes = sbz_api.filter_node_neighbors(spos, 1, function(pos)
            local nn = core.get_node(pos).name
            if core.get_item_group(nn, 'radioactive') > 0 or core.get_item_group(nn, 'weak_radioactive') > 0 then
                should_go_away_with_chance = false
            end
            if core.get_item_group(nn, 'airlike') == 1 or nn == 'air' then return pos end
        end, false)
        local num_airnodes = #air_nodes
        if num_airnodes == 0 then return false end
        local swap_pos = air_nodes[math.random(1, num_airnodes)]
        if (not should_go_away_with_chance) or (math.random() <= 0.20) then -- 20%
            core.swap_node(swap_pos, node)
        end
        core.remove_node(spos)
    end,
})

core.register_abm({
    label = 'Radon gas/water spawn (by group:radioactive)',
    nodenames = { 'group:radioactive' },
    interval = 1,
    chance = 1,
    action = function(spos, node)
        local radioactive_group = core.get_item_group(node.name, 'radioactive')
        local num_radon = 0
        if radioactive_group >= 5 then
            num_radon = math.floor(radioactive_group / 5)
        else
            if math.random() >= (radioactive_group / 5) then
                num_radon = 0
            else
                num_radon = 1
            end
        end
        if num_radon == 0 then return end

        local target_nodes = sbz_api.filter_node_neighbors(spos, 1 + math.floor(radioactive_group / 10), function(pos)
            local nn = core.get_node(pos).name
            if core.get_item_group(nn, 'airlike') == 1 or nn == 'air' then return { pos = pos, type = 'air' } end
            if nn == 'sbz_resources:water_source' then return { pos = pos, type = 'water' } end
        end, false)
        if #target_nodes == 0 then return end
        for i = 1, num_radon do
            local data = target_nodes[math.random(1, #target_nodes)]
            local node_to_place
            if data.type == 'air' then
                node_to_place = 'sbz_chem:radon'
            elseif data.type == 'water' then
                node_to_place = 'sbz_chem:radioactive_water'
            end
            core.set_node(data.pos, { name = node_to_place })
        end
    end,
})

local water_color = '#6abe3032'

core.register_node('sbz_chem:radioactive_water', {
    description = 'bad water, unhealthy even',
    drawtype = 'liquid',
    tiles = {
        { name = 'water.png^[multiply:' .. water_color .. '^[opacity:200', backface_culling = false },
        { name = 'water.png^[multiply:' .. water_color .. '^[opacity:200', backface_culling = true },
    },
    use_texture_alpha = 'blend',
    groups = { liquid = 3, habitat_conducts = 1, not_in_creative_inventory = 1, weak_radioactive = 80 },
    light_source = 14,
    post_effect_color = water_color,
    paramtype = 'light',
    walkable = false,
    pointable = false,
    buildable_to = true,
    drop = '',
    liquid_viscosity = 1,
    drowning = 6,
})

local positions = {
    { -1, 1, -1 },
    { 0, 1, -1 },
    { -1, 1, 0 },

    { 1, 1, 1 },
    { 0, 1, 1 },
    { 1, 1, 0 },
}

core.register_abm({
    label = 'Radioactive water move',
    nodenames = { 'sbz_chem:radioactive_water' },
    neighbors = { 'air', 'sbz_resources:water_source', 'sbz_chem:radioactive_water' },
    interval = 2,
    chance = 1,
    action = function(spos, node)
        local uppos = vector.new(spos.x, spos.y + 1, spos.z)
        local upnode = core.get_node(uppos)
        if
            upnode.name == 'air'
            or core.get_item_group(upnode.name, 'airlike') > 0
            or upnode.name == 'sbz_bio:algae'
        then
            core.set_node(spos, { name = 'sbz_resources:water_source' })
            core.set_node(uppos, { name = 'sbz_chem:radon' })
            return
        end

        for i = 1, 8 do
            local vec
            if i ~= 1 then
                vec = vector.add(vector.copy(spos), vector.new(unpack(positions[math.random(1, #positions)])))
            else
                vec = vector.add(vector.copy(spos), vector.new(0, 1, 0))
            end

            if core.get_node(vec).name == 'sbz_resources:water_source' then
                core.set_node(spos, { name = 'sbz_resources:water_source' })
                core.after(0, function()
                    core.set_node(vec, node)
                end)
                return
            end
        end
    end,
})
