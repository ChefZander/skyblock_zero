local class = futil.class

--------------------

local tmp_inv_class = smartshop.tmp_inv_class
local tmp_shop_inv_class = class(tmp_inv_class)
smartshop.tmp_shop_inv_class = tmp_shop_inv_class

--------------------

function tmp_shop_inv_class:_init(shop)
	tmp_inv_class._init(self, shop.inv)

	self.is_unlimited = shop:is_unlimited()
	self.strict_meta = shop:is_strict_meta()

	local refill = shop:get_refill()
	local send = shop:get_send()

	if refill and send then
		if vector.equals(refill.pos, send.pos) then
			-- only make 1 detached inventory
			self.refill = tmp_inv_class(refill.inv)
			self.send = self.refill
		else
			self.refill = tmp_inv_class(refill.inv)
			self.send = tmp_inv_class(send.inv)
		end
	elseif refill then
		self.refill = tmp_inv_class(refill.inv)
	elseif send then
		self.send = tmp_inv_class(send.inv)
	end
end

function tmp_shop_inv_class:destroy()
	if self.refill then
		self.refill:destroy()
	end

	if self.send and self.send ~= self.refill then
		self.send:destroy()
	end

	self.send = nil
	self.refill = nil

	tmp_inv_class.destroy(self)
end

--------------------

function tmp_shop_inv_class:is_strict_meta()
	return self.strict_meta
end

-------------------

function tmp_shop_inv_class:get_all_counts(kind)
	local strict_meta = self.strict_meta
	local all_counts = tmp_inv_class.get_all_counts(self, strict_meta)

	if kind == "give" then
		local refill = self.refill
		if refill then
			for key, value in pairs(refill:get_all_counts(strict_meta)) do
				all_counts[key] = (all_counts[key] or 0) + value
			end
		end
	elseif kind == "pay" then
		local send = self.send
		if send then
			for key, value in pairs(send:get_all_counts(strict_meta)) do
				all_counts[key] = (all_counts[key] or 0) + value
			end
		end
	end

	return all_counts
end

function tmp_shop_inv_class:get_count(stack, kind)
	local strict_meta = self.strict_meta
	local count = tmp_inv_class.get_count(self, stack, strict_meta)

	if kind == "give" then
		local refill = self.refill
		if refill then
			count = count + refill:get_count(stack, strict_meta)
		end
	elseif kind == "pay" then
		local send = self.send
		if send then
			count = count + send:get_count(stack, strict_meta)
		end
	end

	return count
end

function tmp_shop_inv_class:room_for_item(stack, kind)
	if self.is_unlimited then
		return true
	end

	if tmp_inv_class.room_for_item(self, stack) then
		return true
	end

	if kind == "give" then
		local refill = self.refill
		return refill and refill:room_for_item(stack)
	elseif kind == "pay" then
		local send = self.send
		return send and send:room_for_item(stack)
	end
end

function tmp_shop_inv_class:add_item(stack, kind)
	if self.is_unlimited then
		return ItemStack()
	end

	if kind == "give" then
		local refill = self.refill
		if refill and refill:room_for_item(stack) then
			return refill:add_item(stack)
		end
	elseif kind == "pay" then
		local send = self.send
		if send and send:room_for_item(stack) then
			return send:add_item(stack)
		end
	end

	return tmp_inv_class.add_item(self, stack)
end

function tmp_shop_inv_class:contains_item(stack, kind)
	if self.is_unlimited then
		return true
	end

	local strict_meta = self.strict_meta

	if tmp_inv_class.contains_item(self, stack, strict_meta) then
		return true
	end

	if kind == "give" then
		local refill = self.refill
		return refill and refill:contains_item(stack, strict_meta)
	elseif kind == "pay" then
		local send = self.send
		return send and send:contains_item(stack, strict_meta)
	end
end

function tmp_shop_inv_class:remove_item(stack, kind)
	if self.is_unlimited then
		return stack
	end

	local strict_meta = self.strict_meta

	if kind == "give" then
		local refill = self.refill
		if refill and refill:contains_item(stack, strict_meta) then
			return refill:remove_item(stack, strict_meta)
		end
	elseif kind == "pay" then
		local send = self.send
		if send and send:contains_item(stack, strict_meta) then
			return send:remove_item(stack, strict_meta)
		end
	end

	return tmp_inv_class.remove_item(self, stack, strict_meta)
end
