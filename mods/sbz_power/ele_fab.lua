-- concept shamelessly borrowed from techage

local animation_def = {
    type = "vertical_frames",
    aspect_w = 16,
    aspect_h = 16,
    length = 1,
}

local function get_possible_recipe(list, rtype, inv)
    -- this is not the ideal way to do it
    -- lets just say that LMAO
    -- this is O(spagetti)

    -- if you need to copy this function
    -- consider making an api for this, and making it like... more efficent
    local internal_recipe_list = {}
    local out = {}
    for k, v in pairs(list) do
        local str = v:get_name()
        internal_recipe_list[#internal_recipe_list + 1] = unified_inventory.get_usage_list(str)
    end
    for k, v in pairs(internal_recipe_list) do
        for kk, vv in ipairs(v) do
            if vv.type == rtype then
                out[#out + 1] = {
                    out = vv.output,
                    items = vv.items,
                }
            end
        end
    end

    for k, v in pairs(out) do
        local succ = true
        for kk, vv in pairs(v.items) do
            if not inv:contains_item("input", vv) then
                succ = false
                break
            end
        end
        if succ then
            return v
        end
    end
    return {}
end

unified_inventory.register_craft_type("ele_fab", {
    description = "Ele Fab",
    icon = "ele_fab.png^[verticalframe:8:1",
    width = 2,
    height = 2,
    dynamic_display_size = function(craft)
        return {
            width = craft.width,
            height = craft.height
        }
    end,
    uses_crafting_grid = false,
})

unified_inventory.register_craft {
    type = "ele_fab",
    output = "sbz_resources:luanium",
    items = {
        "sbz_chem:copper_ingot 8",
        "sbz_chem:silicon_ingot 8"
    },
    width = 2,
    height = 1
}

unified_inventory.register_craft {
    type = "ele_fab",
    output = "sbz_resources:lua_chip",
    items = {
        "sbz_resources:luanium 4",
        "sbz_resources:matter_plate 2"
    },
    width = 2,
    height = 1
}

unified_inventory.register_craft {
    type = "ele_fab",
    output = "sbz_resources:ram_stick_1mb",
    items = {
        "sbz_chem:gold_ingot 2",
        "sbz_chem:silicon_ingot 2"
    },
    width = 2,
    height = 1
}



local power_needed = 30

sbz_api.register_stateful_machine("sbz_power:ele_fab", {
    description = "Ele Fab",
    info_extra = "Yeah the concept is from techage.",
    tiles = {
        "ele_fab_top.png",
        "ele_fab_top.png",
        "ele_fab.png^[verticalframe:8:1"
    },
    on_construct = function(pos)
        local meta = minetest.get_meta(pos)
        local inv = meta:get_inventory()
        inv:set_size("input", 4)
        inv:set_size("output", 1)
        meta:set_string("formspec", [[
formspec_version[7]
size[8.2,9]
style_type[list;spacing=.2;size=.8]
list[context;output;6,2;1,1;]
list[context;input;1,2;2,2;]
list[current_player;main;0.2,5;8,4;]
listring[current_player;main]listring[context;input]listring[current_player;main]listring[context;output]listring[current_player;main]
]])
    end,
    autostate = true,
    action = function(pos, node, meta, supply, demand)
        local inv = meta:get_inventory()

        local recipe = get_possible_recipe(inv:get_list("input"), "ele_fab", inv)
        if not recipe.out then
            meta:set_string("infotext", "Idle")
            return 0
        end

        if not inv:room_for_item("output", recipe.out) then
            meta:set_string("infotext", "Full")
            return 0
        end

        if demand + power_needed > supply then
            meta:set_string("infotext", "Not enough power")
            return power_needed, false
        end

        for k, v in pairs(recipe.items) do
            inv:remove_item("input", v)
        end
        inv:add_item("output", recipe.out)

        meta:set_string("infotext", "Working")

        return power_needed
    end,
    input_inv = "input",
    output_inv = "output",
    groups = {
        matter = 1,
    }
}, {
    light_source = 14,
    tiles = {
        [3] = { name = "ele_fab.png", animation = animation_def },
    }
})

minetest.register_craft {
    output = "sbz_power:ele_fab",
    recipe = {
        { "sbz_power:simple_charged_field",  "sbz_resources:antimatter_plate", "sbz_power:simple_charged_field" },
        { "sbz_resources:emittrium_circuit", "sbz_resources:emittrium_glass",  "sbz_resources:emittrium_circuit" },
        { "sbz_power:simple_charged_field",  "sbz_resources:antimatter_plate", "sbz_power:simple_charged_field" }
    }
}
