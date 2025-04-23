local logic = sbz_api.logic

function logic.in_square_radius(pos1, pos2, rad)
    local x1, y1, z1 = pos1.x, pos1.y, pos1.z
    local x2, y2, z2 = pos2.x, pos2.y, pos2.z

    local a = math.abs
    local dx, dy, dz = a(x1 - x2), a(y1 - y2), a(z1 - z2)

    if dx > rad or dy > rad or dz > rad then
        return false
    end
    return true
end

function logic.add_to_link(link, value)
    if link.x then
        return vector.add(link, value)
    else
        link = table.copy(link)
        for k, v in pairs(link) do
            link[k] = vector.add(v, value)
        end
        return link
    end
end

function logic.range_check(luac_pos, pos2)
    local M = minetest.get_meta
    local ret_value = true
    local meta = M(luac_pos)
    local linking_range = meta:get_int("linking_range")
    local owner = meta:get_string("owner")
    if not pos2.x then
        for k, v in pairs(pos2) do
            ret_value = ret_value and logic.in_square_radius(luac_pos, v, linking_range)
                and not minetest.is_protected(v, owner)
        end
    else
        ret_value = ret_value and logic.in_square_radius(luac_pos, pos2, linking_range) and
            not minetest.is_protected(pos2, owner)
    end
    return ret_value
end

function logic.type_link(x, or_pos)
    if type(x) ~= "table" then return false end
    if libox.type_vector(x) and or_pos then return true end

    local ret = true
    for k, v in pairs(x) do
        ret = ret and libox.type_vector(v)
    end
    return ret
end

function logic.try_to_unpack(x)
    if #x == 1 then return x[1] end
    return x
end

function logic.kill_itemstacks(t)
    for k, v in pairs(t) do
        if type(v) == "table" then
            t[k] = logic.kill_itemstacks(v)
        elseif type(v) == "userdata" and v.to_table then
            t[k] = v:to_table()
        end
    end
    return t
end
