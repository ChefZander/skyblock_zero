local uip = unified_inventory_plus
local settings = minetest.settings

uip.settings = {
    enable_craft_all = settings:get_bool("unified_inventory_plus.enable_craft_all", true),
    enable_craft_organize = settings:get_bool("unified_inventory_plus.enable_craft_organize", true),
    enable_craft_rotate = settings:get_bool("unified_inventory_plus.enable_craft_rotate", true),
    enable_craft_clear = settings:get_bool("unified_inventory_plus.enable_craft_clear", true),

    craft_all_min_saturation = tonumber(settings:get("unified_inventory_plus.craft_all_min_saturation")) or 1,
}
