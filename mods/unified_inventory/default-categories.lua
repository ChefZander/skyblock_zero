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
	label = S("Powders and Ingots")
})

unified_inventory.register_category('lighting', {
	symbol = "sbz_decor:photonlamp",
	label = S("Lighting")
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
				group.habitat_conducts or
				group.burn or
				group.ui_bio or
				group.habitat_conducts or
				group.co2_source or
				group.soil or
				group.needs_co2
			then
				unified_inventory.add_category_item('organics', name)
			elseif def.type == 'tool' then
				unified_inventory.add_category_item('tools', name)
			elseif def.liquidtype == 'source' then
				unified_inventory.add_category_item('environment', name)
			elseif def.light_source and def.light_source > 0 then
				unified_inventory.add_category_item('lighting', name)
			end
		end
	end
end

if ui.automatic_categorization then
	ui.register_on_initialized(register_automatic_categorization)
end
