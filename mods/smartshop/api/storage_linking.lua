local get_us_time = minetest.get_us_time

local api = smartshop.api

local S = smartshop.S

local storage_max_distance = smartshop.settings.storage_max_distance
local storage_link_time = smartshop.settings.storage_link_time

local data_by_player_name = {}

local function expire(player_name, id, shop, storage_type)
	local data = data_by_player_name[player_name]

	-- make sure we're expiring the correct request
	if data and data.id == id and data.shop == shop and data.storage_type == storage_type then
		data_by_player_name[player_name] = nil
		smartshop.chat_send_player(player_name, "Storage link attempt timed out, please try again.")
	end
end

function api.start_storage_linking(player, shop, storage_type)
	local player_name = player:get_player_name()

	smartshop.chat_send_player(player_name, "Punch a smartshop storage node to link @1 storage", S(storage_type))

	local id = get_us_time()
	data_by_player_name[player_name] = {
		id = id,
		shop = shop,
		storage_type = storage_type,
	}

	minetest.after(storage_link_time, expire, player_name, id, shop, storage_type)
end

function api.try_link_storage(storage, player)
	local player_name = player:get_player_name()
	local data = data_by_player_name[player_name]
	if not data then
		return
	end

	local shop = data.shop
	local storage_type = data.storage_type

	if not storage:is_owner(shop:get_owner()) then
		smartshop.chat_send_player(player_name, "You do not own this storage!")
	elseif storage_max_distance > 0 and vector.distance(data.shop.pos, storage.pos) > storage_max_distance then
		smartshop.chat_send_player(player_name, "Storage is too far from shop to link!")
	else
		shop:link_storage(storage, storage_type)

		smartshop.chat_send_player(player_name, "@1 storage linked!", storage_type)
	end

	data_by_player_name[player_name] = nil
end
