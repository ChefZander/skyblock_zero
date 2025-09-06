controls = {
	registered_on_press = {},
	registered_on_hold = {},
	registered_on_release = {},
	players = {},
}

function controls.register_on_press(callback)
	table.insert(controls.registered_on_press, callback)
end

function controls.register_on_hold(callback)
	table.insert(controls.registered_on_hold, callback)
end

function controls.register_on_release(callback)
	table.insert(controls.registered_on_release, callback)
end

minetest.register_on_joinplayer(function(player)
	local name = player:get_player_name()
	controls.players[name] = {}
	for key in pairs(player:get_player_control()) do
		controls.players[name][key] = {false}
	end
end)

minetest.register_on_leaveplayer(function(player)
	local name = player:get_player_name()
	controls.players[name] = nil
end)

local function update_player_controls(player, player_controls)
	local time_now = minetest.get_us_time()
	for key, pressed in pairs(player:get_player_control()) do
		if player_controls[key] then
			if pressed and not player_controls[key][1] then
				for _, callback in pairs(controls.registered_on_press) do
					callback(player, key)
				end
				player_controls[key] = {true, time_now}
			elseif pressed and player_controls[key][1] then
				for _, callback in pairs(controls.registered_on_hold) do
					callback(player, key, (time_now - player_controls[key][2]) / 1e6)
				end
			elseif not pressed and player_controls[key][1] then
				for _, callback in pairs(controls.registered_on_release) do
					callback(player, key, (time_now - player_controls[key][2]) / 1e6)
				end
				player_controls[key] = {false}
			end
		end
	end
end

minetest.register_globalstep(function()
	for _, player in pairs(minetest.get_connected_players()) do
		local name = player:get_player_name()
		if controls.players[name] then
			update_player_controls(player, controls.players[name])
		end
	end
end)

if minetest.settings:get_bool("controls_enable_debug", false) then
	dofile(minetest.get_modpath("controls") .. "/debug.lua")
end
