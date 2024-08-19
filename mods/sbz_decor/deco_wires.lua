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
local wire_size_normal = 1 / 8
local wire_size_thick = 1 / 5

local function register_deco_wire(color, upper)
    minetest.register_node("sbz_decor:"..color.."_wire", {
        description = upper.." Decorational Wire",
        connects_to = {"sbz_decor:"..color.."_wire"},
        connect_sides = { "top", "bottom", "front", "left", "back", "right" },

        tiles = { color.."_wire.png" },

        drawtype = "nodebox",

        groups = { matter = 1, cracky = 3 },

        node_box = {
            type = "connected",
            disconnected = wire(wire_size_normal),
            connect_top = wire(wire_size_normal, "top"),
            connect_bottom = wire(wire_size_normal, "bottom"),
            connect_front = wire(wire_size_normal, "front"),
            connect_back = wire(wire_size_normal, "back"),
            connect_left = wire(wire_size_normal, "left"),
            connect_right = wire(wire_size_normal, "right"),
        },
    })
    minetest.register_node("sbz_decor:"..color.."_wire_thick", {
        description = upper.." Thick Decorational Wire",
        connects_to = {"sbz_decor:"..color.."_wire_thick"},
        connect_sides = { "top", "bottom", "front", "left", "back", "right" },

        tiles = { color.."_wire.png" },

        drawtype = "nodebox",

        groups = { matter = 1, cracky = 3 },

        node_box = {
            type = "connected",
            disconnected = wire(wire_size_thick),
            connect_top = wire(wire_size_thick, "top"),
            connect_bottom = wire(wire_size_thick, "bottom"),
            connect_front = wire(wire_size_thick, "front"),
            connect_back = wire(wire_size_thick, "back"),
            connect_left = wire(wire_size_thick, "left"),
            connect_right = wire(wire_size_thick, "right"),
        },
    })
end

register_deco_wire("orange", "Orange")
register_deco_wire("pink", "Pink")
register_deco_wire("green", "Green")
register_deco_wire("black", "Black")
register_deco_wire("white", "White")
register_deco_wire("purple", "Purple")