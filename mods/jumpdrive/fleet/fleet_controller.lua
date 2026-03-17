core.register_node("jumpdrive:fleet_controller", {
	description = "Jumpdrive Fleet Controller",

	tiles = { "jumpdrive_fleet_controller.png" },
	groups = { oddly_breakable_by_hand = 3, matter = 1 },

	sounds = {
		footstep = { name = 'gen_muffled_boop_hit', gain = 0.3, pitch = 0.5, fade = 0.0 },
		dig      = { name = 'gen_simple_tap_low', gain = 0.7, pitch = 1.0, fade = 0.0 },
		dug      = { name = 'mix_explode_puffy_metallic', gain = 1.0, pitch = 1.0, fade = 0.0 },
		place    = { name = 'gen_metallic_hit', gain = 1.0, pitch = 1.0, fade = 0.0 },
	},

	is_ground_content = false,
	light_source = 14,
	on_logic_send = jumpdrive.fleet.logic_effector,

	after_place_node = function(pos, placer)
		local meta = core.get_meta(pos)
		-- owner of fleet_controller
		meta:set_string("owner", placer:get_player_name() or "")
		jumpdrive.fleet.update_formspec(meta, pos)
	end,

	on_construct = function(pos)
		local meta = core.get_meta(pos)
		meta:set_int("x", pos.x)
		meta:set_int("y", pos.y)
		meta:set_int("z", pos.z)

		-- jumping active (1=active)
		meta:set_int("active", 0)
		-- if active, current index in jump list (1...n)
		meta:set_int("jump_index", 0)
		-- jump list
		meta:set_string("jump_list", "")

		local inv = meta:get_inventory()
		inv:set_size("main", 8)

		jumpdrive.fleet.update_formspec(meta, pos)
	end,

	can_dig = function(pos, player)
		local meta = core.get_meta(pos);
		local inv = meta:get_inventory()
		local name = player:get_player_name()

		return inv:is_empty("main") and not core.is_protected(pos, name)
	end,

	on_receive_fields = function(pos, _, fields, sender)
		local meta = core.get_meta(pos);

		if not sender then
			return
		end

		if core.is_protected(pos, sender:get_player_name()) then
			-- not allowed
			return
		end

		if fields.read_book then
			jumpdrive.read_from_book(pos)
			jumpdrive.fleet.update_formspec(meta, pos)
			return
		end

		if fields.reset then
			jumpdrive.reset_coordinates(pos)
			jumpdrive.fleet.update_formspec(meta, pos)
			return
		end

		if fields.write_book then
			jumpdrive.write_to_book(pos, sender)
			return
		end

		local x = tonumber(fields.x);
		local y = tonumber(fields.y);
		local z = tonumber(fields.z);

		if x == nil or y == nil or z == nil then
			return
		end

		-- update coords
		meta:set_int("x", jumpdrive.sanitize_coord(x))
		meta:set_int("y", jumpdrive.sanitize_coord(y))
		meta:set_int("z", jumpdrive.sanitize_coord(z))
		jumpdrive.fleet.update_formspec(meta, pos)

		local t0 = core.get_us_time()
		local engines_pos_list = jumpdrive.fleet.find_engines(pos)
		local t1 = core.get_us_time()
		core.log("action", "[jumpdrive-fleet] backbone traversing took " ..
			(t1 - t0) .. " us @ " .. core.pos_to_string(pos))

		local targetPos = { x = meta:get_int("x"), y = meta:get_int("y"), z = meta:get_int("z") }

		-- sort by distance, farthes first
		jumpdrive.fleet.sort_engines(pos, engines_pos_list)

		-- apply new coordinates
		jumpdrive.fleet.apply_coordinates(pos, targetPos, engines_pos_list)

		if fields.jump then
			--TODO check overlapping engines/radius
			meta:set_int("active", 1)
			meta:set_int("jump_index", 1)
			meta:set_string("jump_list", core.serialize(engines_pos_list))
			jumpdrive.fleet.update_formspec(meta, pos)

			local timer = core.get_node_timer(pos)
			timer:start(2.0)
		end

		if fields.stop then
			meta:set_int("active", 0)
			local timer = core.get_node_timer(pos)
			timer:stop()
			jumpdrive.fleet.update_formspec(meta, pos)
		end

		if fields.show then
			local playername = sender:get_player_name()
			core.chat_send_player(playername, "Found " .. #engines_pos_list .. " jumpdrives")

			if #engines_pos_list == 0 then
				return
			end

			local index = 1
			local async_check
			async_check = function()
				local engine_pos = engines_pos_list[index]
				local success, msg = jumpdrive.simulate_jump(engine_pos, sender, true)
				if not success then
					core.chat_send_player(playername, msg .. " @ " .. core.pos_to_string(engine_pos))
					return
				end

				core.chat_send_player(sender:get_player_name(),
					"Check passed for engine " .. index .. "/" .. #engines_pos_list)

				if index < #engines_pos_list then
					-- more drives to check
					index = index + 1
					core.after(1, async_check)
				elseif index >= #engines_pos_list then
					-- done
					core.chat_send_player(sender:get_player_name(), "Simulation successful")
				end
			end

			core.after(1, async_check)
		end
	end,

	on_timer = function(pos)
		local meta = core.get_meta(pos)
		local jump_index = meta:get_int("jump_index")
		local jump_list = core.deserialize(meta:get_string("jump_list"))

		if jump_list and jump_index and #jump_list >= jump_index then
			local is_last = #jump_list == jump_index
			local node_pos = jump_list[jump_index]
			local success, msg = jumpdrive.execute_jump(node_pos)

			local playername = meta:get_string("owner")
			if not playername then
				local node_meta = core.get_meta(node_pos)
				playername = node_meta:get_string("owner")
			end

			if success then
				-- at this point if it is the last engine the metadata does not exist anymore in the current location

				if not is_last then
					meta:set_int("jump_index", jump_index + 1)
					jumpdrive.fleet.update_formspec(meta, pos)

					-- re-schedule
					local timer = core.get_node_timer(pos)
					timer:start(2.0)
				end
				if playername then
					local time_millis = math.floor(msg / 1000)
					core.chat_send_player(playername, "Jump executed in " .. time_millis .. " ms")
				end
			else
				meta:set_int("active", 0)
				jumpdrive.fleet.update_formspec(meta, pos)
				meta:set_string("infotext", "Engine " .. core.pos_to_string(node_pos) .. " failed with: " .. msg)
				if playername then
					core.chat_send_player(playername, msg)
				end
			end
		else
			meta:set_int("active", 0)
			jumpdrive.fleet.update_formspec(meta, pos)
		end
	end
})
