sbz_api.recipe.register_craft_type({
    type = "compressing",
    description = "Compressing",
    icon = "compressor.png^[verticalframe:11:1",
    single = true,
})

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


sbz_api.register_stateful_machine("sbz_chem:compressor", {
    description = "Compressor",
    tiles = {
        "compressor_side.png",
        "compressor_side.png",
        "compressor_side.png",
        "compressor_side.png",
        "compressor_side.png",
        "compressor.png^[verticalframe:11:1",
    },
    groups = { matter = 1 },
    paramtype2 = "4dir",
    allow_metadata_inventory_move = allow_metadata_inventory_move,
    allow_metadata_inventory_put = allow_metadata_inventory_put,

    input_inv = "src",
    output_inv = "dst",
    on_construct = function(pos)
        local meta = minetest.get_meta(pos)
        local inv = meta:get_inventory()
        inv:set_size("src", 4)
        inv:set_size("dst", 4)

        meta:set_string("formspec", [[
formspec_version[7]
size[8.2,9]
style_type[list;spacing=.2;size=.8]
list[current_player;main;0.2,5;8,4;]
list[context;src;1.5,1;2,2;]
listring[]
list[context;dst;4.5,1;2,2;]
listring[current_player;main]
listring[context;dst]
    ]])
    end,
    after_place_node = pipeworks.after_place,
    after_dig_node = pipeworks.after_dig,
    autostate = true,
    action = function(pos, _, meta, supply, demand)
        local power_needed = 20
        local inv = meta:get_inventory()

        if demand + power_needed > supply then
            meta:set_string("infotext", "Not enough power")
            return power_needed, false
        else
            meta:set_string("infotext", "Compressing...")

            local src = inv:get_list("src")

            local out, count, decremented, index = sbz_api.recipe.resolve_craft(src, "compressing", true)

            if out == nil then
                meta:set_string("infotext", "Invalid/no recipe")
                return 0
            end

            if not inv:room_for_item("dst", out) then
                meta:set_string("infotext", "Full")
                return 0
            end

            local input = inv:get_stack("src", index)
            input:set_count(input:get_count() - decremented)
            inv:set_stack("src", index, input)
            inv:add_item("dst", out)
            sbz_api.play_sfx({ name = "simple_alloy_furnace_running", gain = 0.6 }, { pos = pos })
            return power_needed
        end
    end,
}, {
    tiles = {
        "compressor_side.png",
        "compressor_side.png",
        "compressor_side.png",
        "compressor_side.png",
        "compressor_side.png",
        { name = "compressor.png", animation = { type = "vertical_frames", length = 0.7 } },
    },
    light_source = 10,
})


minetest.register_craft({
    output = "sbz_chem:compressor",
    recipe = {
        { "sbz_power:simple_charged_field", "sbz_chem:bronze_ingot",           "sbz_power:simple_charged_field" },
        { "sbz_resources:matter_blob",      "sbz_resources:emittrium_circuit", "sbz_resources:matter_blob" },
        { "sbz_power:simple_charged_field", "sbz_chem:invar_ingot",            "sbz_power:simple_charged_field" }
    }
})
