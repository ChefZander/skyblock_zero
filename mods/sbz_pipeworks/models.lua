-----------------------------------
-- The various pipe select boxes
-- (the standards for tube size)

local function wire(len, stretch_to)
	local full = 0.5
	local base_box = { -len, -len, -len, len, len, len }
	if stretch_to == "top" then
		base_box[5] = full
	elseif stretch_to == "bottom" then
		base_box[2] = -full
	elseif stretch_to == "front" then
		base_box[3] = -full
	elseif stretch_to == "back" then
		base_box[6] = full
	elseif stretch_to == "right" then
		base_box[4] = full
	elseif stretch_to == "left" then
		base_box[1] = -full
	end
	return base_box
end

local wire_size = 3 / 16

-- Tube models

pipeworks.tube_short = { wire(wire_size) }
pipeworks.tube_long = { { -0.5, -wire_size, -wire_size, 0.5, wire_size, wire_size } }
pipeworks.tube_leftstub = { wire(wire_size, "left") }
pipeworks.tube_rightstub = { wire(wire_size, "right") }
pipeworks.tube_bottomstub = { wire(wire_size, "bottom") }
pipeworks.tube_topstub = { wire(wire_size, "top") }
pipeworks.tube_frontstub = { wire(wire_size, "front") }
pipeworks.tube_backstub = { wire(wire_size, "back") }

pipeworks.tube_boxes = {
	pipeworks.tube_leftstub,
	pipeworks.tube_rightstub,
	pipeworks.tube_bottomstub,
	pipeworks.tube_topstub,
	pipeworks.tube_frontstub,
	pipeworks.tube_backstub
}

pipeworks.tube_size = wire_size
