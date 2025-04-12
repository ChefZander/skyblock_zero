sbz_api.multiblocks = {}
local multiblocks = sbz_api.multiblocks


function multiblocks.register_multiblock(def)

end

-- validate and link
--[[
schem format:
{
    data = {[pos] = name|function},
    categories = {
        [name] = {
            [name] = true,
            [name2] = true,
        }
    },
    limits = {
        [name] = { min = , max = }
    },
    item_input = <name>,
    item_output = <name>,
    power_input = <name>,
}

returns:
{
    success = false,
    errmsg = "poo poo"
}
OR
{
    success = true,

    item_input = <pos>|nil,
    item_output = <pos>|nil,
    power_port = <pos>,
}
]]
local uh = core.get_position_from_hash
local h = core.hash_node_position
function multiblocks.form_multiblock(pos, schem)
    local schemdata = schem.data
    local returns = {
        success = true
    }

    local limits = {}
    local category_funcs = {} -- cache them cuz why not :D

    for hpos, node_match in pairs(schemdata) do
        local ipos = vector.add(pos, uh(hpos))
        local node = sbz_api.get_node_force(ipos)
        if not node then
            return {
                success = false,
                errmsg =
                "Congratulations! You got a very rare error, are you proud of yourself... for trying to form a multiblock in un-generated terrain/world border hoping it would crash the game"
            }
        end
        if schem.categories[node_match] then
            if category_funcs[node_match] then
                node_match = category_funcs[node_match]
            else
                local old_node_match = node_match
                category_funcs[node_match] = function(pos_, node_)
                    return schem.categories[old_node_match][node_.name]
                end
                node_match = category_funcs[node_match]
            end
        end

        local matches = false
        if type(node_match) == "string" then
            matches = node_match == node.name
        elseif type(node_match) == "function" then
            matches = node_match(ipos, node)
        end
        if not matches then
            local error_specifics = "??"
            if type(node_match) == "string" then
                error_specifics = "At the position: " ..
                    vector.to_string(ipos) .. " there should have been a node with technical name of \"" .. node_match ..
                    "\", but you placed \"" .. node.name .. "\" instead"
            else
                error_specifics = "At the position: " ..
                    vector.to_string(ipos) ..
                    " you got something wrong. Read the manual for instructions on how to build the multiblock."
            end
            return {
                success = false,
                errmsg = [[Multiblock not complete! ]] .. error_specifics
            }
        end
        if node.name == schem.item_input then
            returns.item_input = ipos
        end
        if node.name == schem.item_output then
            returns.item_output = ipos
        end
        if node.name == schem.power_port then
            returns.power_port = ipos
        end
        if schem.limits[node.name] then
            limits[node.name] = (limits[node.name] or 0) + 1
        end
        -- if it can't wallshare check if its occupied
        if core.get_item_group(node.name, "wallsharing") ~= 1 then
            local meta = core.get_meta(ipos)
            local controller_pos = vector.from_string(meta:get_string("controller_pos"))
            if controller_pos and core.hash_node_position(controller_pos) ~= core.hash_node_position(ipos) then
                return {
                    success = false,
                    errmsg = "Cannot wallshare with " .. node.name .. ", other controller is at " ..
                        vector.to_string(controller_pos) .. ", problematic position: " .. vector.to_string(ipos)
                }
            end
        end
    end

    -- great... now lets check the limits
    for name, limit in pairs(schem.limits) do
        if (limits[name] or 0) < limit.min then
            return {
                success = false,
                errmsg = "You have to have at least " .. limit.min .. " node(s) of " .. name
            }
        elseif (limits[name] or 0) > limit.max then
            return {
                success = false,
                errmsg = "You can only have " .. limit.max .. " node(s) of " .. name
            }
        end
    end
    -- now... actually link it
    for hpos in pairs(schemdata) do
        local ipos = vector.add(pos, uh(hpos))
        local node = sbz_api.get_node_force(ipos) or {}
        local meta = core.get_meta(ipos)
        if core.get_item_group(node.name, "wallsharing") == 1 then
            local controller_positions = core.deserialize(meta:get_string("controller_positions")) or {}
            controller_positions[#controller_positions + 1] = pos
            meta:set_string("controller_positions", core.serialize(controller_positions))
        else
            meta:set_string("controller_pos", vector.to_string(pos))
        end
    end
    return returns
end

function multiblocks.break_multiblock(pos, schem)
    for hpos in pairs(schem.data) do
        local ipos = vector.add(pos, uh(hpos))
        local node = sbz_api.get_node_force(ipos) or {}
        local meta = core.get_meta(ipos)
        if core.get_item_group(node.name, "wallsharing") == 1 then
            local controller_positions = core.deserialize(meta:get_string("controller_positions")) or {}
            for k, v in ipairs(controller_positions) do
                if h(v) == h(pos) then
                    table.remove(controller_positions, k)
                end
            end
            meta:set_string("controller_positions", core.serialize(controller_positions))
        else
            meta:set_string("controller_pos", "")
        end
        if core.get_item_group(node.name, "multiblock_controller") == 1 then
            core.registered_nodes[node.name].on_multiblock_break(pos, meta)
        end
    end
end

function multiblocks.after_dig(pos, oldnode, oldmeta, digger)
    local controller_positions = core.deserialize(oldmeta.fields.controller_positions or "")
    local controller_pos = vector.from_string(oldmeta.fields.controller_pos or "")
    if controller_positions then
        for _, cpos in pairs(controller_positions) do
            local cnode = sbz_api.get_node_force(cpos)

            if cnode then
                local cdef = core.registered_nodes[cnode.name]
                if cdef.get_schematic then
                    local schem = cdef.get_schematic(cpos, oldmeta)
                    multiblocks.break_multiblock(cpos, schem)
                end
            end
        end
    elseif controller_pos then
        local cnode = sbz_api.get_node_force(controller_pos)
        if cnode then
            local cdef = core.registered_nodes[cnode.name]
            if cdef.get_schematic then
                local schem = cdef.get_schematic(controller_pos, oldmeta)
                multiblocks.break_multiblock(controller_pos, schem)
            end
        end
    end
end

function multiblocks.before_movenode(from_pos, to_pos)
    local meta = core.get_meta(from_pos)
    multiblocks.after_dig(_, _, meta:to_table(), _)
end

local mp = core.get_modpath(core.get_current_modname())
dofile(mp .. "/visuals.lua")

dofile(mp .. "/blast_furnace.lua")
