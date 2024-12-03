-- this doesn't use any code from techage

local jetpack_durability_s = 60 * 5           -- jetpack durability, in seconds
local jetpack_velocity = vector.new(0, 15, 0) -- multiplied by dtime
local jetpack_full_charge = 1000
local jetpack_durability_save_during_sneak_flight = 2
local default_number_of_particles = 20
local jetpack_boost = 3

local jetpack_users = {}
local jetpack_charge_per_1_wear = math.floor(65535 / jetpack_full_charge)


local function edit_stack_image(user, stack)
    if stack:get_name() == "sbz_resources:jetpack" then
        if jetpack_users[user] then
            stack:get_meta():set_string("inventory_image", "jetpack_on.png")
        else
            stack:get_meta():set_string("inventory_image", "jetpack_off.png")
        end
    end
end

minetest.register_tool("sbz_resources:jetpack", {
    description = "Jetpack",
    info_extra = "Idea originated from techage",
    inventory_image = "jetpack_off.png",
    stack_max = 1,
    tool_capabilities = {}, -- No specific tool capabilities, as it's not meant for digging
    wear_color = {
        blend = "constant",
        color_stops = {
            [0] = "lime"
        }
    },
    groups = { disable_repair = 1 },
    on_use = function(itemstack, user, pointed_thing)
        -- Check if user is valid
        if not user or user.is_fake_player then
            return itemstack
        end
        local wear = itemstack:get_wear()
        local username = user:get_player_name()
        if wear < 65535 then
            if jetpack_users[username] then
                jetpack_users[username] = nil
            else
                jetpack_users[username] = user:get_wield_index()
            end
        else
            minetest.chat_send_player(user:get_player_name(), "Jetpack ran out of charge")
        end
        edit_stack_image(username, itemstack)
        return itemstack
    end,
    on_place = function(stack, user, pointed)
        if pointed.type ~= "node" then return end
        local target = pointed.under
        if core.is_protected(target, user:get_player_name()) then
            return core.record_protection_violation(target, user:get_player_name())
        end
        local target_node_name = minetest.get_node(target).name
        if minetest.get_item_group(target_node_name, "sbz_battery") == 0 then return end

        local target_meta = minetest.get_meta(target)
        local targets_power = target_meta:get_int("power")

        local wear = stack:get_wear()
        local wear_repaired = math.min(math.floor(targets_power * jetpack_charge_per_1_wear), wear)
        targets_power = targets_power - (wear_repaired / jetpack_charge_per_1_wear)
        local targes_def = minetest.registered_nodes[target_node_name]

        target_meta:set_int("power", targets_power)
        targes_def.action(target, target_node_name, target_meta, 0, wear_repaired * jetpack_charge_per_1_wear)

        stack:set_wear(wear - wear_repaired)
        edit_stack_image(user:get_player_name(), stack)
        return stack
    end
})



local speed = player_monoids.speed
minetest.register_globalstep(function(dtime)
    for player in pairs(jetpack_users) do
        local real_player = minetest.get_player_by_name(player)
        local slot = jetpack_users[player]
        local jetpack_item = real_player:get_inventory():get_stack("main", slot)
        if jetpack_item:get_name() ~= "sbz_resources:jetpack" then
            jetpack_users[player] = nil
        end
        if jetpack_item:get_wear() >= 65535 then
            jetpack_users[player] = nil
        end

        local controls = real_player:get_player_control()

        local num_particles = 0
        if (controls.sneak or controls.aux1) and controls.jump and jetpack_users[player] then
            speed:add_change(real_player, jetpack_boost, "sbz_resources:jetpack_boost")
            real_player:add_velocity((jetpack_velocity / 2) * dtime)
            jetpack_item:set_wear(math.min(65535,
                jetpack_item:get_wear() +
                65535 *
                ((jetpack_durability_s * (1 / jetpack_durability_save_during_sneak_flight)) ^ -1)
                * dtime)) -- this works, do not question it
            num_particles = default_number_of_particles / 5
        elseif controls.jump and jetpack_users[player] then
            speed:add_change(real_player, jetpack_boost, "sbz_resources:jetpack_boost")
            real_player:add_velocity(jetpack_velocity * dtime)
            jetpack_item:set_wear(math.min(65535,
                jetpack_item:get_wear() + ((65535 * (jetpack_durability_s ^ -1))) * dtime)) -- this works, do not question it
            num_particles = default_number_of_particles
        else
            speed:del_change(real_player, "sbz_resources:jetpack_boost")
        end
        edit_stack_image(player, jetpack_item)
        real_player:get_inventory():set_stack("main", slot, jetpack_item)
        if num_particles ~= 0 then
            -- make a effect
            local vel = real_player:get_velocity()
            vel = vector.subtract(vector.zero(), vel)

            minetest.add_particlespawner({
                amount = num_particles,
                time = dtime,
                texture = "star.png",
                texpool = {
                    "star.png^[colorize:red",
                    "star.png^[colorize:blue",
                    "star.png^[colorize:green",
                },
                exptime = { min = 1, max = 2 },
                vel = { min = vector.new(-2, -2, -2), max = vector.new(2, 2, 2) },
                acc = { min = vel, max = vel * 5 },
                radius = { min = 0.1, max = 0.3, bias = 1 },
                glow = 14,
                pos = real_player:get_pos()
            })
            sbz_api.players_with_temporarily_hidden_trails[player] = true
        else
            sbz_api.players_with_temporarily_hidden_trails[player] = nil
        end
    end
    for k, v in ipairs(minetest.get_connected_players()) do
        if not jetpack_users[v:get_player_name()] then
            speed:del_change(v, "sbz_resources:jetpack_boost")
        end
    end
end)


minetest.register_craft {
    output = "sbz_resources:jetpack",
    recipe = {
        { "sbz_resources:emittrium_circuit", "sbz_power:battery",         "sbz_resources:emittrium_circuit" },
        { "sbz_resources:angels_wing",       "sbz_meteorites:neutronium", "sbz_resources:angels_wing" },
        { "sbz_resources:emittrium_circuit", "",                          "sbz_resources:emittrium_circuit" }
    }
}
