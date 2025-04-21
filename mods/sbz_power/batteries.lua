local storage = core.get_mod_storage()


function sbz_power.register_battery(name, def)
    for k, v in pairs { sbz_battery = 1, sbz_machine = 1, pipe_connects = 1, pipe_conducts = 1 } do
        def.groups[k] = v
    end

    local max = def.battery_max
    def.action = def.action or function(pos, node, meta, supply, demand)
        local current_power = meta:get_int("power")
        meta:set_string("infotext",
            string.format("Battery: %s power", sbz_api.format_power(current_power, max)))
        meta:set_string("formspec",
            sbz_api.battery_fs(sbz_power.round_power(current_power), sbz_power.round_power(max)))
    end
    minetest.register_node(name, def)
end

sbz_power.register_battery("sbz_power:battery", {
    description = "Battery",
    tiles = { "battery.png" },
    groups = { matter = 1 },
    battery_max = 5000,
})

minetest.register_craft({
    output = "sbz_power:battery",
    recipe = {
        { "sbz_resources:matter_blob", "sbz_resources:matter_blob",       "sbz_resources:matter_blob" },
        { "sbz_power:power_pipe",      "sbz_resources:emittrium_circuit", "sbz_resources:matter_blob" },
        { "sbz_resources:matter_blob", "sbz_resources:matter_blob",       "sbz_resources:matter_blob" }
    }
})

sbz_power.register_battery("sbz_power:advanced_battery", {
    description = "Advanced Battery",
    tiles = { "advanced_battery.png" },
    groups = { matter = 1 },
    battery_max = 20000,
})
minetest.register_craft({
    output = "sbz_power:advanced_battery",
    recipe = {
        { "sbz_chem:cobalt_ingot",  "sbz_chem:lithium_ingot", "sbz_chem:cobalt_ingot" },
        { "sbz_chem:lithium_ingot", "sbz_chem:lithium_ingot", "sbz_chem:lithium_ingot" },
        { "sbz_chem:cobalt_ingot",  "sbz_chem:lithium_ingot", "sbz_chem:cobalt_ingot" }
    }
})

sbz_power.register_battery("sbz_power:very_advanced_battery", {
    description = "Very Advanced Battery",
    tiles = { "very_advanced_battery.png" },
    groups = { matter = 1, level = 2 },
    battery_max = 200000,
})

minetest.register_craft({
    output = "sbz_power:very_advanced_battery",
    recipe = {
        { "sbz_chem:cobalt_block",  "sbz_chem:lithium_block", "sbz_chem:cobalt_block" },
        { "sbz_chem:lithium_block", "sbz_chem:lithium_block", "sbz_chem:lithium_block" },
        { "sbz_chem:cobalt_block",  "sbz_chem:lithium_block", "sbz_chem:cobalt_block" }
    }
})

local function set_tp_battery_formspec(pos)
    local meta = core.get_meta(pos)
    --local channel = meta:get_string("channel")
    local help_text = minetest.formspec_escape(
        "Channels are public by default" .. "\n" ..
        "Use <player>:<player>:<player>:<channel> \n To limit the channel to the set of players given"
    )

    local formspec = "formspec_version[2]size[8,4.4]" ..
        "image[0.5,0.3;1,1;warp_crystal.png]" ..
        "label[1.75,0.8;" .. "Teleporting Battery" .. "]" ..
        "field[0.5,1.7;5,0.8;channel;" .. "Channel" .. ";${channel}]" ..
        "field[5,0.5;2.5,0.8;maxpower;" .. "Power limit in Cj" .. ";${maxpower}]" ..
        "button_exit[5.5,1.7;2,0.8;save;" .. "Save" .. "]" ..
        "label[0.5,2.8;" .. help_text .. "]"
    meta:set_string("formspec", formspec)
end

sbz_power.register_battery("sbz_power:teleport_battery", {
    description = "Teleport Battery",
    tiles = { "teleport_battery.png" },
    groups = { matter = 1, level = 2 },
    battery_max = 10000,
    on_construct = function(pos)
        set_tp_battery_formspec(pos)
    end,
    get_battery_max = function(pos, meta)
        if meta:get_string("channel") == "" then return 0 end
        return meta:get_int("maxpower")
    end,
    set_power = function(pos, node, meta, current, supplied_power, dir)
        meta:set_int("power", supplied_power)
        storage:set_int(meta:get_string("channel"), supplied_power)
    end,
    get_battery_id = function(pos, meta)
        return meta:get_string("channel")
    end,

    get_power = function(pos, node, meta)
        if meta:get_string("channel") == "" then return 0 end
        return storage:get_int(meta:get_string("channel"))
    end,
    action = function(pos, node, meta, supply, demand)
        local current_power = storage:get_int(meta:get_string("channel"))
        local max = meta:get_int("maxpower")
        meta:set_string("infotext",
            string.format("Battery: %s power", sbz_api.format_power(current_power, max)))
        set_tp_battery_formspec(pos)
    end,
    on_receive_fields = function(pos, formname, fields, player)
        local meta = core.get_meta(pos)
        if fields.save == "Save" or fields.key_enter == "true"
        then
            if tonumber(fields.maxpower) == nil
            then
                if fields.maxpower ~= ""
                then
                    core.chat_send_player(player:get_player_name(), "This field only accepts numbers.")
                end
                meta:set_int("maxpower", 10000)
            else
                if tonumber(fields.maxpower) > 10000
                then
                    core.chat_send_player(player:get_player_name(), "The power limit it too high. Try setting it lower.")
                else
                    if tonumber(fields.maxpower) < 0
                    then
                        core.chat_send_player(player:get_player_name(), "Please input a positive number.")
                    else
                        meta:set_int("maxpower", tonumber(fields.maxpower))
                    end
                end
            end
            local sep = ":"
            local index = 0
            local username_flag = -1
            if fields.channel ~= "" and fields.channel ~= nil then
                for str in string.gmatch(fields.channel, "([^" .. sep .. "]+)") do
                    if str == player:get_player_name() and username_flag == -1
                    then
                        username_flag =
                            index -- set it to the index so we can track if it is the last string where it would get rejected
                    end
                    index = index + 1
                end
            end
            if string.len(fields.channel) < 257 then
                if username_flag ~= index and username_flag ~= -1 or index == 1 then
                    meta:set_string("channel", fields.channel)
                elseif fields.channel == "" then
                    core.chat_send_player(player:get_player_name(), "The channel can't be blank.")
                else
                    core.chat_send_player(player:get_player_name(),
                        "Sorry, receiving from this channel is reserved, try another one.")
                end
            else
                core.chat_send_player(player:get_player_name(),
                    "The power party can't be this big (you can't input more then 256 characters)")
            end
        end
    end,
    on_logic_send = function(pos, msg, from_pos)
        local node = sbz_api.get_node_force(from_pos) -- get even if its unloaded
        if not node then return end
        local controller_meta = core.get_meta(from_pos)
        local owner = controller_meta:get_string("owner")

        local meta = core.get_meta(pos)
        if type(msg) == "table" then
            local sep = ":"
            local index = 0
            local username_flag = -1
            if msg.channel ~= "" and msg.channel ~= nil and type(msg.channel) == "string" then
                for str in string.gmatch(msg.channel, "([^" .. sep .. "]+)") do
                    if str == owner and username_flag == -1 then
                        username_flag = index
                        -- set it to the index so we can track if it is the last string where it would get rejected
                    end
                    index = index + 1
                end
                if string.len(msg.channel) < 256 then
                    if username_flag ~= index and username_flag ~= -1 or index == 1 then
                        if tonumber(msg.maxpower) ~= nil and msg.maxpower ~= "" and tonumber(msg.maxpower) <= 10000 and tonumber(msg.maxpower) >= 0 then
                            meta:set_int("maxpower", tonumber(msg.maxpower))
                        end
                        meta:set_string("channel", msg.channel)
                    end
                end
            end
        end
    end
})

minetest.register_craft({
    output = "sbz_power:teleport_battery",
    recipe = {
        { "sbz_resources:warp_crystal", "sbz_resources:warp_crystal",      "sbz_resources:warp_crystal" },
        { "sbz_resources:warp_crystal", "sbz_power:very_advanced_battery", "sbz_resources:warp_crystal" },
        { "sbz_resources:warp_crystal", "sbz_resources:warp_crystal",      "sbz_resources:warp_crystal" }
    }
})

core.register_node("sbz_power:creative_battery", {
    description = "Creative Power Generating Battery",
    info_extra =
    "It never runs out of power... useful for when you need to not have noise in your \"Supply\" statistic in the switching station.",
    tiles = { { name = "creative_battery_power_gen.png", animation = { type = "vertical_frames", length = 0.5 }, } },
    groups = { creative = 1, sbz_battery = 1, sbz_machine = 1, pipe_conducts = 1, pipe_connects = 1, matter = 3 },
    battery_max = 10 ^ 9, -- G
    action = function(pos, node, meta, supply, demand)
        local current_power = meta:get_int("power")
        meta:set_int("power", 10 ^ 9)
        meta:set_string("infotext", "Creative Power Generating Battery")
    end,
})

core.register_node("sbz_power:real_creative_battery", {
    description = "Creative Battery",
    tiles = { "creative_battery.png" },
    groups = { creative = 1, sbz_battery = 1, sbz_machine = 1, pipe_conducts = 1, pipe_connects = 1, matter = 3 },
    battery_max = 10 ^ 9, -- G
    action = function(pos, node, meta, supply, demand)
        local current_power = meta:get_int("power")
        meta:set_string("infotext", string.format("Creative Battery: %s / 1 GCj", sbz_api.format_power(current_power)))
    end,
})
