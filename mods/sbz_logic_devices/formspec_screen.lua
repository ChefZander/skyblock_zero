local max = 100 * 1024
minetest.register_node("sbz_logic_devices:formspec_screen", {
    description = "Formspec Screen",
    info_extra = "Max formspec size: 100kb",
    tiles = {
        "formspec_screen.png",
        "formspec_screen_back.png",
        "formspec_screen_side.png",
        "formspec_screen_side.png",
        "formspec_screen_side.png",
        "formspec_screen_side.png",
    },
    drawtype = "nodebox",
    node_box = {
        type = "fixed",
        fixed = {
            -0.5, -8 / 16, -0.5,
            0.5, -3 / 16, 0.5
        },
    },
    sounds = sbz_api.sounds.machine(),
    paramtype2 = "wallmounted",
    paramtype = "light",
    light_source = 5,
    groups = {
        matter = 1,
        ui_logic = 1,
        public = 1,
    },
    on_logic_send = function(pos, msg, from_pos)
        if type(msg) ~= "string" then return end
        if #msg > max then return end
        if msg == "subscribe" then
            minetest.get_meta(pos):set_string("linked", vector.to_string(from_pos))
        elseif msg == "unsubscribe" then
            minetest.get_meta(pos):set_string("linked", "")
        else
            minetest.get_meta(pos):set_string("formspec", msg)
        end
    end,
    on_receive_fields = function(pos, formname, fields, sender)
        local send_to_pos = vector.from_string(minetest.get_meta(pos):get_string("linked") or "")
        if send_to_pos == nil then return end
        local result = table.copy(fields)
        result.sender = sender:get_player_name()

        sbz_logic.send(send_to_pos, result, pos)
    end
})

minetest.register_craft {
    output = "sbz_logic_devices:formspec_screen",
    recipe = {
        { "",                      "sbz_resources:luanium",     "", },
        { "sbz_resources:luanium", "sbz_resources:matter_blob", "sbz_resources:luanium" },
        { "",                      "sbz_logic:data_disk",       "", }
    }
}
