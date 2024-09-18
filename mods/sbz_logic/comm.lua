local logic = sbz_api.logic

local send_max_cost = 10 * 1024 -- idk 10 kilobytes??

function logic.send(pos, thing, from_pos)
    local msg, cost = libox.digiline_sanitize(thing, false)
    if cost > send_max_cost then
        return false, "Whatever you are sending is way too large"
    end

    if pos.x then
        sbz_api.queue:add_action(pos, "logic_send", { msg, vector.subtract(from_pos, pos) })
    elseif pos[1] then
        for _, v in pairs(pos) do
            sbz_api.queue:add_action(pos, "logic_send", { msg, vector.subtract(from_pos, v) })
        end
    end
    return true
end

sbz_api.queue:add_function("logic_send", function(pos, msg, from_pos)
    local node_at_pos = (sbz_api.get_node_force(pos) or { name = "ignore lol" }).name
    local ndef = minetest.registered_nodes[node_at_pos]
    if ndef then
        if ndef.on_logic_send then
            ndef.on_logic_send(pos, msg, from_pos)
        end
    end
end)
