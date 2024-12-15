-- each meteorite should require something like 1 000 matter blobs

local meteorite_recipes = {
    {
        type = "matter_blob",
        requires = {
            -- my reasoning
            -- iron and nickel are very dense
            -- 1 chemical, would be, in a very ideal scenario: 3 matter blobs
            "sbz_chem:iron_ingot 50",        -- 150 matter blobs
            "sbz_chem:nickel_ingot 50",      -- 150 matter blobs
            "sbz_resources:matter_blob 792", -- 8 stacks
            -- around 1000 matter blobs
        },
    },
    {
        type = "emitter",
        requires = {
            -- now... my reasoning
            -- i decided that emittrium should be a lot denser than matter blobs
            -- so like, 1 emittrium = 3 matter blobs
            -- emitter meteorites are by far THE FASTEST to manifacture
            "sbz_resources:raw_emittrium 297", -- 891 matter blobs
            "sbz_resources:matter_blob 109"    -- the rest, to be exactly 1000
        }
    },
    {
        type = "antimatter_blob",
        requires = {
            "sbz_resources:antimatter_blob 1000", -- 1:1 with matter blobs        }
        }
    },
}

local recipes = {}

for k, v in pairs(meteorite_recipes) do
    recipes[v.type] = v
end

local max_items_to_throw_per_second = 30

local function get_meteorite_maker_formspec(pos, meta, counts)
    local discard_button = ""
    local choose_type = ""
    if meta:get_string("type") ~= "" then
        discard_button = "button[0.4,0.4;3.6,1;discard;Discard]"
    else
        choose_type = choose_type .. [[
        container[0.2,0.2]
            box[0,0;6,3.4;#111111]
            button[0.2,0.2;3.6,1;type_matter;Matter]
            button[0.2,1.2;3.6,1;type_antimatter;Antimatter]
            button[0.2,2.2;3.6,1;type_emitter;Emitter]
        container_end[]
        ]]
    end

    local counts_display = ""

    -- peak code right here
    if counts and next(counts) ~= nil then
        counts_display = [[
            container[0.4,1.6]
                box[0,0;4,3.4;#111111]
                %s
            container_end[]
        ]]
        local fs = {}

        local y = 0.2
        local counts_arr = {}
        for k, v in pairs(counts) do
            counts_arr[#counts_arr + 1] = k
        end
        table.sort(counts_arr)
        for k, v in pairs(counts_arr) do
            k = v
            v = counts[v]
            if core.registered_items[k] == nil then error(dump(k)) end
            local desc = core.registered_items[k].short_description or core.registered_items[k].description
            local text = string.format("%s: %s/%s", desc, v.current, v.max)
            y = y + 0.5
            fs[#fs + 1] = ("label[0.2,%s;%s]"):format(y, text)
        end
        counts_display = string.format(counts_display, table.concat(fs))
    end

    return ([[
formspec_version[7]
size[10.2,20.2]
container[0.2,0.2]
    %s
    %s
    %s
    list[context;main;0,9.4;8,4]
    list[current_player;main;0,15;8,8]
    listring[]
container_end[]
]]):format(choose_type, discard_button, counts_display)
end

local power_consume = 800
local power_consume_when_holding_meteorite = 80

core.register_entity("sbz_meteorites:emerging_meteorite", {
    initial_properties = {
        visual = "cube",
        visual_size = { x = 0.5, y = 0.5 },
        automatic_rotate = 0.2,
        glow = 14,
        physical = false,
        static_save = false,
    },
    on_activate = function(self, staticdata, dtime)
        self.object:set_rotation(vector.new(math.random() * 2, math.random(), math.random() * 2) * math.pi)
        staticdata = minetest.deserialize(staticdata) -- why does the engine make me do this crap? xd

        self.type = staticdata.type
        self.origin = staticdata.origin

        local texture = self.type .. ".png^meteorite.png"
        self.object:set_properties({ textures = { texture, texture, texture, texture, texture, texture } })
    end,
    on_punch = function(self)
        self.object:remove()
    end
})

local function split_stack_to_correct_items(stack)
    local result = {}
    if stack:get_count() <= stack:get_stack_max() then
        result[#result + 1] = stack
    else
        local count = stack:get_count()
        local max = stack:get_stack_max()
        local stacks_that_have_max = math.floor(count / max)
        local rest = count - (stacks_that_have_max * max)
        result[#result + 1] = stack:take_item(rest)
        for i = 1, stacks_that_have_max do
            result[#result + 1] = stack:take_item(max)
        end
    end
    return result
end

sbz_api.register_stateful_machine("sbz_meteorites:meteorite_maker", {
    tiles = {
        "meteorite_maker_top.png",
        "meteorite_maker_bottom.png",
        "meteorite_maker_off_side.png",
        "meteorite_maker_off_side.png",
        "meteorite_maker_off_side.png",
        "meteorite_maker_off_side.png",
    },
    groups = { matter = 1 },
    light_source = 0,
    description = "Meteorite maker",
    info_extra = "Makes meteorites",

    on_construct = function(pos)
        local meta = minetest.get_meta(pos)
        local inventory = meta:get_inventory()
        inventory:set_size("main", 32)
        meta:set_string("type", "")
        meta:set_string("formspec", get_meteorite_maker_formspec(pos, meta))
        meta:set_string("counts", minetest.serialize {})
    end,
    autostate = true,
    action = function(pos, node, meta, supply, demand, dir)
        local type = meta:get_string("type")
        if type == "" then
            meta:set_string("infotext", "Idle")
            return 0
        end

        -- verify and check for power

        local vn = vector.new
        local positions = {
            vn(0, 2, 0),
            vn(0, 3, 0),
            vn(0, 4, 0),

            vn(0, 2, 1),
            vn(0, 3, 1),
            vn(0, 4, 1),

            vn(0, 2, -1),
            vn(0, 3, -1),
            vn(0, 4, -1),

            vn(1, 2, 0),
            vn(1, 3, 0),
            vn(1, 4, 0),

            vn(-1, 2, 0),
            vn(-1, 3, 0),
            vn(-1, 4, 0),
        }

        for k, v in ipairs(positions) do
            local def = minetest.registered_nodes[minetest.get_node(vector.add(pos, v)).name]
            if not def or not def.buildable_to then
                meta:set_string("infotext", "Can't summon/feed meteorite, it needs some space, come on")
                return 0
            end
        end

        if supply < demand + power_consume then
            meta:set_string("infotext", "Not enough power")
            return power_consume
        end

        -- find the emerging meteorite, if not create it

        local center_pos = vector.add(pos, vector.new(0, 4, 0))

        local entities = minetest.get_objects_inside_radius(center_pos, 1)
        local our_meteorite = nil

        for k, v in pairs(entities) do
            local luaentity = v:get_luaentity()
            if luaentity and luaentity.name == "sbz_meteorites:emerging_meteorite" then
                if
                    luaentity.origin and
                    minetest.hash_node_position(luaentity.origin) == minetest.hash_node_position(pos)
                then
                    our_meteorite = v
                    break
                end
            end
        end

        if our_meteorite == nil then
            our_meteorite = minetest.add_entity(center_pos, "sbz_meteorites:emerging_meteorite", minetest.serialize {
                origin = pos,
                type = meta:get_string("type"),
            })
            if our_meteorite == nil then
                meta:set_string("infotext", "Failed to spawn meteorite")
                return 0
            end
        end

        local counts = minetest.deserialize(meta:get_string("counts"))

        local sum_max = 0
        local sum_current = 0
        for k, v in pairs(counts) do
            sum_current = sum_current + v.current
            sum_max = sum_max + v.max
        end

        -- min: 0.5, max: 2
        -- edit: nah, screw that min = 0.5, i will just make it math.min to 0.1
        local size_to_apply = math.max(0.3, (sum_current / sum_max) * 2)
        our_meteorite:set_properties {
            visual_size = {
                x = size_to_apply, y = size_to_apply, z = size_to_apply
            },
        }

        if size_to_apply == 2 then -- full
            our_meteorite:remove()
            local m = minetest.add_entity(center_pos, "sbz_meteorites:meteorite", meta:get_string("type"))
            m:set_velocity(1.5 * vector.random_direction())

            for k, v in pairs(counts) do
                v.current = 0
            end

            meta:set_string("counts", minetest.serialize(counts))
            meta:set_string("infotext", "Spawned the meteorite")
            return power_consume
        end

        -- and supply to counts
        local inv = meta:get_inventory()
        local mittps = max_items_to_throw_per_second
        local added_any_items = false
        for k, v in pairs(counts) do
            for i = 1, mittps do
                if inv:contains_item("main", k .. " 1") and v.current < v.max then
                    inv:remove_item("main", k .. " 1")
                    v.current = v.current + 1
                    added_any_items = true
                else
                    break
                end
            end
        end

        meta:set_string("counts", minetest.serialize(counts))
        meta:set_string("formspec", get_meteorite_maker_formspec(pos, meta, counts))
        meta:set_string("infotext", "Working")

        minetest.add_particlespawner({
            pos = pos,
            attract = {
                kind = "point",
                origin = vector.subtract(center_pos, vector.new(0, 0.5, 0)),
                strength = 1,
                die_on_contact = true,
            },
            texture = "star.png",
            time = 1,
            exptime = 1,
            amount = 20,
            glow = 14,
            acc = { x = 0, y = 1, z = 0 },
            radius = {
                min = 0.5,
                max = 0.9,
                bias = 1
            }
        })

        return added_any_items and power_consume or power_consume_when_holding_meteorite
    end,
    on_receive_fields = function(pos, formname, fields, sender)
        local meta = minetest.get_meta(pos)
        local inv = meta:get_inventory()
        local type = meta:get_string("type")

        if type == "" then
            if fields.type_matter then
                meta:set_string("type", "matter_blob")
            elseif fields.type_antimatter then
                meta:set_string("type", "antimatter_blob")
            elseif fields.type_emitter then
                meta:set_string("type", "emitter")
            end

            local c = {}
            local recipe = recipes[meta:get_string("type")]

            if recipe ~= nil then
                for k, v in pairs(recipe.requires) do
                    local stack = ItemStack(v)
                    c[stack:get_name()] = {
                        current = 0,
                        max = stack:get_count(),
                    }
                end
                meta:set_string("counts", minetest.serialize(c))
            end
        else
            if fields.discard then
                local center_pos = vector.add(pos, vector.new(0, 4, 0))
                local counts = minetest.deserialize(meta:get_string("counts"))
                for item, v in pairs(counts) do
                    local items = split_stack_to_correct_items(ItemStack(item .. " " .. v.current))
                    for k, v in pairs(items) do
                        minetest.item_drop(v, fakelib.create_player({
                            name = "",
                            direction = {
                                x = 0, y = 1, z = 0
                            }
                        }), center_pos)
                    end
                end
                meta:set_string("type", "")
                meta:set_string("counts", minetest.serialize {})

                -- and remove the meteorite entity


                local entities = minetest.get_objects_inside_radius(center_pos, 1)
                local our_meteorite = nil

                for k, v in pairs(entities) do
                    local luaentity = v:get_luaentity()
                    if luaentity and luaentity.name == "sbz_meteorites:emerging_meteorite" then
                        if
                            luaentity.origin and
                            minetest.hash_node_position(luaentity.origin) == minetest.hash_node_position(pos)
                        then
                            our_meteorite = v
                            break
                        end
                    end
                end
                if our_meteorite then our_meteorite:remove() end
            end
        end

        meta:set_string("formspec",
            get_meteorite_maker_formspec(pos, meta, minetest.deserialize(meta:get_string("counts"))))
    end,
    output_inv = "main",
    input_inv = "main",
}, {
    light_source = 14,
    tiles = {
        "meteorite_maker_top.png",
        "meteorite_maker_bottom.png",
        { name = "meteorite_maker_on_side.png", animation = { type = "vertical_frames", length = 1 } },
        { name = "meteorite_maker_on_side.png", animation = { type = "vertical_frames", length = 1 } },
        { name = "meteorite_maker_on_side.png", animation = { type = "vertical_frames", length = 1 } },
        { name = "meteorite_maker_on_side.png", animation = { type = "vertical_frames", length = 1 } },
    },
})

mesecon.register_mvps_stopper("sbz_meteorites:meteorite_maker_off")
mesecon.register_mvps_stopper("sbz_meteorites:meteorite_maker_on")

core.register_craft {
    output = "sbz_meteorites:meteorite_maker",
    recipe = {
        { "sbz_resources:robotic_arm", "sbz_resources:emittrium_circuit", "sbz_resources:robotic_arm" },
        { "sbz_meteorites:neutronium", "sbz_meteorites:neutronium",       "sbz_meteorites:neutronium" },
        { "pipeworks:autocrafter",     "sbz_resources:storinator",        "pipeworks:autocrafter" }
    }
}
