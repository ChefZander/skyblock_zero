local http = ...
-- License: LGPLv3 or later
-- from: https://github.com/mt-mods/digistuff/blob/master/nic.lua

local settings = minetest.settings
local is_priv_locked = settings:get_bool("sbz_nic_priv_locked", true)

minetest.register_privilege("nic_user", {
    description = "If the server has priv locked the NIC, this priv makes you able to place the thing.",
    give_to_admin = true,
    give_to_singleplayer = true,
})

minetest.register_node("sbz_logic_devices:nic", {
    description = "Logic NIC",
    info_extra = "<Server setting> Priv Locked: " .. (is_priv_locked and "yes" or "no"),

    groups = { cracky = 3, matter = 1, ui_logic = 1 },
    sounds = sbz_api.sounds.machine(),
    is_ground_content = false,
    tiles = {
        "nic_top.png",
        "nic_bottom.png",
        "nic_side.png",
        "nic_side.png",
        "nic_side.png",
        "nic_side.png"
    },
    drawtype = "nodebox",
    node_box = {
        type = "fixed",
        fixed = {
            { -0.5,    -0.5,   -0.5,    0.5,     -0.3125, 0.5 },     -- NodeBox1
            { -0.4375, -0.5,   0.3125,  -0.3125, 0.4375,  0.4375 },  -- NodeBox2
            { -0.4375, -0.5,   -0.4375, -0.3125, 0.4375,  -0.3125 }, -- NodeBox6
            { 0.3125,  -0.5,   -0.4375, 0.4375,  0.4375,  -0.3125 }, -- NodeBox8
            { 0.3125,  -0.5,   0.3125,  0.4375,  0.4375,  0.4375 },  -- NodeBox11
            { -0.5,    0.3125, 0.25,    -0.25,   0.5,     0.5 },     -- NodeBox14
            { 0.25,    0.3125, 0.25,    0.5,     0.5,     0.5 },     -- NodeBox16
            { 0.25,    0.3125, -0.5,    0.5,     0.5,     -0.25 },   -- NodeBox18
            { -0.5,    0.3125, -0.5,    -0.25,   0.5,     -0.25 },   -- NodeBox19
        }
    },
    paramtype = "light",
    sunlight_propagates = true,

    after_place_node = function(pos, placer, stack, pointed)
        if is_priv_locked then -- not perfect priv locking but whatever
            if minetest.check_player_privs(placer, "nic_user") == false then
                minetest.remove_node(pos)
                minetest.chat_send_player(placer:get_player_name(), "You don't have the nic_user priv!")
            end
        end
    end,

    on_logic_send = function(pos, msg, from_pos)
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
        if type(url) ~= "string" then return end

        http.fetch({
                url = url,
                timeout = 5,
                user_agent = "Minetest Digilines Modem" -- keep the digistuff user agent
            },
            function(res)
                if type(res.data) == "string" and parse_json then
                    -- parse json data and replace payload
                    res.data = minetest.parse_json(res.data)
                end
                sbz_logic.send(from_pos, res, pos)
            end)
    end
})

unified_inventory.register_craft {
    type = "ele_fab",
    items = {
        "sbz_resources:warp_crystal 4",
        "sbz_resources:lua_chip 5",
        "sbz_chem:silicon_ingot 3",
        "sbz_chem:invar_ingot 20"
    },
    width = 2, height = 2,
    output = "sbz_logic_devices:nic"
}
