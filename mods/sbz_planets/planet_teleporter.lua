local mg_limit = tonumber(core.settings:get("mapgen_limit")) or 31007
local mg_vector = vector.new(mg_limit, mg_limit, mg_limit)
core.register_node("sbz_planets:planet_teleporter", {
    info_extra = "Teleports you to a planet. Insert a warp crystal to get teleported.",
    description = "Planet Teleporter",
    tiles = { "planet_teleporter.png" },
    groups = { matter = 1, level = 2 },
    on_rightclick = function(pos, node, clicker, stack, pointed)
        if clicker.is_fake_player then return stack end
        local clicker_name = clicker:get_player_name()
        if stack:get_name() ~= "sbz_resources:warp_crystal" then
            core.chat_send_player(clicker_name, "You must be holding a warp crystal for this to work.")
            return stack
        end
        local id = math.random(0, sbz_api.planets.num_planets)
        local content = sbz_api.planets.area:get_area(id, true, true)
        local data = core.deserialize(content.data)
        local pos_to_tp_to = (vector.subtract(content.max, content.min) / 2) + content.min
        pos_to_tp_to.y = content.max.y + 60
        if not vector.in_area(pos_to_tp_to, -mg_vector, mg_vector) then
            core.chat_send_player(clicker_name,
                "Oops, the crystal broke, please insert another one. [What actually happened was that the planet teleporter tried to teleport you out of this world. Hello if you are seeing this - you must be very lucky.]")
            stack:take_item(1)
            return stack
        end
        if sbz_api.planets.has_rings(data[1], data[2]) then
            pos_to_tp_to.y = pos_to_tp_to.y - (((content.max.y - content.min.y) / 4) + sbz_api.planets.ring_size + 10)
        end
        clicker:set_pos(pos_to_tp_to)
        core.chat_send_player(clicker_name, "You have been teleported to the planet. Please wait and fall a bit.")
        stack:take_item(1)
        return stack
    end
})

core.register_craft {
    output = "sbz_planets:planet_teleporter",
    recipe = {
        { "sbz_resources:matter_blob",        "sbz_resources:prediction_circuit", "sbz_resources:matter_blob" },
        { "sbz_resources:prediction_circuit", "sbz_resources:phlogiston_circuit", "sbz_resources:prediction_circuit" },
        { "sbz_resources:matter_blob",        "sbz_resources:prediction_circuit", "sbz_resources:matter_blob" },
    }
}
