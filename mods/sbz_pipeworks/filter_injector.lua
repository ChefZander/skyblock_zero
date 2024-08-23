-- can't use sbz_api.register_machine here
-- also holy crap it's so insanely complex... good luck...

local fs_helpers = pipeworks.fs_helpers

local function set_filter_formspec(meta)
    local size = "10.2,11"

    local formspec =
        "formspec_version[2]" ..
        "size[10.2,11]" ..
        pipeworks.fs_helpers.get_prepends(size) ..
        "item_image[0.22,0.22;1,1;pipeworks:automatic_filter_injector]" ..
        "label[1.22,0.72;Automatic Filter-Injector]" ..
        "label[0.22,1.5;Prefer item types:]" ..
        "list[context;main;0.22,1.75;8,2;]" ..
        fs_helpers.cycling_button(meta, "button[0.22,4.5;4,1", "slotseq_mode",
            { "Sequence slots by Priority",
                "Sequence slots Randomly",
                "Sequence slots by Rotation" }) ..
        fs_helpers.cycling_button(meta, "button[" .. (10.2 - (0.22) - 4) .. ",4.5;4,1", "exmatch_mode",
            { "Exact match - off",
                "Exact match - on" }) ..
        pipeworks.fs_helpers.get_inv(6) ..
        "listring[]"

    meta:set_string("formspec", formspec)
end


minetest.register_node("pipeworks:automatic_filter_injector", {
    description = "Automatic Filter-Injector",
    info_extra = "Pulls stuff from storinators, machines... and more.... to a tube",
    tiles = {
        "filter_top.png",
        "filter_top.png",
        "filter_output.png",
        "filter_input.png",
        "filter_side.png",
        "filter_top.png",
    },
    paramtype2 = "facedir",
    groups = { cracky = 3, matter = 1, sbz_machine = 1, pipe_connects = 1, pipe_conducts = 0 }, -- you can optionally make it faster, not a bug, a FEATURE!
    on_construct = function(pos)
        local meta = minetest.get_meta(pos)
        local inv = meta:get_inventory()
        inv:set_size("main", 8 * 2)
        set_filter_formspec(meta)
    end,
    after_place_node = function(pos, placer)
        minetest.get_meta(pos):set_string("owner", placer:get_player_name())
        pipeworks.after_place(pos)
    end,
    after_dig_node = pipeworks.after_dig,
    on_rotate = pipeworks.on_rotate,
    allow_metadata_inventory_put = function(pos, listname, index, stack, player)
        if not pipeworks.may_configure(pos, player) then
            return 0
        end
        local inv = minetest.get_meta(pos):get_inventory()
        inv:set_stack("main", index, stack)
        return 0
    end,
    allow_metadata_inventory_take = function(pos, listname, index, stack, player)
        if not pipeworks.may_configure(pos, player) then
            return 0
        end
        local inv = minetest.get_meta(pos):get_inventory()
        local fake_stack = inv:get_stack("main", index)
        fake_stack:take_item(stack:get_count())
        inv:set_stack("main", index, fake_stack)
        return 0
    end,
    allow_metadata_inventory_move = function(pos, from_list, from_index, to_list, to_index, count, player)
        if not pipeworks.may_configure(pos, player) then return 0 end
        return count
    end,
    can_dig = function(pos, player)
        local meta = minetest.get_meta(pos)
        local inv = meta:get_inventory()
        return inv:is_empty("main")
    end,
    tube = { connect_sides = { right = 1 } },
    on_receive_fields = function(pos, formname, fields, sender)
        if (fields.quit and not fields.key_enter_field)
            or not pipeworks.may_configure(pos, sender) then
            return
        end
        fs_helpers.on_receive_fields(pos, fields)
        local meta = minetest.get_meta(pos)

        --meta:set_int("slotseq_index", 1)
        set_filter_formspec(meta)
    end,
    action = function(pos, node, meta, supply, demand)
        if supply < demand + 1 then
            meta:set_string("infotext", "Not enough power")
            return 1
        end
        meta:set_string("infotext", "Working")

        node = minetest.get_node(pos)
        local inv = meta:get_inventory()
        local owner = meta:get_string("owner")
        local fakeplayer = fakelib.create_player(owner)
        local dir = pipeworks.facedir_to_right_dir(node.param2)

        local frompos = vector.subtract(pos, dir)
        local fromnode = minetest.get_node(frompos)

        if not fromnode then
            meta:set_string("infotext", "I can't pull from that node - there is no node there?")
            return 1
        end

        local fromdef = minetest.registered_nodes[fromnode.name]
        if not fromdef or not fromdef.tube then
            meta:set_string("infotext", "I can't pull from that node :/")
            return 1
        end
        local fromtube = table.copy(fromdef.tube)

        local todir = pipeworks.facedir_to_right_dir(node.param2)
        local topos = vector.add(pos, todir)
        local tonode = minetest.get_node(topos)
        local todef = minetest.registered_nodes[tonode.name]

        if not todef
            or not (minetest.get_item_group(tonode.name, "tube") == 1
                or minetest.get_item_group(tonode.name, "tubedevice") == 1
                or minetest.get_item_group(tonode.name, "tubedevice_receiver") == 1) then
            meta:set_string("infotext", "I can't push to that node")
            return 1
        end

        if fromtube then fromtube.input_inventory = fromtube.input_inventory end
        if not (fromtube and fromtube.input_inventory) then
            meta:set_string("infotext", "I can't pull from that node :/")
            return 1
        end

        local filters = {}

        for _, filterstack in ipairs(inv:get_list("main")) do
            local filtername = filterstack:get_name()
            local filtercount = filterstack:get_count()
            if filtername ~= "" then table.insert(filters, { name = filtername, count = filtercount }) end
        end


        if #filters == 0 then table.insert(filters, "") end

        local slotseq_mode = meta:get_int("slotseq_mode")
        local exmatch_mode = meta:get_int("exmatch_mode")

        local frominv
        if fromtube.return_input_invref then
            frominv = fromtube.return_input_invref(frompos, fromnode, dir, owner)
            if not frominv then
                return 1
            end
        else
            local frommeta = minetest.get_meta(frompos)
            frominv = frommeta:get_inventory()
        end
        if fromtube.before_filter then fromtube.before_filter(frompos) end

        local function grabAndFire(frominvname, filterfor)
            local sposes = {}
            if not frominvname or not frominv:get_list(frominvname) then return end
            for spos, stack in ipairs(frominv:get_list(frominvname)) do
                local matches
                if filterfor == "" then
                    matches = stack:get_name() ~= ""
                else
                    local fname = filterfor.name
                    local fgroup = filterfor.group
                    local fwear = filterfor.wear
                    local fmetadata = filterfor.metadata
                    matches = (not fname                     -- If there's a name filter,
                            or stack:get_name() == fname)    --  it must match.

                        and (not fgroup                      -- If there's a group filter,
                            or (type(fgroup) == "string"     --  it must be a string
                                and minetest.get_item_group( --  and it must match.
                                    stack:get_name(), fgroup) ~= 0))

                        and (not fwear                                      -- If there's a wear filter:
                            or (type(fwear) == "number"                     --  If it's a number,
                                and stack:get_wear() == fwear)              --   it must match.
                            or (type(fwear) == "table"                      --  If it's a table:
                                and (not fwear[1]                           --   If there's a lower bound,
                                    or (type(fwear[1]) == "number"          --    it must be a number
                                        and fwear[1] <= stack:get_wear()))  --    and it must be <= the actual wear.
                                and (not fwear[2]                           --   If there's an upper bound
                                    or (type(fwear[2]) == "number"          --    it must be a number
                                        and stack:get_wear() < fwear[2])))) --    and it must be > the actual wear.
                        --  If the wear filter is of any other type, fail.

                        and (not fmetadata                              -- If there's a metadata filter,
                            or (type(fmetadata) == "string"             --  it must be a string
                                and stack:get_metadata() == fmetadata)) --  and it must match.
                end
                if matches then table.insert(sposes, spos) end
            end
            if #sposes == 0 then return false end
            if slotseq_mode == 1 then
                for i = #sposes, 2, -1 do
                    local j = math.random(i)
                    local t = sposes[j]
                    sposes[j] = sposes[i]
                    sposes[i] = t
                end
            elseif slotseq_mode == 2 then
                local headpos = meta:get_int("slotseq_index")
                table.sort(sposes, function(a, b)
                    if a >= headpos then
                        if b < headpos then return true end
                    else
                        if b >= headpos then return false end
                    end
                    return a < b
                end)
            end
            for _, spos in ipairs(sposes) do
                local stack = frominv:get_stack(frominvname, spos)
                local doRemove = stack:get_count()
                if fromtube.can_remove then
                    doRemove = fromtube.can_remove(frompos, fromnode, stack, dir, frominvname, spos)
                elseif fromdef.allow_metadata_inventory_take then
                    doRemove = fromdef.allow_metadata_inventory_take(frompos, frominvname, spos, stack, fakeplayer)
                end
                -- stupid lack of continue statements grumble
                if doRemove > 0 then
                    if slotseq_mode == 2 then
                        local nextpos = spos + 1
                        if nextpos > frominv:get_size(frominvname) then
                            nextpos = 1
                        end
                        meta:set_int("slotseq_index", nextpos)
                    end
                    local item
                    local count = math.min(stack:get_count(), doRemove)
                    if filterfor.count and (filterfor.count > 1) then
                        if exmatch_mode ~= 0 and filterfor.count > count then
                            return false -- not enough, fail
                        else
                            -- limit quantity to filter amount
                            count = math.min(filterfor.count, count)
                        end
                    end
                    if fromtube.remove_items then
                        -- it could be the entire stack...
                        item = fromtube.remove_items(frompos, fromnode, stack, dir, count, frominvname, spos)
                    else
                        item = stack:take_item(count)
                        frominv:set_stack(frominvname, spos, stack)
                        if fromdef.on_metadata_inventory_take then
                            fromdef.on_metadata_inventory_take(frompos, frominvname, spos, item, fakeplayer)
                        end
                    end
                    local pos = vector.add(frompos, vector.multiply(dir, 1.4))
                    local start_pos = vector.add(frompos, dir)
                    pipeworks.tube_inject_item(pos, start_pos, dir, item,
                        fakeplayer:get_player_name())
                    return true -- only fire one item, please
                end
            end
            return false
        end

        for _, frominvname in ipairs(type(fromtube.input_inventory) == "table" and fromtube.input_inventory or { fromtube.input_inventory }) do
            local done = false
            for _, filterfor in ipairs(filters) do
                if grabAndFire(frominvname, filterfor) then
                    done = true
                    break
                end
            end
            if done then break end
        end
        if fromtube.after_filter then fromtube.after_filter(frompos) end

        return 1
    end
})
