local logic = sbz_api.logic


local valid_keys = { ["formspec"] = 1, ["editor_code"] = 1, ["code"] = 1, ["error"] = 1 }
local function get_editor_table(meta)
    return setmetatable({}, {
        __index = function(t, k)
            if valid_keys[k] then
                return meta:get_string(k)
            else
                return nil
            end
        end,
        __newindex = function(t, k, v)
            if valid_keys[k] and type(v) == 'string' then
                if #v > 1024 * 10 then
                    error("editor.* metatable speaking here: Value way too large WTF dude!")
                end
                meta:mark_as_private(k) -- hopefully not a client lag generator
                meta:set_string(k, v)
            end
        end
    })
end

local libf = libox.sandbox_lib_f


function logic.get_the_get_node_function(start_pos)
    return libf(function(pos)
        if not libox.type_vector(pos) then
            return false, "Invalid position"
        end
        pos = vector.add(pos, start_pos)
        local range_allowed = logic.range_check(start_pos, pos)
        if not range_allowed then
            return false, "The node you are trying to get is too far away or is protected."
        end
        return minetest.get_node(pos)
    end)
end

function logic.get_env(pos, meta)
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

    for k, v in pairs {
        editor = get_editor_table(meta),

        pos = vector.copy(pos),
        origin = vector.new(0, 0, 0),
        yield = coroutine.yield,
        wait_for_event_type = wait_for_event_type,
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
            return logic.send(logic.add_to_link(send_to_pos, pos), msg, pos)
        end),
        get_node = logic.get_the_get_node_function(pos),
        is_protected = function(rpos, who)
            if not libox.type_vector(rpos) then return false, "Invalid position." end
            local abs_pos = vector.add(rpos, pos)
            return minetest.is_protected(abs_pos, who or meta:get_string("owner"))
        end,
        full_traceback = debug.traceback,
        turn_on = function(rpos)
            if not libox.type_vector(rpos) then return false, "Invalid position." end
            if not sbz_api.is_machine(pos) then return false, "Not a machine." end
            local abs_pos = vector.add(pos, rpos)
            if not logic.range_check(pos, abs_pos) then return false, "Can't turn on that, outside of linking range" end
            return sbz_api.force_turn_on(abs_pos, minetest.get_meta(abs_pos))
        end,
        turn_off = function(rpos)
            if not libox.type_vector(rpos) then return false, "Invalid position." end
            if not sbz_api.is_machine(pos) then return false, "Not a machine." end
            local abs_pos = vector.add(pos, rpos)
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
            -- may not be avaliable, also should not be used if you want to make an independant editors
        end
    end
    for k, v in pairs {
        editor = get_editor_table(meta),
        event = event,
        turn_on = libf(function()
            sbz_api.queue:add_action(pos, "logic_turn_on", {})
        end),
        turn_off = libf(function()
            sbz_api.queue:add_action(pos, "logic_turn_off", {})
        end),
    } do
        base[k] = v
    end

    return base
end
