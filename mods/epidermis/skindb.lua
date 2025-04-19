-- SkinDB (https://bitbucket.org/kingarthursteam/mt-skin-db/src/master/) support
--[[
Assumptions:
- Skins are usually added
- Skins are rarely removed by the admin / hoster
- Skins are never changed
- `GROUP BY` works like `ORDER BY` (otherwise no ordering is guaranteed)
]]

-- Load offline copy

local texture_path = epidermis.paths.dynamic_textures.skindb
epidermis.skins = {}

local function on_local_copy_loaded() end

local function load_local_copy()
	local ids = {}
	for _, filename in ipairs(minetest.get_dir_list(texture_path, false)) do
		local id = filename:match "^epidermis_skindb_(%d+)%.png$"
		if id then
			table.insert(ids, tonumber(id))
		end
	end
	table.sort(ids)
	for index, id in ipairs(ids) do
		local filename = ("epidermis_skindb_%d.png"):format(id)
		local path = modlib.file.concat_path { texture_path, filename }
		local metafile = assert(io.open(modlib.file.concat_path { texture_path, filename .. ".json" }))
		local meta = modlib.json:read_file(metafile)
		metafile:close()
		meta.texture = "blank.png" -- dynamic media isn't available yet
		epidermis.skins[index] = meta
		epidermis.dynamic_add_media(path, function()
			meta.texture = filename
		end, false) -- Enable caching for SkinDB skins
	end
	on_local_copy_loaded()
end
-- HACK wait a globalstep before loading the local copy to prevent the dynamic media join race condition in singleplayer
minetest.after(0, function()
	minetest.after(0, load_local_copy)
end)

-- HTTP-requiring code

local http = ...

if not http then
	function on_local_copy_loaded()
		if #epidermis.skins == 0 then -- empty local copy...
			epidermis.skins = nil -- ... disable skin picking entirely
		end
	end

	return -- disable entirely
end

local base_url = "http://minetest.fensta.bplaced.net"

-- Uploading

epidermis.upload_licenses = {
	"CC BY-SA 3.0",
	"CC BY-NC-SA 3.0",
	"CC BY 3.0",
	"CC BY 4.0",
	"CC BY-SA 4.0",
	"CC BY-NC-SA 4.0",
	"CC 0 (1.0)"
}

function epidermis.upload(params)
	http.fetch({
		url = base_url .. "/api/v2/upload.php",
		timeout = 10,
		method = "POST",
		data = {
			name = assert(params.name),
			author = assert(params.author),
			license = assert(params.license),
			img = "data:image/png;base64," .. minetest.encode_base64(params.raw_png_data)
		},
		extra_headers = { "Accept: application/json", "Accept-Charset: utf-8" },
	}, function(res)
		if res.timeout then
			params.on_complete "Timeout"
			return
		end
		if not res.succeeded then
			params.on_complete("HTTP status code: " .. res.code)
			return
		end
		local status, data_or_err = pcall(modlib.json.read_string, modlib.json, res.data)
		if not status then
			local err = data_or_err
			params.on_complete("JSON error: " .. err)
			return
		end
		local data = data_or_err
		if not data.success then
			local message = data.status_msg
			if #message > 100 then -- trim to 100 characters
				message = message:sub(1, 100) .. "..."
			end
			params.on_complete(("SkinDB error message: %q"):format(message))
		end
		params.on_complete() -- success
	end)
end

minetest.register_privilege("epidermis_upload", {
	description = "Can upload skins",
	give_to_singleplayer = false,
	give_to_admin = false,
})

-- "Downloading" / Updating

local timeout = 10
local html_unescape = modlib.web.html.unescape

local function fetch_page(num, per_page, func, retry_time)
	local function on_fail()
		if retry_time then
			modlib.minetest.after(retry_time, fetch_page, num, per_page, func, retry_time)
			return
		end
		func()
	end
	http.fetch({
		url = ("%s/api/v2/get.json.php?getlist&outformat=base64&page=%d&per_page=%d"):format(base_url, num, per_page),
		timeout = timeout,
		method = "GET",
		extra_headers = { "Accept-Charset: utf-8" },
	}, function(res)
		if not res.succeeded then
			return on_fail()
		end
		local status, data = pcall(modlib.json.read_string, modlib.json, res.data)
		if not status then
			return on_fail()
		end
		local skins = data.skins
		-- Check sortedness of skins
		for i = 2, #skins do
			assert(skins[i - 1].id < skins[i].id)
		end
		func(data.pages, skins)
	end)
end

local function add_skin(skin, index)
	assert(skin.type == "image/png")
	assert(type(skin.id) == "number" and skin.id % 1 == 0)
	assert(type(skin.uploaded) == "string" and #skin.uploaded < 100)
	-- These fields may have been incorrectly & automatically casted to numbers by SkinDB (PHP)
	local name = html_unescape(tostring(skin.name))
	local author = html_unescape(tostring(skin.author))
	local license = tostring(skin.license)
	local uploaded = skin.uploaded == "0000-00-00 00:00:00" and "Before 2013-08-11" or skin.uploaded
	local data = assert(minetest.decode_base64(skin.img))
	local meta = {
		id = skin.id,
		name = name,
		author = author,
		license = license,
		uploaded = uploaded
	}
	local path, texture = epidermis.write_skindb_skin(skin.id, data, meta)
	meta.texture = "blank.png"
	if index then -- replace at index
		epidermis.skins[index] = meta
	else
		table.insert(epidermis.skins, meta)
	end
	epidermis.dynamic_add_media(path, function()
		meta.texture = texture
	end, false)
end

local function page(pagenum, per_page, on_complete)
	fetch_page(pagenum, per_page, function(pages, skins)
		pagenum = math.min(pagenum, pages)
		local start = math.min(1 + #epidermis.skins - (pagenum - 1) * per_page, per_page + 1)
		for i = start - 1, 1, -1 do
			local index = i + (pagenum - 1) * per_page
			if skins[i].id > epidermis.skins[index].id then -- Deletion
				epidermis.remove_skindb_skin(epidermis.skins[index].id)
				add_skin(skins[i], index)
			end
		end
		for i = start, #skins do
			add_skin(skins[i])
		end
		if pagenum < pages then
			return page(pagenum + 1, per_page, on_complete)
		end
		-- Last page reached, delete leftover skins
		for i = (pagenum - 1) * per_page + #skins + 1, #epidermis.skins do
			epidermis.skins[i] = nil
		end
		(on_complete or modlib.func.no_op)()
	end, timeout)
end

minetest.register_chatcommand("epidermis_fetch_skindb", {
	params = "<per_page>",
	privs = { server = true },
	description = "Start fully fetching SkinDB",
	func = function(name, per_page)
		per_page = modlib.text.trim_spacing(per_page)
		if per_page == "" then
			per_page = "50"
		end
		if not per_page:match "^%d+$" then
			return false, "per_page must be an integer"
		end
		per_page = tonumber(per_page)
		if per_page < 10 or per_page > 100 then
			return false, "per_page must be between 10 and 100, both inclusive."
		end
		page(1, per_page, function()
			minetest.chat_send_player(name, minetest.colorize("yellow", "[epidermis]") .. " SkinDB fetching complete.")
		end)
		return true, minetest.colorize("yellow", "[epidermis]") .. " SkinDB fetching started..."
	end
})

if not epidermis.conf.skindb.autosync then return end

local function last_page(per_page, on_complete)
	page(1 + math.floor(#epidermis.skins / per_page), per_page, on_complete)
end

function on_local_copy_loaded()
	last_page(50, function()
		-- Fetch 10 skins every 10s
		modlib.minetest.register_globalstep(10, function()
			last_page(10)
		end)
	end)
end
