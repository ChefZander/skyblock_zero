local logic = sbz_api.logic

local max_memsize = 1024 -- 1024 bytes, just use disks lol
logic.mem_size = max_memsize

local err_lc_should_be_off = "Error: Luacontroller should've been off, how did you even get this errrorr"

-- make_safe() et. al. from mesecons (heavily edited):
-- https://github.com/minetest-mods/mesecons/blob/master/mesecons_luacontroller/init.lua
local function can_serialize(x)
    local tp = type(x)
    -- since mod security exists, we CANNOT serialize functions
    if tp == "function" or tp == "userdata" or tp == "thread" then
        return false
    else
        return true
    end
end
--- Don't use this
local function make_safe1(x, seen)
    if x == nil then return end
    if seen[x] then return end
    seen[x] = true
    if type(x) ~= "table" then return end

    for key, value in pairs(x) do
        if not (can_serialize(key) and can_serialize(value)) then
            x[key] = nil
        else
            if type(key) == "table" then
                make_safe1(key, seen)
            end
            if type(value) == "table" then
                make_safe1(value, seen)
            end
        end
    end
end
local function make_safe(x)
    if not can_serialize(x) then
        return nil
    end
    make_safe1(x, {})
    return x
end

function logic.serialize_data(mem, max, name)
    if not name then name = "the mem table" end
    local safe_mem = make_safe(mem)
    local serialized_mem = core.serialize(safe_mem)
    if #serialized_mem > max then
        return false, string.format("You stored too much in %s (%s/%s bytes)", name, #serialized_mem, max)
    else
        return serialized_mem
    end
end

local valid_keys = { ["formspec"] = 1, ["editor_code"] = 1, ["code"] = 1, ["error"] = 1 }
local function get_editor_table(id, provided_meta)
    return setmetatable({}, {
        __index = function(t, k)
            if valid_keys[k] then
                local meta = provided_meta
                if not meta then
                    local pdata = logic.id2pos[id]
                    if not pdata then error(err_lc_should_be_off) end
                    meta = pdata.meta
                end
                return meta:get_string(k)
            else
                return nil
            end
        end,
        __newindex = function(t, k, v)
            if valid_keys[k] and type(v) == 'string' then
                if #v > 1024 * 25 then
                    error("Oh no! " .. k .. " is too large")
                end
                local meta = provided_meta
                if not meta then
                    local pdata = logic.id2pos[id]
                    if not pdata then error(err_lc_should_be_off) end
                    meta = pdata.meta
                end
                meta:set_string(k, v)
                if k ~= "formspec" then
                    meta:mark_as_private(k)
                end
            end
        end
    })
end

local libf = libox.sandbox_lib_f

-- See also: https://github.com/ChefZander/skyblock_zero/pull/134
-- for how JIT affected these luac functions

local function get_unpack_pdata(id, pos, meta)
    if id then
        local pdata = logic.id2pos[id]
        if not pdata then error(err_lc_should_be_off) end
        return pdata.pos, pdata.meta
    end
    return pos, meta
end

function logic.get_the_get_node_function(id)
    return libf(function(pos)
        local lc_pos = get_unpack_pdata(id)
        if not libox.type_vector(pos) then
            return false, "Invalid position"
        end
        pos = vector.add(pos, lc_pos)
        local range_allowed = logic.range_check(lc_pos, pos)
        if not range_allowed then
            return false, "The node you are trying to get is too far away or is protected by someone else."
        end
        return minetest.get_node(pos)
    end)
end

function logic.get_chat_debug_function(id, owner, provided_pos)
    return libf(function(msg)
        local pos = get_unpack_pdata(id, provided_pos, nil)

        if type(msg) ~= "string" then
            error("In chat_debug(msg), the msg must be a string!")
        end
        if #msg > 800 then
            error("Message too large")
        end
        if owner == "" then
            error("No owner of luacontroller? Solution: re-build the luacontroller")
        end
        if not core.is_protected(pos, "") or core.is_protected(pos, owner) then
            error("For " .. owner .. "'s safety, the area must be protected by them")
        end
        if not core.get_player_by_name(owner) then
            return false
        end
        core.chat_send_player(owner,
            string.format("[Luacontroller @%s] %s", vector.to_string(pos), core.colorize("lime", msg)))
    end)
end

local function get_read_mem(id, meta)
    return libf(function()
        local _, meta = get_unpack_pdata(id, nil, meta)
        return core.deserialize(meta:get_string("mem")) or {}
    end)
end

local function get_write_mem(id, meta)
    return libf(function(mem_data)
        local _, meta = get_unpack_pdata(id, nil, meta)
        local mem, errmsg = logic.serialize_data(mem_data, max_memsize)
        if errmsg then
            -- NOTE: mem overflow no longer erases data
            -- since players can now handle errors.
            -- meta:set_string('mem', core.serialize({}))
            return false, errmsg
        end
        meta:set_string('mem', mem)
        meta:mark_as_private('mem')
        return true
    end)
end

local function disk_get(stack, stack_name, slot, stack_meta, disk_name)
    if core.get_item_group(stack_name, 'sbz_disk_immutable') ~= 0 then
        local node_def = core.registered_craftitems[stack_name]
        return {
            immutable = true,
            data = node_def.source,
            punches_code = node_def.punches_code,
            punches_editor = node_def.punches_editor,
            name = node_def.description,
            index = slot,
        }
    else
        stack_meta = stack_meta or stack:get_meta()
        return {
            immutable = false,
            data = core.deserialize(stack_meta:get_string("data")),
            punches_code = stack_meta:get_int("override_code") == 1,
            punches_editor = stack_meta:get_int("override_editor") == 1,
            name = disk_name or stack_meta:get_string("description"),
            index = slot,
            max = minetest.registered_craftitems[stack_name].can_hold
        }
    end
end
local function get_read_disk(id, meta)
    return libf(function(disk_id)
        local _, meta = get_unpack_pdata(id, nil, meta)
        local inv = meta:get_inventory()
        local disk_list = inv:get_list('disks') or {}

        local ty = type(disk_id)
        if ty == 'number' then
            if disk_id ~= disk_id or disk_id == math.huge or disk_id == -math.huge then
                return false, 'Given disk slot is not finite'
            end
            local stack = disk_list[disk_id]
            local stack_name = stack:get_name()
            if stack_name == '' then
                return false, string.format('No disk in slot #%d', disk_id)
            end
            return disk_get(stack, stack_name, disk_id)

        elseif ty == 'string' then
            for slot, stack in ipairs(disk_list) do
                local stack_name = stack:get_name()
                if stack_name ~= '' then
                    local stack_meta = stack:get_meta()
                    if disk_id == stack_meta:get_string('description') then
                        return disk_get(stack, stack_name, slot, stack_meta, disk_id)
                    end
                end
            end
            return false, string.format('No disk named %q', disk_id)
        else
            return false, string.format(
                'Expecting disk ID name or slot index, got %s', ty)
        end
    end)
end

-- TODO: this should be in a utils mod/namespace
local function boolean4meta(v)
    return v and 1 or 0
end
local function get_write_disk(id, meta)
    return libf(function(disk_id, disk_data)
        local _, meta = get_unpack_pdata(id, nil, meta)
        local inv = meta:get_inventory()
        local disk_list = inv:get_list('disks') or {}

        local ty = type(disk_id)
        local slot = disk_id
        local stack, stack_name, stack_meta
        if ty == 'number' then
            if disk_id ~= disk_id or disk_id == math.huge or disk_id == -math.huge then
                return false, 'Given disk slot is not finite'
            end
            stack = disk_list[disk_id]
            stack_name = stack:get_name()
            if stack_name == '' then
                return false, string.format('No disk in slot #%d', slot)
            end
            if core.get_item_group(stack_name, 'sbz_disk_immutable') ~= 0 then
                return false, string.format(
                    'Cannot write to immutable disk in slot #%d', slot)
            end
            stack_meta = stack:get_meta()
        elseif ty == 'string' then
            for slot1, stack1 in ipairs(disk_list) do
                stack_name = stack1:get_name()
                if stack_name ~= '' then
                    stack_meta = stack1:get_meta()
                    local disk_name = stack_meta:get_string('description')
                    if disk_id == disk_name then
                        if core.get_item_group(stack_name, 'sbz_disk_immutable') ~= 0 then
                            return false, string.format(
                                'Cannot write to immutable disk named %q', disk_name)
                        end
                        stack = stack1
                        slot = slot1
                        break
                    end
                end
            end
            if not slot then
                return false, string.format('No disk named %q', disk_id)
            end
        else
            return false, string.format(
                'Expecting disk ID name or slot index, got %s', ty)
        end


        ty = type(disk_data)
        if ty ~= 'table' then -- Destroy disk! >:)
            disk_data = { data = '' }
        end

        if disk_data.data == nil and disk_data.name == nil and disk_data.punches_code == nil and disk_data.punches_editor == nil then
            return false, 'No disk fields to write, did you forget to put e.g. data into disk_data.data?'
        end

        local data, errmsg
        if disk_data.data then
            local max_size = core.registered_craftitems[stack_name].can_hold
            local errmsg_name
            if ty == 'number' then
                errmsg_name = string.format('disk in slot #%s', disk_id)
            else -- ty == 'string', confirmed this earlier
                errmsg_name = string.format('disk named %q', disk_id)
            end
            data, errmsg = logic.serialize_data(disk_data.data, max_size, errmsg_name)
            if errmsg then
                return false, errmsg
            end
        end

        local description
        if disk_data.name then
            description = tostring(disk_data.name) or ''
            if #description > 128 then
                return false, 'New disk name is huuuge, must be 128 bytes or lower'
            end
        end


        -- now safe to write :D
        stack_meta:set_string('data', data)
        stack_meta:set_string('description', description)

        if disk_data.punches_code ~= nil then
            stack_meta:set_int('override_code', boolean4meta(disk_data.punches_code))
        end
        if disk_data.punches_editor ~= nil then
            stack_meta:set_int('override_editor', boolean4meta(disk_data.punches_editor))
        end
        inv:set_stack('disks', slot, stack)
        return true
    end)
end
local function get_available_disks(id, meta)
    return libf(function()
        local _, meta = get_unpack_pdata(id, nil, meta)
        local inv = meta:get_inventory()
        local disk_list = inv:get_list('disks') or {}
        local slots = {}
        for slot, stack in pairs(disk_list) do
            local stack_name = stack:get_name()
            if stack_name ~= '' then
                slots[#slots+1] = slot
            end
        end
        return slots
    end)
end
local function get_available_disk_names(id, meta)
    return libf(function ()
        local _, meta = get_unpack_pdata(id, nil, meta)
        local inv = meta:get_inventory()
        local disk_list = inv:get_list('disks') or {}
        local names = {}
        for _, stack in pairs(disk_list) do
            local stack_name = stack:get_name()
            if stack_name ~= '' then
                names[#names+1] = stack:get_meta():get_string('description')
            end
        end

        return names
    end)
end

function logic.get_env(initial_pos, initial_meta, id)
    ---@type table
    local base = libox.create_basic_environment()

    local function wait_for_event_type(event_type)
        local ignored_events = {}
        while true do
            local e = coroutine.yield()
            ignored_events[#ignored_events + 1] = e
            if e.type == event_type then
                return ignored_events
            end
        end
    end
    local owner = initial_meta:get_string("owner")

    for k, v in pairs {
        editor = get_editor_table(id),
        pos = vector.copy(initial_pos),
        yield = coroutine.yield,
        wait_for_event_type = wait_for_event_type,
        chat_debug = logic.get_chat_debug_function(id, owner),
        wait = function(t)
            local e = coroutine.yield({
                type = "wait",
                time = t,
            })
            if e.type == "wait" then return { e } end
            return wait_for_event_type("wait")
        end,
        send_to = libf(function(send_to_pos, msg)
            if not logic.type_link(send_to_pos, true) then return false, "send_to_pos must be a link or position" end
            local posdata = logic.id2pos[id]
            if not posdata then error(err_lc_should_be_off) end
            return logic.send_l(logic.add_to_link(send_to_pos, posdata.pos), msg, posdata.pos)
        end),
        get_node = logic.get_the_get_node_function(id),
        is_protected = libf(function(rpos, who)
            if not libox.type_vector(rpos) then return false, "Invalid position." end
            local posdata = logic.id2pos[id]
            if not posdata then error(err_lc_should_be_off) end
            local abs_pos = vector.add(rpos, posdata.pos)
            return minetest.is_protected(abs_pos, who or owner)
        end),
        full_traceback = debug.traceback,
        turn_on_machine = libf(function(rpos)
            if not libox.type_vector(rpos) then return false, "Invalid position." end
            local posdata = logic.id2pos[id]
            if not posdata then error(err_lc_should_be_off) end
            local pos = posdata.pos

            local abs_pos = vector.add(pos, rpos)
            if not sbz_api.is_machine(abs_pos) and (string.find(core.get_node(abs_pos).name, "connector") == nil) then
                return false, "Not a machine."
            end
            if not logic.range_check(pos, abs_pos) then return false, "Can't turn on that, outside of linking range" end
            return sbz_api.force_turn_on(abs_pos, minetest.get_meta(abs_pos))
        end),
        turn_off_machine = libf(function(rpos)
            if not libox.type_vector(rpos) then return false, "Invalid position." end
            local posdata = logic.id2pos[id]
            if not posdata then error(err_lc_should_be_off) end
            local pos = posdata.pos

            local abs_pos = vector.add(pos, rpos)
            if not sbz_api.is_machine(abs_pos) and (string.find(core.get_node(abs_pos).name, "connector") == nil) then
                return false, "Not a machine."
            end
            if not logic.range_check(pos, abs_pos) then return false, "Can't turn off that, outside of linking range" end
            return sbz_api.force_turn_off(abs_pos, minetest.get_meta(abs_pos))
        end),
        read_mem = get_read_mem(id),
        write_mem = get_write_mem(id),
        read_disk = get_read_disk(id),
        write_disk = get_write_disk(id),
        available_disks = get_available_disks(id),
        available_disk_names = get_available_disk_names(id),
    } do
        base[k] = v
    end
    return base
end

function logic.get_editor_env(pos, meta, event)
    local base = libox.create_basic_environment()
    local ID = meta:get_string("ID")
    if ID then
        if libox.coroutine.active_sandboxes[ID] then
            base.coroutine_env = libox.coroutine.active_sandboxes[ID].env
            -- dont know how overpowered this is..... i mean like... hey i will see
        end
    end

    local owner = meta:get_string("owner")

    for k, v in pairs {
        editor = get_editor_table(nil, meta),
        event = event,
        pos = vector.copy(pos),
        origin = vector.new(0, 0, 0),
        chat_debug = logic.get_chat_debug_function(nil, owner, pos),
        turn_on = libf(function()
            sbz_api.queue:add_action(pos, "logic_turn_on", {})
        end),
        turn_off = libf(function()
            sbz_api.queue:add_action(pos, "logic_turn_off", {})
        end),
        full_traceback = debug.traceback,
        read_mem = get_read_mem(nil, meta),
        write_mem = get_write_mem(nil, meta),
        read_disk = get_read_disk(nil, meta),
        write_disk = get_write_disk(nil, meta),
        available_disks = get_available_disks(nil, meta),
        available_disk_names = get_available_disk_names(nil, meta),
    } do
        base[k] = v
    end

    return base
end
