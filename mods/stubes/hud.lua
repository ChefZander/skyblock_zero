-- Display how many items are inside a tube with a HUD
-- ... wow HUDs are dogsh#t

--- { [player name] = id[] }
---@type table<string, number[]>
local ids = {}

local timer = 0
local timer_max = 0.25

function stube.hud_update(player)
    local player_name = player:get_player_name()
    local tube_pos, tube_node

    local look_dir = player:get_look_dir()
    local eye_pos = player:get_pos()
    eye_pos.y = eye_pos.y + (player:get_properties().eye_height or 0)

    local ray = core.raycast(eye_pos, vector.add(eye_pos, vector.multiply(look_dir, 5)), false, false)
    for pointed_thing in ray do
        if pointed_thing.type == 'node' then
            local node = core.get_node(pointed_thing.under)
            if core.get_item_group(node.name, 'stube') == 1 then
                tube_pos, tube_node = pointed_thing.under, node
                break
            end
        end
    end

    if ids[player_name] then
        for _, id in pairs(ids[player_name]) do
            player:hud_remove(id)
        end
        ids[player_name] = nil
    end

    if not tube_pos then return end
    local tube_state = stube.all_stubes[stube.get_prefix_tube_name(tube_node.name)][core.hash_node_position(tube_pos)]
    if not tube_state then return end

    ids[player_name] = {}
    for dir, connection in pairs(tube_state.connections) do
        table.insert(
            ids[player_name],
            player:hud_add {
                type = 'waypoint',
                precision = 0,
                name = tostring(connection.stack:get_count()),
                number = (connection.stack:get_count() / connection.stack:get_stack_max()) * 0xFFFFFF, -- i love the not at all confusing HUD api
                world_pos = stube.get_precise_connection_pos(tube_pos, dir),
            }
        )
    end
end

---@param dtime number
function stube.hud_globalstep(dtime)
    timer = timer + dtime
    if timer < timer_max then return end
    timer = 0

    for _, player in pairs(core.get_connected_players()) do
        stube.hud_update(player)
    end
end

core.register_globalstep(stube.hud_globalstep)
