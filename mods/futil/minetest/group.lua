function futil.add_groups(itemstring, new_groups)
	local def = minetest.registered_items[itemstring]
	if not def then
		error(("attempting to override unknown item %s"):format(itemstring))
	end
	local groups = table.copy(def.groups or {})
	futil.table.set_all(groups, new_groups)
	minetest.override_item(itemstring, { groups = groups })
end

function futil.remove_groups(itemstring, ...)
	local def = minetest.registered_items[itemstring]
	if not def then
		error(("attempting to override unknown item %s"):format(itemstring))
	end
	local groups = table.copy(def.groups or {})
	for _, group in ipairs({ ... }) do
		groups[group] = nil
	end
	minetest.override_item(itemstring, { groups = groups })
end

function futil.get_items_with_group(group)
	if futil.items_by_group then
		return futil.items_by_group[group] or {}
	end

	local items = {}

	for item in pairs(minetest.registered_items) do
		if minetest.get_item_group(item, group) > 0 then
			table.insert(items, item)
		end
	end

	return items
end

function futil.get_item_with_group(group)
	return futil.get_items_with_group(group)[1]
end

function futil.generate_items_by_group()
	local items_by_group = {}

	for item, def in pairs(minetest.registered_items) do
		for group in pairs(def.groups or {}) do
			local items = items_by_group[group] or {}
			table.insert(items, item)
			items_by_group[group] = items
		end
	end

	futil.items_by_group = items_by_group
end

if INIT == "game" then
	-- it's not 100% safe to assume items and groups can't change after this point.
	-- but please, don't do that :\
	minetest.register_on_mods_loaded(futil.generate_items_by_group)
end
