local mlvec = modlib.vector

local function mlvec_interpolate_barycentric(u, v, p_1, p_2, p_3)
	return mlvec.multiply_scalar(p_1, 1 - u - v)
		+ mlvec.multiply_scalar(p_2, u)
		+ mlvec.multiply_scalar(p_3, v)
end

local media_paths = epidermis.media_paths
local models = modlib.mod.include "models.lua"

local def = {
	initial_properties = {
		visual = "mesh",
		mesh = "character.b3d",
		textures = { "character.png" },
		backface_culling = false,
		collisionbox = { -0.5, 0, -0.5, 0.5, 2, 0.5 },
		physical = true
	},
	lua_properties = {
		staticdata = "lua",
		id = true
	},
}

function def:_get_pixel_index(x, y)
	return 1 + x + self._.width * y
end

function def:_get_xy(index)
	index = index - 1
	return index % self._.width, math.floor(index / self._.width)
end

function def:_get_color(index)
	return self._.overlay_pixels[index] or self._pixels[index]
end

function def:_set_color(index, color, log)
	if not self._paintable_pixels[index] then
		return
	end
	if log then
		self:_log_actions("undo", { [index] = self:_get_color(index) })
	end
	if self._pixels[index] == color then
		self._.overlay_pixels[index] = nil
	else
		self._.overlay_pixels[index] = color
	end
end

local logsize = 100
function def:_log_actions(logname, actions)
	local logs = self._.logs
	local log = assert(logs[logname])
	local count = modlib.table.count(actions)
	log.pixel_count = log.pixel_count + count
	log:push_tail(actions)
	while log:len() >= logsize or log.pixel_count > self._log_max_count do
		local popped_actions = assert(log:pop_head())
		log.pixel_count = log.pixel_count - modlib.table.count(popped_actions)
	end
end

function def:_reverse_last_log_action(logname)
	local action_log = self._.logs[logname]
	local last_action = action_log:pop_tail()
	if not last_action then
		return
	end
	for index, color in pairs(last_action) do
		last_action[index] = self:_get_color(index)
		self:_set_color(index, color)
	end
	self:_log_actions(assert(({ undo = "redo", redo = "undo" })[logname]), last_action)
	return true
end

function def:_bulk_set_color(indices, color, log)
	for index in pairs(indices) do
		if self._paintable_pixels[index] then
			indices[index] = self:_get_color(index)
			self:_set_color(index, color)
		else
			indices[index] = nil
		end
	end
	if log then
		self:_log_actions(log, indices)
	end
end

function def:_set_mesh(mesh)
	self.object:set_properties { mesh = mesh }
	self._.mesh = mesh
end

function def:_set_rotation(rotation)
	self.object:set_rotation(rotation)
	-- Update collision & selection box
	local rotation_axis, rotation_angle = epidermis.vector_axis_angle(rotation)
	local model = assert(models[self._.mesh])
	local min, max = mlvec.new { math.huge, math.huge, math.huge }, mlvec.new { -math.huge, -math.huge, -math.huge }
	for _, vertex in ipairs(model.vertices) do
		local pos = mlvec.rotate3(vertex.pos, rotation_axis, rotation_angle)
		min = mlvec.combine(min, pos, math.min)
		max = mlvec.combine(max, pos, math.max)
	end
	local box = { min[1], min[2], min[3], max[1], max[2], max[3] }
	self.object:set_properties {
		collisionbox = box,
		selectionbox = box,
	}
	self._.rotation = rotation
end

function def:_face(player)
	-- Don't use the eye pos as the eye pos of the paintable is unknown
	local rotation = moblib.get_rotation(vector.direction(player:get_pos(), self.object:get_pos()))
	-- Tweak rotation to better align with character.b3d which faces -Z
	rotation.x = -rotation.x
	rotation.y = rotation.y - math.pi
	self:_set_rotation(rotation)
end

function def:_set_backface_culling(backface_culling)
	self.object:set_properties { backface_culling = backface_culling }
	self._.backface_culling = backface_culling
end

function def:_encode_png()
	modlib.table.add_all(self._pixels, self._.overlay_pixels)
	return modlib.minetest.encode_png(self._.width, self._.height, self._pixels, 9)
end

function def:_write_texture(on_all_received)
	self._.dynamic_texture_id = (self._.dynamic_texture_id or 0) + 1
	-- It is assumed that the preview will always fit within the remaining space; only check the overlay pixels
	local path, texture_name = epidermis.write_epidermis(self._.id, self._.dynamic_texture_id, self:_encode_png())
	self._.base_texture = texture_name
	self._.overlay_pixels = {}
	self._status = "loading"
	epidermis.dynamic_add_media(path, function()
		self._status = "active"
		on_all_received()
	end, true)
end

local max_overlay_pixels = 1e3
function def:_update_texture(preview)
	if modlib.table.count(self._.overlay_pixels) > max_overlay_pixels then
		self:_write_texture(function()
			self:_update_texture(preview)
		end)
		return
	end
	local preview_pixels = type(preview) == "table" -- preview is a table of pixels (line preview)
	local dim = self._.width .. "x" .. self._.height
	local overlays = { "0,0=" .. self._.base_texture }
	local function pixels(func)
		if preview_pixels then
			for index, color in pairs(preview) do
				func(index, color)
			end
		end
		for index, color in pairs(self._.overlay_pixels) do
			if not (preview_pixels and preview[index]) then
				func(index, color)
			end
		end
	end
	pixels(function(index, color)
		local x, y = self:_get_xy(index)
		table.insert(overlays, ([[%d,%d=epxw.png\^[multiply\:#%06X]]):format(x, y, color % 0x1000000))
	end)
	local mask_overlays = {}
	pixels(function(index, color)
		local x, y = self:_get_xy(index)
		local alpha = math.floor(color / 0x1000000)
		if alpha < 255 then
			table.insert(mask_overlays, ([[%d,%d=epxb.png\\^[opacity\\:%d]]):format(x, y, 255 - alpha))
		end
	end)
	local nonalpha = "[combine:" .. dim .. ":" .. table.concat(overlays, ":")
	local alpha = [[[combine\:]] .. dim .. [[\:]] .. table.concat(mask_overlays, [[\:]])
	local tex = nonalpha .. [[^[mask:]] .. alpha .. [[\^[invert\:rgba]]
	if type(preview) == "string" then -- preview is a texture modifier, just append
		tex = tex .. preview
	end
	assert(#tex < 2 ^ 16)
	local properties = self.object:get_properties()
	if properties == nil then return false end
	self.object:set_properties { textures = { tex, unpack(properties.textures, 2) } }
end

function def:_set_texture(texture, reset)
	self._.base_texture = texture
	if reset then
		self._.overlay_pixels = {}
		self._.logs = {
			undo = modlib.hashlist.new { pixel_count = 0 },
			redo = modlib.hashlist.new { pixel_count = 0 },
		}
	end
	self._paintable_pixels = {}
	if not media_paths[self._.base_texture] then return false end
	local file = io.open(media_paths[self._.base_texture], "rb")
	local png = modlib.minetest.decode_png(file)
	assert(not file:read(1), "EOF expected")
	file:close()
	assert(png.width <= 1024 and png.height <= 1024, "image too large (> 1024x1024)")
	modlib.minetest.convert_png_to_argb8(png)
	self._pixels = png.data
	self._.width = png.width
	self._.height = png.height
	self._log_max_count = 10 * self._.width * self._.height
	local dim = { self._.width, self._.height }
	local model = assert(models[self._.mesh])
	for texid, tris in pairs(model.triangle_sets) do
		for _, triangle in pairs(tris) do
			local base = triangle[1].tex_coords[texid]
			local edge_1 = mlvec.subtract(triangle[2].tex_coords[texid], base)
			local edge_2 = mlvec.subtract(triangle[3].tex_coords[texid], base)
			for u = 0, 1, 1 / math.ceil(edge_1:multiply(dim):length() + 1) do
				for v = 0, 1, 1 / math.ceil(edge_2:multiply(dim):length() + 1) do
					local tc = mlvec.add(base, edge_1:multiply_scalar(u) + edge_2:multiply_scalar(v))
					self._paintable_pixels[self:_get_pixel_index(math.floor(tc[1] * dim[1]), math.floor(tc[2] * dim[2]))] = true
				end
			end
		end
	end
	self:_update_texture()
end

function def:_init()
	modlib.table.deepcomplete(self._, {
		mesh = def.initial_properties.mesh,
		overlay_pixels = {},
		logs = {
			undo = { pixel_count = 0 },
			redo = { pixel_count = 0 },
		},
		backface_culling = def.initial_properties.backface_culling,
		rotation = vector.new(0, 0, 0)
	})
	-- Set metatables
	modlib.hashlist.new(self._.logs.undo)
	modlib.hashlist.new(self._.logs.redo)
	self:_set_mesh(self._.mesh)
	self:_set_texture(self._.base_texture)
	self:_set_rotation(self._.rotation)
	self:_set_backface_culling(self._.backface_culling)
	-- self.object:set_acceleration(vector.new(0, -0.981, 0))
	self.object:set_armor_groups { immortal = 1, punch_operable = 1 }
	self._status = "active"
end

function def:_get_dir_path()
	return modlib.file.concat_path { epidermis.paths.dynamic_textures.epidermi, ("epidermis_paintable_%d"):format(self._.id) }
end

function def:on_activate()
	local dir_path = self:_get_dir_path()
	minetest.mkdir(dir_path)
	self._.base_texture = self._.base_texture or def.initial_properties.textures[1]
	if media_paths[self._.base_texture] then
		self:_init()
		return
	end
	local path = epidermis.get_epidermis_path(self._.id, self._.dynamic_texture_id)
	if not path then
		minetest.log("warning", ("Base texture %s not found, defaulting to character.png."):format(self._.base_texture))
		self:_set_texture("character.png", true)
		self:_init()
		return
	end
	if not modlib.file.exists(path) then
		local texture
		path, texture = epidermis.get_last_epidermis_path(self._.id)
		if path then
			minetest.log("warning", ("Force-upgrading paintable #%d to texture %s due to staticdata loss")
				:format(self._.id, texture))
			self:_set_texture(texture, true) -- related staticdata must be overwritten, as it relates to the old texture
		else
			minetest.log("warning",
				("No texture for paintable #%d available, defaulting to character.png."):format(self._.id))
			self:_set_texture("character.png", true)
			return self:_init()
		end
	end
	epidermis.dynamic_add_media(path, function()
		self:_init()
	end, true)
end

function def:_delete()
	epidermis.mark_for_deletion(self._.id)
	self.object:remove()
end

-- TODO override clearobjects to catch that as well
function def:on_deactivate(removal)
	if removal then
		epidermis.mark_for_deletion(self._.id)
	end
end

function def:_get_intersection_infos(mt_pos, mt_direction)
	local intersection_infos = {}

	local pos = mlvec.from_minetest(mt_pos)
	local direction = mlvec.from_minetest(mt_direction)

	local properties = self.object:get_properties()

	local scale = mlvec.from_minetest(properties.visual_size)
	local rotation = self.object:get_rotation()
	local rotation_axis, rotation_angle = epidermis.vector_axis_angle(rotation)
	-- Instead of transforming all triangle vertices, we inversely transform the ray, which is a lot cheaper
	local inv_trans_dir = mlvec.rotate3((direction / scale):normalize(), rotation_axis, -rotation_angle)
	local inv_trans_rel_pos = mlvec.rotate3(pos - mlvec.from_minetest(self.object:get_pos()),
		rotation_axis, -rotation_angle)

	for texid, tris in pairs(assert(models[properties.mesh]).triangle_sets) do
		for _, triangle in pairs(tris) do
			local pos_on_ray, u, v = mlvec.ray_triangle_intersection(inv_trans_rel_pos, inv_trans_dir, triangle.poses)
			if pos_on_ray then
				local normal
				if triangle[1].normal then
					normal = mlvec_interpolate_barycentric(u, v, triangle[1].normal, triangle[2].normal,
						triangle[3].normal)
				else
					normal = mlvec.triangle_normal(triangle.poses)
				end
				local frontface = mlvec.dot(inv_trans_dir, normal) < 0
				local texcoord = mlvec_interpolate_barycentric(u, v,
					triangle[1].tex_coords[texid],
					triangle[2].tex_coords[texid],
					triangle[3].tex_coords[texid])
				local width, height = self._.width, self._.height
				local pixelcoord = mlvec.apply(mlvec.multiply(texcoord, { width, height }), math.floor)
				pixelcoord[1] = math.min(width - 1, pixelcoord[1])
				pixelcoord[2] = math.min(height - 1, pixelcoord[2])
				local index = self:_get_pixel_index(unpack(pixelcoord))
				local paintable = self._paintable_pixels[index]
				if paintable then
					local color = modlib.minetest.colorspec.from_number(self:_get_color(index))
					if frontface or not properties.backface_culling then
						table.insert(intersection_infos, {
							pos_on_ray = pos_on_ray,
							frontface = frontface,
							pixelcoord = pixelcoord,
							color = color
						})
					end
				end
			end
		end
	end
	table.sort(intersection_infos, function(a, b) return a.pos_on_ray < b.pos_on_ray end)
	return intersection_infos
end

function def:_can_edit(user)
	if self._status ~= "active" then
		epidermis.send_notification(user, ("This paintable is %s!"):format(self._status), "warning")
		return false
	end
	if self._.owner ~= user:get_player_name() then
		epidermis.send_notification(user, ("This paintable belongs to %s!"):format(self._.owner or "no one"), "warning")
		return false
	end
	return true
end

function def:on_rightclick(clicker)
	if clicker:get_wielded_item():get_name() ~= "" or not self:_can_edit(clicker) then
		return
	end
	self:_show_control_panel(clicker)
end

function def:on_punch(puncher)
	if puncher:get_wielded_item():get_name() ~= "" or not self:_can_edit(puncher) then
		return true
	end
	local player_name = puncher:get_player_name()
	assert(player_name:match "^[A-Za-z_%-]+$")
	self:_write_texture(function()
		self:_update_texture()
		epidermis.set_player_data(player_name, { epidermis = self._.base_texture })
		-- Swap skins & meshes with owner
		local puncher_model = epidermis.get_model(puncher)
		local puncher_skin = epidermis.get_skin(puncher)
		epidermis.set_model(puncher, self._.mesh)
		epidermis.set_skin(puncher, self._.base_texture)
		if puncher_skin:match "^[^%[%^]+%.png$" then -- simple texture without modifiers
			self:_set_mesh(puncher_model)
			self:_set_texture(puncher_skin, true)
			self:_write_texture(modlib.func.no_op) -- force-copy the player texture
		else
			epidermis.send_notification(puncher, "Invalid (combined?) texture! Defaulting to character.png.", "warning")
			self:_set_mesh("character.b3d")
			self:_set_texture("character.png", true)
		end
	end)
end

function def:_show_control_panel(player)
	local backface_culling = self._.backface_culling
	local action_groups = {
		{ {
			exit = true,
			name = "backface_culling",
			icon = (backface_culling and "backface_visible" or "backface_hidden"),
			tooltip = (backface_culling and "Show" or "Hide") .. " back faces"
		} },
		{
			{
				exit = true,
				name = "rotation_random",
				icon = "dice",
				tooltip = "Randomize paintable rotation"
			},
			{
				exit = true,
				name = "rotation_face_you",
				icon = "eyes",
				tooltip = "Rotation: Face you"
			},
		},
		{
			{
				exit = true,
				name = "preview_animation",
				icon = "animation",
				tooltip = "Play animation"
			},
			{
				exit = false,
				name = "preview_texture",
				icon = "checker",
				tooltip = "Open texture preview"
			},
		},
	}

	local skindb_group = {}
	if epidermis.skins then
		if def._show_upload_formspec then
			table.insert(skindb_group, {
				exit = false,
				name = "upload",
				icon = "upload",
				tooltip = "Upload to SkinDB"
			})
		end
		if def._show_picker_formspec then
			table.insert(skindb_group, {
				exit = false,
				name = "download",
				icon = "download",
				tooltip = "Pick from SkinDB"
			})
		end
		if #skindb_group > 0 then
			table.insert(action_groups, skindb_group)
		end
	end
	table.insert(action_groups, { {
		exit = false,
		name = "delete",
		icon = "bin",
		tooltip = "Delete"
	} })
	table.insert(action_groups, { {
		exit = true,
		name = "close",
		icon = "cross",
		tooltip = "Close"
	} })
	local fs = {
		false, -- placeholder
		{ "real_coordinates", true },
	}
	local x = 0.25
	for _, group in ipairs(action_groups) do
		for _, action in ipairs(group) do
			table.insert(fs, {
				"image_button" .. (action.exit and "_exit" or ""),
				{ x, 0.25 }, { 0.5, 0.5 },
				epidermis.textures[action.icon] or ("epidermis_" .. action.icon .. ".png"),
				action.name,
				""
			})
			table.insert(fs, { "tooltip", action.name, action.tooltip })
			x = x + 0.5
		end
		x = x + 0.25
	end
	fs[1] = { "size", { x, 1, false } }
	fslib.show_formspec(player, fs, function(fields)
		if fields.backface_culling then
			self:_set_backface_culling(not self._.backface_culling)
		elseif fields.rotation_random then
			self:_set_rotation(vector.multiply(vector.new(math.random(), math.random(), math.random()), 2 * math.pi))
		elseif fields.rotation_face_you then
			self:_face(player)
		elseif fields.preview_animation then
			local frames = models[self.object:get_properties().mesh].frames
			local fps = 30
			self.object:set_animation({ x = 1, y = frames }, fps, 0, false)
			modlib.minetest.after(frames / fps, function()
				if self.object:get_pos() then -- check if object is still active
					self.object:set_animation()
				end
			end)
		elseif fields.preview_texture then
			self:_show_texture_preview(player)
		elseif fields.delete then
			self:_show_delete_formspec(player)
		elseif fields.upload then
			if self._show_upload_formspec then
				self:_show_upload_formspec(player)
			end
		elseif fields.download then
			if self._show_picker_formspec then
				self:_show_picker_formspec(player)
			end
		end
	end)
end

function def:_show_texture_preview(player)
	local fs_content_width = 8
	local image_height = fs_content_width * (self._.height / self._.width) --[fs units]
	fslib.show_formspec(player, {
		{ "size",              { fs_content_width + 0.5, image_height + 1.25, false } },
		{ "real_coordinates",  true },
		{ "label",             { 0.25, 0.5 },                                         "Texture Preview:" },
		{ "image",             { 0.25, 1 },                                           { fs_content_width, image_height }, self.object:get_properties().textures[1] },
		{ "image_button",      { 7.25, 0.25 },                                        { 0.5, 0.5 },                       epidermis.textures.back,                 "back",  "" },
		{ "tooltip",           "back",                                                "Go back" },
		{ "image_button_exit", { 7.75, 0.25 },                                        { 0.5, 0.5 },                       "epidermis_cross.png",                   "close", "" },
		{ "tooltip",           "close",                                               "Close" },
	}, function(fields)
		if fields.back then
			self:_show_control_panel(player)
		end
	end)
end

local delete_confirmation_fs = fslib.build_formspec {
	{ "size",              { 6, 1, false } },
	{ "real_coordinates",  true },
	{ "label",             { 0.25, 0.5 },  "Irreversably delete paintable?" },
	{ "image_button_exit", { 4.75, 0.25 }, { 0.5, 0.5 },                    "epidermis_check.png", "confirm", "" },
	{ "tooltip",           "confirm",      "Confirm" },
	{ "image_button_exit", { 5.25, 0.25 }, { 0.5, 0.5 },                    "epidermis_cross.png", "close",   "" },
	{ "tooltip",           "close",        "Close" },
}
function def:_show_delete_formspec(player)
	fslib.show_formspec(player, delete_confirmation_fs, function(fields)
		if fields.confirm then
			self:_delete()
		end
	end)
end

function def:_show_upload_formspec(player, message)
	local context = {}
	fslib.show_formspec(player, {
		{ "size",                 { 7.5, 4.75, false } },
		{ "real_coordinates",     true },
		{ "label",                { 0.25, 0.5 },       "Upload to SkinDB: " .. (message or "") },
		{ "image_button",         { 5.75, 0.25 },      { 0.5, 0.5 },                           epidermis.textures.back,                    "back",                    "" },
		{ "tooltip",              "back",              "Go back" },
		{ "image_button",         { 6.25, 0.25 },      { 0.5, 0.5 },                           epidermis.textures.upload,                  "upload",                  "" },
		{ "tooltip",              "upload",            "Upload" },
		{ "image_button_exit",    { 6.75, 0.25 },      { 0.5, 0.5 },                           "epidermis_cross.png",                      "cancel",                  "" },
		{ "tooltip",              "cancel",            "Cancel" },
		{ "field",                { 0.25, 1.25 },      { 7, 0.5 },                             "name",                                     "Name:",                   "" },
		{ "field_close_on_enter", "name",              false },
		{ "field",                { 0.25, 2.25 },      { 7, 0.5 },                             "author",                                   "Author:",                 player:get_player_name() },
		{ "field_close_on_enter", "author",            false },
		{ "label",                { 0.25, 3.125 },     "License:" },
		{ "dropdown",             { 0.25, 3.25 },      { 3, 0.5 },                             "license",                                  epidermis.upload_licenses, 1,                       true },
		{ "checkbox",             { 3.5, 3.5 },        "credit",                               "I have credited properly",                 false },
		{ "checkbox",             { 0.25, 4.25 },      "completeness",                         "My skin is complete and ready for upload", false },
	}, function(fields)
		if fields.quit then
			return
		end
		if fields.back then
			self:_show_control_panel(player)
			return
		end
		if fields.credit ~= nil then
			context.credit = fields.credit == "true"
			return
		end
		if fields.completeness ~= nil then
			context.completeness = fields.completeness == "true"
			return
		end
		if not fields.upload then
			return
		end
		local license = (fields.license or ""):match "^%d+$"
		if not license then
			epidermis.on_cheat(player, { type = "invalid_formspec_fields" })
			return
		end
		license = tonumber(license)
		if not epidermis.upload_licenses[license] then
			epidermis.on_cheat(player, { type = "invalid_formspec_fields" })
			return
		end
		local credit, completeness = context.credit, context.completeness
		local name, author = modlib.text.trim_spacing(fields.name or ""), modlib.text.trim_spacing(fields.author or "")
		if not (credit and completeness and name ~= "" and author ~= "") then
			self:_show_upload_formspec(player,
				minetest.colorize(epidermis.colors.error:to_string(),
					"Please fill out the form!"))
			return
		end
		fslib.close_formspec(player)
		local player_name = player:get_player_name()
		if not minetest.get_player_privs(player_name).epidermis_upload then
			epidermis.send_notification(player, 'Missing "epidermis_upload" privilege!', "error")
			return
		end
		epidermis.send_notification(player, "Upload in progress...", "info")
		epidermis.upload {
			name = name,
			author = author,
			license = license,
			raw_png_data = self:_encode_png(),
			on_complete = function(error)
				if not minetest.get_player_by_name(player_name) then
					return
				end
				if error then
					epidermis.send_notification(player, "Upload failed!", "error")
				else
					minetest.log("action", player_name .. " uploaded a skin: " .. modlib.json:write_string {
						name = name,
						author = author,
						license = license
					})
					epidermis.send_notification(player, "Upload completed!", "success")
				end
			end
		}
	end)
end

if not epidermis.upload then -- no SkinDB support
	def._show_upload_formspec = nil
end

function def:_show_picker_formspec(player)
	if epidermis.skins == nil or #epidermis.skins == 0 then
		epidermis.send_notification(player, "SkinDB not loaded yet!", "error")
		return
	end
	local context = {
		query = "",
		results = epidermis.skins,
		index = #epidermis.skins
	}
	local function get_formspec()
		local skin = assert(context.results[context.index])
		return {
			{ "size",                 { 8.5, 5.25, false } },
			{ "real_coordinates",     true },
			{ "label",                { 0.25, 0.5 },       "Pick a texture:" },
			{ "field",                { 3.5, 0.25 },       { 2, 0.5 },                   "query",                          "",              context.query },
			{ "field_close_on_enter", "query",             false },
			{ "image_button",         { 5, 0.25 },         { 0.5, 0.5 },                 "epidermis_magnifying_glass.png", "search",        "" },
			{ "tooltip",              "search",            "Search" },
			{ "image_button",         { 6.75, 0.25 },      { 0.5, 0.5 },                 epidermis.textures.back,          "back",          "" },
			{ "tooltip",              "back",              "Go back" },
			{ "image_button_exit",    { 7.25, 0.25 },      { 0.5, 0.5 },                 "epidermis_check.png",            "set",           "" },
			{ "tooltip",              "set",               "Set texture" },
			{ "image_button_exit",    { 7.75, 0.25 },      { 0.5, 0.5 },                 "epidermis_cross.png",            "cancel",        "" },
			{ "tooltip",              "cancel",            "Cancel" },
			{ "model",                { 0.25, 1 },         { 3, 4 },                     "character",                      "character.b3d", skin.texture, { -45, 135 } },
			{ "tooltip",              "character",         "Drag to rotate" },
			{ "label",                { 3.5, 1.25 },       "Name: " .. skin.name },
			{ "label",                { 3.5, 1.75 },       "Author: " .. skin.author },
			{ "label",                { 3.5, 2.25 },       "License: " .. skin.license },
			{ "label",                { 3.5, 2.75 },       "Uploaded: " .. skin.uploaded },
			{ "label", { 3.5, 3.25 }, context.message
			or (skin.deleted and minetest.colorize(epidermis.colors.error:to_string(), "This skin was deleted!")) or "" },
			-- HACK use hypertext for right-aligned text
			{ "hypertext", { 4.75, 4.45 }, { 2, 0.7 }, "_of", fslib.hypertext_root {
				fslib.hypertext_tags.global { valign = "middle", halign = "right" },
				("%d/%d"):format(context.index, #context.results)
			} },
			{ "image_button", { 6.75, 4.5 }, { 0.5, 0.5 }, epidermis.textures.dice,     "random",   "" },
			{ "tooltip",      "random",      "Random" },
			{ "image_button", { 7.25, 4.5 }, { 0.5, 0.5 }, epidermis.textures.previous, "previous", "" },
			{ "tooltip",      "previous",    "Previous" },
			{ "image_button", { 7.75, 4.5 }, { 0.5, 0.5 }, epidermis.textures.next,     "next",     "" },
			{ "tooltip",      "next",        "Next" }
		}
	end
	local function show_formspec()
		fslib.show_formspec(player, get_formspec(), function(fields)
			if fields.set then
				local selected_skin = context.results[context.index]
				if selected_skin.deleted then
					epidermis.send_notification(player, "The selected skin was deleted!")
				else
					self:_set_texture(selected_skin.texture, true)
				end
				return
			end
			if fields.back then
				self:_show_control_panel(player)
				return
			end

			if fields.next then
				context.index = context.index + 1
				if context.index > #context.results then
					context.index = 1
				end
			elseif fields.previous then
				context.index = context.index - 1
				if context.index <= 0 then
					context.index = #context.results
				end
			elseif fields.random then
				context.index = math.random(1, #context.results)
			elseif fields.key_enter or fields.search then
				local query = {}
				for keyword in (fields.query or ""):sub(1, 100):gmatch("%S+") do -- limit to 100 characters
					if #query == 10 then break end                   -- limit to 10 components
					table.insert(query, keyword:lower())
				end
				if query[1] == nil then
					context.query = ""
					context.results = epidermis.skins
					context.index = #epidermis.skins
					context.message = nil
					show_formspec()
					return
				end
				context.query = table.concat(query, " ")
				local results = {}
				for _, skin in ipairs(epidermis.skins) do
					for _, keyword in pairs(query) do
						if skin.name:lower():find(keyword, 1, true)
							or skin.author:lower():find(keyword, 1, true)
						then
							table.insert(results, skin)
							break
						end
					end
				end
				if results[1] == nil then
					context.message = minetest.colorize(epidermis.colors.error:to_string(),
						"No skins matching query found!")
				else
					context.results = results
					context.index = #results
					context.message = nil
				end
			end
			show_formspec()
		end)
	end
	show_formspec()
end

if not epidermis.skins then -- no SkinDB support
	def._show_picker_formspec = nil
end

moblib.register_entity("epidermis:paintable", def)
