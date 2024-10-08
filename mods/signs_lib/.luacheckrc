unused_args = false
max_line_length = 180

globals = {
    "minetest",
	"signs_lib",
}

read_globals = {
	-- Builtin
	table = {fields = {"copy"}},
	"ItemStack", "vector", "default",

	-- Mod deps
	"screwdriver",
}
