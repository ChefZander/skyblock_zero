local book_item, book_written = ""

if minetest.get_modpath("default") then
	book_item = "default:book"
	book_written = "default:book_written"
end

if minetest.get_modpath("mcl_books") then
	book_item = "mcl_books:book"
	book_written = "mcl_books:written_book"
end

jumpdrive.write_to_book = function(pos, sender)
	local meta = minetest.get_meta(pos)
	local inv = meta:get_inventory()

	if inv:contains_item("main", { name = book_item, count = 1 }) then
		local stack = inv:remove_item("main", { name = book_item, count = 1 })

		local new_stack = ItemStack(book_written)

		local data = {}

		data.owner = sender:get_player_name()
		data.title = "Jumpdrive coordinates"
		data.description = "Jumpdrive coordinates"
		data.text = minetest.serialize(jumpdrive.get_meta_pos(pos))
		data.page = 1
		data.page_max = 1

		new_stack:get_meta():from_table({ fields = data })

		if inv:room_for_item("main", new_stack) then
			-- put written book back
			inv:add_item("main", new_stack)
		else
			-- put back old stack
			inv:add_item("main", stack)
		end
	end
end

local function has_nil(pos)
	if nil == pos
		or nil == pos.x
		or nil == pos.y
		or nil == pos.z
	then
		return true
	end
	return false
end

local function sanitize_and_set_coordinates(meta, pos)
	meta:set_int("x", jumpdrive.sanitize_coord(pos.x))
	meta:set_int("y", jumpdrive.sanitize_coord(pos.y))
	meta:set_int("z", jumpdrive.sanitize_coord(pos.z))
end

jumpdrive.read_from_book = function(pos)
	local meta = minetest.get_meta(pos)
	local inv = meta:get_inventory()
	local player_name = meta:get_string("owner")

	local inv_size = inv:get_size("main")
	local stack
	local stack_name
	local stack_meta
	local text
	local target_pos
	for i = inv_size, 1, -1 do
		stack = inv:get_stack("main", i)
		stack_name = stack:get_name()
		if book_written == stack_name then
			-- remove item from inventory
			inv:set_stack("main", i, ItemStack())
			stack_meta = stack:get_meta()
			text = stack_meta:get_string("text")
			local data = minetest.deserialize(text)
			if has_nil(data) then
				-- put book back where it was, it may contain other information
				inv:set_stack("main", i, stack)
			else
				target_pos = {
					x = tonumber(data.x),
					y = tonumber(data.y),
					z = tonumber(data.z)
				}

				if has_nil(target_pos) then
					-- put book back where it was, it may contain other information
					inv:set_stack("main", i, stack)
					-- alert player
					if nil ~= player_name then
						minetest.chat_send_player(player_name, "Invalid coordinates")
					end
					return
				end
				sanitize_and_set_coordinates(meta, target_pos)
				-- put book back to next free slot
				inv:add_item("main", stack)
				return
			end
		elseif "missions:wand_position" == stack_name then
			-- remove item from inventory
			inv:set_stack("main", i, ItemStack())
			stack_meta = stack:get_meta()

			text = stack_meta:get_string("pos")
			target_pos = minetest.string_to_pos(text)

			if has_nil(target_pos) then
				-- put wand back where it was.
				-- In singleplayer/creative you can get an invalid position wand
				inv:set_stack("main", i, stack)
			else
				-- don't know how you could get unsanitary coords in a wand,
				-- let's just be safe
				sanitize_and_set_coordinates(meta, target_pos)
				-- put wand back to next free slot
				inv:add_item("main", stack)
				return
			end
		elseif "ccompass:" == stack_name:sub(1, 9)
			or "compass:" == stack_name:sub(1, 8) then
			-- remove item from inventory
			inv:set_stack("main", i, ItemStack())
			stack_meta = stack:get_meta()

			text = stack_meta:get_string("target_pos")
			target_pos = minetest.string_to_pos(text)

			if has_nil(target_pos) then
				-- put compass back, it is probably not calibrated
				-- we put it at same position as we did not actually use it
				inv:set_stack("main", i, stack)
			else
				sanitize_and_set_coordinates(meta, target_pos)
				-- put compass back to next free slot
				inv:add_item("main", stack)
				return
			end
		end -- switch item type
	end -- loop inventory
	-- if we got here, there was nothing.
	-- should we or should we not message user?
	--[[
	if nil ~= player_name then
		minetest.chat_send_player(player_name, "No valid bookmark item found.")
	end
	--]]
end
