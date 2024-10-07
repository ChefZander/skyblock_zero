local logic = sbz_api.logic

local send_max_cost = 10 * 1024 -- idk 10 kilobytes??

function logic.send_l(pos, thing, from_pos)
    -- used for the luacontroller, dont use anywhere else it wont work
    local msg, cost = libox.digiline_sanitize(thing, false)
    if cost > send_max_cost then
        return false, "Whatever you are sending is way too large"
    end
    local range_allowed = logic.range_check(from_pos, pos)
    if not range_allowed then
        return false, "The position you are sending to is too far away or is protected."
    end

    if not pos.x then
        for _, v in pairs(pos) do
            sbz_api.queue:add_action(v, "logic_send", { msg, from_pos })
        end
    else
        sbz_api.queue:add_action(pos, "logic_send", { msg, from_pos })
    end
    return true
end

function logic.send(pos, thing, from_pos) -- used in logic devices
    local msg = libox.digiline_sanitize(thing, false)
    sbz_api.queue:add_action(pos, "logic_send", { msg, from_pos })
    return true
end

sbz_api.queue:add_function("logic_send", function(pos, msg, from_pos)
    local node_at_pos = (sbz_api.get_node_force(pos) or { name = "Less lines of code" }).name
    local ndef = minetest.registered_nodes[node_at_pos]
    if ndef and ndef.on_logic_send then
        ndef.on_logic_send(pos, msg, from_pos)
    end
end)
