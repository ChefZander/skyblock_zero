-- light, node type

-- i hope its performant at least a little bit
local function basic_ish_switch(n, ...)
    local args = { ... }
    return args[n]
end

--[[
ok.. so...
Operations by their "index":
1: <
2: >
3: =
4: <=
5: >=
]]

local operations_by_index = {
    [1] = "<",
    [2] = ">",
    [3] = "=",
    [4] = "<=",
    [5] = ">=",
}
local index_by_operations = table.key_value_swap(table.copy(operations_by_index))

local function get_light_sensor_formspec(pos, meta)
    local operation = meta:get_int("operation")
    if operation == 0 then operation = 1 end
    return ([[
    formspec_version[7]
size[5,2]
hypertext[0.5,0.75;2,0.5;;<b>Light level</b>]
style[operation;font=mono,bold]
button[2.2,0.55;0.75,0.75;operation;%s]

style_type[field;font=mono]
field_close_on_enter[light_level;false]
field_enter_after_edit[light_level;true]
field[3.2,0.55;0.75,0.75;light_level;;%s]

button[4,1.5;1,0.5;save;Save]
]]):format(operations_by_index[operation], meta:get_int("light_level"))
end

sbz_api.register_stateful_machine("sbz_power:light_sensor", unifieddyes.def {
    description = "Light Sensor",
    info_extra = "Doesn't emit light when turned on",
    tiles = {
        sbz_api.make_sensor_tex_off("light_sensor")
    },
    paramtype2 = "colorfacedir",
    can_sensor_link = true,
    groups = { matter = 1, sbz_machine_subticking = 1 },
    action = function() return 0 end,
    linking_range = 4,
    on_construct = function(pos)
        local meta = core.get_meta(pos)
        meta:set_string("formspec", get_light_sensor_formspec(pos, meta))
    end,
    on_receive_fields = function(pos, _, fields, sender) -- why give me _ when i cant use it
        local meta = core.get_meta(pos)
        local name = sender:get_player_name()
        if fields.light_level then
            local light_level = tonumber(fields.light_level)
            if not light_level or core.is_nan(light_level) then
                return sbz_api.displayDialogLine(name, "Light level needs to be a number")
            end
            if light_level < 0 then return sbz_api.displayDialogLine(name, "Light level needs to be above zero.") end
            if light_level > 14 then return sbz_api.displayDialogLine(name, "Light level needs to be below 14.") end
            light_level = math.floor(light_level)
            meta:set_int("light_level", light_level)
        end
        if fields.operation then
            local operation = fields.operation
            local index = index_by_operations[operation]
            if not index then return sbz_api.displayDialogLine(name, "You hacker you") end
            local new_index = index + 1
            local new_operation = operations_by_index[new_index]
            if not new_operation then
                new_index = 1
                new_operation = operations_by_index[1]
            end
            meta:set_int("operation", new_index)
        end
        meta:set_string("formspec", get_light_sensor_formspec(pos, meta))
    end,
    action_subtick = function(pos, _, meta)
        meta:set_string("infotext", "")
        local links = core.deserialize(meta:get_string("links"))
        local links_errmsg = "Light sensor needs an \"A\" link, that link is the target node."
        if not links then
            meta:set_string("infotext", links_errmsg)
            return 0
        end
        if not links.A or (links.A and not links.A[1]) then
            meta:set_string("infotext", links_errmsg)
            return 0
        end
        local compare_light_level = meta:get_int("light_level")
        local operation = meta:get_int("operation"); if operation == 0 then operation = 1 end
        local light_level = core.get_node_light(links.A[1], 0)

        -- you know... i could leave this without any comments so that you struggle to figure out what it does... yeah i will do that
        -- have fun
        local state = basic_ish_switch(operation,
            light_level < compare_light_level,
            light_level > compare_light_level,
            light_level == compare_light_level,
            light_level <= compare_light_level,
            light_level >= compare_light_level
        )

        if state then
            sbz_api.turn_on(pos)
        else
            sbz_api.turn_off(pos)
        end
        return 1
    end,
    on_logic_send = function(pos, msg, from_pos)
        local meta = core.get_meta(pos)
        if type(msg) == "table" then
            local light_level = msg.light_level
            local operation = msg.operation

            if light_level and type(light_level) == "number" then
                light_level = math.min(14, math.max(0, math.floor(tonumber(msg.light_level) or 0)))
                meta:set_int("light_level", light_level)
            end
            if operation and type(operation) == "string" then
                local index = index_by_operations[operation]
                if index then
                    meta:set_int("operation", index)
                end
            end
            meta:set_string("formspec", get_light_sensor_formspec(pos, meta))
        end
    end
}, {
    light_source = 0, -- so it doesn't actually emit light
    tiles = {
        sbz_api.make_sensor_tex_on("light_sensor")
    }
})

local function get_node_sensor_formspec(pos, meta)
    return ([[
formspec_version[7]
size[8,2]
hypertext[0.5,0.75;2,0.5;;<b>Node Type</b>]
hypertext[2.2,0.75;0.75,0.75;;<b><mono>==</mono></b>]

style_type[field;font=mono]
field_close_on_enter[node_type;false]
field_enter_after_edit[node_type;true]
field[2.8,0.55;4.75,0.75;node_type;;%s]

button[7,1.5;1,0.5;save;Save]
]]):format(meta:get_string("node_type"))
end
-- NODE SENSOR
sbz_api.register_stateful_machine("sbz_power:node_sensor", unifieddyes.def {
    description = "Node Sensor",
    tiles = {
        sbz_api.make_sensor_tex_off("node_detector")
    },
    paramtype2 = "colorfacedir",
    can_sensor_link = true,
    groups = { matter = 1, sbz_machine_subticking = 1 },
    action = function() return 0 end,
    linking_range = 4,
    on_construct = function(pos)
        local meta = core.get_meta(pos)
        meta:set_string("formspec", get_node_sensor_formspec(pos, meta))
    end,
    on_receive_fields = function(pos, _, fields, sender) -- why give me _ when i cant use it
        if fields.node_type then
            local meta = core.get_meta(pos)
            local name = sender:get_player_name()

            local node_type = tostring(fields.node_type)
            local node_def = core.registered_nodes[node_type]
            if not node_def then
                return sbz_api.displayDialogLine(name,
                    "Needs to be a known node name, usually in format of my_mod:my_node")
            end
            meta:set_string("node_type", node_type)
            meta:set_string("formspec", get_node_sensor_formspec(pos, meta))
        end
    end,
    action_subtick = function(pos, _, meta)
        meta:set_string("infotext", "")
        local links = core.deserialize(meta:get_string("links"))
        local links_errmsg = "Node sensor needs an \"A\" link, that link is the target node."
        if not links then
            meta:set_string("infotext", links_errmsg)
            return 0
        end
        if not links.A or (links.A and not links.A[1]) then
            meta:set_string("infotext", links_errmsg)
            return 0
        end

        local node = sbz_api.get_or_load_node(links.A[1])
        local state = node.name == meta:get_string("node_type")

        if state then
            sbz_api.turn_on(pos)
        else
            sbz_api.turn_off(pos)
        end
        return 1
    end,
    on_logic_send = function(pos, msg, from_pos)
        local meta = core.get_meta(pos)
        if type(msg) == "string" then
            meta:set_string("node_type", msg)
            meta:set_string("formspec", get_node_sensor_formspec(pos, meta))
        end
    end
}, {
    light_source = 14,
    tiles = {
        sbz_api.make_sensor_tex_on("node_detector")
    }
})
