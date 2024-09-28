-- Clear items in the craft inventory
local ui = unified_inventory
local uip = unified_inventory_plus

-- Backup to inject code
uip.craft_clear = ui.pages["craft"].get_formspec

ui.pages["craft"] = {
    get_formspec = function(player, perplayer_formspec)
        local formspec = uip.craft_clear(player, perplayer_formspec).formspec
        formspec = formspec ..
            ("image_button[%f,%f;%f,%f;pattern_clear.png;craft_clear;]"):format(
                perplayer_formspec.craft_x - perplayer_formspec.btn_spc,
                perplayer_formspec.craft_y + ui.imgscale,
                perplayer_formspec.btn_size,
                perplayer_formspec.btn_size
            )
        return { formspec = formspec }
    end,
}

-- Return items from the craft inventory to the player's inventory
local function craft_clear(player)
    local player_inv = player:get_inventory()
    local craft_list = player_inv:get_list("craft")

    for i, stk in ipairs(craft_list) do
        if player_inv:room_for_item("main", stk) then
            player_inv:add_item("main", stk)
            craft_list[i]:clear()
        end
    end

    player_inv:set_list("craft", craft_list)
end

minetest.register_on_player_receive_fields(function(player, formname, fields)
    for k, _ in pairs(fields) do
        if k:match("craft_clear") then
            craft_clear(player)
        end
    end
end)
