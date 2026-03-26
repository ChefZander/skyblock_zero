-- can't use sbz_api.register_machine here
-- also holy crap it's so insanely complex?... good luck..., taken from pipeworks

-- Patches: https://github.com/mt-mods/pipeworks/pull/154 by The4codeblocks (Heavily edited)

local fs_helpers = pipeworks.fs_helpers

local function set_filter_formspec(meta)
    local size = '10.2,11'

    local formspec = 'formspec_version[2]'
        .. 'size[10.2,11]'
        .. pipeworks.fs_helpers.get_prepends(size)
        .. 'item_image[0.22,0.22;1,1;pipeworks:automatic_filter_injector]'
        .. 'label[1.22,0.72;Automatic Filter-Injector]'
        .. 'label[0.22,1.5;Prefer item types:]'
        .. 'list[context;main;0.22,1.75;8,2;]'
        .. fs_helpers.cycling_button(
            meta,
            'button[0.22,4.5;4,1',
            'slotseq_mode',
            { 'Sequence slots\nby Priority', 'Sequence slots\nRandomly', 'Sequence slots\nby Rotation' }
        )
        .. fs_helpers.cycling_button(
            meta,
            'button[' .. (10.2 - 0.22 - 4) .. ',4.5;4,1',
            'exmatch_mode',
            { 'Exact match - off', 'Exact match - on', 'Threshold' }
        )
        .. pipeworks.fs_helpers.get_inv(6)
        .. 'listring[]'

    meta:set_string('formspec', formspec)
end

local animation_def = {
    type = 'vertical_frames',
    aspect_w = 16,
    aspect_h = 16,
    length = 1,
}

core.register_node('pipeworks:automatic_filter_injector', {
    description = 'Automatic Filter-Injector',
    sounds = sbz_api.sounds.matter(),
    info_extra = 'Pushes items out of containers.',
    tiles = {
        { name = 'filter_side.png^[transformFX', animation = animation_def },
        { name = 'filter_side.png^[transformFX', animation = animation_def },
        'filter_output.png',
        'filter_input.png',
        { name = 'filter_side.png', animation = animation_def },
        { name = 'filter_side.png^[transformFX', animation = animation_def },
    },
    paramtype2 = 'facedir',
    groups = { matter = 1, sbz_machine = 1, pipe_connects = 1, pipe_conducts = 1 },
    on_construct = function(pos)
        local meta = core.get_meta(pos)
        local inv = meta:get_inventory()
        inv:set_size('main', 8 * 2)
        set_filter_formspec(meta)
    end,
    after_place_node = function(pos, placer, itemstack, pointed_thing)
        core.get_meta(pos):set_string('owner', placer:get_player_name())

        if pointed_thing and pointed_thing.above then
            local face = vector.subtract(pointed_thing.above, pointed_thing.under)
            face = -face
            local node = core.get_node(pos)
            node.param2 = core.dir_to_facedir(face, true) + 1
            core.swap_node(pos, node)
        end
        pipeworks.after_place(pos)
    end,
    after_dig_node = pipeworks.after_dig,
    on_rotate = pipeworks.on_rotate,
    allow_metadata_inventory_put = function(pos, listname, index, stack, player)
        if not pipeworks.may_configure(pos, player) then return 0 end
        local inv = core.get_meta(pos):get_inventory()
        inv:set_stack('main', index, stack)
        return 0
    end,
    allow_metadata_inventory_take = function(pos, listname, index, stack, player)
        if not pipeworks.may_configure(pos, player) then return 0 end
        local inv = core.get_meta(pos):get_inventory()
        local fake_stack = inv:get_stack('main', index)
        fake_stack:take_item(stack:get_count())
        inv:set_stack('main', index, fake_stack)
        return 0
    end,
    allow_metadata_inventory_move = function(pos, from_list, from_index, to_list, to_index, count, player)
        if not pipeworks.may_configure(pos, player) then return 0 end
        return count
    end,
    tube = { connect_sides = { right = 1 } },
    on_receive_fields = function(pos, formname, fields, sender)
        if (fields.quit and not fields.key_enter_field) or not pipeworks.may_configure(pos, sender) then return end
        fs_helpers.on_receive_fields(pos, fields)
        local meta = core.get_meta(pos)

        --meta:set_int("slotseq_index", 1)
        set_filter_formspec(meta)
    end,
    action = function(pos, node, meta, supply, demand)
        if supply < demand + 1 then
            meta:set_string('infotext', 'Not enough power')
            return 1
        end
        meta:set_string('infotext', 'Working')

        node = core.get_node(pos)
        local inv = meta:get_inventory()
        local owner = meta:get_string 'owner'
        local fake_player = fakelib.create_player(owner)
        local dir = pipeworks.facedir_to_right_dir(node.param2)

        local from_pos = vector.subtract(pos, dir)
        local from_node = sbz_api.get_or_load_node(from_pos)

        if not from_node then
            meta:set_string('infotext', "Can't pull from that node, there is no node there???")
            return 1
        end

        local from_def = core.registered_nodes[from_node.name]
        if not from_def or not from_def.tube then
            meta:set_string('infotext', "Can't pull from that node :/ - No behavior for tube interaction defined.")
            return 1
        end
        local from_tube = table.copy(from_def.tube)

        local to_dir = pipeworks.facedir_to_right_dir(node.param2)
        local topos = vector.add(pos, to_dir)
        local to_node = sbz_api.get_or_load_node(topos)

        if not to_node then
            meta:set_string('infotext', "Can't push to that node - that node does not exist.")
            return 1
        end
        local to_def = core.registered_nodes[to_node.name]

        if
            not to_def
            or not (
                core.get_item_group(to_node.name, 'tube') == 1
                or core.get_item_group(to_node.name, 'tubedevice') == 1
                or core.get_item_group(to_node.name, 'tubedevice_receiver') == 1
            )
        then
            meta:set_string('infotext', "Can't push to that node")
            return 1
        end

        if not from_tube.input_inventory then
            meta:set_string(
                'infotext',
                "Can't pull from that node :/ - No input inventory in definition. (" .. from_node.name .. ')'
            )
            return 1
        end

        local filters = {}

        for _, filter_stack in ipairs(inv:get_list 'main') do
            local filter_name = filter_stack:get_name()
            local filter_count = filter_stack:get_count()
            if filter_name ~= '' then table.insert(filters, { name = filter_name, count = filter_count }) end
        end

        if #filters == 0 then table.insert(filters, '') end

        local slotseq_mode = meta:get_int 'slotseq_mode'
        local exmatch_mode = meta:get_int 'exmatch_mode'

        local from_inv
        if from_tube.return_input_invref then
            from_inv = from_tube.return_input_invref(from_pos, from_node, dir, owner)
            if not from_inv then
                meta:set_string(
                    'infotext',
                    "Can't pull from that node yet. (May be dependant on direction or node state.)"
                )
                return 1
            end
        else
            local from_meta = core.get_meta(from_pos)
            from_inv = from_meta:get_inventory()
        end
        if from_tube.before_filter then from_tube.before_filter(from_pos) end

        local function grabAndFire(from_inv_name, filter_for)
            local sposes = {}
            if not from_inv_name or not from_inv:get_list(from_inv_name) then return end
            for spos, stack in ipairs(from_inv:get_list(from_inv_name)) do
                local matches
                if filter_for == '' then
                    matches = stack:get_name() ~= ''
                else
                    local f_name = filter_for.name
                    local f_group = filter_for.group
                    local f_wear = filter_for.wear
                    local f_metadata = filter_for.metadata
                    matches = (
                        not f_name -- If there's a name filter,
                        or stack:get_name() == f_name
                    ) --  it must match.
                        and (
                            not f_group -- If there's a group filter,
                            or (
                                type(f_group) == 'string' --  it must be a string
                                and core.get_item_group( --  and it must match.
                                        stack:get_name(),
                                        f_group
                                    )
                                    ~= 0
                            )
                        )
                        and (
                            not f_wear -- If there's a wear filter:
                            or (
                                type(f_wear) == 'number' --  If it's a number,
                                and stack:get_wear() == f_wear
                            ) --   it must match.
                            or (
                                type(f_wear) == 'table' --  If it's a table:
                                and (
                                    not f_wear[1] --   If there's a lower bound,
                                    or (
                                        type(f_wear[1]) == 'number' --    it must be a number
                                        and f_wear[1] <= stack:get_wear()
                                    )
                                ) --    and it must be <= the actual wear.
                                and (
                                    not f_wear[2] --   If there's an upper bound
                                    or (
                                        type(f_wear[2]) == 'number' --    it must be a number
                                        and stack:get_wear() < f_wear[2]
                                    )
                                )
                            )
                        ) --    and it must be > the actual wear.
                        --  If the wear filter is of any other type, fail.
                        and (
                            not f_metadata -- If there's a metadata filter,
                            or (
                                type(f_metadata) == 'string' --  it must be a string
                                and stack:get_metadata() == f_metadata
                            )
                        ) --  and it must match.
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
                local head_pos = meta:get_int 'slotseq_index'

                local shifted = {}

                for i = 1, #sposes do
                    shifted[(i - head_pos - 1) % #sposes + 1] = sposes[i]
                end
                sposes = shifted
            end

            local taken = 0

            for _, spos in ipairs(sposes) do
                local stack = from_inv:get_stack(from_inv_name, spos)
                local doRemove = stack:get_count()
                if from_tube.can_remove then
                    doRemove = from_tube.can_remove(from_pos, from_node, stack, dir, from_inv_name, spos)
                elseif from_def.allow_metadata_inventory_take and not from_tube.ignore_metadata_inventory_take then
                    doRemove = from_def.allow_metadata_inventory_take(from_pos, from_inv_name, spos, stack, fake_player)
                end
                -- stupid lack of continue statements grumble
                if doRemove > 0 then
                    --[[                    if slotseq_mode == 2 then
                        local next_pos = spos + 1
                        if next_pos > inv_size then
                            next_pos = 1
                        end
                        meta:set_int("slotseq_index", next_pos)
                    end
                    ]]
                    local count = math.min(stack:get_count(), doRemove)
                    taken = taken + count
                    if exmatch_mode == 0 then break end
                end
            end
            if slotseq_mode == 2 then meta:set_int('slotseq_index', meta:get_int 'slotseq_index' + 1) end
            local item
            if taken == 0 then return false end
            if filter_for.count and (exmatch_mode == 2) then
                if filter_for.count < taken then
                    taken = taken - filter_for.count
                else
                    return false
                end
            elseif filter_for.count and exmatch_mode == 1 then
                if filter_for.count > taken then return false end
                taken = math.min(taken, filter_for.count)
            end

            local take_multiple = (filter_for.count ~= nil) and (exmatch_mode ~= 2)
            local real_taken = 0
            if from_tube.remove_items then
                for i, spos in ipairs(sposes) do
                    -- it could be the entire stack...
                    item = from_tube.remove_items(
                        from_pos,
                        from_node,
                        from_inv:get_stack(from_inv_name, spos),
                        dir,
                        taken,
                        from_inv_name,
                        spos,
                        inv
                    )
                    local count = math.min(taken, item:get_count())
                    taken = taken - count
                    real_taken = real_taken + count
                    if taken == 0 then break end
                    if not take_multiple then break end
                end
            else
                for i, spos in ipairs(sposes) do
                    -- it could be the entire stack...
                    local stack = from_inv:get_stack(from_inv_name, spos)
                    local count = math.min(taken, stack:get_count())
                    item = stack:take_item(taken)
                    from_inv:set_stack(from_inv_name, spos, stack)
                    if from_def.on_metadata_inventory_take and not from_tube.ignore_metadata_inventory_take then
                        from_def.on_metadata_inventory_take(from_pos, from_inv_name, spos, item, fake_player)
                    end
                    taken = taken - count
                    real_taken = real_taken + count
                    if taken == 0 then break end
                    if not take_multiple then break end
                end
            end

            local vel = vector.copy(to_dir)
            vel.speed = 1
            if to_def.tube and to_def.tube.can_go then
                if not to_def.tube.can_go(topos, to_node, vel, item, {}) then return false end
            end

            item:set_count(real_taken)

            if
                core.get_item_group(to_node.name, 'tubedevice_receiver') == 1
                and core.get_item_group(to_node.name, 'tubedevice_use_item_entities') == 0
            then
                item = to_def.tube.insert_object(topos, to_node, item, vel, owner)
                from_inv:add_item(from_inv_name, item)
                core.sound_play(
                    { name = 'mix_afi_transfer', gain = 0.5 },
                    { pos = pos, max_hear_distance = 8 }
                )
                return true
            end

            local pos = vector.add(from_pos, vector.multiply(dir, 1.4))
            local start_pos = vector.add(from_pos, dir)

            pipeworks.tube_inject_direct(pos, start_pos, topos, dir, item, fake_player:get_player_name())

            return true
        end

        for _, from_inv_name in
            ipairs(
                type(from_tube.input_inventory) == 'table' and from_tube.input_inventory or { from_tube.input_inventory }
            )
        do
            local done = false
            for _, filter_for in ipairs(filters) do
                if grabAndFire(from_inv_name, filter_for) then
                    done = true
                    break
                end
            end
            if done then break end
        end
        if from_tube.after_filter then from_tube.after_filter(from_pos, from_inv) end

        return 1
    end,
})

do -- Automatic Filter Injector recipe scope
    local AFI = 'pipeworks:automatic_filter_injector'
    local amount = 4
    local MB = "sbz_resources:matter_blob"
    local RA = "sbz_resources:robotic_arm"
    local RC = "sbz_resources:retaining_circuit"
    local BT = "pipeworks:tube_1" -- ("Basic Tube" in-game)
    core.register_craft({
        output = AFI .. ' ' .. tostring(amount),
        recipe = {
            { MB, MB, MB },
            { RA, RC, BT },
            { MB, MB, MB },
        },
    })
end
