minetest.register_craftitem("sbz_resources:strange_dust", {
    description = "Strange Dust",
    inventory_image = "strange_dust.png",
})

minetest.register_node("sbz_resources:strange_blob", {
    description = "Strange Blob",
    info_extra = "It sure is strange looking... never before seen green color...\n wait did it just- oh no....",
    tiles = { "strange_blob.png" },
    groups = { matter = 1, antimatter = 1, strange = 1, explody = 100 },
    sounds = sbz_api.sounds.strange(),
    light_source = 14,
})

minetest.register_craft {
    output = "sbz_resources:strange_blob",
    recipe = {
        { "sbz_resources:strange_dust", "sbz_resources:strange_dust", "sbz_resources:strange_dust", },
        { "sbz_resources:strange_dust", "sbz_resources:strange_dust", "sbz_resources:strange_dust", },
        { "sbz_resources:strange_dust", "sbz_resources:strange_dust", "sbz_resources:strange_dust", },
    }
}

minetest.register_craft {
    output = "sbz_resources:strange_dust 9",
    type = "shapeless",
    recipe = { "sbz_resources:strange_blob" }
}

-- its been a while since i got to use theese
-- - frog
minetest.register_abm({
    label = "Strange blob infecting",
    nodenames = { "group:strange" },
    neighbors = { "group:antimatter", "group:matter" },
    interval = 1,
    chance = 20,
    catch_up = false,
    action = function(pos, node)
        local to_spread = sbz_api.filter_node_neighbors(pos, 1, function(filtering_pos)
            local filtering_node = minetest.get_node(filtering_pos)
            local name = filtering_node.name
            if minetest.get_item_group(name, "strange") ~= 0 then return end
            if minetest.get_item_group(name, "sbz_machine") ~= 0 then return end
            if minetest.get_item_group(name, "matter") == 0 and
                minetest.get_item_group(name, "antimatter") == 0 then
                return
            end
            if minetest.get_item_group(name, "no_spread") ~= 0 then return end
            if minetest.get_item_group(name, "charged") ~= 0 then return end
            if minetest.is_protected(filtering_pos, ".strange_blob_spread") then return end
            return filtering_pos
        end)

        if #to_spread == 0 then return end
        local index = math.random(1, #to_spread)
        local v = to_spread[index]
        local old_node = minetest.get_node(v)
        local old_meta = minetest.get_meta(v)
        local meta = minetest.get_meta(v)
        if next(old_meta:to_table().inventory) == nil then -- you can't serialize userdata
            core.swap_node(v, { name = "sbz_resources:strange_blob" })
            meta:set_string("old_meta", minetest.serialize(old_meta:to_table()))
            meta:set_string("old_node", minetest.serialize(old_node))
        end
    end
})


local strange_cleaner_radius = 5
local power_per_1_use = 10
local max_wear = power_per_1_use * 200


minetest.register_tool("sbz_resources:strange_cleaner", {
    description = "Strange Blob Cleaner",
    info_extra = {
        "Restores what was.... done.... by strange blobs.",
        "\"Place\" it into a battery to charge.",
    },
    inventory_image = "strange_cleaner.png",
    groups = { disable_repair = 1, power_tool = 1 },
    on_place = sbz_api.on_place_recharge((max_wear / 65535) * power_per_1_use),
    powertool_charge = sbz_api.powertool_charge((max_wear / 65535) * power_per_1_use),
    wear_represents = "power",
    charge_per_use = power_per_1_use,
    charge_in_wielders = false,
    on_use = function(stack, user, pointed)
        -- boilerplate
        if pointed.type ~= "node" then return end
        local target = pointed.under
        if core.is_protected(target, user:get_player_name()) then
            return core.record_protection_violation(target, user:get_player_name())
        end
        -- ok great, i guess now... we should like... try to convert nodes i guess

        -- take away wear


        local deferred = {}

        for x = -strange_cleaner_radius, strange_cleaner_radius do
            for y = -strange_cleaner_radius, strange_cleaner_radius do
                for z = -strange_cleaner_radius, strange_cleaner_radius do
                    local pos = vector.add(target, vector.new(x, y, z))
                    local node = minetest.get_node(pos)
                    local name = node.name
                    if minetest.get_item_group(name, "strange") ~= 0 then
                        local meta = minetest.get_meta(pos)
                        local old_node = minetest.deserialize(meta:get_string("old_node"))
                        local old_meta = minetest.deserialize(meta:get_string("old_meta"))
                        if old_node == nil then
                            old_node = { name = "air" }
                        end
                        deferred[#deferred + 1] = { pos, old_node }
                        meta = minetest.get_meta(pos)
                        if old_meta ~= nil then
                            table.insert(deferred[#deferred], meta)
                            table.insert(deferred[#deferred], old_meta)
                        end
                    end
                end
            end
        end

        local wear = stack:get_wear()
        local new_wear = wear + (power_per_1_use * #deferred)
        if new_wear >= 65535 then
            return
        end
        stack:set_wear(new_wear)

        for k, v in pairs(deferred) do
            minetest.swap_node(v[1], v[2])
            if v[3] then
                v[3]:from_table(v[4])
            end
        end
        return stack
    end
})

minetest.register_craft {
    output = "sbz_resources:strange_cleaner",
    recipe = {
        { "sbz_power:simple_charged_field", "sbz_power:simple_charged_field",  "sbz_power:simple_charged_field" },
        { "",                               "sbz_resources:emittrium_circuit", "" },
        { "",                               "sbz_resources:matter_blob",       "" }
    }
}

minetest.register_node("sbz_resources:stable_strange_blob", unifieddyes.def {
    description = "Stabilized Strange Blob",
    tiles = { "stable_strange_blob.png" },
    paramtype2 = "color",
    paramtype = "light",
    groups = { matter = 1, antimatter = 1, strange = 0, charged = 1, explody = 5 },
    light_source = 14,
    info_extra = "Now i can enjoy the never-before seen green color with less of the... strange-ness..."
})

minetest.register_craft {
    output = "sbz_resources:stable_strange_blob",
    type = "shapeless",
    recipe = {
        "sbz_resources:charged_particle", "sbz_resources:strange_blob"
    }
}
