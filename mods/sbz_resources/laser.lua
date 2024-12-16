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
            local ray = minetest.raycast(eyepos, endpos, true, false)

            repeat
                local pointed = ray:next()
                if pointed and pointed.type == "object" then
                    local ref = pointed.ref
                    local luaentity = ref:get_luaentity()
                    if luaentity and luaentity.name == "sbz_meteorites:meteorite" then
                        minetest.after(0.1, function()
                            sbz_api.meteorite_explode(ref:get_pos(), luaentity.type)
                        end)
                    end
                end
            until not pointed

            core.add_particlespawner {
                pos     = vector.subtract(eyepos, vector.new(0, 0.25, 0)),
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
    on_place = function(stack, user, pointed)
        if pointed.type ~= "node" then return end
        local target = pointed.under
        if core.is_protected(target, user:get_player_name()) then
            return core.record_protection_violation(target, user:get_player_name())
        end
        local target_node = minetest.get_node(target)
        if minetest.get_item_group(target_node.name, "sbz_battery") == 0 then return end
        local meta = minetest.get_meta(target)
        local power = meta:get_int("power")
        local current_wear = math.floor((stack:get_wear() / 65535) * max_wear)
        local wear_repaired = math.min(current_wear, math.floor(power / power_per_1_use))
        local power_charged = wear_repaired * power_per_1_use
        local new_power = power - power_charged

        meta:set_int("power", new_power)
        minetest.registered_nodes[target_node.name].action(target, target_node.name, meta, 0, power_charged)

        stack:set_wear(((current_wear - wear_repaired) / max_wear) * 65535)
        return stack
    end,

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
