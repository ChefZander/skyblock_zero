local logic = sbz_api.logic

local err_lc_should_be_off = "Error: Luacontroller should've been off, how did you even get this errrorr"

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

function logic.get_the_get_node_function(id)
    return libf(function(pos)
        local pdata = logic.id2pos[id]
        if not pdata then error(err_lc_should_be_off) end
        local lc_pos = pdata.pos
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
        local pos = provided_pos
        if not pos then
            local posdata = logic.id2pos[id]
            if not posdata then error(err_lc_should_be_off) end
            pos = posdata.pos
        end
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
        is_protected = function(rpos, who)
            if not libox.type_vector(rpos) then return false, "Invalid position." end
            local posdata = logic.id2pos[id]
            if not posdata then error(err_lc_should_be_off) end
            local abs_pos = vector.add(rpos, posdata.pos)
            return minetest.is_protected(abs_pos, who or owner)
        end,
        full_traceback = debug.traceback,
        turn_on_machine = function(rpos)
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
        end,
        turn_off_machine = function(rpos)
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
        end,
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
    } do
        base[k] = v
    end

    return base
end
