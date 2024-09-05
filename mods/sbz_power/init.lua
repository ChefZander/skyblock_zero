local modpath = minetest.get_modpath("sbz_power")

local function add_tube_support(def)
    --[[
    def.input_inv = def.input_inv or "input"
    def.output_inv = def.output_inv or "output"
    --]]
    if (def.input_inv or def.output_inv) and not def.disallow_pipeworks then
        def.groups.tubedevice = 1
        def.groups.tubedevice_receiver = 1
        if def.input_inv and def.output_inv then
            def.tube = def.tube or {
                insert_object = function(pos, node, stack, direction)
                    local meta = minetest.get_meta(pos)
                    local inv = meta:get_inventory()
                    if inv:get_list(def.input_inv) then
                        return inv:add_item(def.input_inv, stack)
                    end
                    return stack
                end,
                can_insert = function(pos, node, stack, direction)
                    local meta = minetest.get_meta(pos)
                    local inv = meta:get_inventory()

                    if inv:get_list(def.input_inv) then
                        stack:peek_item(1)
                        return inv:room_for_item(def.input_inv, stack)
                    end
                    return false
                end,
                input_inventory = def.output_inv,
                connect_sides = { left = 1, right = 1, back = 1, front = 1, top = 1, bottom = 1 },
            }
        elseif def.output_inv then
            def.tube = def.tube or {
                input_inventory = def.output_inv,
                connect_sides = {},
            }
        end
        def.after_place_node = def.after_place_node or pipeworks.after_place
        def.after_dig_node = def.after_dig_node or pipeworks.after_dig
    end
end

local function overwrite(original, overwrites)
    for k, v in pairs(overwrites) do
        if type(overwrites[k]) == "table" and type(original[k]) == "table" then
            overwrite(original[k], overwrites[k])
        else
            original[k] = overwrites[k]
        end
    end
    return original
end

function sbz_api.register_machine(name, def)
    def.groups = def.groups or {}

    def.groups.sbz_machine = 1
    def.groups.pipe_conducts = def.groups.pipe_conducts or 1
    def.groups.pipe_connects = 1

    add_tube_support(def)
    if not def.control_action_raw then
        local old_action = def.action
        if def.power_needed then
            function def.action(pos, node, meta, supply, demand)
                if (demand + def.power_needed) > supply then
                    meta:set_string("infotext", "Not enough power, needs: " .. def.power_needed)
                    if def.stateful then
                        sbz_api.turn_off(pos)
                    end
                    return def.power_needed
                else
                    if def.stateful then
                        sbz_api.turn_on(pos)
                    end
                    meta:set_string("infotext", "Running")
                    local count = meta:get_int("count")+1
                    local power_consumed = def.idle_consume or def.power_needed
                    if count >= def.action_interval then
                        power_consumed = old_action(pos, node, meta, supply, demand) or def.power_needed
                        meta:set_int("count", 0)
                    else
                        meta:set_int("count", count)
                    end
                    return power_consumed
                end
            end
        elseif def.autostate then
            function def.action(pos, node, meta, supply, demand)
                local power_output, overwrite_decision = old_action(pos, node, meta, supply, demand)
                if overwrite_decision ~= nil then
                    if overwrite_decision == true then
                        sbz_api.turn_on(pos)
                    elseif overwrite_decision == false then
                        sbz_api.turn_off(pos)
                    end
                else
                    if power_output <= 0 then
                        sbz_api.turn_off(pos)
                    else
                        sbz_api.turn_on(pos)
                    end
                end
                return power_output
            end
        end
    end
    minetest.register_node(name, def)
end

function sbz_api.register_generator(name, def)
    def.groups.sbz_machine = 1
    def.groups.sbz_generator = 1
    def.groups.pipe_conducts = def.groups.pipe_conducts or 1
    def.groups.pipe_connects = 1

    if def.power_generated then
        def.action = function(pos, node, meta, ...)
            meta:set_string("infotext", "Running")
            return def.power_generated
        end
        def.disallow_pipeworks = true
    else -- not just a static solar panel but also something that like.. yeah
        local old_action = def.action
        def.action = function(pos, node, meta, ...)
            if meta:get_int("count") <= 0 then
                local power_generated, no_restart_count = old_action(pos, node, meta, ...)
                meta:set_int("power_generated", power_generated)
                if not no_restart_count then
                    meta:set_int("count", def.action_interval or 0)
                end
                -- autostate :D
                if def.stateful and def.autostate then
                    if power_generated <= 0 then
                        sbz_api.turn_off(pos)
                    else
                        sbz_api.turn_on(pos)
                    end
                end
            else
                meta:set_int("count", meta:get_int("count") - 1)
            end
            return meta:get_int("power_generated")
        end
    end
    add_tube_support(def)

    minetest.register_node(name, def)
end

local function register_stateful_internal(name, def, on_def, off_def, func)
    local name_off = name .. "_off"
    local name_on = name .. "_on"

    def.stateful = true

    on_def.groups = on_def.groups or {}
    on_def.groups.not_in_creative_inventory = on_def.groups.not_in_creative_inventory or 1
    on_def.drop = on_def.drop or name_off
    func(name_on, overwrite(table.copy(def), on_def))
    func(name_off, overwrite(table.copy(def), off_def or {}))

    minetest.register_alias(name, name_off)
end

function sbz_api.register_stateful_machine(name, def, on_def, off_def)
    register_stateful_internal(name, def, on_def, off_def, sbz_api.register_machine)
end

function sbz_api.register_stateful_generator(name, def, on_def, off_def)
    register_stateful_internal(name, def, on_def, off_def, sbz_api.register_generator)
end

local ndef = minetest.registered_nodes
-- easier manipulating of stateful machines
function sbz_api.turn_off(pos)
    local node = minetest.get_node(pos)
    local nodename = node.name
    if string.sub(nodename, -3) == "_on" then
        node.name = string.sub(nodename, 1, -4) .. "_off"
        minetest.swap_node(pos, node)
    end
    local ndef_nodename = ndef[nodename]
    if ndef_nodename and ndef_nodename.on_turn_off then
        ndef_nodename.on_turn_off(pos)
    end
end

function sbz_api.turn_on(pos)
    local node = minetest.get_node(pos)
    local nodename = node.name
    if string.sub(nodename, -4) == "_off" then
        node.name = string.sub(nodename, 1, -5) .. "_on"
        minetest.swap_node(pos, node)
    end

    local ndef_nodename = ndef[nodename]
    if ndef_nodename and ndef_nodename.on_turn_on then
        ndef_nodename.on_turn_on(pos)
    end
end

function sbz_api.force_turn_off(pos, meta)
    sbz_api.turn_off(pos)
    meta:set_int("force_off", 1)
end

function sbz_api.force_turn_on(pos, meta)
    sbz_api.turn_on(pos)
    meta:set_int("force_off", 0)
end

function sbz_api.is_on(pos)
    local nodename = minetest.get_node(pos).name
    return string.sub(nodename, -4) ~= "_off"
end

dofile(modpath .. "/vm.lua")
dofile(modpath .. "/switching_station.lua")
dofile(modpath .. "/power_pipes.lua")
dofile(modpath .. "/batteries.lua")
dofile(modpath .. "/extractor.lua")
dofile(modpath .. "/generator.lua")
dofile(modpath .. "/connectors.lua")
dofile(modpath .. "/infinite_storinator.lua")
dofile(modpath .. "/misc.lua")

--fixing worlds, again remove in a few releases
local fucked_items = {
    "switching_station",
    "power_pipe",
    "battery",
    "advanced_battery",
    "creative_battery",
    "simple_matter_extractor",
    "advanced_matter_extractor",
    "simple_charge_generator",
    "simple_charged_field",
    "starlight_collector",
    "connector_off",
    "connector_on",
    "infinite_storinator",
    "phosphor_off",
    "phosphor_on"
}

local function replace_in_inv(inv)
    for listname, _ in pairs(inv:get_lists()) do
        for i = 1, inv:get_size(listname) do
            for _, itemname in ipairs(fucked_items) do
                local itemstack = inv:get_stack(listname, i)
                if itemstack:get_name() == "sbz_resources:" .. itemname then
                    itemstack:set_name("sbz_power:" .. itemname)
                    inv:set_stack(listname, i, itemstack)
                end
            end
        end
    end
end

minetest.register_on_joinplayer(function(player)
    replace_in_inv(player:get_inventory())
end)

local old_fucked_items = {}
local fucked_item_map = {}
for i, val in ipairs(fucked_items) do
    old_fucked_items[i] = val
    fucked_item_map["sbz_resources:" .. val] = "sbz_power:" .. val
end

minetest.register_lbm({
    name = "sbz_power:replace_old_nodes",
    nodenames = old_fucked_items,
    run_at_every_load = true,
    action = function(pos, node)
        if fucked_item_map[node.name] then
            node.name = fucked_item_map[node.name]
            minetest.swap_node(pos, node)
        end
    end
})

minetest.register_lbm({
    name = "sbz_power:replace_old_items_in_inv",
    nodenames = {
        "sbz_resources:storinator",
        "sbz_resources:infinite_storinator",
        "sbz_power:infinite_storinator",
        "sbz_chem:crusher",
        "sbz_chem:simple_alloy_furnace",
        "sbz_power:simple_matter_extractor",
        "sbz_power:advanced_matter_extractor",
        "sbz_power:simple_charge_generator"
    },
    run_at_every_load = true,
    action = function(pos)
        replace_in_inv(minetest.get_meta(pos):get_inventory())
    end
})
