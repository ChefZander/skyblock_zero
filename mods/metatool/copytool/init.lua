--
-- tubetool:wand is in game tool that allows cloning pipeworks node data
--

local modpath = minetest.get_modpath('copytool')

local recipe = {
	{ "pipeworks:tube_1" },
	{ "screwdriver:screwdriver" }
}

local tool = metatool:register_tool('copytool', {
	description = 'Copy Tool',
	name = 'CopyTool',
	texture = 'copytool_wand.png',
	recipe = recipe,
})

local function explode_teleport_tube_channel(channel)
	-- Return owner, mode, channel. Owner can be nil. Mode can be nil, ; or :
	local a, b, c = channel:match("^([^:;]+)([:;])(.*)$")
	a = a ~= "" and a or nil
	b = b ~= "" and b or nil
	if b then
		return a, b, c
	end
	-- No match for owner and mode
	return nil, nil, channel
end

-- Create namespace containing tubetool common functions
tool:ns({
	pipeworks_tptube_api_check = function(player)
		if not pipeworks or not pipeworks.tptube or not pipeworks.tptube.get_db then
			minetest.chat_send_player(
				player:get_player_name(),
				'Installed pipeworks version does not have required tptube.get_db function.'
			)
			return false
		end
		return true
	end,
	get_teleport_tubes = function(channel, pos)
		local db = pipeworks.tptube.get_db()
		local tubes = {}
		for hash, data in pairs(db) do
			if data.channel == channel then
				local tube_pos = minetest.get_position_from_hash(hash)
				table.insert(tubes, {
					pos = tube_pos,
					distance = vector.distance(pos, tube_pos),
					can_receive = data.cr == 1,
				})
			end
		end
		table.sort(tubes, function(a, b) return a.distance < b.distance end)
		return tubes
	end,
	explode_teleport_tube_channel = explode_teleport_tube_channel,
	allow_teleport_tube_info = function(player, channel)
		local owner, mode = explode_teleport_tube_channel(channel)
		-- Anyone can list all semi private channels for both senders and receivers
		if not mode or mode == ";" then
			return true
		end
		-- Allow anyone to list all shared channels
		if owner and owner == metatool.settings('sharetool', 'shared_account') then
			return true
		end
		-- Owner can always list their own tube locations
		local name = player:get_player_name()
		if owner == name then
			return true
		end
		-- Player with protection_bypass privilege can list any channel
		return metatool.check_privs(player, { protection_bypass = true })
	end
})

-- nodes
tool:load_node_definition(dofile(modpath .. '/nodes/item_sorter.lua'))
tool:load_node_definition(dofile(modpath .. '/nodes/teleport_tube.lua'))
tool:load_node_definition(dofile(modpath .. '/nodes/injector.lua'))
tool:load_node_definition(dofile(modpath .. '/nodes/autocrafter.lua'))
tool:load_node_definition(dofile(modpath .. '/nodes/any.lua'))
tool:load_node_definition(dofile(modpath .. "/nodes/luacontroller.lua"))
