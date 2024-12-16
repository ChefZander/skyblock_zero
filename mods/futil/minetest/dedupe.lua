-- utilities to dedupe messages
local last_by_func = {}
function futil.dedupe(func, ...)
	local cur = { ... }
	if futil.equals(last_by_func[func], cur) then
		return
	end
	last_by_func[func] = cur
	return func(...)
end

local last_by_player_name_by_func = futil.DefaultTable(function()
	return {}
end)
function futil.dedupe_by_player(func, player, ...)
	local cur = { ... }
	local last_by_player_name = last_by_player_name_by_func[func]
	local player_name

	if type(player) == "string" then
		player_name = player
	else
		player_name = player:get_player_name()
	end

	if futil.equals(last_by_player_name[player_name], cur) then
		return
	end
	last_by_player_name[player_name] = cur
	return func(player, ...)
end
