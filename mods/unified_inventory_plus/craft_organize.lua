-- Organize items in the craft inventory following a pattern:
local ui = unified_inventory
local uip = unified_inventory_plus

local default_stack_max = tonumber(minetest.settings:get("default_stack_max")) or 99

-- Backup to inject code
uip.craft_organize = ui.pages["craft"].get_formspec

ui.pages["craft"] = {
    get_formspec = function(player, perplayer_formspec)
        local formspec = uip.craft_organize(player, perplayer_formspec).formspec
        local btnsz = ui.imgscale / 3
        local btnspc = ui.imgscale / 2

        if perplayer_formspec.pagecols == 4 then
            -- UI is in lite mode.
            for i, v in ipairs(uip.craft_patterns) do
                formspec = formspec ..
                    ("image_button[%f,%f;%f,%f;%s;craft_organize_%i;]"):format(
                        perplayer_formspec.craft_x + btnspc * (i - 1),
                        perplayer_formspec.craft_y + 0.1 - btnspc,
                        btnsz,
                        btnsz,
                        v.ico,
                        i
                    )
            end
        else
            for i, v in ipairs(uip.craft_patterns) do
                formspec = formspec ..
                    ("image_button[%f,%f;%f,%f;%s;craft_organize_%i;]"):format(
                        perplayer_formspec.craft_x + btnspc * ((i - 1) % 6) + 0.1,
                        perplayer_formspec.craft_y + 0.22 - (math.ceil(i / 6)) * btnspc,
                        btnsz,
                        btnsz,
                        v.ico,
                        i
                    )
            end
        end
        return { formspec = formspec }
    end,
}

local function get_pattern_id(fields)
    for k, _ in pairs(fields) do
        local pattern_id = tonumber(k:match("craft_organize_(.*)"))
        if pattern_id then
            return pattern_id
        end
    end
end

local function get_single_item(craft_list)
    for _, stk in ipairs(craft_list) do
        if not stk:is_empty() then
            local item = ItemStack(stk)
            item:set_count(1)
            return item
        end
    end
end

local function all_identical(craft_list)
    local single_strings = {}
    for _, stk in ipairs(craft_list) do
        if not stk:is_empty() then
            local item = ItemStack(stk)
            item:set_count(1)
            table.insert(single_strings, item:to_string())
        end
    end
    if #single_strings == 0 then return false end
    local first = single_strings[1]
    for i = 2, #single_strings do
        if first ~= single_strings[i] then
            return false
        end
    end
    return true
end

local function count_items(craft_list)
    local count = 0
    for _, stk in ipairs(craft_list) do
        count = count + stk:get_count()
    end
    return count
end

-- Organize items in the craft inventory following a pattern
local function craft_organize(player, fields)
    local player_name = player:get_player_name()

    local pattern_id = get_pattern_id(fields)
    if not pattern_id or not uip.craft_patterns[pattern_id] then
        minetest.chat_send_player(player_name, "Unexpected pattern!?")
        return
    end
    local pattern = uip.craft_patterns[pattern_id].pattern
    local pattern_size = #pattern

    local player_inv = player:get_inventory()
    local craft_list = player_inv:get_list("craft")

    local single_item = get_single_item(craft_list)
    if not single_item then
        -- craft inv is empty
        minetest.chat_send_player(player_name, "Inventory empty.")
        return
    end

    if not all_identical(craft_list) then
        minetest.chat_send_player(player_name, "You can only organize one type of item.")
        return
    end

    local itemname = single_item:get_name()
    local def = minetest.registered_items[itemname]
    if not def then
        minetest.chat_send_player(player_name, "You can't organize an unknown item.")
        return
    end

    local stacksize = def.stack_max or default_stack_max
    local num_items = count_items(craft_list)

    if num_items > stacksize * pattern_size then
        minetest.chat_send_player(player_name, "Too many items to stack in that pattern.")
        return
    end

    if num_items < pattern_size then
        minetest.chat_send_player(player_name, "Not enough items.")
        return
    end

    local new_stack_size = math.floor(num_items / pattern_size)
    local remainder = num_items % pattern_size

    local new_craft_list = {
        ItemStack(), ItemStack(), ItemStack(),
        ItemStack(), ItemStack(), ItemStack(),
        ItemStack(), ItemStack(), ItemStack(),
    }

    -- because remainder is strictly less than pattern_size, this should always finish w/ remainder = 0
    for _, index in ipairs(pattern) do
        local new_item = ItemStack(single_item)
        if remainder > 0 then
            new_item:set_count(new_stack_size + 1)
            remainder = remainder - 1
        else
            new_item:set_count(new_stack_size)
        end
        new_craft_list[index] = new_item
    end

    player_inv:set_list("craft", new_craft_list)
end

minetest.register_on_player_receive_fields(function(player, formname, fields)
    for k, _ in pairs(fields) do
        if k:match("craft_organize_") then
            craft_organize(player, fields)
            return
        end
    end
end)
