-- This file supplies the various kinds of pneumatic tubes
local tubenodes = {}
pipeworks.tubenodes = tubenodes

minetest.register_alias("pipeworks:tube", "pipeworks:tube_000000")

-- now, a function to define the tubes

pipeworks.check_and_wear_hammer = function() end

local vti = { 4, 3, 2, 1, 6, 5 }

local texture_mt = {
    __index = function(table, key)
        local size, idx = #table, tonumber(key)
        if size > 0 then -- avoid endless loops with empty tables
            while idx > size do idx = idx - size end
            return table[idx]
        end
    end
}

local register_one_tube = function(name, tname, dropname, desc, plain, noctrs, special, connects)
    noctrs = noctrs
    setmetatable(noctrs, texture_mt)
    plain = plain
    setmetatable(plain, texture_mt)
    local ends = table.copy(plain)
    setmetatable(ends, texture_mt)

    local outboxes = {}
    local outimgs = {}

    for i = 1, 6 do
        outimgs[vti[i]] = plain[i]
    end

    for _, v in ipairs(connects) do
        pipeworks.table_extend(outboxes, pipeworks.tube_boxes[v])
        outimgs[vti[v]] = noctrs[v]
    end

    if #connects == 1 then
        local v = connects[1]
        v = v - 1 + 2 * (v % 2) -- Opposite side
        outimgs[vti[v]] = ends[v]
    end

    local tgroups = { matter = 2, snappy = 3, tube = 1, tubedevice = 1, not_in_creative_inventory = 1, dig_generic = 4, axey = 1, handy = 1, pickaxey = 1, habitat_conducts = 1 }
    local tubedesc = string.format("%s %s", desc, dump(connects))
    local wscale = { x = 1, y = 1, z = 1 }

    if #connects == 0 then
        tgroups = { matter = 2, snappy = 3, tube = 1, tubedevice = 1, dig_generic = 4, axey = 1, handy = 1, pickaxey = 1, habitat_conducts = 1 }
        tubedesc = desc
        outboxes = pipeworks.tube_short
        outimgs = {
            plain[1], plain[1],
            plain[1], plain[1],
            plain[1], plain[1]
        }
    end

    for i, tile in ipairs(outimgs) do
        outimgs[i] = pipeworks.make_tube_tile(tile)
    end

    local rname = string.format("%s_%s", name, tname)
    table.insert(tubenodes, rname)

    local nodedef = {
        description = tubedesc,
        drawtype = "nodebox",
        tiles = outimgs,
        use_texture_alpha = "clip",
        sunlight_propagates = true,
        wield_scale = wscale,
        paramtype = "light",
        paramtype2 = "facedir",
        node_box = {
            type = "fixed",
            fixed = outboxes
        },
        groups = tgroups,
        is_ground_content = false,
        walkable = true,
        basename = name,
        style = "6d",
        drop = string.format("%s_%s", name, dropname),
        tubelike = 1,
        tube = {
            connect_sides = { front = 1, back = 1, left = 1, right = 1, top = 1, bottom = 1 },
            priority = 50
        },
        on_punch = function(pos, node, player, pointed)
            local playername = player:get_player_name()
            if minetest.is_protected(pos, playername) and not minetest.check_player_privs(playername, { protection_bypass = true }) then
                return minetest.node_punch(pos, node, player, pointed)
            end
            if pipeworks.check_and_wear_hammer(player) then
                local wieldname = player:get_wielded_item():get_name()
                pipeworks.logger(string.format("%s struck a tube at %s with %s to break it.", playername,
                    minetest.pos_to_string(pos), wieldname))
                pipeworks.break_tube(pos)
            end
            return minetest.node_punch(pos, node, player, pointed)
        end,
        after_place_node = pipeworks.after_place,
        after_dig_node = pipeworks.after_dig,
        on_rotate = false,
        on_blast = function(pos, intensity)
            if not intensity or intensity > 1 + 3 ^ 0.5 then
                minetest.remove_node(pos)
                return { string.format("%s_%s", name, dropname) }
            end
            minetest.swap_node(pos, { name = "pipeworks:broken_tube_1" })
            pipeworks.scan_for_tube_objects(pos)
        end,
        tubenumber = tonumber(tname),
        sounds = sbz_api.sounds.matter()
    }

    if special == nil then special = {} end

    for key, value in pairs(special) do
        --if key == "after_dig_node" or key == "after_place_node" then
        --	nodedef[key.."_"] = value
        if key == "groups" then
            for group, val in pairs(value) do
                nodedef.groups[group] = val
            end
        elseif key == "tube" then
            for key, val in pairs(value) do
                nodedef.tube[key] = val
            end
        else
            nodedef[key] = pipeworks.table_recursive_replace(value, "#id", tname)
        end
    end

    minetest.register_node(rname, nodedef)
end

local register_all_tubes = function(name, desc, plain, noctrs, special)
    -- 6d tubes: uses only 10 nodes instead of 64, but the textures must be rotated
    local cconnects = { {}, { 1 }, { 1, 2 }, { 1, 3 }, { 1, 3, 5 }, { 1, 2, 3 }, { 1, 2, 3, 5 }, { 1, 2, 3, 4 }, { 1, 2, 3, 4, 5 }, { 1, 2, 3, 4, 5, 6 } }
    for index, connects in ipairs(cconnects) do
        register_one_tube(name, tostring(index), "1", desc, plain, noctrs, special, connects)
    end
end


pipeworks.register_tube = function(name, def)
    register_all_tubes(name, def.description, def.plain, def.noctr, def.node_def)
end

pipeworks.register_one_tube = register_one_tube
