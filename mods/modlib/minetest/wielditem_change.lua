-- Localize globals
local minetest, modlib, pairs, table = minetest, modlib, pairs, table

-- Set environment
local _ENV = ...
setfenv(1, _ENV)

players = {}

registered_on_wielditem_changes = {function(...)
	local _, previous_item, _, item = ...
	if previous_item then
		((previous_item:get_definition()._modlib or {}).un_wield or modlib.func.no_op)(...)
	end
	if item then
		((item:get_definition()._modlib or {}).on_wield or modlib.func.no_op)(...)
	end
end}

--+ Registers an on_wielditem_change callback: function(player, previous_item, previous_index, item)
--+ Will be called once with player, nil, index, item on join
register_on_wielditem_change = modlib.func.curry(table.insert, registered_on_wielditem_changes)

local function register_callbacks()
	minetest.register_on_joinplayer(function(player)
		local item, index = player:get_wielded_item(), player:get_wield_index()
		players[player:get_player_name()] = {
			wield = {
				item = item,
				index = index
			}
		}
		modlib.table.icall(registered_on_wielditem_changes, player, nil, index, item)
	end)
	minetest.register_on_leaveplayer(function(player)
		players[player:get_player_name()] = nil
	end)
end

-- Other on_joinplayer / on_leaveplayer callbacks should execute first
if minetest.get_current_modname() then
	-- Loaded during load time, register callbacks after load time
	minetest.register_on_mods_loaded(register_callbacks)
else
	-- Loaded after load time, register callbacks immediately
	register_callbacks()
end

-- TODO export
local function itemstack_equals(a, b)
	return a:get_name() == b:get_name() and a:get_count() == b:get_count() and a:get_wear() == b:get_wear() and a:get_meta():equals(b:get_meta())
end

minetest.register_globalstep(function()
	for _, player in pairs(minetest.get_connected_players()) do
		local item, index = player:get_wielded_item(), player:get_wield_index()
		local playerdata = players[player:get_player_name()]
		if not playerdata then return end
		local previous_item, previous_index = playerdata.wield.item, playerdata.wield.index
		if not (itemstack_equals(item, previous_item) and index == previous_index) then
			playerdata.wield.item = item
			playerdata.wield.index = index
			modlib.table.icall(registered_on_wielditem_changes, player, previous_item, previous_index, item)
		end
	end
end)