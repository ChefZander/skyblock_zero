local logic = sbz_api.logic

local M = minetest.get_meta
local libox_coroutine = libox.coroutine
local active_sandboxes = libox_coroutine.active_sandboxes

local time_limit = 5000        -- 5ms
local editor_time_limit = 1000 -- 1ms

function logic.on_turn_off(pos)
    local meta = M(pos)
    local ID = meta:get_string("ID")
    active_sandboxes[ID] = nil
    logic.send_editor_event(pos, { type = "off" })
end

function logic.turn_off(pos)
    sbz_api.turn_off(pos) -- nah, no special logic needed yet
end

function logic.can_run(pos, meta)
    if libox_coroutine.is_sandbox_dead(meta:get_string("ID")) then
        return true
    else
        active_sandboxes[meta:get_string("ID")] = nil
        logic.send_editor_event(pos, { type = "off" })
        return true
    end
end

function logic.post_run(response)

end

function logic.receives_events(meta)
    return true
end

function logic.turn_on(pos)
    local meta = M(pos)
    if not logic.can_run(pos, meta) then
        minetest.log("Cant run")
        return false
    end
    meta:set_string("error", "")
    local id = libox_coroutine.create_sandbox {
        ID = vector.to_string(pos),
        code = meta:get_string("code"),
        env = logic.get_env(pos, meta),
        time_limit = time_limit,
    }
    meta:set_string("ID", id)
    local ok = logic.send_event_to_sandbox(pos, { type = "program" })
    if not ok then
        return false
    end
    logic.send_editor_event(pos, { type = "on" })
    return id
end

function logic.send_event_to_sandbox(pos, event)
    local meta = M(pos)
    local id = meta:get_string("ID")
    if id == nil then
        id = logic.turn_on(pos)
        if not id then return false end
        meta:set_string("ID", id)
    end
    if not logic.receives_events(meta) then
        return false
    end
    local ok, errmsg = libox_coroutine.run_sandbox(id, event)
    if not ok then
        meta:set_string("error", errmsg)
        logic.turn_off(pos)
        return false
    else
        local value = errmsg
        logic.post_run(value)
        return true
    end
end

function logic.send_editor_event(pos, event)
    local meta = M(pos)
    local ok, errmsg = libox.normal_sandbox {
        code = meta:get_string("editor_code"),
        env = logic.get_editor_env(pos, meta, event),
        max_time = editor_time_limit,
    }
    if not ok then
        meta:set_string("infotext", "Error in editor code:" .. tostring(errmsg))
        return false
    end
    return true
end

function logic.on_receive_fields(pos, formname, fields, sender)
    logic.send_editor_event(pos, {
        fields = fields,
        clicker = sender:get_player_name(),
        type = "gui",
    })
end

function logic.override_editor(pos, code)
    local meta = M(pos)
    meta:set_string("editor_code", code)
    logic.send_editor_event(pos, {
        type = "program"
    })
end

function logic.override_code(pos, code)
    local meta = M(pos)
    meta:set_string("code", code)

    local ID = meta:get_string("ID")
    if not libox_coroutine.is_sandbox_dead(ID) then
        logic.turn_off(pos)
    end
    logic.turn_on(pos)
end

sbz_api.queue:add_function("logic_send_event", logic.send_event_to_sandbox)
sbz_api.queue:add_function("logic_turn_off", logic.turn_off)
sbz_api.queue:add_function("logic_turn_on", logic.turn_on)
