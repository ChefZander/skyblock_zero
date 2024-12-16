
for i=1,3 do
	minetest.override_item("locator:beacon_" .. i, {
		on_movenode = function(from_pos, to_pos)
			local meta = minetest.get_meta(to_pos)
			locator.remove_beacon(from_pos)
			locator.update_beacon(to_pos, meta)
		end
	})
end
