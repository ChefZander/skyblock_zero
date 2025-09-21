local h, uh = core.hash_node_position, core.get_position_from_hash

--- The state of an active tube, doesn't update if the node does, so things like `dir` should not be there
---@class stube.TubeState
---@field items table<integer, ItemStack> Not an array
---@field entities? table<integer, userdata> Not an array
---@field updated_at integer
---@field to_remove? boolean

---@type table<string, table<number, stube.TubeState>>
local stubes = {} -- A table of all the tubed items, t[tube_name][h(tube_pos)] = TubeState
stube.all_stubes = stubes
stube.current_update_time = 0 -- used in tubed items

local timers = {}
core.register_on_mods_loaded(function()
    for name, def in pairs(stube.registered_tubes) do
        timers[name] = { current = 0, max = def.speed }
        stubes[name] = {}
    end
end)

local IG = core.get_item_group

--- Transfer items to foreign nodes (pipeworks receivers), The owner field in pipeworks isn't tracked
function stube.transfer_items(tube_state, tube_def, transfer_to_node, transfer_to_pos, tube_dir)
    local next_node_def = core.registered_nodes[transfer_to_node.name]
    if next_node_def.tube and next_node_def.tube.insert_object then
        for i = tube_def.capacity, 1, -1 do
            local stack = tube_state.items[i]
            local vel = table.copy(core.wallmounted_to_dir(tube_dir))
            vel.speed = 1
            if stack then
                stack = next_node_def.tube.insert_object(transfer_to_pos, transfer_to_node, stack, vel, '')
                if stack == nil or stack:is_empty() then
                    tube_state.items[i] = nil
                else
                    tube_state.items[i] = stack
                end
            end
        end
    end
end

--- Problem: can't trust table length or table.insert with tables that have holes
--- so this has to be the solution, does not seem to be a good one though
local function insert_item(t, v, c)
    for i = 1, c do
        if t[i] == nil then
            t[i] = v
            return true
        end
    end
    return false
end

local function push_items_to_next_tube(next_node, next_pos, tube_def, tube_state)
    local prefix = stube.get_prefix_tube_name(next_node.name)
    local next_tube_def = stube.registered_tubes[prefix]
    local next_tube_hpos = core.hash_node_position(next_pos)
    local next_tube_state = stubes[prefix][next_tube_hpos]
    local is_empty = next_tube_state == nil -- i love how cheap this is
    local can_insert = is_empty and next_tube_def.capacity or 0

    if next_tube_state then
        -- actually check how much we can insert, not just if its empty
        local items = next_tube_state.items

        for i = 1, next_tube_def.capacity do
            if items[i] == nil then can_insert = can_insert + 1 end
        end
    end

    if is_empty then
        stubes[prefix][next_tube_hpos] = {
            items = {},
            updated_at = stube.current_update_time,
        }
        next_tube_state = stubes[prefix][next_tube_hpos]
    end

    if can_insert > 0 then
        local inserted = 0
        for i = tube_def.capacity, 1, -1 do
            local item = tube_state.items[i]
            if item then
                inserted = inserted + 1
                if inserted > can_insert then break end

                insert_item(next_tube_state.items, item, next_tube_def.capacity)
                tube_state.items[i] = nil
            end
        end
    else
        return false, next_tube_hpos, next_tube_def, stubes[prefix], prefix
    end
end

local function delete_if_empty_state(tube_hpos, tube_def, tube_state, tubes_array)
    local empty = true
    for i = tube_def.capacity, 1, -1 do
        if tube_state.items[i] ~= nil then
            empty = false
            break
        end
    end
    if empty then tube_state.to_remove = true end

    if tube_state.to_remove then tubes_array[tube_hpos] = nil end
end

--- This is a very recursive function
function stube.update_tube(tube_hpos, tube_def, tube_state, prefix)
    if tube_state.updated_at == stube.current_update_time then return end
    tube_state.updated_at = stube.current_update_time
    if
        not tube_def.should_update(
            tube_hpos,
            tube_state,
            sbz_api.get_or_load_node(core.get_position_from_hash(tube_hpos))
        )
    then
        return
    end -- In cases like short tubes you don't want to update the tube, as there is nowhere that items can go, there basically wouldn't be a next node

    local tube_vpos = uh(tube_hpos)

    local this_node = stube.get_or_load_node(tube_vpos)
    if stube.get_prefix_tube_name(this_node.name) ~= prefix then -- innacurate state, as node has changed, get rid of it
        tube_state.to_remove = true
        return
    end
    local tube_dir = stube.get_tube_dir(this_node.name)

    local next_pos, next_node = tube_def.get_next_pos_and_node(tube_hpos, tube_state, tube_dir)

    if IG(next_node.name, 'stube') == 1 then -- Worst case: another tube, oh no xD
        core.debug 'TRANSFERRING TO ANOTHER STUBE'
        -- Need to:
        -- 1) If the tube next to it has space
        -- 2) If not, repeat step 1 from the tube next to it
        -- If you encounter a loop (**checkable by TubeState.updated_at**), or if there just isn't space anywhere, job is done
        local success, next_tube_hpos, next_tube_def, next_tube_prefix, next_tube_type_array =
            push_items_to_next_tube(next_node, next_pos, tube_def, tube_state)

        if success == false then
            core.debug 'NOT SUCCESSFUL'
            stube.update_tube(next_tube_hpos, next_tube_def, next_tube_type_array[next_tube_hpos], next_tube_prefix)
            delete_if_empty_state(tube_hpos, tube_def, tube_state)
            push_items_to_next_tube(next_node, next_pos, tube_def, tube_state)
        end
    elseif IG(next_node.name, 'tubedevice_receiver') == 1 then
        core.debug 'TRANSFERING TO FOREIGN NODE'
        stube.transfer_items(tube_state, tube_def, next_node, next_pos, tube_dir)
    end
    core.debug 'PASSED'
end

function stube.process_tube_type(tube_name, tube_def)
    local tubes = stubes[tube_name]
    for tube_hpos, tube_state in pairs(tubes) do
        if tube_state.updated_at == stube.current_update_time then return end
        stube.update_tube(tube_hpos, tube_def, tube_state, tube_name)
        delete_if_empty_state(tube_hpos, tube_def, tube_state, tubes)
    end
end

function stube.globalstep(dtime)
    stube.current_update_time = stube.current_update_time + 1
    for name, timer in pairs(timers) do
        timer.current = timer.current + dtime
        if timer.current >= timer.max then
            stube.process_tube_type(name, stube.registered_tubes[name])
            timer.current = 0
        end
    end
end
core.register_globalstep(stube.globalstep)

---@return boolean Success Returns false if it can't
function stube.add_tubed_item(pos, stack)
    local hpos = core.hash_node_position(pos)
    local node = stube.get_or_load_node(pos)
    if core.get_item_group(node.name, 'stube') == 0 then return false end

    local prefix = stube.get_prefix_tube_name(node.name)
    local tube_state = stubes[prefix][hpos]
    if not tube_state then
        stubes[prefix][hpos] = {
            items = {},
            updated_at = stube.current_update_time,
        }
        tube_state = stubes[prefix][hpos]
    end

    return insert_item(tube_state.items, stack, stube.registered_tubes[prefix].capacity)
end

function stube.tube_input_insert_object(pos, node, stack, vel, owner)
    local prefix = stube.get_prefix_tube_name(node.name)
    local all_stubes_of_our_type = stubes[prefix]
    local hpos = h(pos)
    local tube_state = all_stubes_of_our_type[hpos]
    if not tube_state then
        all_stubes_of_our_type[hpos] = {
            items = {},
            updated_at = stube.current_update_time,
        }
        tube_state = all_stubes_of_our_type[hpos]
    end
    if insert_item(tube_state.items, stack, stube.registered_tubes[prefix].capacity) == false then return stack end
end
