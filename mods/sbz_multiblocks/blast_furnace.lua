-- controller, machine casing, furnace heaters
-- item I/O, power input

sbz_api.recipe.register_craft_type({
    type = "blast_furnace",
    description = "Blast Furnace",
    icon = "blast_furnace_heater_inner.png^blast_furnace_heater_frame.png",
    width = 3,
    height = 1,
    uses_crafting_grid = false,
    single = false
})


local ud = unifieddyes.def -- Why not!

local function get_furnce_controller_formspec(pos)
    local meta = core.get_meta(pos)
    local is_multiblock = vector.from_string(meta:get_string("power_port"))
    if not is_multiblock then
        local fs = string.format([[
formspec_version[7]
size[8,6]
button[0.5,0.5;3,1;form_multiblock;Form Multiblock]
button[4.5,0.5;3,1;show_ghosts;Show Build Plan]
label[0.5,2;Number of heater rows:]
scrollbaroptions[min=1;max=4;smallstep=1;largestep=4;arrows=default]
scrollbar[0.5,2.5;7,0.5;horizontal;num_of_heater_rows;%s]

label[1.6,3.3;1]
label[3.2,3.3;2]
label[4.7,3.3;3]
label[6.25,3.3;4]
    ]], math.max(1, meta:get_int("num_of_heater_rows")))
        if #meta:get_string("errmsg") ~= 0 then
            fs = fs ..
                string.format("textarea[0.5,4;8,2;;Error message when trying to form multiblock:;%s]",
                    meta:get_string("errmsg"))
        end
        return fs
    else
        local furnace_mode = meta:get_string("furnace_mode")
        if furnace_mode == "" then furnace_mode = "Regular" end
        local fs = ([[
formspec_version[7]
size[10.2,12]
list[current_player;main;0.2,7;8,4;]

button[0.2,5.6;4,1;furnace_mode;Furnace Mode: %s]

image[5.8,2;1,1;furnace_arrow.png;]

list[context;src1;4.2,2;1,1;]
    ]]):format(furnace_mode)
        if not vector.from_string(meta:get_string("item_output")) then
            fs = fs .. "list[context;dst;7,1.5;2,2;]"
        else
            fs = fs .. "image[7,1.5;2,2;" ..
                core.formspec_escape(core.inventorycube(
                    "blast_furnace_item_IO_sides.png",
                    "blast_furnace_item_output_front.png",
                    "blast_furnace_item_IO_sides.png"
                )) .. "]"
        end
        if furnace_mode == "Alloyer" or furnace_mode == "Blast" then
            fs = fs .. [[
                image[3.2,2;1,1;furnace_plus.png;]
                list[context;src2;2.2,2;1,1;]
            ]]
        end
        if furnace_mode == "Blast" then
            fs = fs .. [[
                image[1.2,2;1,1;furnace_plus.png;]
                list[context;src3;0.2,2;1,1;]
            ]]
        end
        fs = fs ..
            "listring[current_player;main]listring[context;src]listring[current_player;main]listring[context;dst]listring[current_player;main]"
        for i = 1, 3 do
            fs = fs .. string.format("listring[context;src%s]listring[current_player;main]", i)
        end
        return fs
    end
end

local h = core.hash_node_position
local cached_schems = {}
-- THE META ARGUMENT IS IMPORTANT HERE
-- **It gets called on after_dig_node**, with the oldmeta being supplied
-- so core.get_meta and meta (arg) would be different in that case!!... actually it would be a different TYPE
local function make_schem(pos, meta)
    meta = meta or core.get_meta(pos)
    local heater_rows
    if type(meta) == "table" then
        heater_rows = math.max(1, meta.fields.num_of_heater_rows or 4)
    else
        heater_rows = math.max(1, meta:get_int("num_of_heater_rows"))
    end
    if cached_schems[heater_rows] then return cached_schems[heater_rows] end
    meta = nil
    pos = nil

    -- should be only f(heater_rows) => schem, nothing else, no pos, no meta.
    local schemdata = {}
    local schem = {
        data = schemdata,
        categories = {
            machine_casing = {
                ["sbz_multiblocks:blast_furnace_casing"] = true, -- can wallshare
                ["sbz_multiblocks:blast_furnace_power_port"] = true,
                ["sbz_multiblocks:blast_furnace_item_input"] = true,
                ["sbz_multiblocks:blast_furnace_item_output"] = true,
                default = "sbz_multiblocks:blast_furnace_casing"
            }
        },
        limits = {
            ["sbz_multiblocks:blast_furnace_power_port"] = { max = 1, min = 1 },
            ["sbz_multiblocks:blast_furnace_item_input"] = { min = 0, max = 1 },
            ["sbz_multiblocks:blast_furnace_item_output"] = { min = 0, max = 1 },
        },
        item_input = "sbz_multiblocks:blast_furnace_item_input",
        item_output = "sbz_multiblocks:blast_furnace_item_output",
        power_port = "sbz_multiblocks:blast_furnace_power_port"
    }

    -- layer 0
    for x = 0, 2 do
        for z = 0, 2 do
            if not (x == 0 and z == 0) then
                schemdata[h(vector.new(x, 0, z))] = "machine_casing"
            else
                schemdata[h(vector.new(x, 0, z))] = "sbz_multiblocks:blast_furnace_controller"
            end
        end
    end

    local max_y = heater_rows

    -- layer 1 to max_y
    for x = 0, 2 do
        for z = 0, 2 do
            for y = 1, max_y do
                schemdata[h(vector.new(x, y, z))] = "sbz_multiblocks:blast_furnace_heater"
            end
        end
    end

    -- layer max_y+1

    for x = 0, 2 do
        for z = 0, 2 do
            schemdata[h(vector.new(x, max_y + 1, z))] = "machine_casing"
        end
    end

    cached_schems[heater_rows] = sbz_api.make_immutable(schem)
    return schem
end


-- contains storage
core.register_node("sbz_multiblocks:blast_furnace_controller", ud {
    description = "Blast Furnace Controller",
    groups = {
        matter = 1,
        multiblock_controller = 1,
    },
    paramtype2 = "color",
    tiles = {
        "blast_furnace_controller_top.png",
        "blast_furnace_controller_bottom.png",
        "blast_furnace_controller_sides.png",
    },
    light_source = 3,
    on_construct = function(pos)
        local meta = core.get_meta(pos)
        meta:set_string("formspec", get_furnce_controller_formspec(pos))
        local inv = meta:get_inventory()
        inv:set_size("src1", 1)
        inv:set_size("src2", 1)
        inv:set_size("src3", 1)
        inv:set_size("src", 1) -- virtual insert inventory, should never get clogged up
        inv:set_size("dst", 4)
    end,
    on_receive_fields = function(pos, _, fields, sender)
        local meta = core.get_meta(pos)
        local is_multiblock = vector.from_string(meta:get_string("power_port")) ~= nil
        if not is_multiblock then
            if fields.num_of_heater_rows then
                local scrollbar_event = core.explode_scrollbar_event(fields.num_of_heater_rows)
                if scrollbar_event.type == "CHG" and scrollbar_event.value <= 4 and scrollbar_event.value >= 1 then
                    meta:set_int("num_of_heater_rows", scrollbar_event.value)
                end
            end
            if fields.show_ghosts then
                local default_expiration = 8
                local last_used = meta:get_int("last_used_build_helper")
                if os.difftime(os.time(), last_used) >= default_expiration then
                    local schem = make_schem(pos)
                    sbz_api.multiblocks.draw_schematic(pos, schem)
                    meta:set_int("last_used_build_helper", os.time())
                else
                    core.chat_send_player(sender:get_player_name(),
                        "You need to wait " ..
                        (default_expiration - os.difftime(os.time(), last_used)) ..
                        " seconds before showing build plan again.")
                end
            end
            if fields.form_multiblock then
                if meta:get_int("num_of_heater_rows") == 0 then
                    meta:set_int("num_of_heater_rows", 1)
                end
                local schem = make_schem(pos)
                local result = sbz_api.multiblocks.form_multiblock(pos, schem)
                if result.success == false then
                    meta:set_string("errmsg", result.errmsg)
                else
                    -- link power port to self
                    meta:set_string("errmsg", "")
                    meta:set_string("power_port", vector.to_string(result.power_port))
                    if result.item_output then
                        meta:set_string("item_output", vector.to_string(result.item_output))
                    end
                end
            end
        else
            if fields.furnace_mode then
                local furnace_mode = meta:get_string("furnace_mode")
                local set_furnace_mode
                if furnace_mode == "" or furnace_mode == "Regular" then
                    set_furnace_mode = "Alloyer"
                elseif furnace_mode == "Alloyer" then
                    set_furnace_mode = "Blast"
                elseif furnace_mode == "Blast" then
                    set_furnace_mode = "Regular"
                end
                meta:set_string("furnace_mode", set_furnace_mode)
            end
        end
        meta:set_string("formspec", get_furnce_controller_formspec(pos))
    end,
    -- handle smelting and output port :D
    power_port_action = function(pos, meta)
        local num_of_heater_rows = meta:get_int("num_of_heater_rows")
        local efficiency = num_of_heater_rows * 9 -- each heater is like a furnace
        local mode = meta:get_string("furnace_mode")
        if mode == "" then mode = "Regular" end
        local inventory = meta:get_inventory()

        local out
        local cost
        local chance
        -- determine recipe
        if mode == "Regular" then
            out = minetest.get_craft_result({
                method = "cooking",
                width = 1,
                items = { inventory:get_stack("src1", 1) },
            })
            out = out.item
            cost = { inventory:get_stack("src1", 1) }
            cost[1]:set_count(1)
        elseif mode == "Alloyer" then
            local inp1 = inventory:get_stack("src1", 1)
            local inp2 = inventory:get_stack("src2", 1)
            local count
            out, count, cost = sbz_api.recipe.resolve_craft({ inp1, inp2 }, "alloying", true)
        elseif mode == "Blast" then
            local inp1 = inventory:get_stack("src1", 1)
            local inp2 = inventory:get_stack("src2", 1)
            local inp3 = inventory:get_stack("src3", 1)

            local inp1name, inp2name, inp3name = inp1:get_name(), inp2:get_name(), inp3:get_name()
            for _, recipe in pairs(sbz_api.recipe.get_all_crafts_of_type("blast_furnace")) do
                local r = table.copy(recipe.items)
                for k, v in pairs(r) do r[k] = ItemStack(v):get_name() end
                -- great :), you love to see it
                if (r[1] == inp1name and r[2] == inp2name and r[3] == inp3name) or
                    (r[1] == inp1name and r[2] == inp3name and r[3] == inp2name) or
                    (r[1] == inp2name and r[2] == inp3name and r[3] == inp1name) or
                    (r[1] == inp2name and r[2] == inp1name and r[3] == inp3name) or
                    (r[1] == inp3name and r[2] == inp1name and r[3] == inp2name) or
                    (r[1] == inp3name and r[2] == inp2name and r[3] == inp1name)
                then
                    out = ItemStack(recipe.output)
                    cost = table.copy(recipe.items)
                    for k, v in pairs(cost) do
                        cost[k] = ItemStack(v)
                    end
                    local names = { inp1name, inp2name, inp3name }
                    local newcost = {}
                    for i = 1, 3 do
                        for j = 1, 3 do
                            if cost[i]:get_name() == names[j] then
                                newcost[j] = cost[i]
                            end
                        end
                    end
                    cost = newcost
                    chance = recipe.chance
                end
            end
        end
        if not out or out:is_empty() then return false end
        -- S M E L T, TODO: yeah i'm sure this can be easily optimized but ehh a for loop "woorks"
        for i = 1, efficiency do
            if inventory:contains_item("src1", cost[1]) and
                (not cost[2] or inventory:contains_item("src2", cost[2])) and
                (not cost[3] or inventory:contains_item("src3", cost[3]))
                and inventory:room_for_item("dst", out)
            then
                if not chance or (chance and math.random() <= chance) then
                    inventory:remove_item("src1", cost[1])
                    if cost[2] then inventory:remove_item("src2", cost[2]) end
                    if cost[3] then inventory:remove_item("src3", cost[3]) end
                    inventory:add_item("dst", out)
                end
            else
                break
            end
        end
        -- dump to item output
        local item_output = vector.from_string(meta:get_string("item_output"))
        if item_output then
            local node = sbz_api.get_node_force(item_output)
            if node then
                local list = inventory:get_list("dst")
                for _, stack in pairs(list) do
                    local dir = -core.facedir_to_dir(node.param2)
                    local vel = { x = dir.x, y = dir.y, z = dir.z, speed = 1 }
                    pipeworks.tube_inject_item(vector.add(item_output, dir), item_output, vel, stack, {},
                        vector.add(item_output, dir))
                end
                inventory:set_list("dst", { ItemStack(), ItemStack(), ItemStack(), ItemStack() })
            end
        end
    end,
    -- virtual "src" inventory
    allow_metadata_inventory_put = function(pos, listname, index, stack, player)
        if listname == "dst" then return 0 end -- dont allow inserting to dst
        if listname == "src" then
            local meta = core.get_meta(pos)
            local inv = meta:get_inventory()
            local mode = meta:get_string("furnace_mode")
            local max_src = 1
            if mode == "Alloyer" then max_src = 2 end
            if mode == "Blast" then max_src = 3 end
            for i = 1, max_src do
                if inv:room_for_item("src" .. i, stack) then
                    local existing_stack = inv:get_stack("src" .. i, 1)
                    local new_stack = ItemStack(existing_stack); new_stack:add_item(stack)
                    inv:set_stack("src" .. i, 1, new_stack)
                    return stack:get_stack_max() - existing_stack:get_count()
                end
            end
            return 0
        end
        return stack:get_count()
    end,
    on_metadata_inventory_put = function(pos, listname, index, stack, player)
        core.get_meta(pos):get_inventory():set_stack("src", 1, ItemStack()) -- clear it asap
    end,
    on_multiblock_break = function(pos, meta)
        meta:set_string("power_port", "") -- this makes it aware that it should be off
        meta:set_string("item_output", "")
        meta:set_string("formspec", get_furnce_controller_formspec(pos))
    end,
    get_schematic = make_schem,
    after_dig_node = sbz_api.multiblocks.after_dig_controller("sbz_multiblocks:blast_furnace_controller"),
    before_movenode = sbz_api.multiblocks.before_movenode,
})

core.register_node("sbz_multiblocks:blast_furnace_casing", ud {
    description = "Blast Furnace Casing",
    groups = {
        matter = 1,
        wallsharing = 1,
    },
    info_extra = "Nobody says that you can't use theese as decoration...",
    drawtype = "glasslike_framed",
    paramtype = "light",
    paramtype2 = "color",
    tiles = {
        "blast_furnace_casing_frame.png",
        "blast_furnace_casing_inner.png",
    },
    light_source = 3,
    after_dig_node = sbz_api.multiblocks.after_dig,
    before_movenode = sbz_api.multiblocks.before_movenode,
})

core.register_node("sbz_multiblocks:blast_furnace_heater", ud {
    description = "Blast Furnace Heater",
    heater_power_use = 5,
    info_power_needed = 5, -- they do not connect to cables directly
    groups = {
        matter = 1,
    },
    drawtype = "glasslike_framed",
    paramtype = "light",
    paramtype2 = "color",
    tiles = {
        "blast_furnace_heater_frame.png",
        "blast_furnace_heater_inner.png",
    },
    --    overlay_tiles = {
    -- Hehe, whoever made the glasslike_framed drawtype certainly did NOT think of this use i can bet,
    --        "blast_furnace_heater_top.png",
    --},
    -- edit: does not work
    use_texture_alpha = "clip",
    light_source = 3,
    wallmounted_rotate_vertical = true,
    after_dig_node = sbz_api.multiblocks.after_dig,
    before_movenode = sbz_api.multiblocks.before_movenode,
})

sbz_api.register_machine("sbz_multiblocks:blast_furnace_power_port", ud {
    description = "Blast Furnace Power Port",
    groups = {
        matter = 1,
        multiblock_power_port = 1,
    },
    connect_sides = { "front" },
    paramtype = "light",
    paramtype2 = "colorfacedir",
    tiles = {
        "blast_furnace_power_port_sides.png",
        "blast_furnace_power_port_sides.png",
        "blast_furnace_power_port_sides.png",
        "blast_furnace_power_port_sides.png",
        "blast_furnace_power_port_sides.png",
        "blast_furnace_power_port_front.png",
    },
    light_source = 3,
    action = function(pos, node, meta, supply, demand, dir)
        local controller_pos = vector.from_string(meta:get_string("controller_pos"))
        local controller_node
        if controller_pos then
            controller_node = sbz_api.get_node_force(controller_pos)
        end
        if controller_pos and controller_node and (controller_node or {}).name == "sbz_multiblocks:blast_furnace_controller" then
            local num_of_heater_rows = core.get_meta(controller_pos):get_int("num_of_heater_rows")
            local heaters = num_of_heater_rows * 9
            local heater_consume = heaters * 5
            if supply >= demand + heater_consume then
                meta:set_int("active", 1)
                meta:set_string("infotext",
                    "Powering " .. heaters .. " heaters, and consuming " .. heater_consume .. "Cj, 5Cj per heater")
                if core.registered_nodes[controller_node.name].power_port_action(controller_pos, core.get_meta(controller_pos)) == false then
                    meta:set_string("infotext", "Furnace is idle.")
                    return 0
                else
                    return heaters * 5
                end
            else
                meta:set_int("active", 0)
                meta:set_string("infotext", "Not enough power, needs: " .. heater_consume .. "Cj")
                return 0
            end
        else
            meta:set_int("active", 0)
            meta:set_string("infotext", "Not linked")
            return 0
        end
    end,
    after_dig_node = sbz_api.multiblocks.after_dig,
    before_movenode = sbz_api.multiblocks.before_movenode,
})

core.register_node("sbz_multiblocks:blast_furnace_item_input", ud {
    description = "Blast Furnace Item Input",
    info_extra = "It will never clog the furnace just trust me, if it does somehow its a bug",
    groups = {
        matter = 1,
        tubedevice = 1,
        tubedevice_receiver = 1,
        multiblock_item_input = 1,
    },
    connect_sides = { "front" },
    paramtype = "light",
    paramtype2 = "colorfacedir",
    tiles = {
        "blast_furnace_item_IO_sides.png",
        "blast_furnace_item_IO_sides.png",
        "blast_furnace_item_IO_sides.png",
        "blast_furnace_item_IO_sides.png",
        "blast_furnace_item_IO_sides.png",
        "blast_furnace_item_input_front.png",
    },
    light_source = 3,
    tube = {
        connect_sides = { front = 1 },
        can_insert = function(pos, node, stack, direction)
            local meta = core.get_meta(pos)
            local controller_pos = vector.from_string(meta:get_string("controller_pos"))
            if not controller_pos then
                return false
            else
                meta = core.get_meta(controller_pos)
                local inv = meta:get_inventory()
                local src_stacks = { inv:get_stack("src1", 1), inv:get_stack("src2", 1), inv:get_stack("src3", 1) }
                for i = 1, 3 do
                    if src_stacks[i]:is_empty() or src_stacks[i]:get_name() == stack:get_name() then
                        if src_stacks[i]:get_stack_max() == src_stacks[i]:get_count() then return false end
                        return true
                    end
                end
                return false
            end
        end,
        insert_object = function(pos, node, stack, direction)
            -- returns leftover
            local meta = core.get_meta(pos)
            local controller_pos = vector.from_string(meta:get_string("controller_pos"))
            if not controller_pos then
                return stack
            else
                meta = core.get_meta(controller_pos)
                local inv = meta:get_inventory()
                local src_stacks = { inv:get_stack("src1", 1), inv:get_stack("src2", 1), inv:get_stack("src3", 1) }
                for i = 1, 3 do
                    if src_stacks[i]:is_empty() or src_stacks[i]:get_name() == stack:get_name() then
                        if src_stacks[i]:get_stack_max() == src_stacks[i]:get_count() then return stack end
                        -- can actually insert
                        local leftover = src_stacks[i]:add_item(stack)
                        inv:set_stack("src" .. i, 1, src_stacks[i])
                        return leftover
                    end
                end
                return stack
            end
        end,
    },
    after_dig_node = sbz_api.multiblocks.after_dig,
    before_movenode = sbz_api.multiblocks.before_movenode,
})
core.register_node("sbz_multiblocks:blast_furnace_item_output", ud {
    description = "Blast Furnace Item Output",
    groups = {
        matter = 1,
        tubedevice = 1,
        tubedevice_receiver = 1,
        multiblock_item_output = 1,
    },
    connect_sides = { "front" },
    paramtype = "light",
    paramtype2 = "colorfacedir",
    tiles = {
        "blast_furnace_item_IO_sides.png",
        "blast_furnace_item_IO_sides.png",
        "blast_furnace_item_IO_sides.png",
        "blast_furnace_item_IO_sides.png",
        "blast_furnace_item_IO_sides.png",
        "blast_furnace_item_output_front.png",
    },
    light_source = 3,
    disallow_pipeworks = true,
    tube = {
        connect_sides = { front = 1 },
        can_insert = function(pos, node, stack, direction)
            return false
        end,
        insert_object = function(pos, node, stack, direction)
            return stack
        end,
        priority = -1,
    },
    after_dig_node = sbz_api.multiblocks.after_dig,
    before_movenode = sbz_api.multiblocks.before_movenode,
})

-- wrench blacklist
wrench.blacklist_item("sbz_multiblocks:blast_furnace_controller")
wrench.blacklist_item("sbz_multiblocks:blast_furnace_casing")
wrench.blacklist_item("sbz_multiblocks:blast_furnace_heater")
wrench.blacklist_item("sbz_multiblocks:blast_furnace_item_output")
wrench.blacklist_item("sbz_multiblocks:blast_furnace_item_input")

-- yey... 566 lines of codes in...
core.register_craft {
    output = "sbz_multiblocks:blast_furnace_casing 9",
    recipe = {
        { "sbz_chem:invar_block", "sbz_chem:invar_block",  "sbz_chem:invar_block", },
        { "sbz_chem:invar_block", "sbz_chem:silver_block", "sbz_chem:invar_block", },
        { "sbz_chem:invar_block", "sbz_chem:invar_block",  "sbz_chem:invar_block", },
    }
}

core.register_craft {
    output = "sbz_multiblocks:blast_furnace_controller",
    recipe = {
        { "sbz_chem:silver_block",                "sbz_multiblocks:blast_furnace_casing", "sbz_chem:silver_block", },
        { "sbz_multiblocks:blast_furnace_casing", "sbz_resources:simple_processor",       "sbz_multiblocks:blast_furnace_casing", },
        { "sbz_chem:silver_block",                "sbz_multiblocks:blast_furnace_casing", "sbz_chem:silver_block", },
    }
}

core.register_craft {
    output = "sbz_multiblocks:blast_furnace_heater 2",
    recipe = {
        { "sbz_multiblocks:blast_furnace_casing", "sbz_resources:heating_element", "sbz_multiblocks:blast_furnace_casing", },
        { "sbz_multiblocks:blast_furnace_casing", "sbz_resources:heating_element", "sbz_multiblocks:blast_furnace_casing", },
        { "sbz_multiblocks:blast_furnace_casing", "sbz_resources:heating_element", "sbz_multiblocks:blast_furnace_casing", }
    }
}

core.register_craft {
    output = "sbz_multiblocks:blast_furnace_item_input",
    recipe = {
        { "sbz_chem:silver_block",                "sbz_multiblocks:blast_furnace_casing", "sbz_chem:silver_block" },
        { "sbz_multiblocks:blast_furnace_casing", "sbz_resources:storinator_bronze",      "sbz_multiblocks:blast_furnace_casing" },
        { "sbz_chem:silver_block",                "sbz_multiblocks:blast_furnace_casing", "sbz_chem:silver_block" },
    }
}

core.register_craft {
    output = "sbz_multiblocks:blast_furnace_item_output",
    recipe = {
        { "sbz_chem:silver_block",                "sbz_multiblocks:blast_furnace_casing", "sbz_chem:silver_block" },
        { "sbz_multiblocks:blast_furnace_casing", "pipeworks:automatic_filter_injector",  "sbz_multiblocks:blast_furnace_casing" },
        { "sbz_chem:silver_block",                "sbz_multiblocks:blast_furnace_casing", "sbz_chem:silver_block" },
    }
}

core.register_craft {
    output = "sbz_multiblocks:blast_furnace_power_port",
    recipe = {
        { "sbz_chem:silver_block",                "sbz_multiblocks:blast_furnace_casing", "sbz_chem:silver_block" },
        { "sbz_multiblocks:blast_furnace_casing", "sbz_power:power_pipe",                 "sbz_multiblocks:blast_furnace_casing" },
        { "sbz_chem:silver_block",                "sbz_multiblocks:blast_furnace_casing", "sbz_chem:silver_block" },
    }
}
