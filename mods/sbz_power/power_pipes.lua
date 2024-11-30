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

local wire_size = 1 / 8

minetest.register_node("sbz_power:power_pipe", {
    description = "Emittrium Power Cable",
    connects_to = { "group:pipe_connects" },
    connect_sides = { "top", "bottom", "front", "left", "back", "right" },

    tiles = { "power_pipe.png" },

    drawtype = "nodebox",
    light_source = 3,
    paramtype = "light",
    sunlight_propagates = true,

    groups = { matter = 1, cracky = 3, pipe_connects = 1, pipe_conducts = 1, habitat_conducts = 1, explody = 100 },

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

minetest.register_alias("sbz_power:power_pipe", "sbz_power:power_cable")

minetest.register_craft({
    type = "shapeless",
    output = "sbz_power:power_pipe",
    recipe = { "sbz_resources:raw_emittrium", "sbz_resources:matter_plate" }
})


minetest.register_node("sbz_power:airtight_power_cable", {
    description = "Airtight Emittrium Power Cable",
    connects_to = { "group:pipe_connects" },
    connect_sides = { "top", "bottom", "front", "left", "back", "right" },

    tiles = { "airtight_power_cable.png" },

    drawtype = "mesh",
    mesh = "voxelmodel.obj",
    light_source = 3,
    paramtype = "light",
    paramtype2 = "wallmounted",
    sunlight_propagates = true,

    groups = { matter = 1, cracky = 3, pipe_connects = 1, pipe_conducts = 1, habitat_conducts = 0, explody = 100, },

    use_texture_alpha = "clip",
})

minetest.register_craft {
    output = "sbz_power:airtight_power_cable",
    type = "shapeless",
    recipe = {
        "sbz_power:power_pipe", "sbz_resources:emittrium_glass",
    }
}
