local has_vizlib = minetest.get_modpath("vizlib")

core.register_node("jumpdrive:engine", {
	description = "Jumpdrive",

	tiles = { "jumpdrive.png" },

	is_ground_content = false,
	light_source = 14,
	groups = {
		matter = 1,
		oddly_breakable_by_hand = 3,
		tubedevice = 1,
		tubedevice_receiver = 1,

		sbz_battery = 1,
		sbz_machine = 1,
		pipe_connects = 1,
		pipe_conducts = 1
	},

	battery_max = jumpdrive.config.powerstorage,

	action = function(_, _, meta)
		jumpdrive.update_infotext(meta)
	end,
	sounds = sbz_api.sounds.glass(),
	on_logic_send = jumpdrive.logic_effector,

	after_place_node = function(pos, placer)
		local meta = minetest.get_meta(pos)
		meta:set_string("owner", placer:get_player_name() or "")
	end,

	on_construct = function(pos)
		local meta = minetest.get_meta(pos)
		meta:set_int("x", pos.x)
		meta:set_int("y", pos.y)
		meta:set_int("z", pos.z)
		meta:set_int("radius", 5)
		meta:set_int("power", 0)

		jumpdrive.update_formspec(meta, pos)
	end,

	can_dig = function(pos, player)
		local meta = minetest.get_meta(pos);
		local inv = meta:get_inventory()
		local name = player:get_player_name()

		return inv:is_empty("main") and not minetest.is_protected(pos, name)
	end,


	on_receive_fields = function(pos, _, fields, sender)
		local meta = minetest.get_meta(pos);

		if not sender then
			return
		end

		if minetest.is_protected(pos, sender:get_player_name()) then
			-- not allowed
			return
		end

		if fields.read_book then
			jumpdrive.read_from_book(pos)
			jumpdrive.update_formspec(meta, pos)
			return
		end

		if fields.reset then
			jumpdrive.reset_coordinates(pos)
			jumpdrive.update_formspec(meta, pos)
			return
		end

		if fields.write_book then
			jumpdrive.write_to_book(pos, sender)
			return
		end

		local x = tonumber(fields.x);
		local y = tonumber(fields.y);
		local z = tonumber(fields.z);
		local radius = tonumber(fields.radius);

		if x == nil or y == nil or z == nil or radius == nil or radius < 1 then
			return
		end

		local max_radius = jumpdrive.config.max_radius

		if radius > max_radius then
			minetest.chat_send_player(sender:get_player_name(), "Invalid jump: max-radius=" .. max_radius)
			return
		end

		-- update coords
		meta:set_int("x", jumpdrive.sanitize_coord(x))
		meta:set_int("y", jumpdrive.sanitize_coord(y))
		meta:set_int("z", jumpdrive.sanitize_coord(z))
		meta:set_int("radius", radius)
		jumpdrive.update_formspec(meta, pos)

		if fields.jump then
			local success, msg = jumpdrive.execute_jump(pos, sender)
			if success then
				local time_millis = math.floor(msg / 1000)
				minetest.chat_send_player(sender:get_player_name(), "Jump executed in " .. time_millis .. " ms")
			else
				minetest.chat_send_player(sender:get_player_name(), msg)
			end
		end

		if fields.show then
			local success, msg = jumpdrive.simulate_jump(pos, sender, true)
			if not success then
				minetest.chat_send_player(sender:get_player_name(), msg)
				return
			end
			minetest.chat_send_player(sender:get_player_name(), "Simulation successful")
		end
	end,

	-- inventory protection
	allow_metadata_inventory_move = function(pos, _, _, _, _, count, player)
		if (not player)
			or (not player:is_player())
			or minetest.is_protected(pos, player:get_player_name())
		then
			return 0
		end

		return count
	end,

	allow_metadata_inventory_take = function(pos, _, _, stack, player)
		if (not player)
			or (not player:is_player())
			or minetest.is_protected(pos, player:get_player_name())
		then
			return 0
		end

		return stack:get_count()
	end,

	allow_metadata_inventory_put = function(pos, _, _, stack, player)
		if (not player)
			or (not player:is_player())
			or minetest.is_protected(pos, player:get_player_name())
		then
			return 0
		end

		return stack:get_count()
	end,

	-- upgrade re-calculation
	on_metadata_inventory_put = function(pos, listname)
		if listname == "upgrade" then
			jumpdrive.upgrade.calculate(pos)
		end
	end,

	on_metadata_inventory_take = function(pos, listname)
		if listname == "upgrade" then
			jumpdrive.upgrade.calculate(pos)
		end
	end,

	on_metadata_inventory_move = function(pos, from_list, _, to_list)
		if from_list == "upgrade" or to_list == "upgrade" then
			jumpdrive.upgrade.calculate(pos)
		end
	end,

	on_punch = has_vizlib and function(pos, _, player)
		if not player or player:get_wielded_item():get_name() ~= "" then
			-- Only show jump area when using an empty hand
			return
		end
		local radius = minetest.get_meta(pos):get_int("radius")
		vizlib.draw_cube(pos, radius + 0.5, { color = "#00ff00", player = player })
	end or nil,
})
