local options = {
    "slab", "stair", "stair_inner", "stair_outer"
}

local function make_formspec(meta)
    local inv = meta:get_inventory()

    local src = inv:get_stack("src", 1)

    inv:set_stack("choices", 1, src:get_name() .. "_slab " .. math.min(src:get_count() * 2, src:get_stack_max()))
    inv:set_stack("choices", 2, src:get_name() .. "_stair " .. math.min(src:get_count(), src:get_stack_max()))
    inv:set_stack("choices", 3, src:get_name() .. "_stair_inner " .. math.min(src:get_count(), src:get_stack_max()))
    inv:set_stack("choices", 4, src:get_name() .. "_stair_outer " .. math.min(src:get_count(), src:get_stack_max()))

    meta:set_string("formspec", [[
        formspec_version[7]
        size[10.2,9.8]
        item_image[1.5,0.5;1,1;sbz_resources:matter_blob]
        list[context;src;1.5,0.5;1,1;]
        list[context;choices;3,0.5;4,1]
        listring[current_player;main]
        listring[context;src]
        listring[current_player;main]
        listring[context;choices]
        listring[current_player;main]
list[current_player;main;0.2,3.5;8,4;]
    ]])
end

minetest.register_node("sbz_decor:cnc", --[[sbz_api.add_tube_support, nope, im not adding tube support, at least not yet]]
    {
        description = "CNC machine",
        info = "Use it to cut stairs/slabs out of nodes.",
        tiles = { "cnc_top.png", "cnc_top.png", "cnc_side.png" },
        groups = { matter = 1, },
        input_inv = "src",
        output_inv = "src",
        on_construct = function(pos)
            local meta = minetest.get_meta(pos)
            local inv = meta:get_inventory()
            inv:set_size("src", 1)
            inv:set_size("choices", 4)
            make_formspec(meta)
        end,
        allow_metadata_inventory_put = function(pos, listname, index, stack, player)
            if listname == "src" and minetest.get_item_group(stack:get_name(), "cnc") == 1 then
                return stack:get_count()
            end
            return 0
        end,
        on_metadata_inventory_put = function(pos) make_formspec(minetest.get_meta(pos)) end,
        on_metadata_inventory_move = function(pos) make_formspec(minetest.get_meta(pos)) end,
        on_metadata_inventory_take = function(pos) make_formspec(minetest.get_meta(pos)) end,
        allow_metadata_inventory_take = function(pos, listname, index, stack, player)
            if listname == "choices" then
                local inv = minetest.get_meta(pos):get_inventory()
                local srcstack = inv:get_stack("src", 1)
                local sub = stack:get_count()
                if index == 1 then
                    sub = math.ceil(sub / 2)
                end

                srcstack:set_count(srcstack:get_count() - sub)
                inv:set_stack("src", 1, srcstack:to_string())
            end
            return stack:get_count()
        end
    })
minetest.register_craft {
    output = "sbz_decor:cnc",
    recipe = {
        { "sbz_resources:reinforced_matter",  "sbz_resources:reinforced_matter", "sbz_resources:reinforced_matter" },
        { "sbz_resources:matter_annihilator", "sbz_resources:emittrium_circuit", "sbz_resources:matter_annihilator" },
        { "sbz_resources:reinforced_matter",  "sbz_resources:reinforced_matter", "sbz_resources:reinforced_matter" },
    }
}
