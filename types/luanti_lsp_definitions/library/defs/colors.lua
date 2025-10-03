---@meta
-- DRAFT 1 DONE
-- luanti/doc/lua_api.md: Colors

--[[
WIPDOC
]]
---@class core.ColorSpec.tablefmt
--[[
WIPDOC
]]
---@field a integer?
--[[
WIPDOC
]]
---@field r integer?
--[[
WIPDOC
]]
---@field g integer?
--[[
WIPDOC
]]
---@field b integer?

--[[
WIPDOC
]]
---@alias core.ColorString.CSSColors
--- | "aliceblue"
--- | "antiquewhite"
--- | "aqua"
--- | "aquamarine"
--- | "azure"
--- | "beige"
--- | "bisque"
--- | "black"
--- | "blanchedalmond"
--- | "blue"
--- | "blueviolet"
--- | "brown"
--- | "burlywood"
--- | "cadetblue"
--- | "chartreuse"
--- | "chocolate"
--- | "coral"
--- | "cornflowerblue"
--- | "cornsilk"
--- | "crimson"
--- | "cyan"
--- | "darkblue"
--- | "darkcyan"
--- | "darkgoldenrod"
--- | "darkgray"
--- | "darkgreen"
--- | "darkgrey"
--- | "darkkhaki"
--- | "darkmagenta"
--- | "darkolivegreen"
--- | "darkorange"
--- | "darkorchid"
--- | "darkred"
--- | "darksalmon"
--- | "darkseagreen"
--- | "darkslateblue"
--- | "darkslategray"
--- | "darkslategrey"
--- | "darkturquoise"
--- | "darkviolet"
--- | "deeppink"
--- | "deepskyblue"
--- | "dimgray"
--- | "dimgrey"
--- | "dodgerblue"
--- | "firebrick"
--- | "floralwhite"
--- | "forestgreen"
--- | "fuchsia"
--- | "gainsboro"
--- | "ghostwhite"
--- | "gold"
--- | "goldenrod"
--- | "gray"
--- | "green"
--- | "greenyellow"
--- | "grey"
--- | "honeydew"
--- | "hotpink"
--- | "indianred"
--- | "indigo"
--- | "ivory"
--- | "khaki"
--- | "lavender"
--- | "lavenderblush"
--- | "lawngreen"
--- | "lemonchiffon"
--- | "lightblue"
--- | "lightcoral"
--- | "lightcyan"
--- | "lightgoldenrodyellow"
--- | "lightgray"
--- | "lightgreen"
--- | "lightgrey"
--- | "lightpink"
--- | "lightsalmon"
--- | "lightseagreen"
--- | "lightskyblue"
--- | "lightslategray"
--- | "lightslategrey"
--- | "lightsteelblue"
--- | "lightyellow"
--- | "lime"
--- | "limegreen"
--- | "linen"
--- | "magenta"
--- | "maroon"
--- | "mediumaquamarine"
--- | "mediumblue"
--- | "mediumorchid"
--- | "mediumpurple"
--- | "mediumseagreen"
--- | "mediumslateblue"
--- | "mediumspringgreen"
--- | "mediumturquoise"
--- | "mediumvioletred"
--- | "midnightblue"
--- | "mintcream"
--- | "mistyrose"
--- | "moccasin"
--- | "navajowhite"
--- | "navy"
--- | "oldlace"
--- | "olive"
--- | "olivedrab"
--- | "orange"
--- | "orangered"
--- | "orchid"
--- | "palegoldenrod"
--- | "palegreen"
--- | "paleturquoise"
--- | "palevioletred"
--- | "papayawhip"
--- | "peachpuff"
--- | "peru"
--- | "pink"
--- | "plum"
--- | "powderblue"
--- | "purple"
--- | "rebeccapurple"
--- | "red"
--- | "rosybrown"
--- | "royalblue"
--- | "saddlebrown"
--- | "salmon"
--- | "sandybrown"
--- | "seagreen"
--- | "seashell"
--- | "sienna"
--- | "silver"
--- | "skyblue"
--- | "slateblue"
--- | "slategray"
--- | "slategrey"
--- | "snow"
--- | "springgreen"
--- | "steelblue"
--- | "tan"
--- | "teal"
--- | "thistle"
--- | "tomato"
--- | "turquoise"
--- | "violet"
--- | "wheat"
--- | "white"
--- | "whitesmoke"
--- | "yellow"
--- | "yellowgreen"

--[[
`#RGB` defines a color in hexadecimal format.

`#RGBA` defines a color in hexadecimal format and alpha channel.

`#RRGGBB` defines a color in hexadecimal format.

`#RRGGBBAA` defines a color in hexadecimal format and alpha channel.

Named colors are also supported and are equivalent to
[CSS Color Module Level 4](https://www.w3.org/TR/css-color-4/#named-color).
To specify the value of the alpha channel, append `#A` or `#AA` to the end of
the color name (e.g. `colorname#08`).
]]
---@alias core.ColorString
--- | string
--- | core.ColorString.CSSColors

--[[
WIPDOC
]]
---@alias core.ColorSpec.numberfmt integer

--[[
WIPDOC
]]
---@alias core.ColorSpec
--- | core.ColorSpec.tablefmt
--- | core.ColorString
--- | core.ColorSpec.numberfmt