
vizlib = {}

vizlib.colors = {
	{name = "red",        hex = "#ff0000"},
	{name = "vermilion",  hex = "#ff4000"},
	{name = "orange",     hex = "#ff8000"},
	{name = "amber",      hex = "#ffbf00"},
	{name = "yellow",     hex = "#ffff00"},
	{name = "lime",       hex = "#bfff00"},
	{name = "chartreuse", hex = "#80ff00"},
	{name = "harlequin",  hex = "#40ff00"},
	{name = "green",      hex = "#00ff00"},
	{name = "malachite",  hex = "#00ff40"},
	{name = "spring",     hex = "#00ff80"},
	{name = "turquoise",  hex = "#00ffbf"},
	{name = "cyan",       hex = "#00ffff"},
	{name = "cerulean",   hex = "#00bfff"},
	{name = "azure",      hex = "#0080ff"},
	{name = "sapphire",   hex = "#0040ff"},
	{name = "blue",       hex = "#0000ff"},
	{name = "indigo",     hex = "#4000ff"},
	{name = "violet",     hex = "#8000ff"},
	{name = "mulberry",   hex = "#bf00ff"},
	{name = "magenta",    hex = "#ff00ff"},
	{name = "fuchsia",    hex = "#ff00bf"},
	{name = "rose",       hex = "#ff0080"},
	{name = "crimson",    hex = "#ff0040"}
}

vizlib.default_color = minetest.settings:get("vizlib_default_color") or "#ff0000"

dofile(minetest.get_modpath("vizlib").."/api.lua")
