--[[
local my_hud = futil.define_hud("my_mod:my_hud", {
	period = 1,
	catchup = nil,  -- not currently supported
	name_field = nil,  -- in case you want to override the id field
	enabled_by_default = nil,  -- set to true to enable by default
	get_hud_data = function()
		-- get data that's identical for all players
		-- passed to get_hud_def
	end,
	get_hud_def = function(player, data)
		return {}
	end,
})

my_hud:toggle_enabled(player)
]]

local f = string.format

local ManagedHud = futil.class1()

function ManagedHud:_init(hud_name, def)
	self.name = hud_name

	self._name_field = def.name_field or ((def.type or def.hud_elem_type) == "waypoint" and "text2" or "name")
	self._period = def.period
	self._get_hud_data = def.get_hud_data
	self._get_hud_def = def.get_hud_def
	self._enabled_by_default = def.enabled_by_default

	self._hud_id_by_player_name = {}

	self._hud_enabled_key = f("hud_manager:%s_enabled", hud_name)
	self._hud_name = f("hud_manager:%s", hud_name)
end

function ManagedHud:is_enabled(player)
	local meta = player:get_meta()
	local value = meta:get(self._hud_enabled_key)
	if value == nil then
		return self._enabled_by_default
	else
		return minetest.is_yes(value)
	end
end

function ManagedHud:set_enabled(player, value)
	local meta = player:get_meta()
	if minetest.is_yes(value) then
		meta:set_string(self._hud_enabled_key, "y")
	else
		meta:set_string(self._hud_enabled_key, "n")
	end
end

function ManagedHud:toggle_enabled(player)
	local meta = player:get_meta()
	local enabled = not self:is_enabled(player)
	if enabled then
		meta:set_string(self._hud_enabled_key, "y")
	else
		meta:set_string(self._hud_enabled_key, "n")
	end
	return enabled
end

function ManagedHud:update(player, data)
	local is_enabled = self:is_enabled(player)
	local player_name = player:get_player_name()
	local hud_id = self._hud_id_by_player_name[player_name]
	local old_hud_def
	if hud_id then
		old_hud_def = player:hud_get(hud_id)
		if old_hud_def and old_hud_def[self._name_field] == self._hud_name then
			if not is_enabled then
				player:hud_remove(hud_id)
				self._hud_id_by_player_name[player_name] = nil
				return
			end
		else
			-- hud_id is bad
			hud_id = nil
			old_hud_def = nil
		end
	end

	if is_enabled then
		local new_hud_def = self._get_hud_def(player, data)
		if not new_hud_def then
			if hud_id then
				player:hud_remove(hud_id)
				self._hud_id_by_player_name[player_name] = nil
			end
			return
		elseif new_hud_def[self._name_field] and new_hud_def[self._name_field] ~= self._hud_name then
			error(f("you cannot specify the value of the %q field, this is generated", self._name_field))
		end

		if old_hud_def then
			for k, v in pairs(new_hud_def) do
				if k == "position" or k == "scale" or k == "align" or k == "offset" then
					v = futil.vector.v2f_to_float_32(v)
				end

				if not futil.equals(old_hud_def[k], v) and k ~= "type" and k ~= "hud_elem_type" then
					player:hud_change(hud_id, k, v)
				end
			end
		else
			new_hud_def[self._name_field] = self._hud_name
			hud_id = player:hud_add(new_hud_def)
		end
	end

	self._hud_id_by_player_name[player_name] = hud_id
end

futil.defined_huds = {}

function futil.define_hud(hud_name, def)
	if futil.defined_huds[hud_name] then
		error(f("hud %s already exists", hud_name))
	end
	local hud = ManagedHud(hud_name, def)
	futil.defined_huds[hud_name] = hud
	return hud
end

-- TODO: register_hud instead of define_hud, plus alias the old

local function update_hud(hud, players)
	local data
	if hud._get_hud_data then
		local is_any_enabled = false
		for i = 1, #players do
			if hud:is_enabled(players[i]) then
				is_any_enabled = true
				break
			end
		end
		if is_any_enabled then
			data = hud._get_hud_data()
		end
	end
	for i = 1, #players do
		hud:update(players[i], data)
	end
end

-- TODO refactor to use futil.register_globalstep for each hud, to allow use of catchup mechanics
-- ... why would HUD updates need catchup mechanics?
local elapsed_by_hud_name = {}
minetest.register_globalstep(function(dtime)
	local players = minetest.get_connected_players()
	if #players == 0 then
		return
	end
	for hud_name, hud in pairs(futil.defined_huds) do
		if hud._period then
			local elapsed = (elapsed_by_hud_name[hud_name] or 0) + dtime
			if elapsed < hud._period then
				elapsed_by_hud_name[hud_name] = elapsed
			else
				elapsed_by_hud_name[hud_name] = 0
				update_hud(hud, players)
			end
		else
			update_hud(hud, players)
		end
	end
end)
