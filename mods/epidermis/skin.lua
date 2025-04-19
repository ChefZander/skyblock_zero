local player_api = rawget(_G, "player_api")
local nodecore = rawget(_G, "nodecore")

local function get_textures(player)
	if player_api then
		local anim = player_api.get_animation(player)
		return anim.textures or player_api.registered_models[anim.model].textures
	end
	return player:get_properties().textures
end

local function get_texture(player, index)
	return assert(get_textures(player)[index])
end

local function set_textures(player, textures)
	if player_api then
		player_api.set_textures(player, textures)
		return
	end
	player:set_properties{textures = textures}
end

local function set_texture(player, index, texture)
	local textures = modlib.table.copy(get_textures(player))
	textures[index] = texture
	set_textures(player, textures)
end

local skin_texture_index = 1

function epidermis.get_skin(player)
	return get_texture(player, skin_texture_index)
end

local nc_skins = {}
if nodecore then
	local player_skin = nodecore.player_skin
	function nodecore.player_skin(player, ...)
		return nc_skins[player:get_player_name()] or player_skin(player, ...)
	end
end
function epidermis.set_skin(player, skin)
	if nodecore then
		nc_skins[player:get_player_name()] = skin
		return
	end
	set_texture(player, skin_texture_index, skin)
end

function epidermis.get_model(player)
	if player_api then
		return player_api.get_animation(player).model
	end
	return player:get_properties().mesh
end

local nc_models = {}
if nodecore then
	local player_visuals_base = nodecore.player_visuals_base
	function nodecore.player_visuals_base(player)
		local visuals = player_visuals_base(player)
		visuals.mesh = nc_models[player:get_player_name()] or visuals.mesh
		return visuals
	end
end
function epidermis.set_model(player, model)
	if player_api then
		player_api.set_model(player, model)
		return
	end
	if nodecore then
		nc_models[player:get_player_name()] = model
		return
	end
	player:set_properties{mesh = model}
end