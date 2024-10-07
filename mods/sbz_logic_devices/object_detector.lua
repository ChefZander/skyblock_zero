local R = 10

minetest.register_node("sbz_logic_devices:object_detector", {
    description = "Object/Player Detector",
    info_extra = ("Has a radius of %s"):format(R),

    tiles = {
        "object_detector.png"
    },
    groups = {
        matter = 1,
        ui_logic = 1
    },
    on_logic_send = function(pos, msg, from_pos)
        local settings = {
            inventories = true,
            props = true
        }
        if type(msg) == "table" then
            if type(msg.inventories) == "boolean" then
                settings.inventories = msg.inventories
            end
            if type(msg.props) == "boolean" then
                settings.props = msg.props
            end
        end

        local result = {}
        for k, v in ipairs(minetest.get_connected_players()) do
            local p = v:get_pos()
            if ((p.x - pos.x) ^ 2 + (p.y - pos.y) ^ 2 + (p.z - pos.z) ^ 2) <= R ^ 2 then
                result[#result + 1] = {
                    is_player = v:is_player(),

                    name = v:get_player_name(),

                    camera = {
                        dir = v:get_look_dir(),
                        pitch = v:get_look_vertical(),
                        yaw = v:get_look_horizontal(),
                        fov = v:get_fov()
                    },
                    control = v:get_player_control(),
                    physics = v:get_physics_override(),
                    lighting = v:get_lighting(),

                    inv = settings.inventories and logic.kill_itemstacks(v:get_inventory():get_lists()),
                    wield_index = v:get_wield_index(), -- can be used for fun stuff like controls in a game
                    wielded_item = settings.inventories and v:get_wielded_item(),

                    nametag = v:get_nametag_attributes(),
                    pos = p,
                    props = settings.props and v:get_properties(),
                    hp = v:get_hp(),
                    armor_groups = v:get_armor_groups(),
                    velocity = v:get_velocity(),
                }
            end
        end

        for obj in minetest.objects_inside_radius(pos, R) do
            if obj:is_valid() and obj:get_luaentity() then
                result[#result + 1] = {
                    is_player = obj:is_player(),

                    nametag = obj:get_nametag_attributes(),
                    pos = obj:get_pos(),
                    props = settings.props and obj:get_properties(),
                    hp = obj:get_hp(),
                    armor_groups = obj:get_armor_groups(),
                    velocity = obj:get_velocity(),

                    -- luaentity only
                    acceleration = obj:get_acceleration(),
                    rotation = obj:get_rotation(),
                    yaw = obj:get_yaw(),
                    texture_mod = obj:get_texture_mod(),
                    name = obj:get_luaentity().name,

                }
            end
        end
        sbz_api.logic.send(from_pos, result, pos)
    end,
    on_punch = function(pos, _, player)
        vizlib.draw_cube(pos, R + 0.5, { player = player })
        minetest.get_meta(pos):set_string("infotext", "Object Detector")
    end,
})
minetest.register_craft {
    output = "sbz_logic_devices:object_detector",
    recipe = {
        { "sbz_resources:luanium", "sbz_resources:luanium",          "sbz_resources:luanium", },
        { "sbz_resources:luanium", "sbz_meteorites:meteorite_radar", "sbz_resources:luanium" },
        { "sbz_resources:luanium", "sbz_resources:luanium",          "sbz_resources:luanium", }
    }
}
