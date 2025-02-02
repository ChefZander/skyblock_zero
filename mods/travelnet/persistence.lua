local S = minetest.get_translator("travelnet")

local mod_data_path = minetest.get_worldpath() .. "/mod_travelnet.data"

local storage = minetest.get_mod_storage()

-- migrate file-based storage to mod-storage
local function migrate_file_storage()
	local file = io.open(mod_data_path, "r")
	if not file then
		return
	end

	-- load from file
	local data = file:read("*all")
	local old_targets
	if data:sub(1, 1) == "{" then
		minetest.log("info", S("[travelnet] migrating from json-file to mod-storage"))
		old_targets = minetest.parse_json(data)
	else
		minetest.log("info", S("[travelnet] migrating from serialize-file to mod-storage"))
		old_targets = minetest.deserialize(data)
	end

	for playername, player_targets in pairs(old_targets) do
		storage:set_string(playername, minetest.write_json(player_targets))
	end

	-- rename old file
	os.rename(mod_data_path, mod_data_path .. ".bak")
end

-- migrate old data as soon as possible
migrate_file_storage()

-- returns the player's travelnets
function travelnet.get_travelnets(playername)
	local json = storage:get_string(playername)
	if not json or json == "" or json == "null" then
		-- default to empty object
		travelnet.log("action", "get_travelnets: player '" .. playername .. "' doesn't have an entry, creating one")
		json = "{}"
	end
	return minetest.parse_json(json)
end

-- saves the player's modified travelnets
function travelnet.set_travelnets(playername, travelnets)
	travelnet.log("action", "set_travelnets: persisting travelnets for player '" .. playername .. "'")
	storage:set_string(playername, minetest.write_json(travelnets))
end