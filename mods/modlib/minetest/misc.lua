-- Localize globals
local Settings, assert, minetest, modlib, next, pairs, ipairs, string, setmetatable, select, table, type, unpack
	= Settings, assert, minetest, modlib, next, pairs, ipairs, string, setmetatable, select, table, type, unpack

-- Set environment
local _ENV = ...
setfenv(1, _ENV)

max_wear = 2 ^ 16 - 1

function override(function_name, function_builder)
	local func = minetest[function_name]
	minetest["original_" .. function_name] = func
	minetest[function_name] = function_builder(func)
end

local jobs = modlib.heap.new(function(a, b)
	return a.time < b.time
end)
local job_metatable = {
	__index = {
		-- TODO (...) proper (instant rather than deferred) cancellation:
		-- Keep index [job] = index, swap with last element and heapify
		cancel = function(self)
			self.cancelled = true
		end
	}
}
local time = 0
function after(seconds, func, ...)
	local job = setmetatable({
		time = time + seconds,
		func = func,
		["#"] = select("#", ...),
		...
	}, job_metatable)
	jobs:push(job)
	return job
end
minetest.register_globalstep(function(dtime)
	time = time + dtime
	local job = jobs[1]
	while job and job.time <= time do
		if not job.cancelled then
			job.func(unpack(job, 1, job["#"]))
		end
		jobs:pop()
		job = jobs[1]
	end
end)

function register_globalstep(interval, callback)
	if type(callback) ~= "function" then
		return
	end
	local time = 0
	minetest.register_globalstep(function(dtime)
		time = time + dtime
		if time >= interval then
			callback(time)
			-- TODO ensure this breaks nothing
			time = time % interval
		end
	end)
end

form_listeners = {}

function register_form_listener(formname, func)
	local current_listeners = form_listeners[formname] or {}
	table.insert(current_listeners, func)
	form_listeners[formname] = current_listeners
end

local icall = modlib.table.icall
minetest.register_on_player_receive_fields(function(player, formname, fields)
	icall(form_listeners[formname] or {}, player, fields)
end)

function texture_modifier_inventorycube(face_1, face_2, face_3)
	return "[inventorycube{" .. string.gsub(face_1, "%^", "&")
			.. "{" .. string.gsub(face_2, "%^", "&")
			.. "{" .. string.gsub(face_3, "%^", "&")
end
function get_node_inventory_image(nodename)
	local n = minetest.registered_nodes[nodename]
	if not n then
		return
	end
	local tiles = {}
	for l, tile in pairs(n.tiles or {}) do
		tiles[l] = (type(tile) == "string" and tile) or tile.name
	end
	local chosen_tiles = { tiles[1], tiles[3], tiles[5] }
	if #chosen_tiles == 0 then
		return false
	end
	if not chosen_tiles[2] then
		chosen_tiles[2] = chosen_tiles[1]
	end
	if not chosen_tiles[3] then
		chosen_tiles[3] = chosen_tiles[2]
	end
	local img = minetest.registered_items[nodename].inventory_image
	if string.len(img) == 0 then
		img = nil
	end
	return img or texture_modifier_inventorycube(chosen_tiles[1], chosen_tiles[2], chosen_tiles[3])
end
function check_player_privs(playername, privtable)
	local privs=minetest.get_player_privs(playername)
	local missing_privs={}
	local to_lose_privs={}
	for priv, expected_value in pairs(privtable) do
		local actual_value=privs[priv]
		if expected_value then
			if not actual_value then
				table.insert(missing_privs, priv)
			end
		else
			if actual_value then
				table.insert(to_lose_privs, priv)
			end
		end
	end
	return missing_privs, to_lose_privs
end

--+ Improved base64 decode removing valid padding
function decode_base64(base64)
	local len = base64:len()
	local padding_char = base64:sub(len, len) == "="
	if padding_char then
		if len % 4 ~= 0 then
			return
		end
		if base64:sub(len-1, len-1) == "=" then
			base64 = base64:sub(1, len-2)
		else
			base64 = base64:sub(1, len-1)
		end
	end
	return minetest.decode_base64(base64)
end

local object_refs = minetest.object_refs
--+ Objects inside radius iterator. Uses a linear search.
function objects_inside_radius(pos, radius)
	radius = radius^2
	local id, object, object_pos
	return function()
		repeat
			id, object = next(object_refs, id)
			object_pos = object:get_pos()
		until (not object) or ((pos.x-object_pos.x)^2 + (pos.y-object_pos.y)^2 + (pos.z-object_pos.z)^2) <= radius
		return object
	end
end

--+ Objects inside area iterator. Uses a linear search.
function objects_inside_area(min, max)
	local id, object, object_pos
	return function()
		repeat
			id, object = next(object_refs, id)
			object_pos = object:get_pos()
		until (not object) or (
			(min.x <= object_pos.x and min.y <= object_pos.y and min.z <= object_pos.z)
			and
			(max.y >= object_pos.x and max.y >= object_pos.y and max.z >= object_pos.z)
		)
		return object
	end
end

--: node_or_groupname "modname:nodename", "group:groupname[,groupname]"
--> function(nodename) -> whether node matches
function nodename_matcher(node_or_groupname)
	if modlib.text.starts_with(node_or_groupname, "group:") then
		local groups = modlib.text.split(node_or_groupname:sub(("group:"):len() + 1), ",")
		return function(nodename)
			for _, groupname in pairs(groups) do
				if minetest.get_item_group(nodename, groupname) == 0 then
					return false
				end
			end
			return true
		end
	else
		return function(nodename)
			return nodename == node_or_groupname
		end
	end
end

do
	local default_create, default_free = function() return {} end, modlib.func.no_op
	local metatable = {__index = function(self, player)
		if type(player) == "userdata" then
			return self[player:get_player_name()]
		end
	end}
	function playerdata(create, free)
		create = create or default_create
		free = free or default_free
		local data = {}
		minetest.register_on_joinplayer(function(player)
			data[player:get_player_name()] = create(player)
		end)
		minetest.register_on_leaveplayer(function(player)
			data[player:get_player_name()] = free(player)
		end)
		setmetatable(data, metatable)
		return data
	end
end

function connected_players()
	-- TODO cache connected players
	local connected_players = minetest.get_connected_players()
	local index = 0
	return function()
		index = index + 1
		return connected_players[index]
	end
end

function set_privs(name, priv_updates)
	local privs = minetest.get_player_privs(name)
	for priv, grant in pairs(priv_updates) do
		if grant then
			privs[priv] = true
		else
			-- May not be set to false; Minetest treats false as truthy in this instance
			privs[priv] = nil
		end
	end
	return minetest.set_player_privs(name, privs)
end

function register_on_leaveplayer(func)
	return minetest["register_on_" .. (minetest.is_singleplayer() and "shutdown" or "leaveplayer")](func)
end

do local mod_info
function get_mod_info()
	if mod_info then return mod_info end
	mod_info = {}
	-- TODO validate modnames
	local modnames = minetest.get_modnames()
	for _, mod in pairs(modnames) do
		local info
		local function read_file(filename)
			return modlib.file.read(modlib.mod.get_resource(mod, filename))
		end
		local mod_conf = Settings(modlib.mod.get_resource(mod, "mod.conf"))
		if mod_conf then
			info = {}
			mod_conf = mod_conf:to_table()
			local function read_depends(field)
				local depends = {}
				for depend in (mod_conf[field] or ""):gmatch"[^,]+" do
					depends[modlib.text.trim_spacing(depend)] = true
				end
				info[field] = depends
			end
			read_depends"depends"
			read_depends"optional_depends"
		else
			info = {
				description = read_file"description.txt",
				depends = {},
				optional_depends = {}
			}
			local depends_txt = read_file"depends.txt"
			if depends_txt then
				for _, dependency in ipairs(modlib.table.map(modlib.text.split(depends_txt or "", "\n"), modlib.text.trim_spacing)) do
					local modname, is_optional = dependency:match"(.+)(%??)"
					table.insert(is_optional == "" and info.depends or info.optional_depends, modname)
				end
			end
		end
		if info.name == nil then
			info.name = mod
		end
		mod_info[mod] = info
	end
	return mod_info
end end

do local mod_load_order
function get_mod_load_order()
	if mod_load_order then return mod_load_order end
	mod_load_order = {}
	local mod_info = get_mod_info()
	-- If there are circular soft dependencies, it is possible that a mod is loaded, but not in the right order
	-- TODO somehow maximize the number of soft dependencies fulfilled in case of circular soft dependencies
	local function load(mod)
		if mod.status == "loaded" then
			return true
		end
		if mod.status == "loading" then
			return false
		end
		-- TODO soft/vs hard loading status, reset?
		mod.status = "loading"
		-- Try hard dependencies first. These must be fulfilled.
		for depend in pairs(mod.depends) do
			if not load(mod_info[depend]) then
				return false
			end
		end
		-- Now, try soft dependencies.
		for depend in pairs(mod.optional_depends) do
			-- Mod may not exist
			if mod_info[depend] then
				load(mod_info[depend])
			end
		end
		mod.status = "loaded"
		table.insert(mod_load_order, mod)
		return true
	end
	for _, mod in pairs(mod_info) do
		assert(load(mod))
	end
	return mod_load_order
end end
