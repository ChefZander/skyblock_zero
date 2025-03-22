unified_inventory.register_craft_type("centrifugeing", {
    description = "Seperating",
    icon = "centrifuge.png^[verticalframe:12:1",
    width = 1,
    height = 1,
    uses_crafting_grid = false,
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

-- sand recipes
-- sand => 50% Silicon 2, 10% Gold, 100% white sand
unified_inventory.register_craft {
    output = "sbz_chem:silicon_powder 2",
    type = "centrifugeing",
    chance = 50, -- 50%
    items = {
        "sbz_resources:sand"
    }
}
unified_inventory.register_craft {
    output = "sbz_chem:gold_powder",
    type = "centrifugeing",
    chance = 10, -- 10%
    items = {
        "sbz_resources:sand"
    }
}
unified_inventory.register_craft {
    output = "sbz_resources:white_sand",
    type = "centrifugeing",
    items = {
        "sbz_resources:sand"
    }
}

-- white sand => 100% dark sand, 5% silver

unified_inventory.register_craft {
    output = "sbz_resources:dark_sand",
    type = "centrifugeing",
    items = {
        "sbz_resources:white_sand"
    }
}

unified_inventory.register_craft {
    output = "sbz_chem:silver_powder",
    chance = 5,
    type = "centrifugeing",
    items = {
        "sbz_resources:white_sand"
    }
}

-- dark sand => 100% black sand, 1% silver

unified_inventory.register_craft {
    output = "sbz_resources:black_sand",
    type = "centrifugeing",
    items = {
        "sbz_resources:dark_sand"
    }
}

unified_inventory.register_craft {
    output = "sbz_chem:silver_powder",
    chance = 1,
    type = "centrifugeing",
    items = {
        "sbz_resources:dark_sand"
    }
}

-- gravel => 10% cobalt, 10% titanium, 10% lithium, 100% 1 pebble, 75% pebble, 50% pebble, 25% pebble, 5% pebble, 1% pebble
unified_inventory.register_craft {
    output = "sbz_chem:cobalt_powder",
    chance = 10,
    type = "centrifugeing",
    items = {
        "sbz_resources:gravel"
    }
}
unified_inventory.register_craft {
    output = "sbz_chem:lithium_powder",
    chance = 10,
    type = "centrifugeing",
    items = {
        "sbz_resources:gravel"
    }
}
unified_inventory.register_craft {
    output = "sbz_chem:titanium_powder",
    chance = 10,
    type = "centrifugeing",
    items = {
        "sbz_resources:gravel"
    }
}

for k, v in ipairs {
    100, 75, 50, 25, 1
} do
    unified_inventory.register_craft {
        output = "sbz_resources:pebble",
        chance = v,
        type = "centrifugeing",
        items = {
            "sbz_resources:gravel"
        }
    }
end

sbz_api.register_stateful_machine("sbz_chem:centrifuge", {
    description = "Centrifuge",
    tiles = {
        "centrifuge.png^[verticalframe:12:1",
        "centrifuge_side.png",
        "centrifuge_side.png",
        "centrifuge_side.png",
        "centrifuge_side.png",
        "centrifuge_side.png",
    },
    groups = { matter = 1 },
    --    paramtype2 = "4dir",
    allow_metadata_inventory_move = allow_metadata_inventory_move,
    allow_metadata_inventory_put = allow_metadata_inventory_put,

    input_inv = "src",
    output_inv = "dst",
    on_construct = function(pos)
        local meta = minetest.get_meta(pos)
        local inv = meta:get_inventory()
        inv:set_size("src", 1)
        inv:set_size("dst", 16)

        meta:set_string("formspec", [[
formspec_version[7]
size[8.2,9]
style_type[list;spacing=.2;size=.8]
list[context;dst;3.5,0.5;4,4;]
list[context;src;1,2;1,1;]
list[current_player;main;0.2,5;8,4;]
listring[current_player;main]listring[context;src]listring[current_player;main]listring[context;dst]listring[current_player;main]
    ]])
    end,
    after_place_node = pipeworks.after_place,
    after_dig_node = pipeworks.after_dig,
    autostate = true,
    action = function(pos, _, meta, supply, demand)
        local power_needed = 16
        local inv = meta:get_inventory()

        if demand + power_needed > supply then
            meta:set_string("infotext", "Not enough power")
            return power_needed, false
        else
            meta:set_string("infotext", "Working...")

            local src = inv:get_list("src")

            local decremented_input = ItemStack(src[1])
            local recipe_outputs = unified_inventory.get_usage_list(src[1]:get_name())
            local outputs = {}

            for _, v in pairs(recipe_outputs or {}) do
                if v.type == "centrifugeing" then
                    if not v.chance or math.random() <= v.chance / 100 then
                        outputs[#outputs + 1] = ItemStack(v.output)
                    end
                end
            end

            if #outputs == 0 then
                meta:set_string("infotext", "Invalid/no recipe")
                return 0
            end


            for k, v in ipairs(outputs) do
                if not inv:room_for_item("dst", v) then
                    meta:set_string("infotext", "Full")
                    -- undo
                    for kk, vv in ipairs(outputs) do
                        if kk >= k then break end
                        inv:remove_item("dst", vv)
                    end
                    return 0
                else
                    inv:add_item("dst", v)
                end
            end

            decremented_input:take_item(1)


            inv:set_stack("src", 1, decremented_input)
            sbz_api.play_sfx({ name = "simple_alloy_furnace_running", gain = 0.6 }, { pos = pos })
            return power_needed
        end
    end,
}, {
    tiles = {
        { name = "centrifuge.png", animation = { type = "vertical_frames", length = 0.6 } },
        "centrifuge_side.png",
        "centrifuge_side.png",
        "centrifuge_side.png",
        "centrifuge_side.png",
        "centrifuge_side.png",
    },
    light_source = 14,
})

core.register_craft {
    output = "sbz_chem:centrifuge_off",
    recipe = {
        { "sbz_chem:iron_ingot",            "sbz_chem:iron_ingot",             "sbz_chem:iron_ingot" },
        { "sbz_power:simple_charged_field", "sbz_resources:emittrium_circuit", "sbz_power:simple_charged_field" },
        { "sbz_chem:copper_ingot",          "sbz_chem:bronze_ingot",           "sbz_chem:copper_ingot" }
    }
}
