--- Game design: There should be a reason to not use the fastest tube all the time
--- So i am going to passionately give you that reason: Some routing blocks are too slow for them
---
--- Oh btw, the routing blocks will have the speed of a fast tube, because if you want to replace slow tubes with just routing blocks, sure go ahead! that's a creative solution to a fun problem!
--- Also, under no situation should routing blocks put things into the air, that's not cool
--- FIXME: Routing nodes should also be tubedevice receivers
--- FIXME: Peacefully remove routing state when dug
--- FIXME: Routing state update loop

local speed = 1 / 3
local IG = core.get_item_group

--- JUNCTIONS

---@class stube.JunctionItem: stube.TubedItem
---@field dir integer Where the item wants to go, interesting behavior happens if you mess with this
---@field just_moved_to_center? boolean

---@class stube.JunctionState: stube.RoutingState
---@field items { [integer]: stube.JunctionItem[]? }

local function move_entity(ent, pos, dir)
    ent:move_to(stube.get_precise_connection_pos(pos, dir), true)
end

--- Okay, so i think the junction code is a little bit confusing, so let me clear up the confusion a little bit
--- Each item in a junction wants to go somewhere (junctionitem.dir)
--- so first it goes to the center
--- then it goes where it wants to go
--- then it gets out
---
--- center can hold 6 items (one for each direction), non-center can hold only 2 items, but theoretically more (one going to the side, one going away, theoretically if this junction code is re-used, you can have wild shenanigans)
--- as you can see, there is a lot of code to enforce that too
---
--- This is a lot simpler than tube routing :D

-- try to output to a node or something
local function junction_try_output(state, out_pos, out_node, side, items)
    local index, item

    for i, test_item in pairs(items) do
        if test_item.dir == side then
            index = i
            item = test_item
            break
        end
    end

    if not item then return end
    if stube.insert_tubed_item(item, out_node, out_pos, side) then
        item.dir = nil
        table.remove(items, index)
    end
    if items[1] == nil and items[2] == nil then state[side] = nil end
end

local function junction_move_to_center(state, side, items, pos)
    for i, item in pairs(items) do
        if item.dir ~= side then -- move to center
            local can_move = true
            for _, potential_duplicate in pairs(state.items[6] or {}) do
                if potential_duplicate.dir == item.dir then can_move = false end
            end
            if can_move then
                state.items[6] = state.items[6] or {}
                state.items[6][#state.items[6] + 1] = item
                if item.entity then move_entity(item.entity, pos, 6) end

                table.remove(items, i)
            end
        end
    end
end

local function junction_move_away_from_center(state, item_index, item, pos)
    local items_at_target = state.items[item.dir]
    if items_at_target == nil then
        state.items[item.dir] = {}
        items_at_target = state.items[item.dir]
    end

    if #items_at_target > 2 then return end
    for _, other_item in pairs(items_at_target) do
        if other_item.dir == item.dir then return end
    end

    items_at_target[#items_at_target + 1] = item

    if item.entity then move_entity(item.entity, pos, item.dir) end
    table.remove(state.items[6], item_index)
end

-- can hold 6*2 + 6 items... that's a lot compared to just 7 items, kinda like a mini chest
-- though i wouldn't use it for that xD

local junction_size = 0.5 - 0.0001
stube.register_routing_node('stubes:junction', {
    description = 'Tube Junction',
    groups = { stube_routing_node = 1 },

    -- visuals:
    tiles = { { name = 'stube_junction.png', backface_culling = false } },
    use_texture_alpha = 'clip',
    drawtype = 'nodebox',
    sunlight_propagates = true,
    node_box = {
        type = 'fixed',
        fixed = { -junction_size, -junction_size, -junction_size, junction_size, junction_size, junction_size }, -- avoid z fighting
    },
    paramtype2 = 'color',
    paramtype = 'light',
}, {
    speed = speed,
    accept = function(state, tubed_item, dir, pos)
        state = state ---@type stube.JunctionState

        local accept_dir = stube.opposite_wallmounted(dir)

        local accept_side = state.items[accept_dir]
        if not accept_side then
            state.items[accept_dir] = {}
            accept_side = state.items[accept_dir] --- @type stube.JunctionItem[]
        end

        if #accept_side == 2 then return false end
        for _, item in pairs(accept_side) do
            if item.dir == dir then return false end -- If its going the same direction
        end

        -- okay excellent, so we can just accept
        tubed_item = tubed_item ---@type stube.JunctionItem
        tubed_item.dir = dir
        table.insert(accept_side, tubed_item)
        if tubed_item.entity then move_entity(tubed_item.entity, pos, accept_dir) end
        return true
    end,
    iterate_items = function(state, f)
        for side, items in pairs(state.items) do
            for _, item in pairs(items) do
                f(item, side)
            end
        end
    end,
    update = function(state, hpos)
        local pos = core.get_position_from_hash(hpos)
        -- output
        for side, items in pairs(state.items) do
            if side ~= 6 then
                local out_pos = vector.add(stube.tube_state_connection_to_dir(side), pos)
                local out_node = stube.get_or_load_node(out_pos)
                junction_try_output(state, out_pos, out_node, side, items)
            end
        end

        -- internal transport

        -- move everything possible away from the center
        local center_items = state.items[6]
        if center_items then
            for i, item in pairs(center_items) do
                junction_move_away_from_center(state, i, item, pos)
            end
        end

        -- move everything possible to the center
        for side, items in pairs(state.items) do
            if side ~= 6 and (state.items[6] == nil or #state.items[6] < 6) then -- center is a true special case
                junction_move_to_center(state, side, items, pos)
            end
        end
    end,
})
