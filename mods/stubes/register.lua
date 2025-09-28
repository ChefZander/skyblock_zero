--- Tube capacity is always <the number of connections>+1
---@class stube.TubeDef
---@field textures table
---@field speed number The amount of time between updates, lower is faster
---@field should_update fun(tube_hpos:integer, tube_state:stube.TubeState, node:node):boolean
---@field get_next_pos_and_node fun(tube_hpos:integer, tube_state:stube.TubeState, dir:integer):vector, node

---@type {[string]: stube.TubeDef }
stube.registered_tubes = {}

local function tube_nodebox(len, stretch_to)
    local full = 0.5
    local base_box = { -len, -len, -len, len, len, len }
    if stretch_to == 'top' then
        base_box[5] = full
    elseif stretch_to == 'bottom' then
        base_box[2] = -full
    elseif stretch_to == 'front' then
        base_box[3] = -full
    elseif stretch_to == 'back' then
        base_box[6] = full
    elseif stretch_to == 'right' then
        base_box[4] = full
    elseif stretch_to == 'left' then
        base_box[1] = -full
    end
    return base_box
end

--- e* -> expected
--- so edir = expected dir
local function short_check(dir, xc, yc, zc, nxc, nyc, nzc, edir, exc, eyc, ezc, enxc, enyc, enzc)
    return dir == edir and xc == exc and yc == eyc and zc == ezc and nxc == enxc and nyc == enyc and nzc == enzc
end

local function change_tile_dir(arranged_connections, tiles, tube_textures, id, transform)
    if arranged_connections[id] == 1 then
        tiles[id] = tube_textures.noctr_up .. transform
    else
        tiles[id] = tube_textures.plain_up .. transform
    end
end

local function register_single_tube(name, def, tubedef, dir, xc, yc, zc, nxc, nyc, nzc)
    local is_short = false -- Shorts are tubes that lead to nowhere, so they are the "endings"
    local visible = false -- If it's visible in the inventory, the _000000 tube
    if
        dir == 0 and yc ~= 1
        or dir == 1 and nyc ~= 1
        or dir == 2 and xc ~= 1
        or dir == 3 and nxc ~= 1
        or dir == 4 and zc ~= 1
        or dir == 5 and nzc ~= 1
    then
        -- i am horrible at working with large amounts of variables xD
        -- good luck understanding this hehe
        if
            short_check(dir, xc, yc, zc, nxc, nyc, nzc, 0, 0, 0, 0, 0, 1, 0)
            or short_check(dir, xc, yc, zc, nxc, nyc, nzc, 1, 0, 1, 0, 0, 0, 0)
            or short_check(dir, xc, yc, zc, nxc, nyc, nzc, 2, 0, 0, 0, 1, 0, 0)
            or short_check(dir, xc, yc, zc, nxc, nyc, nzc, 3, 1, 0, 0, 0, 0, 0)
            or short_check(dir, xc, yc, zc, nxc, nyc, nzc, 4, 0, 0, 0, 0, 0, 1)
            or short_check(dir, xc, yc, zc, nxc, nyc, nzc, 5, 0, 0, 1, 0, 0, 0)
        then
            is_short = true
        elseif short_check(dir, xc, yc, zc, nxc, nyc, nzc, 0, 0, 0, 0, 0, 0, 0) then
            visible = true
        else
            return -- invalid tubes, so only 224 nodes should get registered thanks to this
        end
    end

    name = name .. '_' .. dir .. xc .. yc .. zc .. nxc .. nyc .. nzc
    if visible == false then
        def.description = def.description
            .. table.concat { ', state: ', '\n' }
            .. table.concat { 'short: ', tostring(is_short), '\n' }
            .. table.concat { 'dir: ', dir, '\n' }
            .. table.concat { 'xc: ', xc, '\n' }
            .. table.concat { 'yc: ', yc, '\n' }
            .. table.concat { 'zc: ', zc, '\n' }
            .. table.concat { 'nxc: ', nxc, '\n' }
            .. table.concat { 'nyc: ', nyc, '\n' }
            .. table.concat { 'nzc: ', nzc, '\n' }
    end

    local nodebox = { type = 'fixed', fixed = {} }
    local fixed = nodebox.fixed

    if yc == 1 then table.insert(fixed, tube_nodebox(stube.tube_size, 'top')) end
    if nyc == 1 then table.insert(fixed, tube_nodebox(stube.tube_size, 'bottom')) end

    if xc == 1 then table.insert(fixed, tube_nodebox(stube.tube_size, 'right')) end
    if nxc == 1 then table.insert(fixed, tube_nodebox(stube.tube_size, 'left')) end

    if zc == 1 then table.insert(fixed, tube_nodebox(stube.tube_size, 'back')) end
    if nzc == 1 then table.insert(fixed, tube_nodebox(stube.tube_size, 'front')) end
    if visible then
        table.insert(
            fixed,
            { -stube.tube_size, -stube.tube_size, -stube.tube_size, stube.tube_size, stube.tube_size, stube.tube_size }
        )
    end
    def.node_box = nodebox

    -- okay...... now the textures
    -- Each side that is connected to, will have the texture be `noctr`
    -- Each side that isn't connected to, will have the texture be `plain`
    -- On *short* tubes, the ending texture will be `ends`

    -- These connections are arranged in {+Y, -Y, +X, -X, +Z, -Z} - the same order that tiles are
    -- This makes some seemingly complicated things trivial
    local arranged_connections = { yc, nyc, xc, nxc, zc, nzc }

    def.tiles = {}
    for i = 1, 6 do
        if arranged_connections[i] == 1 then -- if its a connection, use noctr, if we didn't there would be an annoying glitchy effect
            def.tiles[i] = tubedef.textures.noctr
        else
            def.tiles[i] = tubedef.textures.plain
        end
    end

    if is_short then
        -- wallmounted dir -> tile conversion
        def.tiles[dir + 1] = tubedef.textures.ends
    else
        -- Need to correctly apply the direction
        -- Short tubes have it always be correct, so no need to change anything there
        -- All we have to do is change one arrow basically
        -- I don't know if there is a better way to do this than these if statements, possibly/
        --
        -- If you are asking how i figured out all of this, it's called "brute forcing" (at least it felt like it, but was fun?)
        if dir == 0 then
            change_tile_dir(arranged_connections, def.tiles, tubedef.textures, 3, '')
            change_tile_dir(arranged_connections, def.tiles, tubedef.textures, 4, '')
            change_tile_dir(arranged_connections, def.tiles, tubedef.textures, 5, '')
            change_tile_dir(arranged_connections, def.tiles, tubedef.textures, 6, '')
        elseif dir == 1 then
            change_tile_dir(arranged_connections, def.tiles, tubedef.textures, 3, '^[transformFY')
            change_tile_dir(arranged_connections, def.tiles, tubedef.textures, 4, '^[transformFY')
            change_tile_dir(arranged_connections, def.tiles, tubedef.textures, 5, '^[transformFY')
            change_tile_dir(arranged_connections, def.tiles, tubedef.textures, 6, '^[transformFY')
        elseif dir == 2 then
            change_tile_dir(arranged_connections, def.tiles, tubedef.textures, 1, '^[transformR270')
            change_tile_dir(arranged_connections, def.tiles, tubedef.textures, 2, '^[transformR270')
            change_tile_dir(arranged_connections, def.tiles, tubedef.textures, 5, '^[transformR90')
            change_tile_dir(arranged_connections, def.tiles, tubedef.textures, 6, '^[transformR270')
        elseif dir == 3 then
            change_tile_dir(arranged_connections, def.tiles, tubedef.textures, 1, '^[transformR90')
            change_tile_dir(arranged_connections, def.tiles, tubedef.textures, 2, '^[transformR90')
            change_tile_dir(arranged_connections, def.tiles, tubedef.textures, 5, '^[transformR270')
            change_tile_dir(arranged_connections, def.tiles, tubedef.textures, 6, '^[transformR90')
        elseif dir == 4 then
            change_tile_dir(arranged_connections, def.tiles, tubedef.textures, 1, '')
            change_tile_dir(arranged_connections, def.tiles, tubedef.textures, 2, '^[transformFY')
            change_tile_dir(arranged_connections, def.tiles, tubedef.textures, 3, '^[transformR270')
            change_tile_dir(arranged_connections, def.tiles, tubedef.textures, 4, '^[transformR90')
        elseif dir == 5 then
            change_tile_dir(arranged_connections, def.tiles, tubedef.textures, 1, '^[transformFY')
            change_tile_dir(arranged_connections, def.tiles, tubedef.textures, 2, '')
            change_tile_dir(arranged_connections, def.tiles, tubedef.textures, 3, '^[transformR90')
            change_tile_dir(arranged_connections, def.tiles, tubedef.textures, 4, '^[transformR270')
        end
    end

    if not stube.debug then def.groups.not_in_creative_inventory = visible and 0 or 1 end
    if visible then def.after_place_node = stube.tube_after_place end

    core.register_node(name, def)
end

---@param name string
---@param def table
---@param tubedef stube.TubeDef
function stube.register_tube(name, def, tubedef)
    stube.registered_tubes[name] = tubedef
    def.groups = def.groups or {}
    def.groups.stube = 1

    -- pipeworks -> stube compatibility
    def.groups.tubedevice = 1
    def.groups.tubedevice_receiver = 1
    def.tube = {
        insert_object = stube.tube_input_insert_object,
        --can_insert = stube.tube_input_can_insert, NYI: TODO:? maybe? i mean who will use this with pipeworks tubes wtf
    }

    -- Alias
    core.register_alias(name, name .. '_0000000')
    def.drop = 'stubes:test_tube'

    -- i saw what pipeworks was doing, so i think i am going with whatever this "old aproach" is https://github.com/mt-mods/pipeworks/blob/6e11868d1b32d316d60061c78460d260ac92ed6a/tubes/registration.lua#L176
    -- because it mentioned something about "the textures must be rotated" with the "new aproach", and uh i think that will complicate things, and i don't want to deal with rotating them.
    --
    -- also tubes are *directional*... so it won't just be 64 tubes
    -- so, 384 tubes at maximum, of which some are invalid
    -- I calculated there to be about 160 tubes which are invalid, so i will have to register about 224 nodes

    -- naming scheme:
    -- <coordinate>c - if that direction is connected
    -- n<coordinate>c - if that "negative" direction is connected (e.g. Z+ is north, Z- is south, so nzc would be if its connected from the south)
    -- example:
    -- 1. assume tube in the shape of "|", and that the direction that "^" is pointing in, is the y axis
    --  	then yc=1, nyc=1, all else is zero
    -- 2. assume tube in the shape of "+", and the direction that ">" is pointing in, is the x axis
    --  	then yc=1, nyc=1, xc=1, nxc = 1, all else is zero
    -- Does this make sense?
    -- And also `direction` is just a wallmounted param2
    --
    for direction = 0, 5 do
        for xc = 0, 1 do
            for yc = 0, 1 do
                for zc = 0, 1 do
                    for nxc = 0, 1 do
                        for nyc = 0, 1 do
                            for nzc = 0, 1 do
                                register_single_tube(
                                    name,
                                    table.copy(def),
                                    tubedef,
                                    direction,
                                    xc,
                                    yc,
                                    zc,
                                    nxc,
                                    nyc,
                                    nzc
                                )
                            end
                        end
                    end
                end
            end
        end
    end
end

--- Assumes one tube texture is 64x32
-- See textures/ directory for how this is done, alternatively you can do this manually and  split into 4 files (bad, horrible, ew)
function stube.make_tube_textures_from(filename)
    return {
        plain = filename .. '^[sheet:3x2:0,0',
        noctr = filename .. '^[sheet:3x2:1,0',
        ends = filename .. '^[sheet:3x2:2,0',
        plain_up = filename .. '^[sheet:3x2:0,1',
        noctr_up = filename .. '^[sheet:3x2:1,1',
    }
end

--    name = name .. '_' .. dir .. xc .. yc .. zc .. nxc .. nyc .. nzc
--    so last 7 characters
function stube.get_tube_name_info(name)
    local ret = {}
    local start = #name - 7
    for i = 1, 7 do
        ret[i] = tonumber(string.sub(name, start + i, start + i))
    end
    return ret
end

local is_short_tube_memo = {}

function stube.is_short_tube(name)
    if is_short_tube_memo[name] ~= nil then return is_short_tube_memo[name] end

    local info = stube.get_tube_name_info(name)
    local amount_of_connections = 0
    for i = 2, 7 do -- info[1] is direction
        if info[i] == 1 then amount_of_connections = amount_of_connections + 1 end
    end

    local straight_tube_index = (stube.wallmounted_to_connections_index[info[1]] + 3) % 6 -- the index opposite to the dir, if that makes sense
    if straight_tube_index == 0 then straight_tube_index = 6 end

    is_short_tube_memo[name] = amount_of_connections == 1 and info[1 + straight_tube_index] == 1
    return is_short_tube_memo[name]
end

function stube.get_prefix_tube_name(name)
    return name:sub(1, -9)
end

function stube.get_tube_dir(name)
    return assert(tonumber(name:sub(-7, -7)), '!? report this as a bug')
end

function stube.split_tube_name(name)
    local ret = {}

    ret.prefix = stube.get_prefix_tube_name(name)
    ret.connections = stube.get_tube_name_info(name)
    ret.dir = table.remove(ret.connections, 1)

    return ret
end

function stube.join_tube_name(split)
    return split.prefix .. '_' .. split.dir .. table.concat(split.connections, '')
end

function stube.default_should_update_tube(tube_hpos, tube_state, node)
    -- Don't update if its a short tube
    return not stube.is_short_tube(node.name)
end
function stube.default_get_next_pos_and_node(tube_hpos, tube_state, tube_dir)
    local cdir = core.wallmounted_to_dir(tube_dir)
    local pos = core.get_position_from_hash(tube_hpos) + cdir
    return pos, stube.get_or_load_node(pos)
end
