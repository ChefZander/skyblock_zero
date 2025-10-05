core.register_entity('stubes:item_visual', {
    initial_properties = {
        physical = false,
        textures = { '' },
        static_save = false,

        pointable = false,
        visual = 'wielditem',
        visual_size = { x = stube.tube_size - 0.001, y = stube.tube_size - 0.001 }, -- prevent z-fighting
        glow = 1,
    },
    on_activate = function(self, staticdata)
        local stack = ItemStack(staticdata)
        self.object:set_properties {
            textures = { stack:get_name() },
        }
    end,
})

local function create_visual(pos, stack)
    return core.add_entity(pos, 'stubes:item_visual', stack:to_string())
end

---@param pos vector
---@param tubestate stube.TubeState
function stube.add_visuals_to_tubestate(pos, tubestate)
    for dir, connection in pairs(tubestate.connections) do
        local vdir = core.wallmounted_to_dir(dir)
        if dir == 6 then vdir = vector.zero() end
        if not connection.entity then connection.entity = create_visual(vector.add(pos, vdir / 3), connection.stack) end
    end
end

---@param tubestate stube.TubeState
function stube.remove_visuals_from_tubestate(tubestate)
    for _, connection in pairs(tubestate.connections) do
        if connection.entity then
            connection.entity:remove()
            connection.entity = nil
        end
    end
end

local function get_player_positions()
    local ret = {}
    for _, player in pairs(core.get_connected_players()) do
        ret[#ret + 1] = player:get_pos()
    end
    return ret
end

--- Adds/removes tubestate visuals depending on if they are actually needed
--- Time complexity: O(amount_of_tubes*amount_of_players) i think, not great
---@param tubestate stube.TubeState
---@param pos vector
---@param player_positions vector[]?
function stube.add_or_remove_tubestate_visuals(pos, tubestate, player_positions)
    if stube.enable_entities == false then return stube.remove_visuals_from_tubestate(tubestate) end

    if not player_positions then player_positions = get_player_positions() end
    local should_add = false
    for i = 1, #player_positions do
        local player_position = player_positions[i]
        if vector.distance(pos, player_position) <= stube.entity_radius then
            should_add = true
            break
        end
    end

    if should_add then
        stube.add_visuals_to_tubestate(pos, tubestate)
    else
        stube.remove_visuals_from_tubestate(tubestate)
    end
end

local timer = 0
local timer_max = stube.entity_creation_globalstep_time
-- stube.update updates visuals, this is responsible for adding/deleting them
function stube.visual_globalstep(dtime)
    timer = timer + dtime
    if timer < timer_max then return end
    timer = 0

    local player_positions = get_player_positions()

    for tube_type, tubes_array in pairs(stube.all_stubes) do
        for hpos, tube_state in pairs(tubes_array) do
            stube.add_or_remove_tubestate_visuals(core.get_position_from_hash(hpos), tube_state, get_player_positions())
        end
    end
end

core.register_globalstep(stube.visual_globalstep)
