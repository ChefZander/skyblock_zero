local http = ...
-- License: LGPLv3 or later
-- from: https://github.com/mt-mods/digistuff/blob/master/nic.lua

local settings = minetest.settings
local is_priv_locked = settings:get_bool("sbz_nic_priv_locked", true)

minetest.register_node("digistuff:nic", {
    description = "Digilines NIC",
    groups = { cracky = 3 },
    is_ground_content = false,
    on_construct = function(pos)
        local meta = minetest.get_meta(pos)
        meta:set_string("formspec", "field[channel;Channel;${channel}")
    end,
    tiles = {
        "digistuff_nic_top.png",
        "jeija_microcontroller_bottom.png",
        "jeija_microcontroller_sides.png",
        "jeija_microcontroller_sides.png",
        "jeija_microcontroller_sides.png",
        "jeija_microcontroller_sides.png"
    },
    inventory_image = "digistuff_nic_top.png",
    drawtype = "nodebox",
    selection_box = {
        --From luacontroller
        type = "fixed",
        fixed = { -8 / 16, -8 / 16, -8 / 16, 8 / 16, -5 / 16, 8 / 16 },
    },
    _digistuff_channelcopier_fieldname = "channel",
    node_box = {
        --From Luacontroller
        type = "fixed",
        fixed = {
            { -8 / 16, -8 / 16, -8 / 16, 8 / 16, -7 / 16, 8 / 16 }, -- Bottom slab
            { -5 / 16, -7 / 16, -5 / 16, 5 / 16, -6 / 16, 5 / 16 }, -- Circuit board
            { -3 / 16, -6 / 16, -3 / 16, 3 / 16, -5 / 16, 3 / 16 }, -- IC
        }
    },
    paramtype = "light",
    sunlight_propagates = true,
    on_receive_fields = function(pos, formname, fields, sender)
        local name = sender:get_player_name()
        if minetest.is_protected(pos, name) and not minetest.check_player_privs(name, { protection_bypass = true }) then
            minetest.record_protection_violation(pos, name)
            return
        end
        local meta = minetest.get_meta(pos)
        if fields.channel then meta:set_string("channel", fields.channel) end
    end,
    digiline = {
        receptor = {},
        effector = {
            action = function(pos, node, channel, msg)
                local meta = minetest.get_meta(pos)
                if meta:get_string("channel") ~= channel then return end
                local url
                local parse_json = false
                -- parse message
                if type(msg) == "string" then
                    -- simple string data
                    url = msg
                elseif type(msg) == "table" and type(msg.url) == "string" then
                    -- config object
                    url = msg.url
                    parse_json = msg.parse_json
                else
                    -- not supported
                    return
                end
                http.fetch({
                        url = url,
                        timeout = 5,
                        user_agent = "Minetest Digilines Modem"
                    },
                    function(res)
                        if type(res.data) == "string" and parse_json then
                            -- parse json data and replace payload
                            res.data = minetest.parse_json(res.data)
                        end
                        digilines.receptor_send(pos, digilines.rules.default, channel, res)
                    end)
            end
        },
    },
})
minetest.register_craft({
    output = "digistuff:nic",
    recipe = {
        { "",                            "",                                         "mesecons:wire_00000000_off" },
        { "digilines:wire_std_00000000", "mesecons_luacontroller:luacontroller0000", "mesecons:wire_00000000_off" }
    }
})
