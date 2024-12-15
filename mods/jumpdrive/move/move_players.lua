local use_player_monoids = minetest.global_exists("player_monoids")

function jumpdrive.move_players(source_pos1, source_pos2, delta_vector)
    -- move players
	for _,player in ipairs(minetest.get_connected_players()) do
		local playerPos = player:get_pos()
		local player_name = player:get_player_name()

		local xMatch = playerPos.x >= (source_pos1.x-0.5) and playerPos.x <= (source_pos2.x+0.5)
		local yMatch = playerPos.y >= (source_pos1.y-0.5) and playerPos.y <= (source_pos2.y+0.5)
		local zMatch = playerPos.z >= (source_pos1.z-0.5) and playerPos.z <= (source_pos2.z+0.5)

		if xMatch and yMatch and zMatch and player:is_player() then
			minetest.log("action", "[jumpdrive] moving player: " .. player:get_player_name())

			-- override gravity if "player_monoids" is available
			-- *should* execute before the player get moved
			-- to prevent falling through not yet loaded blocks
			if use_player_monoids then
				-- modify gravity
				player_monoids.gravity:add_change(player, 0.01, "jumpdrive:gravity")

				minetest.after(3.0, function()
					-- restore gravity
					local player_deferred = minetest.get_player_by_name(player_name)
					if player_deferred then
						player_monoids.gravity:del_change(player_deferred, "jumpdrive:gravity")
					end
				end)
			end

			local new_player_pos = vector.add(playerPos, delta_vector)
			player:set_pos( new_player_pos );

			-- send moved mapblock to player
			if player.send_mapblock and type(player.send_mapblock) == "function" then
				player:send_mapblock(jumpdrive.get_mapblock_from_pos(new_player_pos))
			end
		end
	end

end