local function allow_metadata_inventory_put(pos, listname, index, stack, player)
    if listname == "dst" then
        return 0
    end
    return stack:get_count()
end

local function allow_metadata_inventory_move(pos, from_list, from_index, to_list, to_index, count, player)
    if to_list == "dst" then return 0 end
    return count
end


local ticks = 60 * 3 -- 3 minutes... yeah
sbz_api.register_stateful_machine("sbz_power:phlogiston_fuser", {
    description = "Phlogiston Fuser",
    tiles = {
        "phlogiston_fuser_side.png",
        "phlogiston_fuser_side.png",
        "phlogiston_fuser_side.png",
        "phlogiston_fuser_side.png",
        "phlogiston_fuser_side.png",
        "phlogiston_fuser_off.png",
    },
    groups = { matter = 1, antimatter = 1 },
    paramtype2 = "4dir",
    allow_metadata_inventory_move = allow_metadata_inventory_move,
    allow_metadata_inventory_put = allow_metadata_inventory_put,

    --input_inv = "src",
    output_inv = "dst",
    on_construct = function(pos)
        local meta = minetest.get_meta(pos)
        local inv = meta:get_inventory()
        inv:set_size("dst", 1)
        meta:set_int("fusion", 0)
        meta:set_string("formspec", [[
formspec_version[7]
size[8.2,9]
style_type[list;spacing=.2;size=.8]
list[current_player;main;0.2,5;8,4;]
list[context;dst;3.6,2;1,1;]
listring[]
    ]])
    end,
    after_place_node = pipeworks.after_place,
    after_dig_node = pipeworks.after_dig,
    autostate = true,
    action = function(pos, _, meta, supply, demand)
        local power_needed = 1000
        local inv = meta:get_inventory()

        if demand + power_needed > supply then
            meta:set_string("infotext",
                ("Not enough power, phlogiston fusion needs 1kCj over %s minutes."):format(ticks / 60))
            return 0, false
        end

        if not inv:room_for_item("dst", "sbz_resources:phlogiston 1") then
            meta:set_string("infotext", "Full")
            return 0, false
        end

        -- we have the power.... now time to start fusing
        local progress = meta:get_int("fusion")
        meta:set_string("infotext",
            ("Fusing... progress: %s%%"):format(math.floor(((progress / ticks) * 100) * 100) / 100)) -- some rounding too!
        progress = progress + 1
        meta:set_int("fusion", progress)

        if progress == ticks then
            meta:set_int("fusion", 0)
            inv:add_item("dst", ItemStack("sbz_resources:phlogiston 1"))
        end
        return power_needed
    end,
}, {
    tiles = {
        "phlogiston_fuser_side.png",
        "phlogiston_fuser_side.png",
        "phlogiston_fuser_side.png",
        "phlogiston_fuser_side.png",
        "phlogiston_fuser_side.png",
        { name = "phlogiston_fuser_on.png", animation = { type = "vertical_frames", length = 3 } },
    },
    light_source = 14,
})

minetest.register_craft({
    output = "sbz_power:phlogiston_fuser",
    recipe = {
        { "sbz_resources:phlogiston", "sbz_resources:phlogiston", "sbz_resources:phlogiston" },
        { "sbz_resources:phlogiston", "sbz_chem:crystal_grower",  "sbz_resources:phlogiston" },
        { "sbz_resources:phlogiston", "sbz_resources:phlogiston", "sbz_resources:phlogiston" },
    }
})

minetest.register_craft({
    output = "sbz_power:phlogiston_fuser",
    recipe = {
        { "sbz_power:very_advanced_battery", "sbz_power:very_advanced_battery", "sbz_power:very_advanced_battery" },
        { "sbz_meteorites:neutronium",       "sbz_chem:crystal_grower",         "sbz_meteorites:antineutronium" },
        { "sbz_power:very_advanced_battery", "sbz_power:very_advanced_battery", "sbz_power:very_advanced_battery" },
    }
})
