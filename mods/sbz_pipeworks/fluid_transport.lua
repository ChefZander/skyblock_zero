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

local wire_size = 1 / 4


minetest.register_node("pipeworks:fluid_pipe", {
    description = "Fluid pipe",
    info_extra = "Transports liquid",

    connects_to = { "group:fluid_pipe_connects" },
    connect_sides = { "top", "bottom", "front", "left", "back", "right" },

    tiles = { "fluid_pipe.png" },

    drawtype = "nodebox",
    light_source = 3,
    paramtype = "light",
    sunlight_propagates = true,

    groups = { matter = 1, cracky = 3, fluid_pipe_connects = 1 },

    node_box = {
        type = "connected",
        disconnected = wire(wire_size),
        connect_top = wire(wire_size, "top"),
        connect_bottom = wire(wire_size, "bottom"),
        connect_front = wire(wire_size, "front"),
        connect_back = wire(wire_size, "back"),
        connect_left = wire(wire_size, "left"),
        connect_right = wire(wire_size, "right"),
    },
    use_texture_alpha = "clip",
})
