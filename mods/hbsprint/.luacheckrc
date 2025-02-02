allow_defined_top = true
unused_args = false
max_line_length = false

read_globals = {
    string = {fields = {"split", "trim"}},
    table = {fields = {"copy", "getn"}},

    "player_monoids",
    "playerphysics",
    "hb",
    "vector",
    "hunger_ng",
}

globals = {
    "minetest",
    "hbhunger"
}
