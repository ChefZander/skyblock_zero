local S = minetest.get_translator("pipeworks")

local function set_wielder_formspec(def, meta)
    local width, height = def.wield_inv.width, def.wield_inv.height
    local offset = 5.22 - width * 0.625
    local size = "10.2," .. (6.5 + height * 1.25)
    local list_bg = ""
    if minetest.get_modpath("i3") or minetest.get_modpath("mcl_formspec") then
        list_bg = "style_type[box;colors=#666]"
        for i = 0, height - 1 do
            for j = 0, width - 1 do
                list_bg = list_bg .. "box[" .. offset + (i * 1.25) .. "," .. 1.25 + (j * 1.25) .. ";1,1;]"
            end
        end
    end
    local inv_offset = 1.5 + height * 1.25
    local fs = "formspec_version[2]size[" .. size .. "]" ..
        pipeworks.fs_helpers.get_prepends(size) .. list_bg ..
        "item_image[0.5,0.3;1,1;" .. def.name .. "]" ..
        "label[1.75,0.8;" .. minetest.formspec_escape(def.description) .. "]" ..
        "list[context;" .. def.wield_inv.name .. ";" .. offset .. ",1.25;" .. width .. "," .. height .. ";]"
        .. pipeworks.fs_helpers.get_inv(inv_offset) .. "listring[]"
    meta:set_string("formspec", fs)
    meta:set_string("infotext", def.description)
end

local function wielder_action(def, pos, node, index)
    local meta = minetest.get_meta(pos)
    local inv = meta:get_inventory()
    local list = inv:get_list(def.wield_inv.name)
    if list == nil then return end
    local wield_index
    if index then
        if list[index] and (def.wield_hand or not list[index]:is_empty()) then
            wield_index = index
        end
    else
        for i, stack in ipairs(list) do
            if not stack:is_empty() then
                wield_index = i
                break
            end
        end
    end
    if not wield_index and not def.wield_hand then
        return
    end
    local dir = minetest.facedir_to_dir(node.param2)
    local fakeplayer = fakelib.create_player({
        name = meta:get_string("owner"),
        direction = vector.multiply(dir, -1),
        position = pos,
        inventory = inv,
        wield_index = wield_index or 1,
        wield_list = def.wield_inv.name,
    })
    -- Under and above positions are intentionally switched.
    local pointed = {
        type = "node",
        under = vector.subtract(pos, dir),
        above = vector.subtract(pos, vector.multiply(dir, 2)),
    }
    local retval = def.action(fakeplayer, pointed)
    if def.eject_drops then
        for i, stack in ipairs(inv:get_list("main")) do
            if not stack:is_empty() then
                pipeworks.tube_inject_item(pos, pos, dir, stack)
                inv:set_stack("main", i, ItemStack(""))
            end
        end
    end
    return retval
end


function pipeworks.register_wielder(def)
    local groups = {
        matter = 2,
        snappy = 2,
        choppy = 2,
        oddly_breakable_by_hand = 2,
        tubedevice = 1,
        tubedevice_receiver = 1,
        sbz_machine = 1,
        pipe_conducts = 1,
        pipe_connects = 1,
        axey = 1,
        handy = 1,
        pickaxey = 1,
    }
    minetest.register_node(def.name, {
        description = def.description,
        tiles = def.tiles,
        paramtype2 = "facedir",
        groups = groups,
        is_ground_content = false,
        tube = {
            can_insert = function(pos, node, stack, direction)
                if def.eject_drops then
                    -- Prevent ejected items from being inserted
                    local dir = vector.multiply(minetest.facedir_to_dir(node.param2), -1)
                    if vector.equals(direction, dir) then
                        return false
                    end
                end
                local inv = minetest.get_meta(pos):get_inventory()
                return inv:room_for_item(def.wield_inv.name, stack)
            end,
            insert_object = function(pos, node, stack)
                local inv = minetest.get_meta(pos):get_inventory()
                return inv:add_item(def.wield_inv.name, stack)
            end,
            input_inventory = def.wield_inv.name,
            connect_sides = def.connect_sides,
            can_remove = function(pos, node, stack)
                return stack:get_count()
            end,
        },
        on_construct = function(pos)
            local meta = minetest.get_meta(pos)
            local inv = meta:get_inventory()
            inv:set_size(def.wield_inv.name, def.wield_inv.width * def.wield_inv.height)
            if def.eject_drops then
                inv:set_size("main", 32)
            end
            set_wielder_formspec(def, meta)
        end,
        after_place_node = function(pos, placer)
            pipeworks.scan_for_tube_objects(pos)
            if not placer then
                return
            end
            local node = minetest.get_node(pos)
            node.param2 = minetest.dir_to_facedir(placer:get_look_dir(), true)
            minetest.set_node(pos, node)
            minetest.get_meta(pos):set_string("owner", placer:get_player_name())
        end,
        after_dig_node = function(pos, oldnode, oldmetadata, digger)
            for _, stack in ipairs(oldmetadata.inventory[def.wield_inv.name] or {}) do
                if not stack:is_empty() then
                    minetest.add_item(pos, stack)
                end
            end
            pipeworks.scan_for_tube_objects(pos)
        end,
        on_rotate = pipeworks.on_rotate,
        allow_metadata_inventory_put = function(pos, listname, index, stack, player)
            if not pipeworks.may_configure(pos, player) then return 0 end
            return stack:get_count()
        end,
        allow_metadata_inventory_take = function(pos, listname, index, stack, player)
            if not pipeworks.may_configure(pos, player) then return 0 end
            return stack:get_count()
        end,
        allow_metadata_inventory_move = function(pos, from_list, from_index, to_list, to_index, count, player)
            if not pipeworks.may_configure(pos, player) then return 0 end
            return count
        end,
        on_receive_fields = function(pos, _, fields, sender)
            if not fields.channel or not pipeworks.may_configure(pos, sender) then
                return
            end
            minetest.get_meta(pos):set_string("channel", fields.channel)
        end,
        action = function(pos, node, meta, supply, demand)
            if supply < demand + def.cost then
                meta:set_string("infotext", "Not enough power")
                return def.cost
            end
            meta:set_string("infotext", "Working")
            if wielder_action(def, pos, minetest.get_node(pos)) == false then
                meta:set_string("infotext", "Idle")
                return 0
            end
            return def.cost
        end,
        sounds = sbz_api.sounds.matter(),
    })
end

pipeworks.register_wielder({
    name = "pipeworks:nodebreaker",
    description = S("Node Breaker"),
    tiles = {
        "nodebreaker_side.png",
        "nodebreaker_side.png",
        "nodebreaker_side.png",
        "nodebreaker_side.png",
        "nodebreaker_back.png",
        "nodebreaker_front.png"
    },
    connect_sides = { top = 1, bottom = 1, left = 1, right = 1, back = 1 },
    wield_inv = { name = "pick", width = 1, height = 1 },
    wield_hand = true,
    eject_drops = true,
    action = function(fakeplayer, pointed)
        local stack = fakeplayer:get_wielded_item()
        local old_stack = ItemStack(stack)
        local item_def = minetest.registered_items[stack:get_name()]
        if item_def.on_use then
            stack = item_def.on_use(stack, fakeplayer, pointed) or stack
            fakeplayer:set_wielded_item(stack)
        else
            local node = minetest.get_node(pointed.under)
            local node_def = minetest.registered_nodes[node.name]
            if not node_def or not node_def.on_dig then
                return false
            end

            if minetest.get_item_group(node.name, "nb_nodig") > 0 then -- DO NOT USE THIS TO LIMIT WHAT CAVEMAN AUTOMATION CAN DO, ONLY USE IT TO STRENGHTEN IT (like making growing plants not breakable)
                return false
            end
            -- Check if the tool can dig the node
            local tool = stack:get_tool_capabilities()
            if not minetest.get_dig_params(node_def.groups, tool).diggable then
                -- Try using hand if tool can't dig the node
                local hand = ItemStack():get_tool_capabilities()
                if not minetest.get_dig_params(node_def.groups, hand).diggable then
                    return false
                end
            end
            -- This must only check for false, because `on_dig` returning nil is the same as returning true.
            if node_def.on_dig(pointed.under, node, fakeplayer) == false then
                return false
            end
            local sound = node_def.sounds and node_def.sounds.dug
            if sound then
                minetest.sound_play(sound, { pos = pointed.under }, true)
            end
            stack = fakeplayer:get_wielded_item()
        end
        if stack:get_name() == old_stack:get_name() then
            -- Don't mechanically wear out tool
            if stack:get_wear() ~= old_stack:get_wear() and stack:get_count() == old_stack:get_count()
                and (item_def.wear_represents == nil or item_def.wear_represents == "mechanical_wear") then
                fakeplayer:set_wielded_item(old_stack)
            end
        elseif not stack:is_empty() then
            -- Tool got replaced by something else, treat it as a drop.
            fakeplayer:get_inventory():add_item("main", stack)
            fakeplayer:set_wielded_item("")
        end
    end,
    cost = 20
})

pipeworks.register_wielder({
    name = "pipeworks:deployer",
    description = S("Deployer"),
    tiles = {
        "deployer_side.png",
        "deployer_side.png",
        "deployer_side.png",
        "deployer_side.png",
        "deployer_back.png",
        "deployer_front.png"
    },
    wield_inv = { name = "main", width = 3, height = 3 },
    connect_sides = { back = 1 },
    action = function(fakeplayer, pointed)
        local stack = fakeplayer:get_wielded_item()
        local def = minetest.registered_items[stack:get_name()]
        if def and def.on_place then
            local new_stack, placed_pos = def.on_place(stack, fakeplayer, pointed)
            fakeplayer:set_wielded_item(new_stack or stack)
            -- minetest.item_place_node doesn't play sound to the placer
            local sound = placed_pos and def.sounds and def.sounds.place
            local name = fakeplayer:get_player_name()
            if sound and name ~= "" then
                minetest.sound_play(sound, { pos = placed_pos, to_player = name }, true)
            end
        else
            return false
        end
    end,
    cost = 20
})

pipeworks.register_wielder({
    name = "pipeworks:puncher",
    description = S("Puncher"),
    tiles = {
        "interactor_side.png^[transformFY",
        "interactor_side.png",
        "interactor_side.png^[transformR90",
        "interactor_side.png^[transformR270",
        "interactor_bottom.png", -- back
        "interactor_top.png"     -- front
    },
    wield_inv = { name = "pick", width = 1, height = 1 },
    connect_sides = { top = 1, bottom = 1, left = 1, right = 1, back = 1 },
    wield_hand = true,
    eject_drops = true,
    action = function(fakeplayer, pointed)
        local node = minetest.get_node(pointed.under)
        local node_def = minetest.registered_nodes[node.name]

        if not node_def then
            return false
        end

        if not node_def.on_punch then
            return false
        end

        node_def.on_punch(fakeplayer:get_pos(), node, fakeplayer, pointed)
    end,
    cost = 40
})

minetest.register_craft({
    output = "pipeworks:puncher",
    recipe = {
        { "sbz_resources:robotic_arm", "sbz_resources:robotic_arm",       "sbz_resources:robotic_arm" },
        { "pipeworks:tube_1",          "sbz_resources:emittrium_circuit", "pipeworks:automatic_filter_injector" },
        { "sbz_chem:aluminum_ingot",   "sbz_chem:aluminum_ingot",         "sbz_chem:aluminum_ingot" }
    }
})

minetest.register_craft({
    output = "pipeworks:nodebreaker",
    recipe = {
        { "sbz_resources:matter_annihilator", "sbz_resources:matter_annihilator", "sbz_resources:matter_annihilator" },
        { "pipeworks:tube_1",                 "sbz_resources:simple_circuit",     "pipeworks:automatic_filter_injector" },
        { "sbz_chem:aluminum_ingot",          "sbz_chem:aluminum_ingot",          "sbz_chem:aluminum_ingot" }
    }
})

minetest.register_craft({
    output = "pipeworks:deployer",
    recipe = {
        { "",                        "sbz_resources:robotic_arm",    "" },
        { "pipeworks:tube_1",        "sbz_resources:simple_circuit", "pipeworks:automatic_filter_injector" },
        { "sbz_chem:aluminum_ingot", "sbz_chem:aluminum_ingot",      "sbz_chem:aluminum_ingot" }
    }
})
