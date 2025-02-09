local laser_range = 100 * 10

local max_wear = 50
local power_per_1_use = 50

minetest.register_tool("sbz_resources:laser_weapon", {
    description = "Laser",
    info_extra = "Do you want to get all the meteorites you see, without bridging to them? This is the perfect weapon",
    inventory_image = "laser_pointer.png",
    groups = { disable_repair = 1 },
    on_use = function(stack, player, original_pointed)
        if stack:get_wear() < (65535) then
            stack:set_wear(math.min(65535, stack:get_wear() + (65535 / max_wear)))

            local eyepos = vector.add(player:get_pos(),
                vector.add(player:get_eye_offset(), vector.new(0, 1.5, 0)))
            local lookdir = player:get_look_dir()
            local endpos = vector.add(eyepos, vector.multiply(lookdir, laser_range))
            local ray = minetest.raycast(vector.add(eyepos, vector.multiply(lookdir, 2)), endpos, true, false)

            repeat
                local pointed = ray:next()
                if pointed and pointed.type == "object" then
                    local ref = pointed.ref
                    local luaentity = ref:get_luaentity()
                    if luaentity and luaentity.name == "sbz_meteorites:meteorite" then
                        minetest.after(0.1, function()
                            if ref and ref:is_valid() then
                                sbz_api.meteorite_explode(ref:get_pos(), luaentity.type)
                            end
                        end)
                    end
                    if ref:is_player() then
                        minetest.after(0.1, function()
                            if ref and ref:is_player() and player and player:is_player() then
                                local damage = 3
                                ref:punch(player, nil, {
                                    full_punch_interval = 0,
                                    damage_groups = { light = damage },
                                }, lookdir)
                            end
                        end)
                    end
                end
            until not pointed

            core.add_particlespawner {
                pos     = vector.subtract(eyepos, vector.new(0, 0.25, 0)) + lookdir * 2,
                texture = "star.png^[colorize:red:255",
                time    = 0.2,
                size    = 3,
                exptime = 1,
                amount  = 3000,
                attract = {
                    kind = "point",
                    origin = endpos,
                    strength = 1 / 5,
                    die_on_contact = true,
                },
                glow    = 14,
            }
        end


        return stack
    end,
    on_place = sbz_api.on_place_recharge((max_wear / 65535) * power_per_1_use),
    wield_scale = { x = 1, y = 1, z = 2.5 },
    wield_image = "laser_wield.png",
    wear_color = { color_stops = { [0] = "lime" } },
})

minetest.register_craft {
    output = "sbz_resources:laser_weapon",
    recipe = {
        { "sbz_resources:emittrium_circuit" },
        { "sbz_power:advanced_battery" },
        { "sbz_resources:reinforced_matter" }
    }
}
