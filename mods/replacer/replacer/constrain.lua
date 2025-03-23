local r = replacer
local rb = replacer.blabla
local S = replacer.S
local is_protected = minetest.is_protected
local pos_to_string = replacer.nice_pos_string

-- limit by node, use replacer.register_limit(sName, iMax)
replacer.limit_list = {}

-- don't allow items of these groups for setting replacer to
replacer.deny_groups = {}
replacer.deny_groups['seed'] = true
replacer.deny_groups['protector'] = true
-- don't allow these at all, neither for placing nor replacing
-- example: r.deny_list['tnt:boom'] = true
replacer.deny_list = {}

-- charge limits
replacer.max_charge = 30000
replacer.charge_per_node = 15
-- node count limit
replacer.max_nodes = tonumber(minetest.settings:get('replacer.max_nodes') or 3168)
-- Time limit when placing the nodes, in seconds (not including search time)
replacer.max_time = tonumber(minetest.settings:get('replacer.max_time') or 0.3)
-- Radius limit factor when more possible positions are found than either max_nodes or charge
-- Set to 0 or less for behaviour of before version 3.3
-- [see replacer_patterns.lua>replacer.patterns.search_positions()]
replacer.radius_factor = tonumber(minetest.settings:get('replacer.radius_factor') or 0.4)

-- disable minor modes on server
replacer.disable_minor_modes =
	minetest.settings:get_bool('replacer.disable_minor_modes') or false

-- priv to allow using history
replacer.history_priv = minetest.settings:get('replacer.history_priv') or 'creative'
-- disable saving history over sessions/reboots. IOW: don't use player meta e.g. if using old MT
replacer.history_disable_persistency =
	minetest.settings:get_bool('replacer.history_disable_persistency') or false
-- ignored when persistency is disabled. Interval in minutes to
replacer.history_save_interval =
	tonumber(minetest.settings:get('replacer.history_save_interval') or 7)
-- include mode when changing from history
replacer.history_include_mode =
	minetest.settings:get_bool('replacer.history_include_mode') or false
-- amount of items in history
replacer.history_max = tonumber(minetest.settings:get('replacer.history_max') or 7)

function replacer.no() return false end

-- function that other mods, especially custom server mods,
-- can override. e.g. restrict usage of replacer in certain
-- areas, privs, throttling etc.
-- This is called before replacing the node/air and expects
-- a boolean return and in the case of fail, an optional message
-- that will be sent to player
--luacheck: no unused args
function replacer.permit_replace(pos, old_node_def, new_node_def,
								 player_ref, player_name, player_inv, creative_or_give)
	if r.deny_list[old_node_def.name] then
		return false, S('Replacing nodes of type "@1" is not allowed '
			.. 'on this server. Replacement failed.', old_node_def.name)
	end

	if is_protected(pos, player_name) then
		return false, S('Protected at @1', pos_to_string(pos))
	end

	return true
end -- permit_replace

local function is_positive_int(value)
	return (type(value) == 'number') and (math.floor(value) == value) and (0 <= value)
end
function replacer.register_limit(node_name, node_max)
	-- ignore nil, negative numbers and non-integers
	if not is_positive_int(node_max) then
		return
	end

	-- add to deny_list if limit is zero
	if 0 == node_max then
		r.deny_list[node_name] = true
		r.log('info', rb.log_deny_list_insert:format(node_name))
		return
	end

	-- log info if already limited
	if nil ~= r.limit_list[node_name] then
		r.log('info', rb.log_limit_override:format(node_name, r.limit_list[node_name]))
	end
	r.limit_list[node_name] = node_max
	r.log('info', rb.log_limit_insert:format(node_name, node_max))
end -- register_limit
