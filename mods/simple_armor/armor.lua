

local get_armor = function(meta)
	local armor_state = meta:get_string("simple_armor_state")
	if not (armor_state and armor_state ~= "") then return end
	return minetest.deserialize(armor_state)
end

local set_armor = function(meta, armor)
	return meta:set_string("simple_armor_state", minetest.serialize(armor))
end

local ARMOR_ON = -1
local ARMOR_OFF = 1 

local apply_armor = function(player, armor, action)

	local def = minetest.registered_items[armor.name]
	local armor = def._simple_armor
	local armor_groups = player:get_armor_groups() or {}

	if armor.texture then 
		local props = player:get_properties()

		local tex_idx = 1
		if props.textures[3] then tex_idx = 3 end -- if use third texture if model has one

		local tex = table.remove(props.textures, tex_idx)

		local tex_pre = tex and tex ~= "" and "^" or ""
		local armor_tex = tex_pre..armor.texture
		local pattern = "[%^]?"..armor.texture

		if action == ARMOR_OFF then
			tex = tex:gsub(pattern, "");
		else
			tex = tex .. armor_tex;
		end

		table.insert(props.textures, tex_idx, tex)
		player:set_properties(props)
	end

	for k, v in pairs(armor.groups) do
		armor_groups[k] = (armor_groups[k] or 0) + v*action
	end
	return player:set_armor_groups(armor_groups)
end

simple_armor.unequip = function(itemstack, player, pointed_thing)

	local meta = player:get_meta()
	local equipped = get_armor(meta)

	if not equipped then return "" end

	local slot, unequip = next(equipped)
	if not unequip then return "" end

	apply_armor(player, unequip, ARMOR_OFF)
	equipped[slot] = nil
	set_armor(meta, equipped)

	itemstack:add_item(unequip.name)
	return itemstack
end

simple_armor.equip = function (itemstack, player, pointed_thing)

	local meta = player:get_meta()
	local item = itemstack:peek_item()
	local def = minetest.registered_items[item:get_name()]
	local armor = def._simple_armor
	local slot = armor.slot

	local equipped = get_armor(meta) or {}
	
	local unequip = equipped[slot]
	if unequip then
		apply_armor(player, unequip, ARMOR_OFF)
	end

	item = itemstack:take_item() 


	equipped[slot] = { name = item:get_name() } 

	apply_armor(player, equipped[slot], ARMOR_ON)
	set_armor(meta, equipped)

	return unequip and unequip.name or ""
end

-- armor_group values are not persisted, so armor must be re-applied on login
minetest.register_on_joinplayer(function (player)
	local meta = player:get_meta()	
	local equipped = get_armor(meta)
	if not equipped then return end

	for k,v in pairs(equipped) do
		apply_armor(player, v, ARMOR_ON)
	end

	set_armor(meta, equipped)
	
end)

simple_armor.register = function(name, def) 
	def._simple_armor = def.armor
	def.armor = nil
	def.on_secondary_use = simple_armor.equip
	minetest.register_craftitem(name, def)
end

minetest.override_item("", {
	on_secondary_use = simple_armor.unequip,
})

