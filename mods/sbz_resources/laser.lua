local laser_range = 300

local max_wear = 50
local power_per_1_use = 50

core.register_tool("sbz_resources:laser_weapon", {
    description = "Laser",
    info_extra = core.colorize("#ffff00", "Ability: Fire (Right-Click)") .. " Fire a laserbeam which destroys meteorites and damages players.",
    inventory_image = "laser_pointer.png",
    groups = { disable_repair = 1, power_tool = 1 },
    wear_represents = "power",
    on_use = function(stack, player, original_pointed)
        if stack:get_wear() < (65535) then
            stack:set_wear(math.min(65535, stack:get_wear() + (65535 / max_wear)))

            local eye_pos = sbz_api.get_pos_with_eye_height(player)
            local look_dir = player:get_look_dir()
            local end_pos = vector.add(eye_pos, vector.multiply(look_dir, laser_range))
            local ray = core.raycast(vector.add(eye_pos, vector.multiply(look_dir, 2)), end_pos, true, false)

            core.sound_play({ name = 'gen_laser_pew', gain = 0.6 }, { pos = eye_pos })
            core.sound_play({ name = 'gen_laser_pew', gain = 0.6 }, { pos = end_pos })

            repeat
                local pointed = ray:next()
                if pointed and pointed.type == "object" then
                    local ref = pointed.ref
                    local luaentity = ref:get_luaentity()
                    if luaentity and luaentity.name == "sbz_meteorites:meteorite" then
                        core.after(0.1, function()
                            if ref and ref:is_valid() then
                                sbz_api.meteorite_explode(ref:get_pos(), luaentity.type)
                            end
                        end)
                    end
                    if ref:is_player() then
                        core.after(0.1, function()
                            if ref and ref:is_player() and player and player:is_player() then
                                local damage = 3
                                sbz_api.punch(ref, player, 200, {
                                    full_punch_interval = 0,
                                    damage_groups = { light = damage },
                                }, look_dir)
                            end
                        end)
                    end
                end
            until not pointed

            core.add_particlespawner {
                pos     = eye_pos + look_dir * 2,
                texture = "star.png^[colorize:red",
                time    = 0.8,
                size    = 3,
                amount  = 5000,
                exptime = 10,
                attract = {
                    kind = "point",
                    origin = end_pos,
                    strength = 0.8,
                    die_on_contact = true,
                },
                glow    = 14,
            }
        end
        core.sound_play({ name = 'foley_dud_click' }, { pos = player.pos })

        return stack
    end,
    on_place = sbz_api.on_place_recharge((max_wear / 65535) * power_per_1_use),
    powertool_charge = sbz_api.powertool_charge((max_wear / 65535) * power_per_1_use),
    charge_per_use = power_per_1_use,
    power_per_1_use = power_per_1_use,
    wield_scale = { x = 1, y = 1, z = 2.5 },
    wield_image = "laser_wield.png",
    wear_color = { color_stops = { [0] = "lime" } },
})

do -- Laser recipe scope
    local Laser = 'sbz_resources:laser_weapon'
    local EC = 'sbz_resources:emittrium_circuit'
    local AB = 'sbz_power:advanced_battery'
    local RM = 'sbz_resources:reinforced_matter'
    core.register_craft({
        output = Laser,
        recipe = {
            { EC },
            { AB },
            { RM },
        }
    })
end
