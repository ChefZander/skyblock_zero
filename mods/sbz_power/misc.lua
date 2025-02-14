sbz_api.register_stateful_machine("sbz_power:phosphor", {
    description = "Phosphor",
    paramtype = "light",
    sunlight_propagates = true,
    drawtype = "glasslike_framed",
    tiles = { "phosphor_overlay.png", "matter_blob.png" },
    groups = { matter = 1, cracky = 3 },
    action = function(pos, node, meta, supply, demand)
        meta:set_string("infotext", "")
        if demand + 1 <= supply then
            sbz_api.turn_on(pos)
            return 1
        end
        return 0
    end,
    control_action_raw = true,
    disallow_pipeworks = true
}, {
    drawtype = "glasslike_framed",
    tiles = { "phosphor_overlay.png", "emitter_imitator.png" },
    light_source = 2,
    action = function(pos, node, meta, supply, demand)
        meta:set_string("infotext", "")
        if demand + 1 <= supply then
            return 1
        else
            sbz_api.turn_off(pos)
            return 0
        end
    end,
})

minetest.register_craft({
    type = "shapeless",
    output = "sbz_power:phosphor_off",
    recipe = { "sbz_resources:emitter_imitator", "sbz_resources:emittrium_circuit" }
})


sbz_api.register_machine("sbz_power:interactor", {
    description = "Interactor (deprecated + you hacker you! you should not own this)",
    tiles = {
        "interactor_top.png",
        "interactor_bottom.png",
        "interactor_side.png"
    },
    drop = "pipeworks:puncher",
    paramtype2 = "wallmounted",
    groups = { matter = 1, cracky = 3, not_in_creative_inventory = 1 },
    action = function(pos, node, meta, supply, demand)
        meta:set_string("infotext", "Deprecated, get rid of this.")
        return 0
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
-- Couldnt you just make pipeworks depend on the mod that implements register_machine and just call it from there ???

-- frog here: Hey anon, no, this mod depends on pipeworks
-- frog here: this mod depends on pipeworks to add pipeworks support...

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
