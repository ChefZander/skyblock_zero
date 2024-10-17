
-- the names of the various colors here came from http://www.procato.com/rgb+index/

unifieddyes.HUES_EXTENDED = {
	{ "red",        0xff, 0x00, 0x00 },
	{ "vermilion",  0xff, 0x40, 0x00 },
	{ "orange",     0xff, 0x80, 0x00 },
	{ "amber",      0xff, 0xbf, 0x00 },
	{ "yellow",     0xff, 0xff, 0x00 },
	{ "lime",       0xbf, 0xff, 0x00 },
	{ "chartreuse", 0x80, 0xff, 0x00 },
	{ "harlequin",  0x40, 0xff, 0x00 },
	{ "green",      0x00, 0xff, 0x00 },
	{ "malachite",  0x00, 0xff, 0x40 },
	{ "spring",     0x00, 0xff, 0x80 },
	{ "turquoise",  0x00, 0xff, 0xbf },
	{ "cyan",       0x00, 0xff, 0xff },
	{ "cerulean",   0x00, 0xbf, 0xff },
	{ "azure",      0x00, 0x80, 0xff },
	{ "sapphire",   0x00, 0x40, 0xff },
	{ "blue",       0x00, 0x00, 0xff },
	{ "indigo",     0x40, 0x00, 0xff },
	{ "violet",     0x80, 0x00, 0xff },
	{ "mulberry",   0xbf, 0x00, 0xff },
	{ "magenta",    0xff, 0x00, 0xff },
	{ "fuchsia",    0xff, 0x00, 0xbf },
	{ "rose",       0xff, 0x00, 0x80 },
	{ "crimson",    0xff, 0x00, 0x40 }
}

unifieddyes.HUES_WITH_GREY = {}

for _,i in ipairs(unifieddyes.HUES_EXTENDED) do
	table.insert(unifieddyes.HUES_WITH_GREY, i[1])
end
table.insert(unifieddyes.HUES_WITH_GREY, "grey")

unifieddyes.HUES_WALLMOUNTED = {
	"red",
	"orange",
	"yellow",
	"green",
	"cyan",
	"blue",
	"violet",
	"magenta"
}

unifieddyes.SATS = {
	"",
	"_s50"
}

unifieddyes.VALS = {
	"",
	"medium_",
	"dark_"
}

unifieddyes.VALS_SPLIT = {
	"faint_",
	"light_",
	"",
	"medium_",
	"dark_"
}

unifieddyes.VALS_EXTENDED = {
	"faint_",
	"pastel_",
	"light_",
	"bright_",
	"",
	"medium_",
	"dark_"
}

unifieddyes.GREYS = {
	"white",
	"light_grey",
	"grey",
	"dark_grey",
	"black"
}

unifieddyes.GREYS_EXTENDED = table.copy(unifieddyes.GREYS)

for i = 1, 14 do
	if i ~= 0 and i ~= 4 and i ~= 8 and i ~= 11 and i ~= 15 then
		table.insert(unifieddyes.GREYS_EXTENDED, "grey_"..i)
	end
end

-- reverse lookups for getpaletteidx()

unifieddyes.gpidx_aliases = {
	["pink"] = "light_red",
	["brown"] = "medium_orange",
	["azure"] = "light_blue"
}

unifieddyes.gpidx_grayscale = {
	["white"] = 1,
	["light_grey"] = 2,
	["grey"] = 3,
	["dark_grey"] = 4,
	["black"] = 5,
}

unifieddyes.gpidx_grayscale_extended = {
	["white"] = 0,
	["grey_14"] = 1,
	["grey_13"] = 2,
	["grey_12"] = 3,
	["light_grey"] = 4,
	["grey_11"] = 4,
	["grey_10"] = 5,
	["grey_9"] = 6,
	["grey_8"] = 7,
	["grey"] = 7,
	["grey_7"] = 8,
	["grey_6"] = 9,
	["grey_5"] = 10,
	["grey_4"] = 11,
	["dark_grey"] = 11,
	["grey_3"] = 12,
	["grey_2"] = 13,
	["grey_1"] = 14,
	["black"] = 15,
}

unifieddyes.gpidx_grayscale_wallmounted = {
	["white"] = 0,
	["light_grey"] = 1,
	["grey"] = 2,
	["dark_grey"] = 3,
	["black"] = 4,
}

unifieddyes.gpidx_hues_extended = {
	["red"] = 0,
	["vermilion"] = 1,
	["orange"] = 2,
	["amber"] = 3,
	["yellow"] = 4,
	["lime"] = 5,
	["chartreuse"] = 6,
	["harlequin"] = 7,
	["green"] = 8,
	["malachite"] = 9,
	["spring"] = 10,
	["aqua"] = 10,
	["turquoise"] = 11,
	["cyan"] = 12,
	["cerulean"] = 13,
	["azure"] = 14,
	["skyblue"] = 14,
	["sapphire"] = 15,
	["blue"] = 16,
	["indigo"] = 17,
	["violet"] = 18,
	["mulberry"] = 19,
	["magenta"] = 20,
	["fuchsia"] = 21,
	["rose"] = 22,
	["redviolet"] = 22,
	["crimson"] = 23,
}

unifieddyes.gpidx_hues_wallmounted = {
	["red"] = 0,
	["orange"] = 1,
	["yellow"] = 2,
	["green"] = 3,
	["cyan"] = 4,
	["blue"] = 5,
	["violet"] = 6,
	["magenta"] = 7
}

unifieddyes.gpidx_shades = {
	[""] = 1,
	["s50"] = 2,
	["light"] = 3,
	["medium"] = 4,
	["mediums50"] = 5,
	["dark"] = 6,
	["darks50"] = 7,
}

unifieddyes.gpidx_shades_split = {
	["faint"] = 0,
	[""] = 1,
	["s50"] = 2,
	["light"] = 3,
	["medium"] = 4,
	["mediums50"] = 5,
	["dark"] = 6,
	["darks50"] = 7,
}

unifieddyes.gpidx_shades_extended = {
	["faint"] = 0,
	["pastel"] = 1,
	["light"] = 2,
	["bright"] = 3,
	[""] = 4,
	["s50"] = 5,
	["medium"] = 6,
	["mediums50"] = 7,
	["dark"] = 8,
	["darks50"] = 9
}

unifieddyes.gpidx_shades_wallmounted = {
	[""] = 1,
	["medium"] = 2,
	["dark"] = 3
}
