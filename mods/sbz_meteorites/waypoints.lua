-- Borrowed mostly from the sub_nav mod in Subnodeica (I'd already done the work, didn't want to have to do it all again)

local storage = minetest.get_mod_storage()

--Set waypoint for all players at given position, returns id
function sbz_api.set_waypoint(pos, defs)
    local data = minetest.deserialize(storage:get_string("waypoints")) or {}
    local next = storage:get_int("next_waypoint") + 1
    data[next] = { pos, defs }
    storage:set_string("waypoints", minetest.serialize(data))
    storage:set_int("next_waypoint", next)
    return next
end

--Change position of specified waypoint, returns success
function sbz_api.move_waypoint(id, pos)
    local data = minetest.deserialize(storage:get_string("waypoints")) or {}
    if not data[id] then return false end
    data[id] = { pos, data[id][2] }
    storage:set_string("waypoints", minetest.serialize(data))
    return true
end

--Remove waypoint
function sbz_api.remove_waypoint(id)
    local data = minetest.deserialize(storage:get_string("waypoints")) or {}
    data[id] = nil
    storage:set_string("waypoints", minetest.serialize(data))
end

--Iterate over waypoints
function sbz_api.waypoint_pairs()
    local data = minetest.deserialize(storage:get_string("waypoints")) or {}
    local i, entry
    local function iter(d)
        i, entry = next(d, i)
        if entry then return entry[1], entry[2] end
    end
    return iter, data, nil
end

--Update waypoints for a particular player
local player_huds = {}

function sbz_api.update(player)
    local name = player:get_player_name()
    if not player_huds[name] then player_huds[name] = {} end
    for i, id in ipairs(player_huds[name]) do player:hud_remove(id) end
    player_huds[name] = {}
    local player_pos = player:get_pos()
    for pos, defs in sbz_api.waypoint_pairs() do
        if vector.distance(player_pos, pos) >= defs.dist then
            table.insert(player_huds[name], player:hud_add({
                name = defs.name,
                type = "waypoint",
                offset = { x = 0, y = -60 },
                z_index = -300,
                precision = 1,
                text = "m",
                number = 0xcef0ff,
                world_pos = pos
            }))
            table.insert(player_huds[name], player:hud_add({
                type = "image_waypoint",
                scale = { x = 6, y = 6 },
                z_index = -300,
                text = defs.image,
                world_pos = pos
            }))
        end
    end
end

minetest.register_on_joinplayer(sbz_api.update)

--Update waypoints for all players
function sbz_api.update_all()
    for i, player in ipairs(minetest.get_connected_players()) do
        sbz_api.update(player)
    end
end

minetest.register_globalstep(sbz_api.update_all)
