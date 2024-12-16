local inv_width = 8
local inv_height = 10

jumpdrive.fleet.update_formspec = function(meta)
	local button_line =
		"button_exit[0,1.5;2,1;jump;Jump]" ..
		"button_exit[2,1.5;2,1;show;Show]" ..
		"button_exit[4,1.5;2,1;save;Save]" ..
		"button[6,1.5;2,1;reset;Reset]"

	if meta:get_int("active") == 1 then
		local jump_index = meta:get_int("jump_index")
		local jump_list = minetest.deserialize(meta:get_string("jump_list"))

		meta:set_string("infotext", "Controller active: " .. jump_index .. "/" .. #jump_list)

		button_line = "button_exit[0,1.5;8,1;stop;Stop]"
	else
		meta:set_string("infotext", "Ready")
	end

	meta:set_string("formspec", "size[" .. 8 .. "," .. 2.5 .. ";]" ..
		"field[0.3,0.5;2,1;x;X;" .. meta:get_int("x") .. "]" ..
		"field[3.3,0.5;2,1;y;Y;" .. meta:get_int("y") .. "]" ..
		"field[6.3,0.5;2,1;z;Z;" .. meta:get_int("z") .. "]" ..
		button_line)
end
