local inv_offset = 0
local inv_width = 8

local player_inv_fs = "list[current_player;main;0," .. 4.5 + inv_offset .. ";8,4;]"

jumpdrive.update_formspec = function(meta)
	local formspec =
		"size[" .. inv_width .. "," .. 2 + inv_offset .. ";]" ..
		"field[0.3,0.5;2,1;x;X;" .. meta:get_int("x") .. "]" ..
		"field[2.3,0.5;2,1;y;Y;" .. meta:get_int("y") .. "]" ..
		"field[4.3,0.5;2,1;z;Z;" .. meta:get_int("z") .. "]" ..
		"field[6.3,0.5;2,1;radius;Radius;" .. meta:get_int("radius") .. "]" ..

		"button_exit[0,1;2,1;jump;Jump]" ..
		"button_exit[2,1;2,1;show;Show]" ..
		"button_exit[4,1;2,1;save;Save]" ..
		"button[6,1;2,1;reset;Reset]" -- ..

	--		"button[0,2;4,1;write_book;Write to book]" ..
	--		"button[4,2;4,1;read_book;Read from bookmark]" -- ..

	-- main inventory for fuel and books
	--		"list[context;main;0,3.25;8,1;]" ..

	-- player inventory
	--		player_inv_fs ..

	-- listring stuff
	--		"listring[context;main]" ..
	--		"listring[current_player;main]" ..


	meta:set_string("formspec", formspec)
end
