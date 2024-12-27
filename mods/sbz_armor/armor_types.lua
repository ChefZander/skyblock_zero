local armor = sbz_api.armor
local recipes = armor.recipes

local admin_armor_protect = {
    immortal = -1,
    matter = 100,
    light = 100,
    antimatter = 100,
    strange = 100,
}

local armor_types_to_names = {
    head = "Helmet",
    legs = "Leggings",
    feet = "Boots",
    torso = "Chestplate"
}



for armor_type, armor_name in pairs(armor_types_to_names) do
    armor.register("sbz_armor:admin_" .. armor_name:lower(), {
        description = "Admin " .. armor_name,
        armor_type = armor_type,
        inventory_image = ("(armor_%s_inv.png^[multiply:grey)"):format(armor_name:lower()),
        armor_texture = ("(armor_%s_body.png^[multiply:grey)"):format(armor_name:lower()),
        armor_groups = recipes.get_protection(admin_armor_protect, armor_name:lower()),
        custom_wear = true,
    })
end

local function make_armor(
    armor_type, armor_name, armor_internal_prefix, description, color, armor_groups, durability, material
)
    armor.register(armor_internal_prefix .. armor_name:lower(), {
        description = description .. armor_name,
        armor_type = armor_type,
        inventory_image = ("(armor_%s_inv.png^[multiply:%s)"):format(armor_name:lower(), color),
        armor_texture = ("(armor_%s_body.png^[multiply:%s)"):format(armor_name:lower(), color),
        armor_groups = recipes.get_protection(armor_groups, armor_name:lower()),
        custom_wear = false,
        durability = durability, -- 100 damage that can be handled by this armor
    })
    core.register_craft {
        output = armor_internal_prefix .. armor_name:lower(),
        recipe = recipes[armor_name:lower()](material)
    }
end

for armor_type, armor_name in pairs(armor_types_to_names) do
    make_armor(armor_type, armor_name, "sbz_armor:matter_", "Matter ", "#352A4A", {
        matter = 10,
        light = 4,
    }, 100, "sbz_resources:reinforced_matter")

    make_armor(armor_type, armor_name, "sbz_armor:antimatter_", "Antimatter ", "#85abab", {
        antimatter = 10,
        light = 4,
    }, 100, "sbz_resources:reinforced_antimatter")

    make_armor(armor_type, armor_name, "sbz_armor:core_dust_", "Core Dust ", "#fbf236", {
        antimatter = 8,
        matter = 8,
        light = 12,
    }, 120, "sbz_resources:compressed_core_dust")

    -- NOW... the late game armor i guess(?) yeah sorry, not balanced

    make_armor(armor_type, armor_name, "sbz_armor:reactor_shell_", "Reactor Shell ", "#5b6ee1", {
        matter = 40,
        antimatter = 40,
        light = 80,
    }, 8000, "sbz_power:reactor_shell")

    -- the extreme armors
    make_armor(armor_type, armor_name, "sbz_armor:neutronium_", "Neutronium ", "#ffffff^[invert:rgb^[multiply:#c2ccd1", {
        matter = 90,
        antimatter = 0,
        light = 99,
    }, 8000, "sbz_meteorites:neutronium")

    make_armor(armor_type, armor_name, "sbz_armor:antineutronium_", "Antineutronium ", "#c2ccd1^[invert:rgb", {
        matter = 0,
        antimatter = 90,
        light = 99,
    }, 8000, "sbz_meteorites:antineutronium")
end
