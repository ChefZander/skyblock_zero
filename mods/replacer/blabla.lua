if not minetest.translate then
	function minetest.translate(_, str, ...)
		local arg = { n = select('#', ...), ... }
		return str:gsub('@(.)', function(matched)
			local c = string.byte(matched)
			if string.byte('1') <= c and c <= string.byte('9') then
				return arg[c - string.byte('0')]
			else
				return matched
			end
		end)
	end

	function minetest.get_translator(textdomain)
		return function(str, ...) return minetest.translate(textdomain or '', str, ...) end
	end
end -- backward compatibility
replacer.S = minetest.get_translator('replacer')
local S = replacer.S

replacer.blabla = {}
replacer.blabla.inspect = {}
local rb = replacer.blabla
local rbi = replacer.blabla.inspect

rb.log_messages = '%s: %s'
rb.choose_history = S('History')
rb.choose_mode = S('Choose mode')
rb.mode_minor1 = S('Both')
rb.mode_minor2 = S('Node')
rb.mode_minor3 = S('Rotation')
rb.mode_minor1_info = S('Replace node and apply orientation.')
rb.mode_minor2_info = S('Replace node without changing orientation.')
rb.mode_minor3_info = S('Apply orientation without changing node type.')
rb.mode_single = S('Single')
rb.mode_field = S('Field')
rb.mode_crust = S('Crust')
rb.mode_single_tooltip = S('Replace single node.')
rb.mode_field_tooltip = S('Left click: Replace field of nodes of a kind where a '
	.. 'translucent node is in front of it.@nRight click: Replace field of air '
	.. 'where no translucent node is behind the air.')
rb.mode_crust_tooltip = S('Left click: Replace nodes which touch another one of '
	.. 'its kind and a translucent node, e.g. air.@nRight click: Replace air nodes '
	.. 'which touch the crust.')
rb.wait_for_load = S('Target node not yet loaded. Please wait a moment for the '
	.. 'server to catch up.')
rb.nothing_to_replace = S('Nothing to replace.')
rb.need_more_charge = S('Not enough charge to use this mode.')
rb.too_many_nodes_detected = S('Aborted, too many nodes detected.')
rb.none_selected = S('Error: No node selected.')
rb.description_basic = S('Node replacement tool')
rb.description_technic = S('Node replacement tool (technic)')
rb.log_limit_override = 'Setting already set node-limit for "%s" was %d.'
rb.log_limit_insert = 'Setting node-limit for "%s" to %d.'
rb.log_deny_list_insert = 'Added "%s" to deny list.'
rb.timed_out = S('Time-limit reached.')
rb.tool_short_description = '(%s %s%s) %s'
rb.tool_long_description = '%s\n%s\n%s'
rb.ccm_params = '(chat|audio) (0|1)'
rb.ccm_description = S('Toggles verbosity.\nchat: When on, '
	.. 'messages are posted to chat.\naudio: When off, replacer is silent.')
rb.ccm_player_not_found = 'Player not found'
rb.ccm_player_meta_error = 'Player meta not existant'
rb.log_reg_exception_override = 'register_exception: '
	.. 'exception for "%s" already exists.'
rb.log_reg_exception = 'registered exception for "%s" to "%s"'
rb.log_reg_exception_callback = 'registered after on_place callback for "%s"'
rb.log_reg_alias_override = 'register_non_creative_alias: '
	.. ' alias for "%s" already exists.'
rb.log_reg_alias = 'registered alias for "%s" to "%s"'
rb.log_reg_set_callback_fail = 'register_set_enabler called without passing function.'
rb.formspec_error = 'formspec error, user "%s" attempting to change history. Fields: %s'
rb.formspec_hacker = 'formspec forge? By user "%s" Fields: %s'
rb.minor_modes_disabled = S('Minor modes are disabled on this server.')
rb.no_pos = S('<no positional information>')
rb.days = S('days')

----------------- replacer:inspect -----------------
rbi.description = S('Inspection Tool\nUse to inspect target node or entity.\n'
		.. 'Place to inspect the adjacent node.')
rbi.broken_object = S('This is a broken object. We have no further information about it. It is located')
rbi.owned_protected_locked = S('owned, protected and locked')
rbi.owned_protected = S('owned and protected')
rbi.owned_locked = S('owned and locked')
rbi.this_is_object = S('This is an object')
rbi.is_protected = S('WARNING: You can\'t dig this node. It is protected.')
rbi.you_can_dig = S('INFO: You can dig this node, others can\'t.')
rbi.no_description = S('~ no description provided ~')
rbi.no_node_description = S('~ no node description provided ~')
rbi.no_item_description = S('~ no item description provided ~')
rbi.name = S('Name:')
rbi.exit = S('Exit')
rbi.this_is = S('This is:')
rbi.prev = S('previous recipe')
rbi.next = S('next recipe')
rbi.no_recipes = S('No recipes.')
rbi.drops_on_dig = S('Drops on dig:')
rbi.nothing = S('nothing.')
rbi.may_drop_on_dig = S('May drop on dig:')
rbi.can_be_fuel = S('This can be used as a fuel.')
rbi.unknown_recipe = S('Error: Unknown recipe.')
rbi.log_reg_craft_method_wrong_arguments = 'register_craft_method invalid arguments given.'
rbi.log_reg_craft_method_overriding_method = 'register_craft_method overriding existing method '
rbi.log_reg_craft_method_added = 'register_craft_method method added: %s %s'
rbi.scoop = S('scoop up')
rbi.pour = S('pour out')
rbi.filling = S('filling')
rbi.mobs_disclaimer = S('(Functions may exist that change attributes and conditions of mobs)')
rbi.mobs_of_type = S('Is of type')
rbi.mobs_loyal = S('Is loyal to owner.')
rbi.mobs_attacks = S('Likes to attack:')
rbi.mobs_follows = S('Follows players holding:')
rbi.mobs_drops = S('May drop:')
rbi.mobs_shoots = S('Can shoot misiles.')
rbi.mobs_breed = S('Can breed.')
rbi.mobs_spawns_on = S('Spawns on:')
rbi.mobs_spawns_neighbours = S('with neighours:')
rbi.player_placed = S('Placed:')
rbi.player_digs = S('Digs:')
rbi.player_inflicted = S('Inflicted:')
rbi.player_punches = S('Punched:')
rbi.player_xp = S('XP:')
rbi.player_deaths = S('Deaths:')
rbi.player_duration = S('Played:')
rbi.player_has_active_mission = S('Is currently on a mission.')
rbi.player_no_common_channels = S("You don't have any common channels.")
rbi.player_common_channels = S('You are both on these channels:')
rbi.player_is_wearing = S('Is wearing:')

