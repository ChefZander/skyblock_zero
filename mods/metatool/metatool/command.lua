
local S = metatool.S

metatool.chat = {}

metatool.chat.register_command = function(cmd, params, description, privs, minarg, maxarg, helpfn, mainfn)
	print(S('Metatool registering chat command /%s', cmd))
	minetest.register_chatcommand(cmd, {
		params = params,
		description = description,
		privs = privs,
		func = function(name, param)
			if not param or param == "" then
				return helpfn(name)
			else
				local params_iterator = string.gmatch(param, "%S+")
				local params_list = {}
				for value in params_iterator do
					table.insert(params_list, value)
				end
				if #params_list >= minarg and #params_list <= maxarg then
					return mainfn(name, params_list)
				else
					minetest.chat_send_player(name, S("Invalid command parameters: %s", table.concat(params_list," ")))
				end
			end
		end
	})
end

local metatool_privileged_give = function(name, params)
		local toolname = metatool.transform_tool_name(params[1])
		local tooldef = metatool.privileged_tools[toolname]
		local count = 1
		if not tooldef then
			minetest.chat_send_player(name, S("Tool not available: %s", toolname))
			return
		end
		if #params > 1 then
			count = tonumber(params[2])
			if not count or math.floor(count) ~= count or count < 1 or count > 99 then
				minetest.chat_send_player(name, S("Tool count must be between %d and %d", 1, 99))
				return
			end
		end
		local player = minetest.get_player_by_name(name)
		if not minetest.check_player_privs(player, tooldef.privs) then
			minetest.chat_send_player(name, S("Tool not available: %s", toolname))
			return
		end
		local inv = player:get_inventory()
		local stack = ItemStack(string.format("%s %d", tooldef.itemname, count))
		if inv:room_for_item("main", stack) then
			inv:add_item("main", stack)
			minetest.chat_send_player(name, S("%d %s added to inventory", count, tooldef.itemname))
			return true
		else
			minetest.chat_send_player(name, S("Not enough inventory space for %s", tooldef.itemname))
			return true
		end
end

local metatool_privileged_list = function(name)
	local player = minetest.get_player_by_name(name)
	local available_tools = {}
	for toolname,tooldef in pairs(metatool.privileged_tools) do
		if metatool.check_privs(player, tooldef.privs) then
			table.insert(available_tools, toolname)
		end
	end
	minetest.chat_send_player(name, S("Available tools: %s", table.concat(available_tools, ", ")))
	return true
end

metatool.chat.register_command_give = function()
	if not minetest.registered_chatcommands["metatool:give"] then
		metatool.chat.register_command(
			"metatool:give",
			"[<tool-name> [<amount>]]",
			"Add tool to your inventory",
			nil, 1, 2,
			metatool_privileged_list,
			metatool_privileged_give
		)
	end
end
