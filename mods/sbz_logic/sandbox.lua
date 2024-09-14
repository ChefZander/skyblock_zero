local logic = sbz_api.logic

local M = minetest.get_meta
local libox_coroutine = libox.coroutine
local active_sandboxes = libox_coroutine.active_sandboxes

local time_limit = 5000        -- 5ms
local editor_time_limit = 1000 -- 1ms
local max_memsize = 1024       -- 1024 serialized characters, just use disks lol


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
        return false, string.format("You stored too much in %s (%s/%s bytes)", name, #serialized_mem, max_memsize)
    else
        return serialized_mem
    end
end

function logic.request_disks_and_mem(meta, env)
    env.mem = minetest.deserialize(meta:get_string("mem"))
    env.disks = {
        by_name = {}
    }

    local inv = meta:get_inventory()
    local disk_list = inv:get_list("disks")

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
                    index = k
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
                    index = k
                }
                env.disks.by_name[node_def.description] = env.disks[k]
            end
        end
    end
end

--[[
    env.disk = {
        [1] = disk def 1..
        [2] = disk def 2..
        ...
        [n] = disk def n..

        by_name = {
            ["hello"] = disk def hello... (= disk def n)
        }
    }
]]

function logic.save_disks_and_mem(meta, env)
    local disk_array = env.disks
    local inv = meta:get_inventory()
    local disk_list = inv:get_list("disks")
    if type(disk_array) ~= "table" then return true end -- by that you chose to not save the disks
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
                    if x == true then return 1 else return 0 end
                end
                stack_meta:set_string('data', serialized_data)
                stack_meta:set_int("override_code", toint(target_disk.punches_code))
                stack_meta:set_int("override_editor", toint(target_disk.punches_editor))
                stack_meta:set_string("description", tostring(target_disk.name))
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
    return true
end

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

function logic.post_run(pos, response)

end

function logic.receives_events(meta)
    return true
end

function logic.turn_on(pos)
    local meta = M(pos)
    if not logic.can_run(pos, meta) then
        return false
    end
    meta:set_string("error", "")

    local mem = minetest.deserialize(meta:get_string("mem"))

    local id = libox_coroutine.create_sandbox {
        ID = vector.to_string(pos),
        code = meta:get_string("code"),
        env = logic.get_env(pos, meta, mem),
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
    if id == nil or libox_coroutine.is_sandbox_dead(id) then
        id = logic.turn_on(pos)
        if not id then return false end
        meta:set_string("ID", id)
    end
    if not logic.receives_events(meta) then
        return false
    end

    -- set mem
    local env = active_sandboxes[id].env
    logic.request_disks_and_mem(meta, env)

    local ok, errmsg = libox_coroutine.run_sandbox(id, event)

    local _, mem_errmsg = logic.save_disks_and_mem(meta, env)

    if not ok or mem_errmsg then
        local used_errmsg = mem_errmsg or errmsg
        meta:set_string("error", used_errmsg)
        logic.turn_off(pos)
        return false
    else
        local value = errmsg
        logic.post_run(pos, value)
        return true
    end
end

-- editor is a different type of sandbox for simplicity
function logic.send_editor_event(pos, event)
    local meta = M(pos)
    local env = logic.get_editor_env(pos, meta, event)

    logic.request_disks_and_mem(meta, env)

    local ok, errmsg = libox.normal_sandbox {
        code = meta:get_string("editor_code"),
        env = env,
        max_time = editor_time_limit,
    }
    local mem_ok, mem_errmsg = logic.save_disks_and_mem(meta, env)

    meta:set_string("infotext", "Luacontroller")
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
