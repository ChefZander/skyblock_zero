local modpath = minetest.get_modpath("sbz_power")

local function add_tube_support(def)
    def.input_inv = def.input_inv or "input"
    def.output_inv = def.output_inv or "output"

    if def.input_inv and def.output_inv and not def.disallow_pipeworks then
        def.groups.tubedevice = 1
        def.groups.tubedevice_receiver = 1
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
            input_inventory = def.input_inv,
            connect_sides = { left = 1, right = 1, back = 1, front = 1, top = 1, bottom = 1 },
        }
        def.after_place_node = def.after_place_node or pipeworks.after_place
        def.after_dig_node = def.after_dig_node or pipeworks.after_dig
    end
end

function sbz_api.register_machine(name, def)
    def.groups = def.groups or {}
    def.groups.sbz_machine = 1
    def.groups.pipe_conducts = 1
    def.groups.pipe_connects = 1

    add_tube_support(def)
    if not def.control_action_raw then
        local old_action = def.action

        function def.action(pos, node, meta, supply, demand)
            if (demand + def.power_needed) > supply then
                meta:set_string("infotext", "Not enough power, needs: " .. def.power_needed)
                return def.power_needed
            else
                meta:set_string("infotext", "Running")
                local count = meta:get_int("count")
                if count >= def.action_interval then
                    old_action(pos, node, meta, supply, demand)
                    meta:set_int("count", 0)
                else
                    meta:set_int("count", count + 1)
                end
                return def.power_needed
            end
        end
    end
    minetest.register_node(name, def)
end

function sbz_api.register_generator(name, def)
    def.groups.sbz_machine = 1
    def.groups.sbz_generator = 1
    def.groups.pipe_conducts = 1
    def.groups.pipe_connects = 1

    if def.power_generated then
        def.action = function(pos, node, meta, ...)
            meta:set_string("infotext", "Running")
            return def.power_generated
        end
        def.disallow_pipeworks = true
    end
    add_tube_support(def)

    minetest.register_node(name, def)
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
}) do
    minetest.register_alias("sbz_resources:" .. n, "sbz_power:" .. n)
end
}

local function replace_in_inv(inv)
    for listname, _ in pairs(inv:get_lists()) do
        for i = 1, inv:get_size(listname) do
            for _, itemname in ipairs(fucked_items) do
                local itemstack = inv:get_stack(listname, i)
                if itemstack:get_name() == "sbz_resources:"..itemname then
                    itemstack:set_name("sbz_power:"..itemname)
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
    fucked_item_map["sbz_resources:"..val] = "sbz_power:"..val
end

minetest.register_lbm({
    name = "sbz_power:replace_old_nodes",
    nodenames = old_fucked_items,
    run_at_every_load = true,
    action = function (pos, node)
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
    action = function (pos)
        replace_in_inv(minetest.get_meta(pos):get_inventory())
    end
})

