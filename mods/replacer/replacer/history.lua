replacer.history = {}
replacer.history.db = {}
replacer.history.dirty = {}
local r = replacer
local rb = replacer.blabla
local rud_colour_name = ""

function replacer.history.add_item(player, mode, node, short_description)
	local name = player:get_player_name()
	local db_old = r.history.db[name]
	if not db_old then return end

	local i = 1
	local db = { { node = node, mode = mode, human_string = short_description } }
	for _, entry in ipairs(db_old) do
		if entry.human_string ~= short_description then
			i = i + 1
			db[i] = entry
			if i == r.history_max then break end
		end
	end
	r.history.db[name] = db
	r.history.dirty[name] = true
end -- add_item

function r.history.auto_save()
	minetest.after(r.history_save_interval, r.history.auto_save)
	for _, player in ipairs(minetest.get_connected_players()) do
		if r.history.dirty[player:get_player_name()] then
			r.history.save(player)
		end
	end
end -- auto_save

function replacer.history.dealloc_player(player)
	r.history.save(player)
	r.history.db[player:get_player_name()] = nil
end -- dealloc_player

function replacer.history.get_by_index(player, index)
	return r.history.get_player_table(player)[index]
end -- get_by_index

function replacer.history.get_player_table(player)
	return r.history.db[player:get_player_name()] or {}
end -- get_player_table

function replacer.history.init_player(player)
	local name = player:get_player_name()
	if not minetest.check_player_privs(name, r.history_priv) then return end

	local db_strings =
		player:get_meta():get_string('replacer_his'):split('||', false, r.history_max) or {}
	local db = {}
	local data, entry, mode, mode_raw, colour_name, node_def
	for i, entry_raw in ipairs(db_strings) do
		data = entry_raw:split(' ', false, 4)
		mode_raw = data[4] or '1.1'
		mode = mode_raw:split('.', false, 2)
		entry = {
			node = {
				name = data[1] or r.tool_default_node,
				param1 = tonumber(data[2]) or 0,
				param2 = tonumber(data[3]) or 0,
			},
			mode = {
				major = tonumber(mode[1]) or 1,
				minor = tonumber(mode[2]) or 1,
			},
		}
		if r.disable_minor_modes then entry.mode.minor = 1 end
		node_def = minetest.registered_items[entry.node.name]
		colour_name = rud_colour_name(entry.node.param2, node_def)
		if 0 < #colour_name then
			colour_name = ' ' .. colour_name
		end
		entry.human_string = tostring(entry.mode.major) .. '.' .. tostring(entry.mode.minor)
			.. ' ' .. rb.tool_short_description:format(entry.node.param1, entry.node.param2,
				colour_name, entry.node.name)
		db[i] = entry
	end
	r.history.db[name] = db
end -- init_player

function replacer.history.on_priv_grant(name, granter, priv)
	-- skip duplicate calls
	if granter then return end
	if priv ~= r.history_priv then return end
	r.history.init_player(minetest.get_player_by_name(name))
end -- on_priv_grant

function replacer.history.on_priv_revoke(name, revoker, priv)
	-- skip duplicate calls
	if revoker then return end
	if priv ~= r.history_priv then return end
	r.history.dealloc_player(minetest.get_player_by_name(name))
end -- on_priv_revoke

function replacer.history.save(player)
	local name = player:get_player_name()
	if r.history_disable_persistency then
		r.history.db[name] = nil
		r.history.dirty[name] = nil
		return
	end

	local db = r.history.db[name]
	if not db then return end

	local t = {}
	for i, entry in ipairs(db) do
		if i > r.history_max then break end
		t[i] = table.concat({ entry.node.name, entry.node.param1, entry.node.param2,
			table.concat({ entry.mode.major, entry.mode.minor }, '.') }, ' ')
	end
	player:get_meta():set_string('replacer_his', table.concat(t, '||'))
	r.history.dirty[name] = nil
end -- save

minetest.register_on_joinplayer(r.history.init_player)
minetest.register_on_leaveplayer(r.history.dealloc_player)
minetest.register_on_priv_grant(r.history.on_priv_grant)
minetest.register_on_priv_revoke(r.history.on_priv_revoke)
if not r.history_disable_persistency then
	r.history_save_interval = 60 * r.history_save_interval
	minetest.after(r.history_save_interval, r.history.auto_save)
end -- if persistency is enabled
