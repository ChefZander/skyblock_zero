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
                meta:set_string(k, v)
            end
        end
    })
end

function logic.get_env(pos, meta)
    local base = libox.create_basic_environment()
    for k, v in pairs {
        editor = get_editor_table(meta),

        pos = vector.copy(pos),
        yield = coroutine.yield,
        wait = function(t)
            local ignored_events = {}
            local e = coroutine.yield({
                type = "wait",
                time = t,
            })
            if e.type == "wait" then return ignored_events end
            while true do
                e = coroutine.yield()
                if e.type ~= "wait" then
                    ignored_events[#ignored_events + 1] = e
                else
                    return ignored_events
                end
            end
        end
    } do
        base[k] = v
    end
    return base
end

local libf = libox.sandbox_lib_f

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
        log = minetest.log,
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
