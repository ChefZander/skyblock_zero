local f = string.format

local current_id = 0

local function get_next_id()
	current_id = current_id + 1
	return current_id
end

local EphemeralHud = futil.class1()

function EphemeralHud:_init(player, hud_def)
	self._player_name = player:get_player_name()
	if (hud_def.type or hud_def.hud_elem_type) == "waypoint" then
		self._id_field = "text2"
	else
		self._id_field = "name"
	end
	self._id = f("ephemeral_hud:%s:%i", hud_def[self._id_field] or "", get_next_id())
	hud_def[self._id_field] = self._id
	self._hud_id = player:hud_add(hud_def)
end

function EphemeralHud:is_active()
	if not self._hud_id then
		return false
	end
	local player = minetest.get_player_by_name(self._player_name)
	if not player then
		self._hud_id = nil
		return false
	end
	local hud_def = player:hud_get(self._hud_id)
	if not hud_def then
		self._hud_id = nil
		return false
	end
	if hud_def[self._id_field] ~= self._id then
		self._hud_id = nil
		return false
	end

	return true
end

function EphemeralHud:change(new_hud_def)
	if not self:is_active() then
		futil.log("warning", "[ephemeral hud] cannot update an inactive hud")
		return false
	end
	local player = minetest.get_player_by_name(self._player_name)
	local old_hud_def = player:hud_get(self._hud_id)
	for key, value in pairs(new_hud_def) do
		if key == "hud_elem_type" then
			if value ~= (old_hud_def.type or old_hud_def.hud_elem_type) then
				error("cannot change hud_elem_type")
			end
		elseif key == "type" then
			if value ~= (old_hud_def.type or old_hud_def.hud_elem_type) then
				error("cannot change type")
			end
		elseif key == self._id_field then
			if value ~= self._id then
				error(f("cannot change the value of %q, as this is an ID", self._id_field))
			end
		else
			if key == "position" or key == "scale" or key == "align" or key == "offset" then
				value = futil.vector.v2f_to_float_32(value)
			end

			if not futil.equals(old_hud_def[key], value) then
				player:hud_change(self._hud_id, key, value)
			end
		end
	end
	return true
end

function EphemeralHud:remove()
	if not self:is_active() then
		futil.log("warning", "[ephemeral hud] cannot remove an inactive hud")
		return false
	end
	local player = minetest.get_player_by_name(self._player_name)
	player:hud_remove(self._hud_id)
	self._hud_id = nil
end

futil.EphemeralHud = EphemeralHud

-- note: sometimes HUDs can fail to get created. if so, the HUD object returned here will be "inactive".
function futil.create_ephemeral_hud(player, timeout, hud_def)
	local hud = EphemeralHud(player, hud_def)
	minetest.after(timeout, function()
		if hud:is_active() then
			hud:remove()
		end
	end)
	return hud
end
