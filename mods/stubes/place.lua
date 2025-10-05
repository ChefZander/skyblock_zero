-- Okay so this code is kinda messy? probably better than pipeworks
-- just uh be aware
-- if you don't understand it thats fine, message me (frog) and i could make a comment explaining

--- If it's a tube device, and is NOT an stube
function stube.is_tubedevice(node_name)
    local reg = core.registered_nodes[node_name]
    if reg == nil then return false end
    if reg.tube == nil then return false end
    if core.get_item_group(node_name, 'stube') == 1 then return false end
    return true
end

-- pipeworks has a better solution im not doing for the sake of licensing
function stube.process_pipeworks_connect_sides(connect_sides, neighbor_dir, neighbor_node)
    local neighbor_facedir = neighbor_node.param2
    local neighbor_facedir_dir = core.facedir_to_dir(neighbor_facedir)
    if neighbor_facedir > 23 then neighbor_facedir = 0 end
    local rotate_by = -vector.dir_to_rotation(neighbor_facedir_dir)
    if math.floor(neighbor_facedir / 4) ~= 0 and rotate_by.y < -1 then rotate_by.x = -(math.pi / 2) end -- HACK, that i am not going to fix, this was derived from brute force, it allows placing tubes to tubedevices from above work, specifically filter injectors
    local correct_dir = vector.rotate(neighbor_dir, rotate_by)
    local wallmounted_dir = core.dir_to_wallmounted(correct_dir)

    local index = (wallmounted_dir == 0 and 'top')
        or (wallmounted_dir == 1 and 'bottom')
        or (wallmounted_dir == 2 and 'right')
        or (wallmounted_dir == 3 and 'left')
        or (wallmounted_dir == 4 and 'front')
        or (wallmounted_dir == 5 and 'back')
    return connect_sides[index] == 1 or connect_sides[index] == true
end

local function has_no_connections(connections)
    for i = 1, 6 do
        if connections[i] == 1 then return false end
    end
    return true
end

-- the order in which i chose the connections was kinda stupid, because it isn't the wallmounted direction
-- so i have to do this sort of thing instead of just doing connections[wallmounted]=1
-- This table is {[wallmounted] = STube connection}
stube.wallmounted_to_connections_index = {
    [0] = 2,
    [1] = 5,
    [2] = 1,
    [3] = 4,
    [4] = 3,
    [5] = 6,
}

local connections_to_wallmounted = table.key_value_swap(table.copy(stube.wallmounted_to_connections_index))

local function make_connection(connections, wallmounted_dir, remove_connection)
    local set_to = 1
    if remove_connection then set_to = 0 end
    connections[stube.wallmounted_to_connections_index[wallmounted_dir]] = set_to
end

function stube.connect_tubes_to(pos, dir, pointed_thing, sneaking)
    pos = vector.copy(pos) -- guaranteed to be a vector

    -- Connect to our tube if it is pointing to it
    for idir = 0, 5 do
        local neighbor_dir_from_origin = core.wallmounted_to_dir(idir)
        local neighbor_pos = pos + neighbor_dir_from_origin
        local neighbor_node = stube.get_or_load_node(neighbor_pos)

        if core.get_item_group(neighbor_node.name, 'stube') == 1 then
            local split = stube.split_tube_name(neighbor_node.name)
            local pointing_to = (core.wallmounted_to_dir(split.dir) + neighbor_pos)

            if pointing_to == pos or has_no_connections(split.connections) then
                local connection_dir = core.dir_to_wallmounted(pos - neighbor_pos)

                if has_no_connections(split.connections) then split.dir = connection_dir end
                make_connection(split.connections, connection_dir)

                core.set_node(neighbor_pos, { name = stube.join_tube_name(split) })
            end
        end
    end

    -- Switch the direction of the position under
    -- Makes making turns actually possible
    if pointed_thing then
        local node = stube.get_or_load_node(pointed_thing.under)

        if core.get_item_group(node.name, 'stube') == 1 then
            local split = stube.split_tube_name(node.name)
            split.dir = dir
            make_connection(split.connections, dir)
            core.set_node(pointed_thing.under, { name = stube.join_tube_name(split) })
        end
    end

    -- make the tube that is in front of us, point to us
    -- This makes connecting tubes with multiple inputs possible, after they have already been placed
    if dir and not sneaking then
        local vdir = core.wallmounted_to_dir(dir)
        local front_pos = pos + vdir
        local front_node = stube.get_or_load_node(front_pos)

        if core.get_item_group(front_node.name, 'stube') == 1 then
            local split = stube.split_tube_name(front_node.name)

            make_connection(split.connections, split.dir)
            make_connection(split.connections, core.dir_to_wallmounted(pos - front_pos))
            core.set_node(front_pos, { name = stube.join_tube_name(split) })
        end
    end
end

function stube.place_tube(name, pos, tube_dir, pointed_thing, sneaking)
    stube.connect_tubes_to(pos, tube_dir, pointed_thing, sneaking)

    local connections = {
        -- X, Y, Z
        0,
        0,
        0,
        -- -X, -Y, -Z
        0,
        0,
        0,
    }

    for neighbor_dir_number = 0, 5 do
        local neighbor_dir = core.wallmounted_to_dir(neighbor_dir_number)
        local neighbor_pos = vector.add(pos, neighbor_dir)
        local neighbor_node = stube.get_or_load_node(neighbor_pos)

        if core.get_item_group(neighbor_node.name, 'stube') == 1 then
            local tube_params = stube.get_tube_name_info(neighbor_node.name)
            if vector.equals(vector.add(core.wallmounted_to_dir(tube_params[1]), neighbor_pos), pos) then -- If the tube is pointing to ours
                make_connection(connections, neighbor_dir_number)
            end
        end
    end

    --- Automatically connect any tubedevices or routing blocks
    if not sneaking then
        for i = 0, 5 do
            local neighbor_dir = core.wallmounted_to_dir(i)
            local neighbor_pos = vector.add(pos, neighbor_dir)
            local neighbor_node = stube.get_or_load_node(neighbor_pos)

            local should_connect = false
            if stube.is_tubedevice(neighbor_node.name) == true then
                local connect_sides = core.registered_nodes[neighbor_node.name].tube.connect_sides
                if connect_sides then
                    should_connect = stube.process_pipeworks_connect_sides(connect_sides, -neighbor_dir, neighbor_node)
                else
                    should_connect = true
                end
            elseif core.get_item_group(neighbor_node.name, 'stube_routing_node') == 1 then
                should_connect = true
            end
            if should_connect then make_connection(connections, i) end
        end
    else -- Only connect the tubedevice we are sneaking at
        local under_node = stube.get_or_load_node(pointed_thing.under)
        local under_dir = vector.subtract(pointed_thing.above, pointed_thing.under)

        local should_connect = false
        if stube.is_tubedevice(under_node.name) == true then
            local connect_sides = core.registered_nodes[under_node.name].tube.connect_sides
            if connect_sides then
                should_connect = stube.process_pipeworks_connect_sides(connect_sides, under_dir, under_node)
            else
                should_connect = true
            end
        elseif core.get_item_group(under_node.name, 'stube_routing_node') == 1 then
            should_connect = true
        end

        if should_connect then
            make_connection(
                connections,
                core.dir_to_wallmounted(vector.subtract(pointed_thing.under, pointed_thing.above))
            )
        end
    end

    local no_connections = true
    local amount_of_connections = 0
    for i = 1, 6 do
        if connections[i] == 1 then
            no_connections = false
            amount_of_connections = amount_of_connections + 1
        end
    end

    -- the square/no connections tube
    if no_connections then tube_dir = 0 end

    -- if a tube is not straight, make a connection
    -- Basically, makes short tubes whenever possible
    -- and maintain a connection to things which interact with tubes, that is important

    local tube_pointing_to = vector.add(pos, core.wallmounted_to_dir(tube_dir))
    local tube_pointing_to_node = stube.get_or_load_node(tube_pointing_to)

    local straight_tube_index = (stube.wallmounted_to_connections_index[tube_dir] + 3) % 6
    if straight_tube_index == 0 then straight_tube_index = 6 end
    if
        not (
            ((amount_of_connections == 1 and connections[straight_tube_index] == 1) or amount_of_connections == 0) -- if the tube is straight or a box
            and stube.is_tubedevice(tube_pointing_to_node.name) == false
        )
    then
        make_connection(connections, tube_dir)
    end

    -- if there is a tube in the front of us, point to it
    -- This makes connecting tubes with multiple inputs possible, after they have already been placed, but sometimes you may not want this behavior

    if not sneaking then
        local vdir = core.wallmounted_to_dir(tube_dir)
        local front_pos = pos + vdir
        local front_node = stube.get_or_load_node(front_pos)
        if core.get_item_group(front_node.name, 'stube') == 1 then make_connection(connections, tube_dir) end
    end

    core.set_node(pos, { name = stube.get_prefix_tube_name(name) .. '_' .. tube_dir .. table.concat(connections) })
end

-- When an stube is broken, or something near it was, this should get called
-- It cleans up garbage connections (e.g. connection to nowhere, that isn't needed)
function stube.update_placement(pos)
    -- All the cases of garbage connections:
    --   - When a connection is pointing to air/incompatible node
    --   - When a connection is pointing to a tube, which is not connected to it -> weird visual
    --   - When a tube could be a short tube instead

    -- So, this function will iterate over the neighboring tubes of this position
    pos = vector.copy(pos) -- ensure pos is a vector
    stube.update_placement_single(pos)
    for i = 0, 5 do
        stube.update_placement_single(pos + core.wallmounted_to_dir(i))
    end
end

---@see stube.update
function stube.update_placement_single(pos)
    local node = stube.get_or_load_node(pos)
    if core.get_item_group(node.name, 'stube') ~= 1 then return end

    local split = stube.split_tube_name(node.name)

    for i = 1, 6 do
        local connection = split.connections[i]
        local connection_dir = connections_to_wallmounted[i]
        local connection_dirv = core.wallmounted_to_dir(connection_dir)
        local connection_pos = pos + connection_dirv

        local connection_node = stube.get_or_load_node(connection_pos)

        local ig = core.get_item_group

        if connection == 1 then
            -- first case: pointing to air/incompatible node
            if
                not (
                    ig(connection_node.name, 'stube') == 1
                    or stube.is_tubedevice(connection_node.name) == true
                    or ig(connection_node.name, 'stube_routing_node') == 1
                )
            then
                split.connections[i] = 0
            end

            -- second case: connection is pointing to a tube that is not connected to it (=> a weird/out of place connection)
            if ig(connection_node.name, 'stube') == 1 then
                local other_tube_split = stube.split_tube_name(connection_node.name)

                local other_connection_index = (i + 3) % 6
                if other_connection_index == 0 then other_connection_index = 6 end
                if other_tube_split.connections[other_connection_index] == 0 then split.connections[i] = 0 end

                -- another case: The tube wants nothing to do with us (manifests as arrows pointing away from eachother), should disconnect
                -- so all connected tubes should point to us, if not disconnect
                if
                    connection_dir ~= split.dir
                    and not vector.equals((core.wallmounted_to_dir(other_tube_split.dir) + connection_pos), pos)
                then
                    split.connections[i] = 0
                end
            end
        end
    end

    local amount_of_connections = 0
    for i = 1, 6 do
        if split.connections[i] == 1 then amount_of_connections = amount_of_connections + 1 end
    end

    local straight_tube_index = (stube.wallmounted_to_connections_index[split.dir] + 3) % 6 -- the index opposite to the dir, if that makes sense
    if straight_tube_index == 0 then straight_tube_index = 6 end

    -- case 2.5: "We could totally be connected to that tubedevice/routing block right now actually, we don't need to be a short tube"
    if amount_of_connections == 1 and split.connections[straight_tube_index] == 1 then
        local dir = core.wallmounted_to_dir(split.dir)
        local next_pos = pos + dir
        local next_node = stube.get_or_load_node(next_pos)
        if stube.is_tubedevice(next_node.name) then
            local connect_sides = core.registered_nodes[next_node.name].tube.connect_sides
            local should_connect = true
            if connect_sides then
                should_connect = stube.process_pipeworks_connect_sides(
                    core.registered_nodes[next_node.name].tube.connect_sides,
                    dir,
                    next_node
                )
            end
            if should_connect then make_connection(split.connections, split.dir) end
        elseif core.get_item_group(next_node.name, 'stube_routing_node') == 1 then
            make_connection(split.connections, split.dir)
        end
    end

    -- third case: it could be a short tube instead, if not, check if there is a tube in our direction, and check if it is properly connected
    if
        not ((amount_of_connections == 1 and split.connections[straight_tube_index] == 1) or amount_of_connections == 0)
    then -- not a short tube
        make_connection(split.connections, split.dir)

        local next_pos = pos + core.wallmounted_to_dir(split.dir)
        local next_node = stube.get_or_load_node(next_pos)
        -- also make sure the neighboring tube is properly connected, this must not occur with short tubes
        if core.get_item_group(next_node.name, 'stube') == 1 then
            local next_tube_split = stube.split_tube_name(next_node.name)
            make_connection(next_tube_split.connections, core.dir_to_wallmounted(pos - next_pos))

            -- small complication: if next_node is a short tube, this could make an invalid tube, crashing the game.. ugh
            -- if short tubes were just not a thing, this mod's source code would be substantially smaller
            -- but the alternative is really ugly (as in, in-game looks, not source code) soo gotta deal with it

            local set_to = stube.join_tube_name(next_tube_split)
            if not core.registered_nodes[set_to] then -- okay this is the extremely lazy way, how did i not think of this earlier
                make_connection(next_tube_split.connections, next_tube_split.dir)
                set_to = stube.join_tube_name(next_tube_split)
            end

            core.set_node(next_pos, { name = set_to })
        end
    end

    if amount_of_connections == 0 then split.dir = 0 end

    core.set_node(pos, { name = stube.join_tube_name(split) })
end

function stube.tube_after_place(pos, placer, stack, pointed)
    if not placer then return end
    if not placer:is_valid() then return end
    if pointed.type ~= 'node' then return end

    local face = vector.subtract(pointed.above, pointed.under)
    local dir = core.dir_to_wallmounted(face)

    local sneaking = placer:get_player_control().sneak
    stube.place_tube(stack:get_name(), pos, dir, pointed, sneaking)
    stube.update_placement(pos)
end

-- Change the direction to the one we are pointing to
-- Needs sneak+punch
function stube.default_tube_punch(pos, node, puncher, pointed_thing)
    if core.is_protected(pos, puncher) then
        core.record_protection_violation(pos, puncher)
        return
    end
    if puncher and puncher:get_player_control().sneak then
        local split = stube.split_tube_name(node.name)
        split.dir = core.dir_to_wallmounted(pointed_thing.above - pointed_thing.under)
        split.connections[stube.wallmounted_to_connections_index[split.dir]] = 1
        core.set_node(pos, { name = stube.join_tube_name(split) })
    end
    stube.update_placement(pos)
end

if core.global_exists 'pipeworks' then -- hijack pipeworks for our benefit nyehehe
    local old_scan_for_tube_objects = pipeworks.scan_for_tube_objects -- this runs when ANY PIPEWORKS TUBE OR TUBEDEVICE GETS PLACED, really convenient

    ---@diagnostic disable-next-line: duplicate-set-field
    function pipeworks.scan_for_tube_objects(pos)
        stube.update_placement(pos)
        return old_scan_for_tube_objects(pos)
    end
end
