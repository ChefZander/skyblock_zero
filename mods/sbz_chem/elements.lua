sbz_api.register_element = function(name, color, description)
    minetest.register_craftitem("sbz_chem:" .. name .. "_powder", {
        groups = { chem_element = 1, not_in_craft_guide = 1 },
        description = string.format(description, "Powder"),
        inventory_image = "powder.png^[colorize:" .. color .. ":100"
    })
    minetest.register_craftitem("sbz_chem:" .. name .. "_ingot", {
        groups = { chem_element = 1, ingot = 1, not_in_craft_guide = 1 },
        description = string.format(description, "Ingot"),
        inventory_image = "ingot.png^[colorize:" .. color .. ":100"
    })
    minetest.register_craft({
        type = "cooking",
        output = "sbz_chem:" .. name .. "_ingot",
        recipe = "sbz_chem:" .. name .. "_powder",

    })
end


sbz_api.register_element("gold", "#FFD700", "Gold %s (Au)")
sbz_api.register_element("silver", "#C0C0C0", "Silver %s (Ag)")
sbz_api.register_element("iron", "#B7410E", "Iron %s (Fe)")
sbz_api.register_element("copper", "#B87333", "Copper %s (Cu)")
sbz_api.register_element("aluminum", "#A9A9A9", "Aluminum %s (Al)")
sbz_api.register_element("lead", "#6E6E6E", "Lead %s (Pb)")
sbz_api.register_element("zinc", "#7F7F7F", "Zinc %s (Zn)")
sbz_api.register_element("tin", "#D2B48C", "Tin %s (Sn)")
sbz_api.register_element("nickel", "#A59B91", "Nickel %s (Ni)")
sbz_api.register_element("platinum", "#E5E4E2", "Platinum %s (Pt)")
sbz_api.register_element("mercury", "#B5B5B5", "Mercury %s (Hg)")
sbz_api.register_element("cobalt", "#0047AB", "Cobalt %s (Co)")
sbz_api.register_element("titanium", "#8A8A8A", "Titanium %s (Ti)")
sbz_api.register_element("magnesium", "#DADADA", "Magnesium %s (Mg)")
sbz_api.register_element("calcium", "#F5F5DC", "Calcium %s (Ca)")
sbz_api.register_element("sodium", "#F4F4F4", "Sodium %s (Na)")
sbz_api.register_element("lithium", "#BCC6CC", "Lithium %s (Li)")

-- alloys

sbz_api.register_element("bronze", "#CD7F32", "Bronze %s (CuSn)")
sbz_api.register_element("brass", "#B5A642", "Brass %s (CuZn)")
sbz_api.register_element("invar", "#808080", "Invar %s (FeNi)")
sbz_api.register_element("titanium_alloy", "#B0C4DE", "Titanium Alloy %s (TiAl)")
sbz_api.register_element("white_gold", "#E5E4E2", "White Gold %s (AuNi)")
