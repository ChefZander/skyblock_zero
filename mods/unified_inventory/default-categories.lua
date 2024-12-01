local S = minetest.get_translator("unified_inventory")
local ui = unified_inventory

unified_inventory.register_category('organics', {
	symbol = "sbz_bio:warpshroom",
	label = S("Organics")
})

unified_inventory.register_category('tools', {
	symbol = "sbz_resources:robotic_arm",
	label = S("Tools")
})
unified_inventory.register_category('chem', {
	symbol = "sbz_chem:iron_ingot",
	label = S("Chemistry")
})

unified_inventory.register_category('deco', {
	symbol = "sbz_decor:factory_warning",
	label = S("Decorations")
})

unified_inventory.register_category("machines", {
	symbol = "sbz_power:advanced_matter_extractor",
	label = S("Machines")
})

unified_inventory.register_category("pipeworks", {
	symbol = "pipeworks:tube_1",
	label = S "Item or Fluid Transportation"
})
unified_inventory.register_category("lua", {
	symbol = "sbz_logic:lua_controller_on",
	label = S "Luacontrollers"
})

local function register_automatic_categorization()
	-- Preparation for ore registration: find all possible drops (digging)
	local possible_node_dig_drops = {}
	for itemname, recipes in pairs(ui.crafts_for.usage) do
		for _, recipe in ipairs(recipes) do
			if recipe.type == "digging" or recipe.type == "digging_chance" then
				if not possible_node_dig_drops[itemname] then
					possible_node_dig_drops[itemname] = {}
				end
				local stack = ItemStack(recipe.output)
				table.insert(possible_node_dig_drops[itemname], stack:get_name())
			end
		end
	end



	-- Add items by item definition
	for name, def in pairs(minetest.registered_items) do
		local group = def.groups or {}
		if not group.not_in_creative_inventory then
			if group.plant or
				group.burn or
				group.ui_bio or
				group.co2_source or
				group.soil or
				group.needs_co2
			then
				unified_inventory.add_category_item('organics', name)
			end
			if def.type == 'tool' then
				unified_inventory.add_category_item('tools', name)
			end
			if string.sub(name, 1, #"sbz_decor") == "sbz_decor" or def.mod_origin == "sbz_decor" then
				unified_inventory.add_category_item('deco', name)
			end
			if group.chem_element then
				unified_inventory.add_category_item("chem", name)
			end
			if group.sbz_machine then
				unified_inventory.add_category_item("machines", name)
			end
			if string.sub(name, 1, #"pipeworks") == "pipeworks" or group.ui_fluid then
				unified_inventory.add_category_item("pipeworks", name)
			end
			if group.ui_logic then
				unified_inventory.add_category_item("lua", name)
			end
		end
	end
end

if ui.automatic_categorization then
	ui.register_on_initialized(register_automatic_categorization)
end
