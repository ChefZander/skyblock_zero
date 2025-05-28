local index_to_dir = {
    [0] = "Up",

    [1] = "Up",
    [2] = "Down",

    [3] = "North",
    [4] = "South",
    [5] = "West",
    [6] = "East"
}
local dir_to_index = table.key_value_swap(table.copy(index_to_dir))

local speed = 1
local dir_to_real_dir = {
    ["Up"] = { x = 0, y = 1, z = 0, speed = speed },
    ["Down"] = { x = 0, y = -1, z = 0, speed = speed },

    ["North"] = { x = 0, y = 0, z = 1, speed = speed },
    ["South"] = { x = 0, y = 0, z = -1, speed = speed },

    ["West"] = { x = 1, y = 0, z = 0, speed = speed },
    ["East"] = { x = -1, y = 0, z = 0, speed = speed },
}

local function update_item_sensor_formspec(meta)
    meta:set_string("formspec", ([[
formspec_version[7]
size[7.9,5]
hypertext[0.4,0.6;2,0.6;;<global valign=middle><b>Can insert</b>]
list[context;can_insert;2.4,0.4;1,1]
list[current_player;main;0.2,3.2;6, 1]

hypertext[3.8,0.6;5,0.6;;<global valign=middle><b>to node in the link A,</b>]
hypertext[0.4,1.6;3,1;;<global valign=middle><b>from the direction: </b>]
dropdown[3.4,1.6;3,1;direction;Up,Down,North,South,West,East;%s;true]
]]):format(meta:get_int("dir")))
end

sbz_api.register_stateful_machine("sbz_power:item_sensor", unifieddyes.def {
    description = "Item Sensor",
    info_extra = "Checks if a machine can be inserted to with an item.\nYou can use it to attempt to optimize your giant instatube set up i guess.",
    tiles = {
        sbz_api.make_sensor_tex_off("item_sensor"),
    },
    paramtype2 = "color4dir",
    can_sensor_link = true,
    groups = { matter = 1, sbz_machine_subticking = 1 },
    action = function() return 0 end,
    on_construct = function(pos)
        local meta = core.get_meta(pos)
        meta:set_int("dir", 1)
        meta:get_inventory():set_size("can_insert", 1)
        update_item_sensor_formspec(meta)
    end,
    after_place_node = function(pos, placer)
        core.get_meta(pos):set_string("owner", placer:get_player_name())
    end,
    on_receive_fields = function(pos, _, fields, sender)
        local dir = fields.direction
        if dir then
            dir = tonumber(dir)
            if not dir then return end
            local dir_string = index_to_dir[dir]
            if not dir_string then return end
            core.get_meta(pos):set_string("dir", dir)
        end
    end,
    on_logic_send = function(pos, msg, from_pos)
        local meta = core.get_meta(pos)
        if type(msg) == "table" then
            local direction = msg.direction
            local item = msg.item

            if direction and type(direction) == "string" then
                if dir_to_real_dir[direction] then
                    meta:set_string("dir", dir_to_index[direction])
                end
            end
            if item and ItemStack(item) then
                item = ItemStack(item)
                meta:get_inventory():set_stack("can_insert", 1, item)
            end
            update_item_sensor_formspec(meta)
        end
    end,
    action_subtick = function(pos, _, meta)
        meta:set_string("infotext", "")
        local links = core.deserialize(meta:get_string("links"))
        if not links then
            meta:set_string("infotext",
                "Needs to be connected with machine linker, make one link with the name \"A\".")
            return 0
        end

        if not links.A or (links.A and not links.A[1]) then
            meta:set_string("infotext", "Needs an \"A\" link.")
            return 0
        end

        local target = links.A[1]
        local node = sbz_api.get_or_load_node(target)
        local def = core.registered_nodes[node.name]
        if not def.tube or (def.tube and not def.tube.can_insert) then
            meta:set_string("infotext", "Node not supported. Try a storinator.")
            return 0
        end

        local index = meta:get_int("dir")
        local dir_string = index_to_dir[index] or "Up"
        local dir = table.copy(dir_to_real_dir[dir_string]) or { x = 0, y = 0, z = 0, speed = 0 }

        local state = def.tube.can_insert(
            target,
            node,
            meta:get_inventory():get_stack("can_insert", 1),
            dir,
            meta:get_string("owner")
        )

        if state then
            sbz_api.turn_on(pos)
        else
            sbz_api.turn_off(pos)
        end
        return 1
    end,
    linking_range = sbz_api.logic_gate_linking_range,
    -- code for these allow_metadata_stuffs taken from item filter, which was taken from pipeworks, modified
    allow_metadata_inventory_put = function(pos, listname, index, stack, player)
        local inv = minetest.get_meta(pos):get_inventory()
        inv:set_stack(listname, index, stack)
        return 0
    end,
    allow_metadata_inventory_take = function(pos, listname, index, stack, player)
        local inv = minetest.get_meta(pos):get_inventory()
        inv:set_stack(listname, index, ItemStack(""))
        return 0
    end,
    -- allow_metadata_inventory_move = function(pos, from_list, from_index, to_list, to_index, count, player)
    -- local inv = minetest.get_meta(pos):get_inventory()
    -- inv:set_stack(from_list, from_index, ItemStack(""))
    -- return 0
    -- end,
}, {
    light_source = 14,
    tiles = {
        sbz_api.make_sensor_tex_on("item_sensor"),
    }
})

core.register_craft {
    output = "sbz_power:item_sensor",
    recipe = {
        { "sbz_resources:sensor_casing_plate", "sbz_resources:storinator",           "sbz_resources:sensor_casing_plate", },
        { "sbz_resources:sensor_casing_plate", "sbz_resources:simple_logic_circuit", "sbz_resources:sensor_casing_plate", },
        { "sbz_resources:sensor_casing_plate", "sbz_resources:sensor_casing_plate",  "sbz_resources:sensor_casing_plate", },
    }
}
