function wrench.register_node(name, def)

end

function wrench.unregister_node(name)

end

function wrench.blacklist_item(name)
	assert(type(name) == "string", "wrench.blacklist_item invalid type for name")
	local node_def = minetest.registered_items[name]
	if node_def then
		wrench.blacklisted_items[name] = true
	else
		minetest.log("warning", "[wrench] Attempt to blacklist unknown item: " .. name)
	end
end

minetest.register_on_mods_loaded(function()
	for name, def in pairs(core.registered_nodes) do
		local old_after_place = def.after_place_node
		minetest.override_item(name, {
			after_place_node = function(...)
				wrench.restore_node(...)
				if old_after_place then
					return old_after_place(...)
				end
			end
		})
	end
end)
