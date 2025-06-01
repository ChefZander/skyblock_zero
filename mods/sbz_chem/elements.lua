sbz_api.blast_furnace_recipes = {}

sbz_api.crusher_drops = {}
sbz_api.crusher_drops_enhanced = {}
sbz_api.unused_chem = {}

sbz_api.register_element = function(name, color, description, def, mod)
    mod = mod or "sbz_chem:"
    def = def or {}
    local disabled, part_of_crusher_drops, radioactive = def.disabled, def.part_of_crusher_drops, def.radioactive
    if disabled == nil then disabled = false end
    local disabled_group = disabled and 1 or nil
    core.register_craftitem(mod .. name .. "_powder", {
        groups = { chem_element = 1, powder = 1, not_in_creative_inventory = disabled_group, chem_disabled = disabled_group, radioactive = radioactive },
        description = string.format(description, "Powder"),
        inventory_image = "powder.png^[colorize:" .. color .. ":150"
    })
    core.register_craftitem(mod .. name .. "_ingot", {
        groups = { chem_element = 1, ingot = 1, not_in_creative_inventory = disabled_group, chem_disabled = disabled_group, radioactive = radioactive },
        description = string.format(description, "Ingot"),
        inventory_image = "ingot.png^[multiply:" .. color --[[.. ":150"]],

    })
    local rad_resistance = def.radiation_resistance or 0

    core.register_node(mod .. name .. "_block", unifieddyes.def {
        groups = {
            chem_element = 1,
            chem_block = 1,
            not_in_creative_inventory = disabled_group,
            chem_disabled = disabled_group,
            matter = 1,
            level = 2,
            explody = 100,
            radioactive = radioactive,
            radiation_resistance = rad_resistance,
        },
        description = string.format(description, "Block"),
        drawtype = "glasslike_framed",
        tiles = { "block_frame.png^[colorize:" .. color .. ":200", "block_inner.png^[colorize:" .. color .. ":200" },
        sounds = sbz_api.sounds.metal()
    })


    -- fluid
    -- if def.fluid then
    core.register_node(("%s%s_fluid_source"):format(mod, name), {
        description = description:format("Fluid Source"),
        drawtype = "liquid",
        tiles = {
            { name = ("flowing_chemical_source.png^[multiply:%s"):format(color), backface_culling = false, },
            { name = ("flowing_chemical_source.png^[multiply:%s"):format(color), backface_culling = true, }
        },
        inventory_image = ("flowing_chemical_source.png^[multiply:%s"):format(color),
        --       use_texture_alpha = "blend",
        groups = {
            no_chem_ui = 1,
            ui_fluid = 1,
            liquid = 3,
            habitat_conducts = 1,
            transparent = 1,
            liquid_capturable = 1,
            water = 0,
            not_in_creative_inventory = disabled_group,
            chem_disabled = disabled_group,
            chem_fluid = 1,
            chem_fluid_source = 1,
            chem_element = 1,
            radioactive = (radioactive or 0) * 2,
            hot = 50,
            radiation_resistance = rad_resistance * 16,
        },
        post_effect_color = color .. "7F",
        paramtype = "light",
        walkable = false,
        pointable = false,
        buildable_to = true,
        liquidtype = "source",
        liquid_alternative_source = ("%s%s_fluid_source"):format(mod, name),
        liquid_alternative_flowing = ("%s%s_fluid_flowing"):format(mod, name),
        drop = "",
        liquid_viscosity = 7,
        liquid_renewable = false,
        sbz_node_damage = {
            matter = 5, -- 5hp/second
        },
        light_source = 14,
        liquid_range = 2,
        chem_block_form = mod .. name .. "_block"
    })

    local animation = {
        type = "vertical_frames",
        aspect_w = 16,
        aspect_h = 16,
        length = 8,
    }

    minetest.register_node(("%s%s_fluid_flowing"):format(mod, name), {
        description = description:format("Fluid Flowing"),
        drawtype = "flowingliquid",
        tiles = { { name = ("flowing_chemical_source.png^[multiply:%s"):format(color), } },
        special_tiles = {
            {
                name = ("flowing_chemical.png^[multiply:%s"):format(color),
                backface_culling = false,
                animation = animation,
            },
            {
                name = ("flowing_chemical.png^[multiply:%s"):format(color),
                backface_culling = true,
                animation = animation,
            }
        },
        --          use_texture_alpha = "blend",
        groups = {
            liquid = 3,
            no_chem_ui = 1,
            habitat_conducts = 1,
            transparent = 1,
            not_in_creative_inventory = 1,
            water = 0,
            hot = 10,
            chem_disabled = disabled_group,
            chem_fluid = 1,
            chem_fluid_source = 0,
            radioactive = radioactive,
            radiation_resistance = rad_resistance,
        },
        post_effect_color = color .. "7F",
        paramtype = "light",
        paramtype2 = "flowingliquid",
        walkable = false,
        pointable = false,
        buildable_to = true,
        liquidtype = "flowing",
        liquid_alternative_source = ("%s%s_fluid_source"):format(mod, name),
        liquid_alternative_flowing = ("%s%s_fluid_flowing"):format(mod, name),
        drop = "",
        liquid_viscosity = 7,
        sbz_node_damage = {
            matter = 3, -- 3hp/second
        },
        liquid_renewable = false,
        light_source = 14,
        liquid_range = 2,
        chem_block_form = mod .. name .. "_block",
    })

    sbz_api.register_fluid_cell(("%s%s_fluid_cell"):format(mod, name), {
        description = description:format("Fluid Cell"),
        groups = {
            chem_disabled = disabled_group,
            ui_fluid = 2,
            chem_fluid_cell = 1,
            chem_fluid_source = 0,
            not_in_creative_inventory = disabled_group,
        },
        stack_max = 4,
        cooled_form = mod .. name .. "_block",
        liquid_form = mod .. name .. "_fluid_source"
    }, ("%s%s_fluid_source"):format(mod, name), color)
    -- end
    if not disabled then
        stairs.register(mod .. name .. "_block", {
            tiles = {
                "block_full.png^[colorize:" .. color .. ":200",
                "block_full.png^[colorize:" .. color .. ":200",
                "block_full.png^[colorize:" .. color .. ":200",
                "block_full.png^[colorize:" .. color .. ":200",
                "block_full.png^[colorize:" .. color .. ":200",
                "block_full.png^[colorize:" .. color .. ":200",
            },
            tex = {
                stair_front = "block_stair_front.png^[colorize:" .. color .. ":200",
                stair_side = "block_stair_side.png^[colorize:" .. color .. ":200",
                stair_cross = "block_stair_cross.png^[colorize:" .. color .. ":200",
            }
        })
        minetest.register_craft({
            type = "cooking",
            output = mod .. name .. "_ingot",
            recipe = mod .. name .. "_powder",
        })

        sbz_api.recipe.register_craft {
            type = "crushing",
            output = mod .. name .. "_powder",
            items = { mod .. name .. "_ingot" }
        }
        sbz_api.recipe.register_craft {
            type = "compressing",
            output = mod .. name .. "_block",
            items = { mod .. name .. "_powder 9" }
        }
        sbz_api.recipe.register_craft {
            type = "compressing",
            output = mod .. name .. "_block",
            items = { mod .. name .. "_ingot 9" }
        }
        sbz_api.recipe.register_craft {
            type = "crushing",
            output = mod .. name .. "_powder 9",
            items = { mod .. name .. "_block" }
        }

        if part_of_crusher_drops == nil or part_of_crusher_drops == true then
            sbz_api.crusher_drops[#sbz_api.crusher_drops + 1] = mod .. name .. "_powder"
            sbz_api.crusher_drops_enhanced[#sbz_api.crusher_drops_enhanced + 1] = mod .. name .. "_powder"
        elseif def.part_of_enhanced_drops == true then
            sbz_api.crusher_drops_enhanced[#sbz_api.crusher_drops_enhanced + 1] = mod .. name .. "_powder"
        end
    else
        sbz_api.unused_chem[#sbz_api.unused_chem + 1] = mod .. name
    end
end

minetest.after(0, function()
    for k, v in pairs(sbz_api.unused_chem) do
        local powder = v .. "_powder"
        local ingot = v .. "_ingot"
        if unified_inventory.get_recipe_list(powder) then
            minetest.log(
                "This chemical: " ..
                powder ..
                " is disabled, and shouldn't have any use.. right... but it has!!! \n details: " ..
                dump(unified_inventory.get_recipe_list(powder)))
        end
        if unified_inventory.get_recipe_list(ingot) then
            minetest.log(
                "This chemical: " ..
                ingot ..
                " is disabled, and shouldn't have any use.. right... but it has!!! \n details: " ..
                dump(unified_inventory.get_recipe_list(ingot)))
        end
    end
end)

sbz_api.register_element("gold", "#FFD700", "Gold %s (Au)",
    { part_of_crusher_drops = false, part_of_enhanced_drops = true })
sbz_api.register_element("silver", "#F0F0F0", "Silver %s (Ag)",
    { part_of_crusher_drops = false, part_of_enhanced_drops = true })
sbz_api.register_element("iron", "#B7410E", "Iron %s (Fe)", { fluid = 1 })
sbz_api.register_element("copper", "#B87333", "Copper %s (Cu)")
sbz_api.register_element("aluminum", "#A9A9A9", "Aluminum %s (Al)")
sbz_api.register_element("tin", "#D2B48C", "Tin %s (Sn)")
sbz_api.register_element("nickel", "#88c6cc", "Nickel %s (Ni)", { fluid = 1 })
sbz_api.register_element("cobalt", "#0047AB", "Cobalt %s (Co)",
    { part_of_crusher_drops = false, part_of_enhanced_drops = true, fluid = 1 })
sbz_api.register_element("titanium", "#4A2A2A", "Titanium %s (Ti)",
    { part_of_crusher_drops = false, part_of_enhanced_drops = true })
sbz_api.register_element("lithium", "#c8a4db", "Lithium %s (Li)",
    { part_of_crusher_drops = false, part_of_enhanced_drops = true })
sbz_api.register_element("silicon", "#5ba082", "Silicon %s (Si)",
    { part_of_crusher_drops = false, part_of_enhanced_drops = true, fluid = 1 })
-- alloys

sbz_api.register_element("bronze", "#87461d", "Bronze %s (CuSn)", { part_of_crusher_drops = false })
sbz_api.register_element("invar", "#808080", "Invar %s (FeNi)", { part_of_crusher_drops = false })
sbz_api.register_element("titanium_alloy", "#B0C4DE", "Titanium Alloy %s (TiAl)", { part_of_crusher_drops = false })

-- RADIOACTIVE TECH

sbz_api.register_element("thorium", "#d633af", "Thorium %s (Th)",
    { part_of_crusher_drops = false, radioactive = 1, part_of_enhanced_drops = true })
sbz_api.register_element("uranium", "#47681e", "Uranium %s (U)",
    { part_of_crusher_drops = false, radioactive = 2, part_of_enhanced_drops = true })
sbz_api.register_element("plutonium", "#1d2aba", "Plutonium %s (Pu)",
    { part_of_crusher_drops = false, part_of_enhanced_drops = false, radioactive = 5 })
sbz_api.register_element("lead", "#6E6E6E", "Lead %s (Pb)",
    { part_of_crusher_drops = false, part_of_enhanced_drops = false, radiation_resistance = 8192 })

-- disabled tech
sbz_api.register_element("zinc", "#7F7F7F", "Zinc %s (Zn)", { disabled = true })
sbz_api.register_element("platinum", "#E5E4E2", "Platinum %s (Pt)", { disabled = true })
sbz_api.register_element("mercury", "#B5B5B5", "Mercury %s (Hg)", { disabled = true })
sbz_api.register_element("magnesium", "#DADADA", "Magnesium %s (Mg)", { disabled = true })
sbz_api.register_element("calcium", "#F5F5DC", "Calcium %s (Ca)", { disabled = true })
sbz_api.register_element("sodium", "#F4F4F4", "Sodium %s (Na)", { disabled = true })

-- disabled alloys
sbz_api.register_element("white_gold", "#E5E4E2", "White Gold %s (AuNi)",
    { disabled = true, part_of_crusher_drops = false })
sbz_api.register_element("brass", "#B5A642", "Brass %s (CuZn)", { disabled = true, part_of_crusher_drops = false })

core.register_abm {
    label = "Freeze liquid metals (group:cold>=1 contacting them)",
    nodenames = { "group:chem_fluid" },
    neighbors = { "group:cold" },
    interval = 6,
    chance = 6,
    catch_up = false,
    action = function(pos, node)
        if core.get_item_group(node.name, "chem_fluid_source") == 0 then
            core.set_node(pos, { name = "sbz_resources:stone" })
        elseif core.registered_nodes[node.name].chem_block_form then
            core.set_node(pos, { name = core.registered_nodes[node.name].chem_block_form })
        end
    end,
}
