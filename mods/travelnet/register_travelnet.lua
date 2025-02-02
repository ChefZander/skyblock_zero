-- contains the node definition for a general travelnet that can be used by anyone
--   further travelnets can only be installed by the owner or by people with the travelnet_attach priv
--   digging of such a travelnet is limited to the owner and to people with the
--   travelnet_remove priv (useful for admins to clean up)
-- (this can be overrided in config.lua)
-- Author: Sokomine

local S = minetest.get_translator("travelnet")


local function on_interact(pos, _, player)
	local meta = minetest.get_meta(pos)
	local legacy_formspec = meta:get_string("formspec")
	if not travelnet.is_falsey_string(legacy_formspec) then
		meta:set_string("formspec", "")
	end

	local player_name = player:get_player_name()
	travelnet.show_current_formspec(pos, meta, player_name)
end

-- travelnet box register function
function travelnet.register_travelnet_box(cfg)
	minetest.register_node(cfg.nodename, unifieddyes.def {
		description = S("Travelnet-Box"),
		drawtype = "mesh",
		mesh = "travelnet.obj",
		sunlight_propagates = true,
		paramtype = "light",
		paramtype2 = "colorfacedir",
		wield_scale = { x = 0.6, y = 0.6, z = 0.6 },
		selection_box = travelnet.node_box,
		collision_box = travelnet.node_box,

		tiles = {
			"(travelnet_travelnet_front_color.png^[multiply:" .. cfg.color .. ")^travelnet_travelnet_front.png", -- backward view
			"(travelnet_travelnet_back_color.png^[multiply:" .. cfg.color .. ")^travelnet_travelnet_back.png", -- front view
			"(travelnet_travelnet_side_color.png^[multiply:" .. cfg.color .. ")^travelnet_travelnet_side.png", -- sides :)
			"travelnet_top.png",                                                                        -- view from top
			"travelnet_bottom.png",                                                                     -- view from bottom
		},

		use_texture_alpha = "clip",
		inventory_image = "travelnet_inv_base.png^(travelnet_inv_colorable.png^[multiply:" .. cfg.color .. ")",
		is_ground_content = false,
		groups = {
			travelnet = 1
		},
		light_source = cfg.light_source or 10,
		after_place_node = function(pos, placer)
			local meta = minetest.get_meta(pos)
			meta:set_string("infotext", S("Travelnet-Box (unconfigured)"))
			meta:set_string("station_name", "")
			meta:set_string("station_network", "")
			meta:set_string("owner", placer:get_player_name())
			minetest.set_node(vector.add(pos, { x = 0, y = 1, z = 0 }), { name = "travelnet:hidden_top" })
		end,

		on_receive_fields = travelnet.on_receive_fields,
		on_rightclick = on_interact,
		on_punch = function(pos, node, puncher)
			on_interact(pos, nil, puncher)
		end,

		can_dig = function(pos, player)
			return travelnet.can_dig(pos, player, "travelnet box")
		end,

		after_dig_node = function(pos, oldnode, oldmetadata, digger)
			travelnet.remove_box(pos, oldnode, oldmetadata, digger)
		end,

		-- TNT and overenthusiastic DMs do not destroy travelnets
		on_blast = function() end,

		-- taken from VanessaEs homedecor fridge
		on_place = function(itemstack, placer, pointed_thing)
			local node = minetest.get_node(vector.add(pointed_thing.above, { x = 0, y = 1, z = 0 }))
			local def = minetest.registered_nodes[node.name]
			-- leftover top nodes can be removed by placing a new travelnet underneath
			if (not def or not def.buildable_to) and node.name ~= "travelnet:hidden_top" then
				minetest.chat_send_player(
					placer:get_player_name(),
					S("Not enough vertical space to place the travelnet box!")
				)
				return
			end
			return minetest.item_place(itemstack, placer, pointed_thing)
		end,

		on_destruct = function(pos)
			local above = vector.add(pos, vector.new(0, 1, 0))
			if minetest.get_node(above).name == "travelnet:hidden_top" then
				minetest.remove_node(above)
			end
		end,
		on_movenode = function(_, to_pos)
			local meta = minetest.get_meta(to_pos);
			minetest.log("action", "[jumpdrive] Restoring travelnet @ " .. to_pos.x .. "/" .. to_pos.y .. "/" .. to_pos
				.z)

			local owner_name = meta:get_string("owner");
			local station_name = meta:get_string("station_name");
			local station_network = meta:get_string("station_network");

			local stations = travelnet.get_travelnets(owner_name)
			if (stations[station_network]
					and stations[station_network][station_name]) then
				-- update station with new position
				stations[station_network][station_name].pos = to_pos
				travelnet.set_travelnets(owner_name, stations)
			end
		end
	})

	if cfg.recipe then
		-- normal recipe
		minetest.register_craft({
			output = cfg.nodename,
			recipe = cfg.recipe,
		})
	end
end
