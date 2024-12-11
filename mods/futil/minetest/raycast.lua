-- before 5.9, raycasts can miss objects they should hit if the cast is too short
-- see https://github.com/minetest/minetest/issues/14337
function futil.safecast(start, stop, objects, liquids, margin)
	margin = margin or 5
	local ray = stop - start
	local ray_length = ray:length()
	if ray_length == 0 then
		return function() end
	elseif ray_length >= margin then
		return Raycast(start, stop, objects, liquids)
	end

	local actual_stop = start + ray:normalize() * margin
	local raycast = Raycast(start, actual_stop, objects, liquids)
	local stopped = false
	return function()
		if stopped then
			return
		end
		local pt = raycast()
		if pt then
			local ip = pt.intersection_point
			if (ip - start):length() > ray_length then
				stopped = true
				return
			end
			return pt
		end
	end
end
