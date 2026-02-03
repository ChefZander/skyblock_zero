--[[
    sbz_area_containers - Implements "area containers" for Skyblock: Zero
    Copyright (C) 2026 frogTheSecond

    This program is free software: you can redistribute it and/or modify
    it under the terms of the GNU General Public License as published by
    the Free Software Foundation, either version 3 of the License, or
    (at your option) any later version.

    This program is distributed in the hope that it will be useful,
    but WITHOUT ANY WARRANTY; without even the implied warranty of
    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
    GNU General Public License for more details.

    You should have received a copy of the GNU General Public License
    along with this program.  If not, see <https://www.gnu.org/licenses/>.
]]

local mapgen_limit = assert(tonumber(core.settings:get 'mapgen_limit') - 200) -- -200 because its LYING, the number is a LIE, that is NOT the MAPGEN LIMIT, that number IS A FAKE (the mapgen limit is actually a tiny bit smaller)
local sbz_safetynet = -20000 -- i think this can fit enough areas

local room_size = vector.new(16, 16, 16)
local room_exit_pos = vector.new(2, 2, 0) -- relative to 0,0,0 of the room position, if that makes sense
local room_spawn_pos = vector.new(2, 1, 1)

local max_areas_per_player = 100

--- for some reason vector.divide is not this?
local function divide_vector(v1, v2)
    v1 = vector.copy(v1)
    v1.x = v1.x / v2.x
    v1.y = v1.y / v2.y
    v1.z = v1.z / v2.z
    return v1
end
local function multiply_vector(v1, v2)
    v1 = vector.copy(v1)
    v1.x = v1.x * v2.x
    v1.y = v1.y * v2.y
    v1.z = v1.z * v2.z
    return v1
end

-- Area reserved for the rooms
local room_world_area = {
    min = vector.new(-mapgen_limit, -mapgen_limit, -mapgen_limit),
    max = vector.new(mapgen_limit, sbz_safetynet, mapgen_limit),
}
room_world_area.min = multiply_vector(vector.floor(divide_vector(room_world_area.min, room_size)), room_size)
room_world_area.max = multiply_vector(vector.floor(divide_vector(room_world_area.max, room_size)), room_size)

-- To save and load:
local room_areastore = AreaStore()
local player_container_ids = {}
local room_container_links = {}

-- saving may be unreliable and is relying on experimental luanti stuff (areastore:to_file), have backups!

local WP = core.get_worldpath()
local save_path = WP .. '/sbz_area_containers_'

local function save()
    room_areastore:to_file(save_path .. 'areastore') -- i am not using core.serialize on areastore:to_string because that will uhh, that may 2x the file size probably and take too long
    local data = { player_container_ids = player_container_ids, room_container_links = room_container_links }
    local serialized = core.serialize(data)
    if not core.safe_file_write(save_path .. 'data', serialized) then
        core.log('error', 'Failed to save sbz_area_containers rooms!')
    end
end

local function load()
    pcall(function() -- pcall because if it loads for the first time it will fail, and that's expected
        room_areastore:from_file(save_path .. 'areastore')
        local data_file = assert(io.open(save_path .. 'data'))
        local data = core.deserialize(data_file:read '*a')
        data_file:close()

        if data then
            player_container_ids = data.player_container_ids
            room_container_links = data.room_container_links
        end
    end)
end

load()

core.register_on_shutdown(save)

---@diagnostic disable-next-line: lowercase-global
sbz_area_containers = {}
sbz_area_containers.areasstore = room_areastore
sbz_area_containers.player_container_ids = player_container_ids

local old_activate_safetynet = sbz_api.activate_safetynet
function sbz_api.activate_safetynet(player_name, pos)
    if old_activate_safetynet(player_name, pos) == false then return false end
    local rooms = room_areastore:get_areas_for_pos(pos, false, false)
    if next(rooms) then return false end
    return true
end

local function get_new_room_pos()
    local pos

    for _ = 1, 10 do
        pos = multiply_vector(
            vector.random_in_area(
                divide_vector(room_world_area.min, room_size),
                divide_vector(room_world_area.max, room_size)
            ),
            room_size
        )
        ---@diagnostic disable-next-line: param-type-mismatch
        if not (next(room_areastore:get_areas_for_pos(pos, false, false)) or core.is_protected(pos, '')) then break end
    end
    if not pos then return false end
    return pos
end

local function is_connected_id(id)
    local link = room_container_links[id]
    if link == nil then return false end
    local pos = core.get_position_from_hash(link)
    if pos == nil then return false end
    if sbz_api.get_or_load_node(pos).name ~= 'sbz_area_containers:room_container' then return false end
    local meta = core.get_meta(pos)
    if meta:get_int 'id' ~= id then return false end
    return true
end

function sbz_area_containers.new_room(player_name)
    local container_ids = player_container_ids[player_name] or {}
    if #container_ids >= max_areas_per_player then
        core.chat_send_player(player_name, ('You may only have %s areas'):format(max_areas_per_player))
        return false
    end

    -- attempt recycling
    for i = 1, #container_ids do
        local id = container_ids[i]
        if not is_connected_id(id) then return id end -- recycled! (the user will be surprised if we don't document this xD)
    end

    local pos = get_new_room_pos()
    if not pos then return false end
    local maxpos = vector.subtract(vector.add(pos, room_size), 1)
    local id = room_areastore:insert_area(pos, maxpos, '')
    player_container_ids[player_name] = container_ids
    container_ids[#container_ids + 1] = id

    core.load_area(pos, maxpos)
    for z = pos.z, maxpos.z do
        for y = pos.y, maxpos.y do
            for x = pos.x, maxpos.x do
                if x == pos.x or x == maxpos.x or y == pos.y or y == maxpos.y or z == pos.z or z == maxpos.z then
                    core.set_node(vector.new(x, y, z), { name = 'sbz_area_containers:wall' })
                end
            end
        end
    end
    core.set_node(vector.add(pos, room_exit_pos), { name = 'sbz_area_containers:room_exit' })

    return id
end

function sbz_area_containers.teleport_to_room(player, id)
    local room = room_areastore:get_area(id, true, false)
    if not room then return end

    local relative_spawn_pos, i, success = room_spawn_pos, 0, false
    local room_min_pos = room.min

    repeat
        local pos = vector.add(room_min_pos, relative_spawn_pos)
        if sbz_api.is_air(pos) then
            success = true
            break
        end
        relative_spawn_pos = vector.random_in_area(vector.zero(), room_size)
        i = i + 1
    until i > 100
    if not success then relative_spawn_pos = room_min_pos end -- well we tried

    player:set_pos(vector.add(room_min_pos, relative_spawn_pos))
end

core.register_node(
    'sbz_area_containers:wall',
    unifieddyes.def {
        diggable = false,
        paramtype = 'light',
        paramtype2 = 'color',
        light_source = 8,
        groups = { not_in_creative_inventory = 1 },
        tiles = { 'room_container_wall.png' },
    }
)
core.register_node(
    'sbz_area_containers:room_exit',
    unifieddyes.def {
        tiles = { 'room_container_exit.png' },
        paramtype = 'light',
        light_source = 14,
        diggable = false,
        groups = { not_in_creative_inventory = 1 },

        on_rightclick = function(pos, _, clicker)
            local ids = room_areastore:get_areas_for_pos(pos, true, false)
            if not next(ids) then return end
            local id = next(ids) -- if there are multiple ids the code has a problem, i won't concern myself with such things hovewer

            local pos = core.get_position_from_hash(room_container_links[id])
            if not pos then return end
            clicker:set_pos(vector.add(pos, vector.new(0, 1, 0)))
        end,
    }
)

core.register_node('sbz_area_containers:room_container', {
    description = 'Room Container',
    tiles = { 'room_container.png' },
    paramtype = 'light',
    light_source = 14,
    groups = { matter = 1 },
    after_place_node = function(pos, placer)
        local meta = core.get_meta(pos)
        local id = sbz_area_containers.new_room(placer:get_player_name())
        if id ~= false then
            meta:set_int('linked', 1)
            -- meta:set_string('infotext', 'Linked with room #' .. id) -- not useful
            room_container_links[id] = core.hash_node_position(pos)
            meta:set_int('id', id)
        else
            meta:set_string('infotext', 'Something went wrong when creating the room, so this points to nothing')
        end
    end,
    on_rightclick = function(pos, _, clicker)
        local meta = core.get_meta(pos)
        if meta:get_int 'linked' == 1 then sbz_area_containers.teleport_to_room(clicker, meta:get_int 'id') end
    end,
    on_movenode = function(oldpos, pos)
        local oldhash = core.hash_node_position(oldpos)
        for k, v in pairs(room_container_links) do
            if v == oldhash then
                room_container_links[k] = core.hash_node_position(pos)
                break
            end
        end
    end,
})
