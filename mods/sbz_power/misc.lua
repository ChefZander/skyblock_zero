sbz_api.register_machine("sbz_power:phosphor_off", {
    description = "Phosphor",
    tiles = { "matter_blob.png^phosphor_overlay.png" },
    groups = { matter = 1, cracky = 3 },
    action = function(pos, node, meta, supply, demand)
        meta:set_string("infotext", "")
        if demand + 1 <= supply then
            minetest.set_node(pos, { name = "sbz_power:phosphor_on" })
            return 1
        end
        return 0
    end,
    control_action_raw = true
})

sbz_api.register_machine("sbz_power:phosphor_on", {
    description = "Phosphor",
    tiles = { "emitter_imitator.png^phosphor_overlay.png" },
    paramtype = "light",
    sunlight_propagates = true,
    light_source = 2,
    groups = { matter = 1, cracky = 3, pipe_connects = 1, sbz_machine = 1, not_in_creative_inventory = 1, pipe_conducts = 1 },
    drop = "sbz_power:phosphor_off",
    action = function(pos, node, meta, supply, demand)
        meta:set_string("infotext", "")
        if demand + 1 <= supply then
            return 1
        else
            minetest.set_node(pos, { name = "sbz_power:phosphor_off" })
            return 0
        end
    end,
    control_action_raw = true,
    on_timeout = function(pos, node)
        minetest.set_node(pos, { name = "sbz_power:phosphor_off" })
    end,
    disallow_pipeworks = true,
})

minetest.register_craft({
    type = "shapeless",
    output = "sbz_power:phosphor_off",
    recipe = { "sbz_resources:emitter_imitator", "sbz_resources:emittrium_circuit" }
})


sbz_api.register_machine("sbz_power:interactor", {
    description = "Interactor (legacy + you hacker you!)",
    tiles = {
        "interactor_top.png",
        "interactor_bottom.png",
        "interactor_side.png"
    },
    drops = "pipeworks:puncher",
    paramtype2 = "wallmounted",
    groups = { matter = 1, cracky = 3, not_in_creative_inventory = 1 },
    action_interval = 3, --on average, an interactor on a core is barely self-sufficient
    power_needed = 30,
    on_construct = function(pos)
        local meta = minetest.get_meta(pos)
        local inv = meta:get_inventory()
        inv:set_size("input", 1)
        inv:set_size("output", 4)
        meta:set_string("formspec",
            "formspec_version[7]" ..
            "size[8.2,9]" ..
            "style_type[list;spacing=.2;size=.8]" ..
            "list[nodemeta:" .. pos.x .. "," .. pos.y .. "," .. pos.z .. ";input;1.5,2;1,1;]" ..
            "list[nodemeta:" .. pos.x .. "," .. pos.y .. "," .. pos.z .. ";output;4.5,1.5;2,2;]" ..
            "list[current_player;main;0.2,5;8,4;]" ..
            "listring[]"
        )
    end,
    action = function(pos, node, meta, supply, demand)
        local target = pos - minetest.wallmounted_to_dir(minetest.get_node(pos).param2)
        local target_node = minetest.get_node(target)
        local inv = meta:get_inventory()
        local input_item = inv:get_stack("input", 1)
        if target_node.name == "sbz_resources:the_core" then
            local items = { "sbz_resources:core_dust", "sbz_resources:matter_dust", "sbz_resources:charged_particle" }
            local item = items[math.random(#items)]
            if inv:room_for_item("output", item) then
                inv:add_item("output", item)
            end
        elseif target_node.name == "sbz_resources:emitter" and math.random(3) == 1 then
            local item = "sbz_resources:raw_emittrium"
            if inv:room_for_item("output", item) then
                inv:add_item("output", item)
            end
        elseif input_item:get_name() == "sbz_resources:matter_annihilator"
            and minetest.get_item_group(target_node.name, "matter") then
            minetest.remove_node(target)
            inv:remove_item("input", input_item)
            if input_item:add_wear_by_uses(30) then
                inv:add_item("input", input_item)
            end
            local drops = minetest.get_node_drops(target_node, "sbz_resources:matter_annihilator")
            for _, item in ipairs(drops) do
                if inv:room_for_item("output", item) then
                    inv:add_item("output", item)
                else
                    minetest.add_item(target, item)
                end
            end
        elseif minetest.registered_nodes[input_item:get_name()] and minetest.registered_nodes[target_node.name].buildable_to then
            input_item:set_count(1)
            inv:remove_item("input", input_item)
            minetest.set_node(target, { name = input_item:get_name() })
        end
    end
})

local function vacuum(pos, radius, inv)
    radius = radius + 0.5
    local min_pos = vector.subtract(pos, radius)
    local max_pos = vector.add(pos, radius)
    for _, obj in pairs(minetest.get_objects_in_area(min_pos, max_pos)) do
        local entity = obj:get_luaentity()
        if entity and entity.name == "__builtin:item" then
            if entity.itemstring ~= "" then
                local leftover = inv:add_item("main", ItemStack(entity.itemstring))
                entity.itemstring = ""

                if leftover then
                    minetest.item_drop(leftover, fakelib.create_player(), obj:get_pos())
                end
            end
            obj:remove()
        end
    end
end

local item_vaccum_power_demand = 20
-- you expected this to be in the pipeworks mod didn't you... well its more convenient to put it here because sbz_api
sbz_api.register_machine("sbz_power:item_vacuum", {
    description = "Item Vacuum",
    tiles = { "item_vacuum.png" },
    groups = {
        sbz_machine = 1,
        pipe_conducts = 1,
        pipe_connects = 1,
        matter = 3,
        cracky = 3,
    },
    on_construct = function(pos)
        local meta = minetest.get_meta(pos)
        local inv = meta:get_inventory()
        inv:set_size("main", 8 * 2)
        meta:set_string("formspec", [[
formspec_version[7]
size[8.2,9]
style_type[list;spacing=.2;size=.8]
list[context;main;0.2,0.2;8,4;]
list[current_player;main;0.2,5;8,4;]
listring[]"
    ]])
    end,
    power_needed = item_vaccum_power_demand,
    action_interval = 3,
    action = function(pos, node, meta, supply, demand)
        vacuum(pos, 16, meta:get_inventory())
        return item_vaccum_power_demand
    end,
    output_inv = "main",
    input_inv = "main",
})

minetest.register_craft({
    output = "sbz_power:item_vacuum",
    recipe = {
        { "pipeworks:tube_1", "sbz_meteorites:neutronium", "sbz_resources:retaining_circuit" },
    }
})
