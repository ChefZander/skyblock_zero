-- Borrowed mostly from the sub_nav mod in Subnodeica (I'd already done the work, didn't want to have to do it all again)
-- Frog here - i've rewritten it because it was laggy

local waypoint_data = {}

--Set waypoint for all players at given position, returns id
function sbz_api.set_waypoint(pos, defs)
    waypoint_data[#waypoint_data + 1] = { pos, defs }
    return #waypoint_data
end

--Change position of specified waypoint, returns success
function sbz_api.move_waypoint(id, pos)
    if not waypoint_data[id] then return false end
    waypoint_data[id] = { pos, waypoint_data[id][2] }
    return true
end

--Remove waypoint
function sbz_api.remove_waypoint(id)
    waypoint_data[id] = nil
end

--Update waypoints for a particular player
local player_huds = {}

function sbz_api.waypoint_update(player)
    local name = player:get_player_name()
    if not player_huds[name] then player_huds[name] = {} end
    local old_huds = player_huds[name]
    player_huds[name] = {}
    local player_pos = player:get_pos()

    for k, v in ipairs(waypoint_data) do
        local pos, defs = unpack(v)
        local dist = vector.distance(player_pos, pos)
        if dist >= (defs.dist or 0) and dist <= (defs.max_dist or 1000) then
            table.insert(player_huds[name], player:hud_add({
                name = defs.name,
                type = "waypoint",
                offset = { x = 0, y = -60 },
                z_index = -300,
                precision = defs.precision or 1,
                text = "m",
                number = 0xcef0ff,
                world_pos = pos
            }))
            if defs.image then
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
    for i, id in ipairs(old_huds) do player:hud_remove(id) end
end

minetest.register_on_joinplayer(sbz_api.waypoint_update)

--Update waypoints for all players
function sbz_api.waypoint_update_all()
    for i, player in ipairs(minetest.get_connected_players()) do
        sbz_api.waypoint_update(player)
    end
end

minetest.register_globalstep(sbz_api.waypoint_update_all)
