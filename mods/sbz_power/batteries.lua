local storage = core.get_mod_storage()


function sbz_power.register_battery(name, def)
    for k, v in pairs { sbz_battery = 1, sbz_machine = 1, pipe_connects = 1, pipe_conducts = 1 } do
        def.groups[k] = v
    end

    local max = def.battery_max
    def.action = def.action or function(pos, node, meta, supply, demand)
        if node == "sbz_power:teleport_battery" and meta:get_string("channel") ~= ""
        then
            meta:set_int("power", storage:get_int(meta:get_string("channel")))
            max = meta:get_int("maxpower")
        end
        local current_power = meta:get_int("power")
        meta:set_string("infotext",
            string.format("Battery: %s power", sbz_api.format_power(current_power, max)))
        meta:set_string("formspec",
            sbz_api.battery_fs(sbz_power.round_power(current_power), sbz_power.round_power(max)))
        if node == "sbz_power:teleport_battery"
        then
            local channel = meta:get_string("channel")
            local help_text = minetest.formspec_escape(
                "Channels are public by default" .. "\n" ..
                "Use <player>:<player>:<player>:<channel> \n To limmit the channle to the set of players given"
            )

            local formspec = "formspec_version[2]size[8,4.4]" ..
                "image[0.5,0.3;1,1;warp_crystal.png]" ..
                "label[1.75,0.8;" .. "Teleporting Battery" .. "]" ..
                "field[0.5,1.7;5,0.8;channel;" .. "Channel" .. ";${channel}]" ..
                "field[5,0.5;2.5,0.8;maxpower;" .. "Power limmit in Cj" .. ";${maxpower}]" ..
                "button_exit[5.5,1.7;2,0.8;save;" .. "Save" .. "]" ..
                "label[0.5,2.8;" .. help_text .. "]"
            meta:set_string("formspec", formspec)

        end
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

sbz_power.register_battery("sbz_power:teleport_battery", {
    description = "Teleport Battery",
    tiles = { "teleport_battery.png" },
    groups = { matter = 1, level = 2 },
    battery_max = 200000,
    on_receive_fields = function(pos, formname, fields, player)
        local meta = core.get_meta(pos)
        if fields.save == "Save" or fields.key_enter == "true"
        then
            if tonumber(fields.maxpower) == nil
            then
                if fields.maxpower ~= ""
                then
                    core.chat_send_player(player:get_player_name(),"Ah yes can I have " .. dump(fields.maxpower) .. " power" .. " ... they have played us for absolute fools")
                    core.chat_send_player(player:get_player_name(),"Input a number next time if you don't want the pwer to be set to 200000")
                end
                meta:set_int("maxpower", 200000)
            else
                if tonumber(fields.maxpower) > 200000
                then
                    core.chat_send_player(player:get_player_name(),"The power limmit it too high try setting it lower")
                else
                    if tonumber(fields.maxpower) < 0
                    then
                        core.chat_send_player(player:get_player_name(),"Unlimited power oh wait ah man")
                    else
                        meta:set_int("maxpower", tonumber(fields.maxpower))
                    end
                end
            end
            local sep = ":"
            local index = 0
            local username_flag = -1
            if fields.channel ~= "" and fields.channel ~= nill
            then
                for str in string.gmatch(fields.channel, "([^"..sep.."]+)") do
                        if str == player:get_player_name() and username_flag == -1
                        then
                            username_flag = index -- set it to the index so we can track if it is the last string where it would get rejected
                        end
                        index=index+1
                end
            end
            if string.len(fields.channel) < 1000
            then
                if username_flag ~= index and username_flag ~= -1 or index == 1
                then
                    meta:set_string("channel", fields.channel)
                elseif fields.channel == ""
                then
                    core.chat_send_player(player:get_player_name(),"The channel can't be blank")
                else
                    core.chat_send_player(player:get_player_name(),"Sorry, receiving from this channel is reserved try another one")
                end
            else
                core.chat_send_player(player:get_player_name(),"Nice try this power party can't be this big (you can't input more then 999 charictors)")
            end
        end

end,
})

minetest.register_craft({
    output = "sbz_power:teleport_battery",
    recipe = {
        { "sbz_resources:warp_crystal",  "sbz_resources:warp_crystal", "sbz_resources:warp_crystal" },
        { "sbz_resources:warp_crystal", "sbz_power:very_advanced_battery", "sbz_resources:warp_crystal" },
        { "sbz_resources:warp_crystal",  "sbz_resources:warp_crystal", "sbz_resources:warp_crystal" }
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
