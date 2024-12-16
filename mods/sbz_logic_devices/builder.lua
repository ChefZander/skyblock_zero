-- like the digibuilder... but better... yea!
-- more overpowered!!


local power_per_action = 40
local queue_max = 50
local range = 20



local function get_index(inv, item)
    if not inv:contains_item("main", item) then return false end
    local list = inv:get_list("main")

    for k, v in ipairs(list) do
        v:set_count(1) -- so that counts match, doesnt actually modify anything in the inventory, kinda wish it would ngl
        v:set_wear(1)  -- so that wear matches
        if item:equals(v) and item:is_known() then
            return k
        end
    end
    return false
end

local function build(pos, owner, def, param2, inv, index)
    if param2 ~= nil then if param2 < 0 or param2 > 255 then param2 = nil end end
    if not def.on_place then return end

    local player = fakelib.create_player({
        name = owner,
        inventory = inv,
        wield_list = "main",
        wield_index = index,
        position = pos,
    })

    local pointed_thing = {
        under = pos,
        above = pos,
        type = "node"
    }
    if def.paramtype2 == "facedir" then
        pointed_thing.under = vector.add(pos, minetest.facedir_to_dir(param2))
    elseif def.paramtype2 == "wallmounted" then
        pointed_thing.under = vector.add(pos, minetest.wallmounted_to_dir(param2))
    end
    local stack = inv:get_stack("main", index)
    local leftover = def.on_place(stack, player, pointed_thing)
    inv:set_stack("main", index, leftover or stack)
    if param2 then -- set param2
        local node = minetest.get_node(pos)
        node.param2 = param2
        minetest.swap_node(pos, node)
    end
end

local function punch(pos, owner, def_target, inv, index, node)
    if not def_target.on_punch then return end
    local player = fakelib.create_player {
        name = owner,
        inventory = inv,
        wield_list = "main",
        wield_index = index,
        position = pos,
    }
    local pointed_thing = {
        under = pos,
        above = pos,
        type = "node"
    }

    def_target.on_punch(pos, node, player, pointed_thing)
end

-- from pipeworks
local function dont_wear_out(stack, old_stack, player, item_def)
    if stack:get_name() == old_stack:get_name() then
        if stack:get_wear() ~= old_stack:get_wear() and stack:get_count() == old_stack:get_count()
            and (item_def.wear_represents == nil or item_def.wear_represents == "mechanical_wear") then
            player:set_wielded_item(old_stack)
        end
    end
end

-- also from pipeworks
local function dig(pos, owner, def_target, def_item, inv, index, node)
    if not def_target.on_dig then return end

    local player = fakelib.create_player {
        name = owner,
        inventory = inv,
        wield_list = "main",
        wield_index = index,
        position = pos,
    }
    local stack = player:get_wielded_item()
    local old_stack = ItemStack(stack)
    local tool = stack:get_tool_capabilities()
    if not minetest.get_dig_params(def_target.groups, tool).diggable then
        local hand = ItemStack():get_tool_capabilities()
        if not minetest.get_dig_params(def_target.groups, hand).diggable then return end
    end
    if def_target.on_dig(pos, node, player) == false then return end

    player:set_wielded_item(stack)
    dont_wear_out(stack, old_stack, player, def_item)
end



local function use(pos, owner, item_def, inv, index)
    if not item_def.on_use then return end
    local player = fakelib.create_player {
        name = owner,
        inventory = inv,
        wield_list = "main",
        wield_index = index,
        position = pos,
    }

    local pointed_thing = {
        under = pos,
        above = pos,
        type = "node"
    }

    stack = player:get_wielded_item()
    local old_stack = ItemStack(stack)
    stack = item_def.on_use(stack, player, pointed_thing) or stack
    player:set_wielded_item(stack)

    dont_wear_out(stack, old_stack, player.def_item)
end

local function see(pos, lc_from_pos, builder_from_pos)
    local result = {}
    local node = sbz_api.get_node_force(pos)
    result.node = node

    local meta = minetest.get_meta(pos):to_table()

    result.fields = meta.fields
    result.inventory = sbz_logic.kill_itemstacks(meta.inventory)

    sbz_logic.send(lc_from_pos, result, builder_from_pos)
end

local function move(pos, pos2)
    if pos2 == nil then return end
    sbz_api.move_node(pos, pos2) -- how simple :D (NO DONT LOOK INSIDE, DONT LOOK AT THE COMPATIBILITY AROUND IT)
end

sbz_api.register_machine("sbz_logic_devices:builder", {
    description = "Lua Builder",
    info_extra = {
        "It lets the lua controller... control it... so that... yea... it builds!!! you can build!!!",
    },
    tiles = {
        "lua_builder.png"
    },
    groups = { matter = 1, ui_logic = 1, sbz_machine_subticking = 1 },
    sounds = sbz_api.sounds.machine(),
    on_construct = function(pos)
        local meta = minetest.get_meta(pos)
        meta:get_inventory():set_size("main", 32)
        meta:set_string("formspec", [[
formspec_version[7]
size[8.2,9]
style_type[list;spacing=.2;size=.8]
list[context;main;0.2,0.2;8,4;]
list[current_player;main;0.2,5;8,4;]
listring[]
]])
    end,
    after_place_node = function(pos, placer)
        minetest.get_meta(pos):set_string("owner", placer:get_player_name())
        pipeworks.after_place(pos)
    end,
    on_punch = function(pos, _, player)
        vizlib.draw_cube(pos, range + 0.5, { player = player })
    end,

    input_inv = "main",
    output_inv = "main",
    action = function() return 0 end,
    action_subtick = function(pos, _, meta, supply, demand)
        local net = supply - demand
        local queued_events = minetest.deserialize(meta:get_string("queued_events")) or {}
        local queue_can_handle = math.min(
            math.min(queue_max, #queued_events),
            math.max(0, math.floor(net / (queue_max * power_per_action)))
        ) -- spagetti math
        local inv = meta:get_inventory()

        local owner = meta:get_string("owner")

        local ndef = minetest.registered_nodes
        local idef = minetest.registered_items

        local function inner_loop(i)
            local e = queued_events[i]
            local ok = libox.type_check(e, {
                type = libox.type("string"),
                pos = libox.type_vector,
                pos2 = function(x) return x == nil or libox.type_vector(x) end,
                item = function(x) return x == nil or libox.type("string")(x) end,
                param2 = function(x) return x == nil and true or libox.type("number")(x) end,
                from_pos = libox.type_vector
            })
            if not ok then return end -- ha see, continue statement, lua has continue statements...!!!!
            e.item = e.item or ""
            local item = ItemStack(e.item)
            -- prepare for comparing
            item:set_count(1)
            item:set_wear(1)
            local index = get_index(inv, item)
            if not index and e.type ~= "see" and e.type ~= "move" then return end
            local abs_pos = vector.add(e.pos, pos)
            local abs_pos2 = nil
            if e.pos2 then
                abs_pos2 = vector.add(e.pos2, pos)
                if not sbz_api.logic.in_square_radius(pos, abs_pos2, range) then return end
                if minetest.is_protected(abs_pos2, owner) then return end
            end
            if not sbz_api.logic.in_square_radius(pos, abs_pos, range) then return end
            if minetest.is_protected(abs_pos, owner) then return end

            if e.type ~= "see" and e.type ~= "move" then
                local node_at_pos = sbz_api.get_node_force(abs_pos)
                if node_at_pos == nil then return end
                local def_node = ndef[node_at_pos.name]
                if def_node == nil then return end

                local def_item = idef[item:get_name()]
                if def_item == nil then return end

                if e.type == "build" then
                    build(abs_pos, owner, def_item, e.param2, inv, index)
                elseif e.type == "dig" then
                    dig(abs_pos, owner, def_node, def_item, inv, index, node_at_pos)
                elseif e.type == "punch" then
                    punch(abs_pos, owner, def_node, inv, index, node_at_pos)
                elseif e.type == "use" then
                    use(abs_pos, owner, def_item, inv, index)
                end
            else
                if e.type == "see" then
                    see(abs_pos, e.from_pos, pos)
                elseif e.type == "move" then
                    move(abs_pos, abs_pos2)
                end
            end
        end
        for i = 1, queue_can_handle do
            inner_loop(i)
        end
        meta:set_string("queued_events", "")
        meta:set_string("infotext",
            string.format("Lua Builder\nHandling: %s events\nConsuming: %s Cj", queue_can_handle,
                queue_can_handle * power_per_action))
        return queue_can_handle * power_per_action
    end,

    on_logic_send = function(pos, msg, from_pos)
        local meta = minetest.get_meta(pos)
        local queued_events = minetest.deserialize(meta:get_string("queued_events")) or {}
        queued_events[#queued_events + 1] = msg
        msg.from_pos = from_pos
        meta:set_string("queued_events", minetest.serialize(queued_events))
    end
})

unified_inventory.register_craft {
    type = "ele_fab",
    output = "sbz_logic_devices:builder",
    items = {
        "pipeworks:puncher 4",
        "pipeworks:deployer 4",
        "pipeworks:nodebreaker 4",
        "sbz_resources:luanium 32"
    },
    width = 2,
    height = 2,
}
