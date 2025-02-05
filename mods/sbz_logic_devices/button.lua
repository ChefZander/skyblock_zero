minetest.register_node("sbz_logic_devices:button", {
    description = "Logic Button",
    tiles = {
        "button_side.png",
        "button_side.png^[transformFY",

        "button_side.png^[transformR270",
        "button_side.png^[transformR90",

        "button_side.png",
        "button.png",
    },
    info_extra = "They are public, anyone can toggle them regardless of protection.",
    drawtype = "nodebox",
    node_box = {
        type = "fixed",
        fixed = {
            { -0.375,  -0.375,  0.3125, 0.375,  0.375,  0.5 },    -- NodeBox1
            { -0.3125, -0.3125, 0.1875, 0.3125, 0.3125, 0.3125 }, -- NodeBox2
        }
    },
    paramtype2 = "facedir",
    paramtype = "light",
    light_source = 10,
    groups = {
        matter = 1,
        ui_logic = 1,
        attached_node = 2,
    },
    on_logic_send = function(pos, msg, from_pos)
        if type(msg) ~= "string" then return end
        if msg == "subscribe" then
            minetest.get_meta(pos):set_string("linked", vector.to_string(from_pos))
        elseif msg == "unsubscribe" then
            minetest.get_meta(pos):set_string("linked", "")
        end
    end,
    on_rightclick = function(pos)
        local m = minetest.get_meta(pos)
        local l = vector.from_string(m:get_string("linked"))
        if l then
            m:set_string("infotext", "Working")
            sbz_logic.send(l, true, pos)
            minetest.add_particlespawner({
                amount = 10,
                time = 0.01,
                exptime = 1,
                glow = 14,
                pos = pos,
                vel = { min = { x = -5, y = -5, z = -5 }, max = { x = 5, y = 5, z = 5 } },
                texture = "blank.png^[invert:rgba^[colorize:red",
            })
        else
            m:set_string("infotext", "No luacontroller is subscribed to this button")
        end
    end
})

local function toint(x)
    if x == true then return 1 elseif x == false then return 0 end
end
local function tobool(x)
    if x == 0 then return false elseif x == 1 then return true end
end

sbz_api.register_stateful("sbz_logic_devices:toggle", {
    description = "Logic Toggle",
    tiles = {
        "button_side.png",
        "button_side.png^[transformFY",

        "button_side.png^[transformR270",
        "button_side.png^[transformR90",

        "button_side.png",
        "button.png",
    },
    drawtype = "nodebox",
    info_extra = "They are public, anyone can toggle them regardless of protection.",
    node_box = {
        type = "fixed",
        fixed = {
            { -0.375, -0.375, 0.3125, 0.375, 0.375, 0.5 }, -- NodeBox1
        }
    },
    sounds = sbz_api.sounds.machine(),
    paramtype2 = "facedir",
    paramtype = "light",
    light_source = 10,
    groups = {
        matter = 1,
        ui_logic = 1,
        attached_node = 2,
    },
    on_logic_send = function(pos, msg, from_pos)
        sbz_logic.send(from_pos, (tobool(minetest.get_meta(pos):get_int("status"))), pos)
    end,
    on_rightclick = function(pos)
        local new_state = not sbz_api.is_on(pos)
        if new_state == false then
            sbz_api.turn_off(pos)
        else
            sbz_api.turn_on(pos)
        end
        minetest.get_meta(pos):set_int("status", toint(new_state))
    end,
}, {
    tiles = {
        "button_side.png",
        "button_side.png^[transformFY",

        "button_side.png^[transformR270",
        "button_side.png^[transformR90",

        "button_side.png",
        "toggle_on.png",
    }
})

unified_inventory.register_craft {
    type = "ele_fab",
    items = {
        "sbz_chem:bronze_ingot 1",
        "sbz_chem:silicon_ingot 1",
        "sbz_resources:matter_plate 1"
    },
    output = "sbz_logic_devices:button 4",
    width = 2,
    height = 2,
}

unified_inventory.register_craft {
    type = "ele_fab",
    items = {
        "sbz_chem:nickel_ingot 1",
        "sbz_chem:silicon_ingot 1",
        "sbz_resources:matter_plate 1"
    },
    output = "sbz_logic_devices:toggle 4",
    width = 2,
    height = 2,
}
