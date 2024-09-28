local ui = unified_inventory
local uip = unified_inventory_plus
local has = uip.has
local settings = uip.settings
local S = uip.S
local F = minetest.formspec_escape

-- Backup to inject code
uip.craft_all = ui.pages["craft"].get_formspec

ui.pages["craft"] = {
    get_formspec = function(player, perplayer_formspec)
        local formspec = uip.craft_all(player, perplayer_formspec).formspec
        formspec = formspec ..
            ("image[%f,%f;%f,%f;ui_crafting_long_arrow.png]"):format(
                perplayer_formspec.craft_arrow_x,
                perplayer_formspec.craft_y,
                ui.imgscale,
                ui.imgscale * 3) ..
            ("button[%f,%f;%f,%f;craft_craftall;%s]"):format(
                perplayer_formspec.craft_arrow_x + 0.23,
                perplayer_formspec.craft_y + 1.50,
                perplayer_formspec.btn_size,
                perplayer_formspec.btn_size,
                F(S("All"))
            )
        return { formspec = formspec }
    end,
}

-- make sure the width is right
local function infer_width(list, expected)
    if not expected or expected:is_empty() then
        return
    end
    local width
    for i = 1, 3 do
        local output, _ = minetest.get_craft_result({ method = "normal", width = i, items = list })
        if output.item:to_string() == expected:to_string() then
            width = i
            break
        end
    end
    if not width then
        uip.log("warning", "Can't infer recipe width for %s", expected:to_string())
    end
    return width
end

-- Craft max possible items and put the result in the main inventory
local function craft_craftall(player)
    local player_name = player:get_player_name()
    local player_inv = player:get_inventory()
    local craft_list = player_inv:get_list("craft")
    local expected_result = player_inv:get_stack("craftpreview", 1)
    local craft_width = infer_width(craft_list, expected_result)
    if not craft_width then
        return
    end

    local num_crafted = 0
    -- don't modify player's inventory until we're done, in case something goes wrong (e.g. crash)
    -- use a fake inventory instead of a detached inventory, because detached inventory actions all result in packets
    -- sent to the player.
    local tmp_inv = fakelib.create_inventory()
    tmp_inv:set_list("main", player_inv:get_list("main"))
    tmp_inv:set_list("craft", craft_list)

    while true do
        if (
            has.stamina and
            stamina.get_saturation and
            stamina.get_saturation(player) <= settings.craft_all_min_saturation
        ) then
            minetest.chat_send_player(player_name, S("You are too hungry to use Craft All at this time."))
            break
        end

        -- note that get_craft_result can be *very* slow, until minetest 5.7.0 is released.
        -- see https://github.com/minetest/minetest/issues/13231
        local output, decremented_input = minetest.get_craft_result({
            method = "normal",
            width = craft_width,
            items = craft_list,
        })

        if output.item:get_name() ~= expected_result:get_name() then
            -- the recipe changed, so we've run out of something. stop processing.
            break
        end

        -- minetest.on_craft expects to see the decremented input list.
        tmp_inv:set_list("craft", decremented_input.items)

        -- invoke callbacks, for compatibility w/ stamina, skyblock, moretrees, etc.
        -- note that this is an *undocumented* handler of the minetest lua API, and possibly is subject to change
        -- in the future.
        output.item = minetest.on_craft(output.item, player, craft_list, tmp_inv)

        -- track items added to the inventory, in case we need to remove them later
        local added = {}

        if tmp_inv:room_for_item("main", output.item) then
            tmp_inv:add_item("main", output.item)  -- should be no remainder, ignore it
            table.insert(added, output.item)
        else
            -- no room for the output item, stop
            break
        end

        -- we now try to add all replacements.
        local all_added = true
        for _, replacement_stk in ipairs(output.replacements) do
            if tmp_inv:room_for_item("main", replacement_stk) then
                tmp_inv:add_item("main", replacement_stk)  -- should be no remainder, ignore it
                table.insert(added, replacement_stk)
            else
                all_added = false
                break
            end
        end

        if not all_added then
            -- if we failed to add all the replacements, remove what we've added, and abort
            for _, stk in ipairs(added) do
                tmp_inv:remove_item("main", stk)  -- should be no remainder, ignore it
            end
            break
        end

        -- the craft list can be modified by the callbacks, so re-load it
        craft_list = tmp_inv:get_list("craft")

        num_crafted = num_crafted + 1
    end

    player_inv:set_list("craft", craft_list)
    player_inv:set_list("main", tmp_inv:get_list("main"))

    uip.log("action", "player %s crafts %s %i", player_name, expected_result:to_string(), num_crafted)
end

minetest.register_on_player_receive_fields(function(player, formname, fields)
    for k, _ in pairs(fields) do
        if k:match("craft_craftall") then
            craft_craftall(player)
            return
        end
    end
end)
