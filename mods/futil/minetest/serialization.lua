local f = string.format

local deserialize = minetest.deserialize

local pairs_by_key = futil.table.pairs_by_key

function futil.serialize(x)
	if type(x) == "number" or type(x) == "boolean" or type(x) == "nil" then
		return tostring(x)
	elseif type(x) == "string" then
		return f("%q", x)
	elseif type(x) == "table" then
		local parts = {}
		for k, v in pairs_by_key(x) do
			table.insert(parts, f("[%s] = %s", futil.serialize(k), futil.serialize(v)))
		end
		return f("{%s}", table.concat(parts, ", "))
	else
		error(f("can't serialize type %s", type(x)))
	end
end

function futil.deserialize(data)
	return deserialize(f("return %s", data))
end

function futil.serialize_invlist(inv, listname)
	local itemstrings = {}
	local list = inv:get_list(listname)

	if not list then
		error(f("couldn't find list %s of %s", listname, minetest.write_json(inv:get_location())))
	end

	for _, stack in ipairs(list) do
		table.insert(itemstrings, stack:to_string())
	end

	return futil.serialize(itemstrings)
end

function futil.deserialize_invlist(serialized_list, inv, listname)
	if not inv:is_empty(listname) then
		error(("trying to deserialize into a non-empty list %s (%s)"):format(listname, serialized_list))
	end

	local itemstrings = futil.deserialize(serialized_list) or minetest.parse_json(serialized_list)

	inv:set_size(listname, #itemstrings)

	for i, itemstring in ipairs(itemstrings) do
		inv:set_stack(listname, i, ItemStack(itemstring))
	end
end

function futil.serialize_inv(inv)
	local serialized_lists = {}

	for listname in pairs(inv:get_lists()) do
		serialized_lists[listname] = futil.serialize_invlist(inv, listname)
	end

	return futil.serialize(serialized_lists)
end

function futil.deserialize_inv(serialized_lists, inv)
	for listname, serialized_list in pairs(futil.deserialize(serialized_lists)) do
		futil.deserialize_invlist(serialized_list, inv, listname)
	end
end

function futil.serialize_node_meta(pos)
	local meta = minetest.get_meta(pos)
	local inv = meta:get_inventory()
	return futil.serialize({
		fields = meta:to_table().fields,
		inventory = futil.serialize_inv(inv),
	})
end

function futil.deserialize_node_meta(serialized_node_meta, pos)
	local meta = minetest.get_meta(pos)
	local x = futil.deserialize(serialized_node_meta)
	meta:from_table({ fields = x.fields })
	local inv = meta:get_inventory()
	futil.deserialize_inv(x.inventory, inv)
end
