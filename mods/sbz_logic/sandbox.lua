local logic = sbz_api.logic

local M = minetest.get_meta
local libox_coroutine = libox.coroutine
local active_sandboxes = libox_coroutine.active_sandboxes

local time_limit = 10 * 1000         --ms
local editor_time_limit = 3000       -- ms
local max_memsize = 1024             -- 1024 serialized characters, just use disks lol
local max_us_per_second = 100 * 1000 -- 100 milis
local max_ram = 400 * 1024

logic.main_limit, logic.editor_limit, logic.mem_size, logic.combined_limit = time_limit, editor_time_limit, max_memsize,
    max_us_per_second
logic.max_ram = max_ram

-- ID to pos and meta
logic.id2pos = {
    -- ["ID1"] = { meta = core.get_meta(pos), pos = pos },
}

-- from mesecons - https://github.com/minetest-mods/mesecons/blob/master/mesecons_luacontroller/init.lua - heavily edited
local function make_safe(x)
    local function is_allowed(_x)
        local tp = type(_x)
        -- since mod security exists, we CANNOT serialize functions
        if tp == "function" or tp == "userdata" or tp == "thread" then
            return false
        else
            return true
        end
    end

    if not is_allowed(x) then
        return nil
    end

    local seen = {}

    local function rfuncs(x)
        if x == nil then return end
        if seen[x] then return end
        seen[x] = true
        if type(x) ~= "table" then return end

        for key, value in pairs(x) do
            if not (is_allowed(key) and is_allowed(value)) then
                x[key] = nil
            else
                if type(key) == "table" then
                    rfuncs(key)
                end
                if type(value) == "table" then
                    rfuncs(value)
                end
            end
        end
    end

    rfuncs(x)

    return x
end

function logic.serialize_mem(mem, max, name)
    if not name then name = "the mem table" end
    local safe_mem = make_safe(mem)
    local serialized_mem = minetest.serialize(safe_mem)
    if #serialized_mem > max then
        return false, string.format("You stored too much in %s (%s/%s bytes)", name, #serialized_mem, max)
    else
        return serialized_mem
    end
end

function logic.initialize_env(meta, env, pos)
    env.mem = minetest.deserialize(meta:get_string("mem")) or {}
    env.disks = {
        by_name = {}
    }

    local inv = meta:get_inventory()
    local disk_list = inv:get_list("disks") or {}

    table.sort(disk_list, function(x, y)
        x = x:is_empty()
        y = y:is_empty()
        return x == false and y == true
    end)

    for k, v in ipairs(disk_list) do
        local stack_name = v:get_name()
        if stack_name ~= "" then
            if minetest.get_item_group(stack_name, "sbz_disk_immutable") == 0 then
                local stack_meta = v:get_meta()
                env.disks[k] = {
                    immutable = false,
                    data = minetest.deserialize(stack_meta:get_string("data")),
                    punches_code = stack_meta:get_int("override_code") == 1,
                    punches_editor = stack_meta:get_int("override_editor") == 1,
                    name = stack_meta:get_string("description"),
                    index = k,
                    max = minetest.registered_craftitems[stack_name].can_hold
                }
                env.disks.by_name[stack_meta:get_string("description")] = env.disks[k]
            else
                local node_def = minetest.registered_craftitems[stack_name]
                env.disks[k] = {
                    immutable = true, -- this just means it won't save, it has no way to
                    data = node_def.source,
                    punches_code = node_def.punches_code,
                    punches_editor = node_def.punches_editor,
                    name = node_def.description,
                    index = k,
                }
                env.disks.by_name[node_def.description] = env.disks[k]
            end
        end
    end
    env.links = minetest.deserialize(meta:get_string("links")) or {}
    for k, v in pairs(env.links) do
        for k, v in pairs(v) do -- transform to relative positions
            v.x = v.x - pos.x
            v.y = v.y - pos.y
            v.z = v.z - pos.z
        end
    end
    env.pos = vector.copy(pos)
end

function logic.save_disks_and_mem(meta, env)
    meta:set_int("force_off", 0)
    local disk_array = env.disks
    local inv = meta:get_inventory()
    local disk_list = inv:get_list("disks") or {}

    if type(disk_array) ~= "table" then return true end -- by that you chose to not save the disks.. and memory... yea, dont do that lol
    for k, v in ipairs(disk_list) do
        local stack_name = v:get_name()
        if stack_name ~= "" then
            if minetest.get_item_group(stack_name, "sbz_disk_immutable") == 0 then -- we don't care about immutable disks
                local stack_meta = v:get_meta()
                local desc = stack_meta:get_string("description")
                local max = minetest.registered_craftitems[stack_name].can_hold
                local target_disk = disk_array[k]
                if type(target_disk) ~= "table" then -- you erased it
                    target_disk = { data = "" }
                end
                local data = target_disk.data
                local serialized_data, errmsg = logic.serialize_mem(data, max,
                    string.format("a disk with the name \"%s\"", desc))
                if errmsg then
                    return false, errmsg
                end
                local function toint(x)
                    if x then return 1 else return 0 end
                end

                stack_meta:set_string('data', serialized_data)
                stack_meta:set_int("override_code", toint(target_disk.punches_code))
                stack_meta:set_int("override_editor", toint(target_disk.punches_editor))
                stack_meta:set_string("description", tostring(target_disk.name) or "")
                inv:set_stack("disks", k, v)
            end
        end
    end

    local mem = env.mem
    local serialized_mem, errmsg = logic.serialize_mem(mem, max_memsize)
    if errmsg then
        meta:set_string('mem', minetest.serialize({}))
        return false, errmsg
    end
    meta:set_string('mem', serialized_mem)
    meta:mark_as_private("mem")
    return true
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

function logic.can_run(pos, meta, editor)
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
            active_sandboxes[meta:get_string("ID")] = nil
            logic.send_editor_event(pos, meta, { type = "off" })
            return true
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
    }
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
        time_limit = time_limit,
        size_limit = max_ram,
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
    local t0 = minetest.get_us_time()

    local meta = M(pos)
    if not logic.receives_events(pos, event) then
        return false
    end

    local id = meta:get_string("ID")
    if id == nil or libox_coroutine.is_sandbox_dead(id) then
        id = logic.turn_on(pos)
        if not id then return false end
        meta:set_string("ID", id)
    end
    logic.id2pos[id] = { pos = pos, meta = meta }
    -- set mem
    local env = active_sandboxes[id].env
    logic.initialize_env(meta, env, pos)

    local ok, errmsg = libox_coroutine.run_sandbox(id, event)
    meta:set_float("microseconds_taken_main_sandbox",
        meta:get_float("microseconds_taken_main_sandbox") + (minetest.get_us_time() - t0))

    local _, mem_errmsg = logic.save_disks_and_mem(meta, env)

    if not ok or mem_errmsg then
        local used_errmsg = mem_errmsg or errmsg
        meta:set_string("error", used_errmsg)
        meta:mark_as_private("error")
        logic.turn_off(pos)
        return false
    else
        local value = errmsg
        logic.post_run(pos, value, id)
        -- send back to the editor
        if type(event) ~= "gui" then
            logic.send_editor_event(pos, meta, { type = "ran" })
        end
        return true
    end
end

-- editor is a different type of sandbox for simplicity
function logic.send_editor_event(pos, meta, event)
    local t0 = minetest.get_us_time()

    if not logic.can_run(pos, meta, true) then
        return false
    end
    local env = logic.get_editor_env(pos, meta, event)

    logic.initialize_env(meta, env, pos)
    meta:mark_as_private("editor_code")
    local ok, errmsg = libox.normal_sandbox {
        code = meta:get_string("editor_code"),
        env = env,
        max_time = editor_time_limit,
    }
    local mem_ok, mem_errmsg = logic.save_disks_and_mem(meta, env)

    meta:set_float("microseconds_taken_editor_sandbox",
        meta:get_float("microseconds_taken_editor_sandbox") + (minetest.get_us_time() - t0))

    if not mem_ok then
        meta:set_string("infotext", "Error in editor code:" .. mem_errmsg)
        return false
    end

    if not ok then
        meta:set_string("infotext", "Error in editor code:" .. tostring(mem_errmsg or errmsg))
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
    return math.ceil((us_taken_main + us_taken_editor) / 1000) * 4
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
    local function format_us(x)
        return tostring(math.floor(x / 1000)) .. "ms"
    end
    meta:set_string("infotext",
        string.format("Editor lag: %s\nMain sandbox lag: %s\nCombined: %s\nBill: %s Cj\nCan run: %s",
            format_us(us_taken_editor), format_us(us_taken_main), format_us(us_taken_editor + us_taken_main), bill,
            logic.can_run(pos, meta, true) and "yes" or
            "no (probably hasn't paid the bill? or you used more than 100 miliseconds)"))

    meta:set_float("microseconds_taken_main_sandbox", 0)
    meta:set_float("microseconds_taken_editor_sandbox", 0)

    logic.send_event_to_sandbox(pos, { type = "tick", supply = supply, demand = demand })

    return return_value
end
