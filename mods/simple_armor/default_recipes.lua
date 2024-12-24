simple_armor.helmet_recipe = function(armor, item)
	minetest.register_craft({
		output = armor,
		recipe = {
			{item, item, item},
			{item, ""  , item},
			{""  , ""  , ""  },
		},
	})
end

simple_armor.chestplate_recipe = function(armor, item)
	minetest.register_craft({
		output = armor,
		recipe = {
			{item, ""  , item},
			{item, item, item},
			{item, item, item},
		},
	})
end

simple_armor.leggings_recipe = function(armor, item)
	minetest.register_craft({
		output = armor,
		recipe = {
			{item, item, item},
			{item, ""  , item},
			{item, ""  , item},
		},
	})
end

simple_armor.boots_recipe = function(armor, item)
	minetest.register_craft({
		output = armor,
		recipe = {
			{""  , ""  , ""  },
			{item, ""  , item},
			{item, ""  , item},
		},
	})
end

