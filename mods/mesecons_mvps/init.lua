sbz_api.mvps_stoppers = {}
sbz_api.on_mvps_move = {}

-- NOT ENTIRELY COMPATIBLE
-- because the way sbz does things is posA => posB
-- code is based off of mesecons, thus licensed under LGPLv3

mesecon = {
    mvps_unmov = {},
    mvps_kill = {},
}

--- Objects (entities) that cannot be moved
function mesecon.register_mvps_unmov(objectname)
    mesecon.mvps_unmov[objectname] = true;
end

function mesecon.is_mvps_unmov(objectname)
    return mesecon.mvps_unmov[objectname or ""]
end

function mesecon.register_mvps_kill(objectname)
    mesecon.mvps_kill[objectname] = true;
end

function mesecon.is_mvps_kill(objectname)
    return mesecon.mvps_kill[objectname or ""]
end

function mesecon.is_mvps_stopper(node, oldpos, pos)
    local stopper = sbz_api.mvps_stoppers[node.name]
    if type(stopper) == "function" then
        stopper = stopper(pos, oldpos, node) -- breaking...
    end

    return stopper
end

function mesecon.register_mvps_stopper(nodename, get_stopper)
    if get_stopper == nil then
        get_stopper = true
    end
    sbz_api.mvps_stoppers[nodename] = get_stopper
end

function mesecon.register_on_mvps_move(callback)
    sbz_api.on_mvps_move[#sbz_api.on_mvps_move + 1] = callback
end

local function on_mvps_move(moved_nodes)
    for _, callback in ipairs(sbz_api.on_mvps_move) do
        callback(moved_nodes)
    end
end

sbz_api.move_node = function(A, B)
    for k, v in pairs(sbz_api.all_caches) do
        local expires = v.expire_on_jump_or_move
        if expires then
            v.data = {}
            v.timer = 0
        end
    end

    sbz_api.vm_begin()
    local nodeA = sbz_api.get_or_load_node(A)
    local nodeAdef = core.registered_nodes[nodeA]

    if not nodeAdef then return false end
    if mesecon.is_mvps_stopper(nodeA, A, B) then
        return false
    end

    local nodeB = sbz_api.get_or_load_node(B)
    local nodeBdef = minetest.registered_nodes[nodeB.name]
    if not nodeBdef then
        return false
    end

    if nodeBdef.buildable_to == false then
        return false
    end
    if nodeAdef.before_movenode then
        nodeAdef.before_movenode(A, B)
    end

    local nodeAmeta = core.get_meta(A)
    local nodeAtimer = core.get_node_timer(A)

    core.set_node(B, nodeA)
    local nodeBmeta = core.get_meta(B)
    nodeBmeta:from_table(nodeAmeta:to_table())
    if nodeAtimer:is_started() then
        core.get_node_timer(B):set(nodeAtimer:get_timeout(), nodeAtimer:get_elapsed())
    end
    core.remove_node(A)

    local objects = core.get_objects_inside_radius(A, 1.5) -- TODO: **WAIT** for luanti to have more sane get_objects_inside_radius, then remove this comment saying: THIS IS LAGGY
    for id, obj in pairs(objects) do
        local pos = obj:get_pos()
        local luaentity = obj:get_luaentity() or {}
        if mesecon.is_mvps_kill(luaentity.name) then
            obj:remove()
        elseif not mesecon.is_mvps_unmov(luaentity.name) then
            obj:set_pos((vector.copy(pos) - vector.copy(A)) + vector.copy(B))
        end
    end

    on_mvps_move({
        {
            oldpos = A,
            pos = B,
            node = nodeA,
        }
    })
end

-- Never push into unloaded blocks. Don’t try to pull from them, either.
mesecon.register_mvps_stopper("ignore")
mesecon.register_on_mvps_move(function(moved_nodes)
    if #moved_nodes == 1 then
        for i = 1, #moved_nodes do
            local moved_node = moved_nodes[i]
            minetest.after(0, function()
                minetest.check_for_falling(moved_node.oldpos)
                minetest.check_for_falling(moved_node.pos)
            end)
            local node_def = minetest.registered_nodes[moved_node.node.name]
            if node_def and node_def.mesecon and node_def.mesecon.on_mvps_move then
                node_def.mesecon.on_mvps_move(moved_node.pos, moved_node.node,
                    moved_node.oldpos, moved_node.meta)
            end
            if node_def.on_movenode then
                node_def.on_movenode(moved_node.oldpos, moved_node.pos)
            end
        end
    end
end)
