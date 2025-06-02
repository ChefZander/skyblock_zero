local logic = sbz_api.logic

local M = minetest.get_meta
local libox_coroutine = libox.coroutine
local active_sandboxes = libox_coroutine.active_sandboxes

local time_limit = 10         -- 10ms
local editor_time_limit = 3   -- 3ms
local max_us_per_second = 100 -- 100ms
local max_ram = 400 * 1024    -- 400kb

logic.main_limit = time_limit
logic.editor_limit = editor_time_limit
logic.combined_limit = max_us_per_second
logic.max_ram = max_ram

-- ID to pos and meta
logic.id2pos = {
    -- ["ID1"] = { meta = core.get_meta(pos), pos = pos },
}

function logic.initialize_env(meta, env, pos)
    env.pos = vector.copy(pos)
    env.links = core.deserialize(meta:get_string("links")) or {}
    for _, l in pairs(env.links) do
        for _, p in pairs(l) do -- transform to relative positions
            p.x = p.x - pos.x
            p.y = p.y - pos.y
            p.z = p.z - pos.z
        end
    end
end

function logic.on_turn_off(pos)
    local meta = M(pos)
    meta:set_int("waiting", 0)
    local ID = meta:get_string("ID")
    active_sandboxes[ID] = nil
    logic.id2pos[ID] = nil
    logic.send_editor_event(pos, meta, { type = "off" })
end

function logic.turn_off(pos)
    sbz_api.turn_off(pos) -- nah, no special logic needed yet
end

function logic.can_run(pos, meta, editor, no_off_events)
    if meta:get_int("bill") ~= 0 then
        return false
    end
    if (meta:get_float "microseconds_taken_main_sandbox" + meta:get_float "microseconds_taken_editor_sandbox") > max_us_per_second then
        return false
    end
    if not editor then
        if libox_coroutine.is_sandbox_dead(meta:get_string("ID")) then
            return true
        else
            if not no_off_events then
                active_sandboxes[meta:get_string("ID")] = nil
                logic.send_editor_event(pos, meta, { type = "off" })
                return true
            else
                return true
            end
        end
    end
    return true
end

-- yield logic
-- stuff that happens after the run

---@type function, function
local transport_items = loadfile(minetest.get_modpath("sbz_logic") .. "/item_transport.lua")()

logic.post_runs = {
    ["wait"] = {
        typedef = {
            time = function(n)
                if libox.type("number")(n) == false then return false end
                if n < 0 then return false end
                return true
            end,
        },
        f = function(pos, response, ID)
            local meta = M(pos)
            if meta:get_int("waiting") == 0 then -- only one wait at a time
                meta:set_int("waiting", 1)
                sbz_api.queue:add_action(pos, "logic_wait", { ID }, response.time)
            end
        end
    },
    ["transport_items"] = {
        typedef = {
            type = libox.type("string"),
            from = libox.type("table"),
            to = libox.type("table"),
            filters = libox.type("table"),
            direction = function(x) return x == nil or libox.type_vector(x) end,
        },
        f = transport_items,
    },
}

function logic.is_on(pos)
    return not libox_coroutine.is_sandbox_dead(M(pos):get_string("ID"))
end

function logic.post_run(pos, response, ID)
    if type(response) == "string" then
        response = {
            type = response
        }
    end
    if type(response) ~= "table" then
        return
    end
    if type(response.type) ~= "string" then
        return
    end

    if logic.post_runs[response.type] then
        local post_run = logic.post_runs[response.type]
        local typedef = post_run.typedef
        typedef.type = libox.type("string")
        local ok, errmsg = libox.type_check(response, typedef)
        if ok then
            post_run.f(pos, response, ID)
        end
    end
end

logic.non_trigger_events = {
    ["gui"] = true,
    ["wait"] = true,
    ["tick"] = true,
    ["subtick"] = true,
    ["error"] = true,
}

function logic.receives_events(pos, event)
    if type(event) == "table" then
        local event_type = event.type
        if logic.non_trigger_events[event_type] == true and not logic.is_on(pos) then
            return false
        end
    end
    return true
end

local BYTE_A, BYTE_Z = string.byte("A"), string.byte("Z")
local function generate_id()
    local out = {}
    for _ = 1, 20 do                                             -- 1 in krillion chance that it somehow collides
        out[#out + 1] = string.char(math.random(BYTE_A, BYTE_Z)) -- [A-Z]
    end
    return table.concat(out)
end

function logic.turn_on(pos)
    logic.log("Turned on: " .. vector.to_string(pos))
    local meta = M(pos)
    if not logic.can_run(pos, meta) then
        return false
    end

    meta:set_string("error", "")
    meta:mark_as_private("code")

    local id = generate_id()
    id = libox_coroutine.create_sandbox {
        ID = id,
        code = meta:get_string("code"),
        env = logic.get_env(pos, meta, id),
        size_limit = max_ram,
        time_limit = time_limit,
        autohook = true,
        in_hook = function()
            local clock = os.clock
            local t0 = clock()
            local limit = time_limit / 1000
            return function()
                if clock() - t0 > limit then
                    debug.sethook()
                    error("Code timed out! Reason: Time limit exceeded, the limit:" ..
                        tostring(limit * 1000) ..
                        "ms, the program took:" .. tostring(math.floor((clock() - t0) * 1000)) .. "ms",
                        2)
                end
            end
        end,
    }
    meta:set_string("ID", id)
    meta:mark_as_private("ID")
    local ok = logic.send_event_to_sandbox(pos, { type = "program" })

    if not ok then
        return false
    end
    logic.send_editor_event(pos, meta, { type = "on" })
    return id
end

function logic.send_event_to_sandbox(pos, event)
    logic.log("Sent event to: " .. vector.to_string(pos))
    local t0 = sbz_api.clock_ms()

    local meta = M(pos)
    if not logic.receives_events(pos, event) then
        return false
    end

    if not logic.can_run(pos, meta, false, true) then
        return false
    end

    local id = meta:get_string("ID")
    if id == nil or libox_coroutine.is_sandbox_dead(id) then
        id = logic.turn_on(pos)
        if not id then return false end
        meta:set_string("ID", id)
    end
    logic.id2pos[id] = { pos = pos, meta = meta }

    local env = active_sandboxes[id].env
    logic.initialize_env(meta, env, pos)

    local ok, errmsg = libox_coroutine.run_sandbox(id, event)

    meta:set_float("microseconds_taken_main_sandbox",
        meta:get_float("microseconds_taken_main_sandbox") + (sbz_api.clock_ms() - t0))

    -- Keep this running
    meta:set_int("force_off", 0)

    if not ok then
        meta:set_string("error", errmsg)
        meta:mark_as_private("error")
        logic.turn_off(pos)
        return false
    else
        local value = errmsg
        logic.post_run(pos, value, id)

        -- send back to the editor
        -- editor gui event already handled before main sandbox.
        if type(event) ~= "gui" then
            logic.send_editor_event(pos, meta, { type = "ran" })
        end
        return true
    end
end

-- editor is a different type of sandbox for simplicity
function logic.send_editor_event(pos, meta, event)
    logic.log("Editor event: " .. vector.to_string(pos))
    local t0 = sbz_api.clock_ms()

    if not logic.can_run(pos, meta, true) then
        return false
    end

    local env = logic.get_editor_env(pos, meta, event)
    logic.initialize_env(meta, env, pos)

    meta:mark_as_private("editor_code")
    local ok, errmsg = libox.normal_sandbox {
        code = meta:get_string("editor_code"),
        env = env,
        max_time = editor_time_limit * 1000,
    }

    -- Keep this running
    meta:set_int("force_off", 0)

    meta:set_float("microseconds_taken_editor_sandbox",
        meta:get_float("microseconds_taken_editor_sandbox") + (sbz_api.clock_ms() - t0))

    if not ok then
        meta:set_string("infotext", "Error in editor code:" .. tostring(errmsg))
        return false
    end
    return true
end

function logic.on_receive_fields(pos, formname, fields, sender)
    local ev = {
        fields = fields,
        clicker = sender:get_player_name(),
        type = "gui",
    }
    logic.send_editor_event(pos, M(pos), ev)
    if logic.is_on(pos) then
        logic.send_event_to_sandbox(pos, ev)
    end
end

function logic.override_editor(pos, code)
    local meta = M(pos)
    meta:set_string("editor_code", code)
    logic.send_editor_event(pos, meta, {
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
sbz_api.queue:add_function("logic_wait", function(_, ID)
    local posdata = logic.id2pos[ID]
    if posdata then
        posdata.meta:set_int("waiting", 0)
        logic.send_event_to_sandbox(posdata.pos, {
            type = "wait",
        })
    end
end)

sbz_api.queue:add_function("logic_turn_off", logic.turn_off)
sbz_api.queue:add_function("logic_turn_on", logic.turn_on)


function logic.calculate_bill(us_taken_main, us_taken_editor)
    return math.ceil((us_taken_main + us_taken_editor)) * 4
end

-- switching station action
function logic.on_tick(pos, node, meta, supply, demand)
    local old_bill = meta:get_int("bill")
    if old_bill ~= 0 then
        local bill = old_bill
        local result = math.max(0, bill - (supply - demand))
        meta:set_int("bill", result)
        return math.max(0, meta:get_int("bill") - result)
    end

    local us_taken_main = meta:get_float("microseconds_taken_main_sandbox")
    local us_taken_editor = meta:get_float("microseconds_taken_editor_sandbox")

    local bill = logic.calculate_bill(us_taken_main, us_taken_editor)

    local net = supply - demand
    local return_value

    if net < bill then -- bill needs to get paid over multiple ticks, that means that your luacontroller will also not work (no editor too)
        local result = math.max(0, bill - net)
        meta:set_int("bill", result)
        return_value = math.max(0, meta:get_int("bill") - result)
    else
        meta:set_int("bill", 0)
        return_value = bill
    end
    local function format_lag(x)
        return tostring(math.floor(x)) .. "ms"
    end
    meta:set_string("infotext",
        string.format("Editor lag: %s\nMain sandbox lag: %s\nCombined: %s\nBill: %s Cj\nCan run: %s",
            format_lag(us_taken_editor), format_lag(us_taken_main), format_lag(us_taken_editor + us_taken_main), bill,
            logic.can_run(pos, meta, true) and "yes" or
            "no (didn't pay bill or used more than 100ms)"))

    meta:set_float("microseconds_taken_main_sandbox", 0)
    meta:set_float("microseconds_taken_editor_sandbox", 0)

    logic.send_event_to_sandbox(pos, { type = "tick", supply = supply, demand = demand })

    return return_value
end
