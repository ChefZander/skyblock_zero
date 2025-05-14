sbz_api.register_stateful("sbz_power:delayer", unifieddyes.def {
    description = "Delayer",
    info_extra = "It is not a machine, but conducts power",
    tiles = {
        sbz_api.make_sensor_tex_off("delayer")
    },
    paramtype2 = "color",
    groups = { matter = 1, state_change_no_swap = 1, pipe_conducts = 1, },
    on_construct = function(pos)
        local meta = core.get_meta(pos)
        meta:set_float("delayer_time", 2)
        meta:set_string("formspec", [[
        formspec_version[7]
        field[delayer_time;Time:;${delayer_time}]
    ]])
        meta:set_int("delayer_state", 0)
    end,
    on_receive_fields = function(pos, _, fields, sender)
        local delayer_time = fields.delayer_time
        if delayer_time then
            delayer_time = tonumber(delayer_time)
            if not delayer_time then return end
            delayer_time = math.abs(delayer_time) -- can be zero
            core.get_meta(pos):set_float("delayer_time", delayer_time)
            core.get_node_timer(pos):stop()
        end
    end,
    on_turn_on = function(pos)
        local timer = core.get_node_timer(pos)
        local meta = core.get_meta(pos)
        local is_started = timer:is_started()
        if is_started or sbz_api.is_on(pos) then return end
        timer:start(meta:get_float("delayer_time"))
        meta:set_int("new_state", 1)
    end,
    on_turn_off = function(pos)
        local timer = core.get_node_timer(pos)
        local meta = core.get_meta(pos)
        local is_started = timer:is_started()

        if is_started or not sbz_api.is_on(pos) then return end
        timer:start(meta:get_float("delayer_time"))
        meta:set_int("new_state", 0)
    end,
    on_timer = function(pos, elapsed)
        local meta = core.get_meta(pos)
        local new_state = meta:get_int("new_state")
        -- NEEDS to skip on_turn_* callbacks
        if new_state == 1 then
            core.swap_node(pos, { name = "sbz_power:delayer_on" })
        elseif new_state == 0 then
            core.swap_node(pos, { name = "sbz_power:delayer_off" })
        end
        meta:set_int("new_state", 0)
        return false
    end,
    on_logic_send = function(pos, msg, from_pos)
        if type(msg) ~= "number" then return end
        local delayer_time = msg
        delayer_time = math.abs(delayer_time)
        core.get_meta(pos):set_float("delayer_time", delayer_time)
        core.get_node_timer(pos):stop()
    end,
}, {
    light_source = 14,
    tiles = {
        sbz_api.make_sensor_tex_on("delayer")
    },

})
