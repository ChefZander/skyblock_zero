local r = replacer
local rb = replacer.blabla

-- see replacer.register_exception()
replacer.exception_map = {}
replacer.exception_callbacks = {}

-- see replacer.register_set_enabler()
replacer.enable_set_callbacks = {}

-- see replacer.register_non_creative_alias()
replacer.alias_map = {}

-- some nodes don't rotate using param2. They can be added
-- using replacer.register_exception(node_name, inv_node_name[, callback_function])
-- where: node_name is the itemstring of node when placed in world
--		inv_node_name the itemstring of item in inventory to consume
--		callback_function is optional and will be called after node is placed.
--		  It must return true on success and false, error_message on fail.
--		  In order to register only a callback, pass two identical itemstrings.
--		  Generally the callback is not needed as on_place() is called on the placed node
--		  callback signature is: (pos, old_node_def, new_node_def, player_ref)
-- Examples:
-- 1) Technic cable plate 'technic:lv_cable_plate_4' needs to consume 'technic:lv_cable_plate_1'
--    r.register_exception('technic:lv_cable_plate_4', 'technic:lv_cable_plate_1')
-- 2) Cobwebs don't drop cobwebs, to enable setting replacer to them without having any in
--    user's inventory, register like so:
--    r.register_exception('mobs:cobweb', 'mobs:cobweb')
function replacer.register_exception(node_name, drop_name, callback)
	if r.exception_map[node_name] then
		r.log('warning', rb.log_reg_exception_override:format(node_name))
	end
	r.exception_map[node_name] = drop_name
	r.log('info', rb.log_reg_exception:format(node_name, drop_name))

	if 'function' ~= type(callback) then return end

	r.exception_callbacks[node_name] = callback
	r.log('info', rb.log_reg_exception_callback:format(node_name))
end -- register_exception

-- sometimes you want a reverse exception, for that you use:
-- replacer.register_non_creative_alias(name_sibling, name_placed)
-- Example vines have middle and end parts. To enable setting replacer on middle part
-- to then place an end part in world (only when player does not have creative priv)
-- register like so:
-- replacer.register_non_creative_alias('vines:jungle_middle', 'vines:jungle_end')
function replacer.register_non_creative_alias(name_sibling, name_placed)
	if r.alias_map[name_sibling] then
		r.log('warning', rb.log_reg_alias_override:format(name_sibling))
	end
	r.alias_map[name_sibling] = name_placed
	r.log('info', rb.log_reg_alias:format(name_sibling, name_placed))
end -- register_non_creative_alias

-- The callback will be called when setting replacer and *none* of these
-- criteria are matched:
--   - user has give priv
--   - user has the item in inventory
--   - user does not have creative priv and item is in alias map
--     see register_non_creative_alias()
--   - item is in exceptions, see register_exception()
--   - the item can be obtained by crafting, cooking etc.
-- The first callback to respond with something other than false or nil
--   allows setting the replacer to node. Such a callback may also
--   modify node-table's name, param1 and param2 fields.
-- If you want all your users to be able to set replacer to any node,
--   looking @Sokomine ;), then in your custom server mod register:
--         replacer.register_set_enabler(replacer.yes)
--   although, at that point you might as well just give users creative.
-- the callback signature is f(node, player, pointed_thing)
function replacer.register_set_enabler(callback)
	if 'function' ~= type(callback) then
		r.log('error', rb.log_reg_set_callback_fail)
		return
	end

	table.insert(r.enable_set_callbacks, callback)
end -- register_set_enabler

function replacer.yes() return true end
