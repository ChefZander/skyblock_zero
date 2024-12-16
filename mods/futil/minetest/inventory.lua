function futil.get_location_string(inv)
	local location = inv:get_location()
	if location.type == "node" then
		return ("nodemeta:%i,%i,%i"):format(location.pos.x, location.pos.y, location.pos.z)
	elseif location.type == "player" then
		return ("player:%s"):format(location.name)
	elseif location.type == "detached" then
		return ("detached:%s"):format(location.name)
	else
		error(("unexpected location? %s"):format(dump(location)))
	end
end

-- InvRef:remove_item() ignores metadata, and sometimes that's wrong
-- for logic, see InventoryList::removeItem in inventory.cpp
function futil.remove_item_with_meta(inv, listname, itemstack)
	itemstack = ItemStack(itemstack)
	if itemstack:is_empty() then
		return ItemStack()
	end
	local removed = ItemStack()
	for i = 1, inv:get_size(listname) do
		local invstack = inv:get_stack(listname, i)
		if
			invstack:get_name() == itemstack:get_name()
			and invstack:get_wear() == itemstack:get_wear()
			and invstack:get_meta() == itemstack:get_meta()
		then
			local still_to_remove = itemstack:get_count() - removed:get_count()
			local leftover = removed:add_item(invstack:take_item(still_to_remove))
			-- if we've requested to remove more than the stack size, ignore the limit
			removed:set_count(removed:get_count() + leftover:get_count())
			inv:set_stack(listname, i, invstack)
			if removed:get_count() == itemstack:get_count() then
				break
			end
		end
	end
	return removed
end
