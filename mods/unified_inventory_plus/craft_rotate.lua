-- Rotate items in the craft inventory
local ui = unified_inventory
local uip = unified_inventory_plus

-- Backup to inject code
uip.craft_rotate = ui.pages["craft"].get_formspec

ui.pages["craft"] = {
    get_formspec = function(player, perplayer_formspec)
        local formspec = uip.craft_rotate(player, perplayer_formspec).formspec
        formspec = formspec ..
            ("image_button[%f,%f;%f,%f;pattern_rotate.png;craft_rotate;]"):format(
                perplayer_formspec.craft_x - perplayer_formspec.btn_spc,
                perplayer_formspec.craft_y,
                perplayer_formspec.btn_size,
                perplayer_formspec.btn_size
            )
        return { formspec = formspec }
    end,
}


-- Rotate items in the craft inventory
local function craft_rotate_cw(player)
    local player_inv = player:get_inventory()
    local craft_list = player_inv:get_list("craft")

    -- Rotate corners
    local stack = craft_list[1]
    craft_list[1] = craft_list[7]
    craft_list[7] = craft_list[9]
    craft_list[9] = craft_list[3]
    craft_list[3] = stack

    -- Rotate middle ones
    stack = craft_list[2]
    craft_list[2] = craft_list[4]
    craft_list[4] = craft_list[8]
    craft_list[8] = craft_list[6]
    craft_list[6] = stack

    player_inv:set_list("craft", craft_list)
end

minetest.register_on_player_receive_fields(function(player, formname, fields)
    --if not formname:match("craft") then return end
    for k, _ in pairs(fields) do
        if k:match("craft_rotate") then
            craft_rotate_cw(player)
        end
    end
end)
