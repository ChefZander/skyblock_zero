---@diagnostic disable: undefined-global, lowercase-global, unused-local
-- any of these functions are designed to be overriden by mods/games

_G.hotbar_switching = {
	default_controls = true,
}

--- If your mod implements a situation where hotbar switching is not acceptable, you can modify this function
--- do something like:
--- ```lua
---		local old_player_can_switch = hotbar_switching.can_player_switch
---		function hotbar_switching.can_player_switch(player)
---			<your code, may return false>
---			return hotbar_switching.can_player_switch(player)
---		end
--- ```
---@param player userdata|table
---@return boolean
function hotbar_switching.can_player_switch(player)
	return true
end

--- You can override to specify what should happen after switching
--- You can use this to make a fancy UI i guess, but that is an excercise for the viewer
---@param player userdata|table
---@param row integer
function hotbar_switching.switch(player, row)
	local listname = player:get_wield_list()
	local inv = player:get_inventory()
	local hotbar_size = player:hud_get_hotbar_itemcount()
	local list = inv:get_list(listname)
	local list_size = #list

	-- suppose hotbar size is 17 items (why) and inv size was 32
	-- this mod can't really handle that, so just silently fail
	if hotbar_size * 2 > list_size then return end
	if row < 0 then row = (list_size / hotbar_size) + row end

	local from_index = row * hotbar_size

	local new_list = {}

	for i = 1, list_size do
		new_list[i] = list[(i + from_index) % list_size]
	end

	inv:set_list(listname, new_list)
end

-- core.get_modpath over core.global_exists in this case because `controls` is a super generic name
if core.get_modpath 'controls' then
	controls.register_on_press(function(player, key)
		local c = player:get_player_control()
		local activated = c.sneak and c.aux1
		if
			_G.hotbar_switching.default_controls == true
			and hotbar_switching.can_player_switch(player)
			and activated
		then
			if key == 'LMB' then
				hotbar_switching.switch(player, 1)
			elseif key == 'RMB' then
				hotbar_switching.switch(player, -1)
			end
		end
	end)
end
