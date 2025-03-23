local r = replacer
local rb = replacer.blabla
local chat_send_player = minetest.chat_send_player
local get_player_by_name = minetest.get_player_by_name
local get_node_drops = minetest.get_node_drops
local core_log = minetest.log
local floor = math.floor
local absolute = math.abs
local concat = table.concat
local insert = table.insert
local gmatch = string.gmatch
local registered_nodes = minetest.registered_nodes
local pos_to_string = minetest.pos_to_string
local sound_play = minetest.sound_play


function replacer.common_list_items(list1, list2)
	if 'table' ~= type(list1) or 'table' ~= type(list2) then return {} end
	if 0 == #list1 or 0 == #list2 then return {} end

	local common, index1, total2, index2 = {}, #list1, #list2
	repeat
		index2 = total2
		repeat
			if list1[index1] == list2[index2] then
				insert(common, list2[index2])
				break
			end
			index2 = index2 - 1
		until 0 == index2
		index1 = index1 - 1
	until 0 == index1

	return common
end -- common_list_items


-- expose creative check function for servers/games to override
-- e.g. server override could check for a priv allowing
-- user to have 'creative' priv only with replacer
function replacer.has_creative(name)
	if minetest.global_exists('creative') and creative.is_enabled_for then
		return creative.is_enabled_for(name)
	end
	return false
end -- has_creative


function replacer.inform(name, message)
	if (not message) or ('' == message) then return end

	r.log('info', rb.log_messages:format(name, message))
	local player = get_player_by_name(name)
	if not player then return end

	local meta = player:get_meta() if not meta then return end

	if 0 < meta:get_int('replacer_mute') then return end

	chat_send_player(name, message)
end -- inform


function replacer.log(level, message)
	if not message then
		message = level
		level = 'warning'
	end

	core_log(level, '[replacer] ' .. message)
end -- log


function replacer.nice_duration(seconds)
	if 'number' ~= type(seconds) then return '' end

	seconds = absolute(seconds)
	local days = floor(seconds / 86400)
	seconds = seconds % 86400
	local text = (0 == days and '') or (tostring(days) .. ' ' .. rb.days .. ' ')
	return text .. os.date('! %H:%M:%S', seconds)
end -- nice_duration


function replacer.nice_number(number, seperator)
	if 'number' ~= type(number) then return '' end

	local sign = 0 > number and '-' or ''
	-- TODO: use default depending on locale, won't work as not all 'de' use same
	-- and not all 'en' use same, hindi has it's own format: 12'34'567
	seperator = seperator or "'"
	local reversed = tostring(absolute(number)):reverse()
	local list = {}
	for s in gmatch(reversed, '...') do insert(list, s) end
	local rest = #reversed % 3
	if 0 ~= rest then insert(list, reversed:sub(-rest, -1)) end
	return sign .. concat(list, seperator):reverse()
end -- nice_number


function replacer.nice_pos_string(pos)
	if 'table' ~= type(pos) then return rb.no_pos end
	if not (pos.x and pos.y and pos.z) then return rb.no_pos end

	pos = { x = floor(pos.x + .5), y = floor(pos.y + .5), z = floor(pos.z + .5) }
	return pos_to_string(pos)
end -- nice_pos_string


function replacer.play_sound(player_name, fail)
	local player = get_player_by_name(player_name)
	if not player then return end

	local meta = player:get_meta() if not meta then return end

	if 0 < meta:get_int('replacer_muteS') then return end

	local sound = fail and r.sounds.fail or r.sounds.success
	sound_play(sound.name, {
		to_player = player_name,
		max_hear_distance = 2,
		gain = sound.gain or 0.5 }, true)
end -- play_sound


function replacer.possible_node_drops(node_name, return_names_only)
	if not registered_nodes[node_name] then return {} end

	local droplist = {}
	local drop = registered_nodes[node_name].drop or ''
	if 'string' == type(drop) then
		if '' == drop then
			-- this returns value with randomness applied :/
			drop = get_node_drops(node_name)
			if 0 == #drop then return {} end

			if not return_names_only then return drop end

			for _, item in ipairs(drop) do
				insert(droplist, item:match('^([^ ]+)'))
			end
			return droplist
		end

		if not return_names_only then return { drop } end

		return { drop:match('^([^ ]+)') }
	end -- if string

	if 'table' ~= type(drop) or not drop.items then return {} end

	local checks = {}
	for _, drops in ipairs(drop.items) do
		for _, item in ipairs(drops.items) do
			-- avoid duplicates; but include the item itself
			-- these are itemstrings so same item can appear multiple times with
			-- different amounts and/or rarity
			if return_names_only then
				item = item:match('^([^ ]+)')
			end
			if not checks[item] then
				checks[item] = 1
				insert(droplist, item)
			end
		end
	end
	return droplist
end -- possible_node_drops


function replacer.print_dump(...)
	if not r.dev_mode then return end

	for _, m in ipairs({ ... }) do
		print(dump(m))
	end
end -- print_dump


-- from: http://lua-users.org/wiki/StringRecipes
function replacer.titleCase(str)
	local function titleCaseHelper(first, rest)
		return first:upper() .. rest:lower()
	end
	-- Add extra characters to the pattern if you need to. _ and ' are
	--  found in the middle of identifiers and English words.
	-- We must also put %w_' into [%w_'] to make it handle normal stuff
	-- and extra stuff the same.
	-- This also turns hex numbers into, eg. 0Xa7d4
	str = str:gsub("(%a)([%w_']*)", titleCaseHelper)
	return str
end -- titleCase

