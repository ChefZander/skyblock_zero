local storinator_upgrades = {}
local function update_node_texture(pos)
    local meta = minetest.get_meta(pos)
    local inv = meta:get_inventory()
    local count = 0


    local invsize = inv:get_size("main")
    for i = 1, inv:get_size("main") do
        if not inv:get_stack("main", i):is_empty() then
            count = count + 1
        end
    end

    local new_texture
    local count_percent = (count / invsize) * 100
    if count_percent < 25 then -- 5%
        new_texture = "storinator"
    elseif count_percent < 50 then
        new_texture = "storinator_full_1"
    elseif count_percent < 75 then
        new_texture = "storinator_full_2"
    else
        new_texture = "storinator_full_3"
    end

    local node = minetest.get_node(pos)

    if storinator_upgrades[node.name] and #storinator_upgrades[node.name] ~= 0 then
        new_texture = new_texture .. "_" .. storinator_upgrades[node.name]
    end

    if minetest.get_item_group(node.name, "public") > 0 then
        new_texture = new_texture .. "_public"
    end

    node.name = "sbz_resources:" .. new_texture


    minetest.swap_node(pos, node)
end



local recipe_tail = "sbz_resources:storinator"
local function slots_lvl(x)
    return (4 + x) * (8 + x)
end
local function register_storinator(added_name, def)
    def.slots = slots_lvl(def.level)
    def.tiles = {
        "storinator_side.png",
        "storinator_side.png",
        "storinator_side.png",
        "storinator_side.png",
        "storinator_side.png",
        "storinator_empty.png"
    }
    if def.brighten_base then
        for i = 1, 6 do
            def.tiles[i] = def.tiles[i] .. "^[colorize:white:20"
        end
    end
    def.overlay_tiles = {
        ("storinator_overlay_side.png^[colorize:%s:255"):format(def.overlay_color),
        ("storinator_overlay_side.png^[colorize:%s:255"):format(def.overlay_color),
        ("storinator_overlay_side.png^[colorize:%s:255"):format(def.overlay_color),
        ("storinator_overlay_side.png^[colorize:%s:255"):format(def.overlay_color),
        ("storinator_overlay_side.png^[colorize:%s:255"):format(def.overlay_color),
        ("storinator_overlay.png^[colorize:%s:255"):format(def.overlay_color),

    }
    for public = 0, 1 do
        for i = 1, 4 do
            local def_copy = table.copy(def)
            for j = 1, i - 1 do -- no, this is not a sorting algorithm lol
                def_copy.tiles[6] = def_copy.tiles[6] .. string.format("^[fill:1x1:%s,%s:#ac3232", 2, (j * 4) - 2)
            end
            local name = "sbz_resources:storinator"
            if i ~= 1 then
                name = name .. "_full_" .. (i - 1)
            end
            if #added_name ~= 0 then
                name = name .. "_" .. added_name
            end

            if public == 1 then
                name = name .. "_public"
            end


            def_copy.groups.storinator = 1
            def_copy.groups.tubedevice = 1
            def_copy.groups.tubedevice_receiver = 1
            def_copy.groups.not_in_creative_inventory = i ~= 1 and 1 or 0
            def_copy.groups.public = public

            def_copy.paramtype2 = "facedir"
            def_copy.on_metadata_inventory_put = update_node_texture
            def_copy.on_metadata_inventory_take = update_node_texture
            def_copy.on_metadata_inventory_move = update_node_texture
            def_copy.info_extra = def_copy.slots .. " Slots"

            local dropname = "sbz_resources:storinator"
            if #added_name ~= 0 then
                dropname = dropname .. "_" .. added_name
            end
            if public == 1 then
                dropname = dropname .. "_public"
            end

            storinator_upgrades[name] = added_name
            def_copy.drop = dropname

            def_copy.after_dig_node = pipeworks.after_dig
            def_copy.after_place_node = pipeworks.after_place
            def_copy.input_inv = "main"
            def_copy.output_inv = "main"
            def_copy.sounds = sbz_api.sounds.machine()

            def_copy.tube = {
                input_inventory = "main",
                insert_object = function(pos, node, stack, direction)
                    local meta = minetest.get_meta(pos)
                    local inv = meta:get_inventory()
                    update_node_texture(pos)
                    return inv:add_item("main", stack)
                end,
                can_insert = function(pos, node, stack, direction)
                    local meta = minetest.get_meta(pos)
                    local inv = meta:get_inventory()
                    stack = stack:peek_item(1)
                    return inv:room_for_item("main", stack)
                end,
                connect_sides = { left = 1, right = 1, front = 1, back = 1, top = 1, bottom = 1 }
            }
            if def.allow_renaming then
                def_copy.on_receive_fields = function(pos, _, fields, sender)
                    if fields.rename then
                        core.get_meta(pos):set_string("infotext", fields.rename)
                    end
                end
            end
            def_copy.on_construct = function(pos)
                local meta = core.get_meta(pos)
                local inv = meta:get_inventory()
                inv:set_size("main", def_copy.slots)


                -- 32 = 0.2 spacing, 2:1 slots
                -- 64 = 0.2/2 spacing, 2:1 slots right?

                meta:set_string("formspec",
                    string.format([[
formspec_version[7]
size[%s,%s]
style_type[list;spacing=%s;size=%s]
list[context;main;0.2,0.2;%s,%s;]
style_type[list;spacing=0.2;size=.8]
list[current_player;main;0.2,%s;8,4;]
listring[]
                    ]] .. (def_copy.renaming_formspec or ""), def_copy.ui_size or 8.2, def_copy.ui_size_y or 9,
                        def_copy.spacing or 0.2, def_copy.size or 0.8,
                        8 + def_copy.level, 4 + def_copy.level,
                        5 + ((def.ui_size_y or 9) - 9)
                    ))
            end
            if public == 1 then
                for kk, vv in ipairs(def_copy.tiles) do
                    def_copy.tiles[kk] = vv .. "^[colorize:cyan:40"
                end
                def_copy.description = "Public " .. def_copy.description
            end
            core.register_node(name, def_copy)
        end
    end

    local dropname = "sbz_resources:storinator"
    if #added_name ~= 0 then
        dropname = dropname .. "_" .. added_name
    end
    dropname = dropname

    minetest.register_craft {
        output = dropname .. "_public",
        type = "shapeless",
        recipe = {
            dropname
        }
    }

    minetest.register_craft {
        output = dropname,
        type = "shapeless",
        recipe = {
            dropname .. "_public"
        }
    }

    if not def.base then
        minetest.register_craft {
            output = dropname,
            recipe = {
                { "",           def.material, "" },
                { def.material, recipe_tail,  def.material },
                { "",           def.material, "" },
            }
        }
        recipe_tail = dropname
    end
end



register_storinator("", {
    description = "Storinator",
    level = 0,
    overlay_color = "#696a6a",
    groups = { matter = 1 },
    base = true,
})

local lvl0 = slots_lvl(0)

register_storinator("bronze", {
    description = "Bronze Storinator",
    level = 1,
    overlay_color = "#df7126",
    spacing = 0.2 / (slots_lvl(1) / lvl0) * 1.25,
    size = 0.8 / (slots_lvl(1) / lvl0) * 1.25,
    groups = { matter = 1 },
    material = "sbz_chem:bronze_ingot",
})

register_storinator("stemfruit", {
    description = "Stemfruit Storinator",
    level = 2,
    overlay_color = "#ac3232",
    spacing = 0.2 / (slots_lvl(2) / lvl0) * 1.5,
    size = 0.8 / (slots_lvl(2) / lvl0) * 1.5,
    groups = { matter = 1 },
    material = "sbz_bio:stemfruit",
})
register_storinator("colorium", {
    description = "Colorium Storinator",
    level = 3,
    overlay_color = "white",
    spacing = 0.2 / (slots_lvl(3) / lvl0) * 1.7,
    size = 0.8 / (slots_lvl(3) / lvl0) * 1.7,
    ui_size = 8.2,
    ui_size_y = 9.5,
    groups = { matter = 1 },
    material = "sbz_bio:stemfruit",
})

register_storinator("warpshroom", {
    description = "Warpshroom Storinator",
    level = 4,
    overlay_color = "#76428a",
    spacing = 0.2 / (slots_lvl(4) / lvl0) * 1.9,
    size = 0.8 / (slots_lvl(4) / lvl0) * 1.9,
    ui_size = 8.2,
    ui_size_y = 9.5,
    groups = { matter = 1 },
    material = "sbz_bio:warpshroom",
})

register_storinator("neutronium", {
    description = "Neutronium Storinator",
    level = 6,
    overlay_color = "#111111",
    brighten_base = true,
    spacing = 0.2 / (slots_lvl(4) / lvl0) * 1.9,
    size = 0.8 / (slots_lvl(4) / lvl0) * 1.9,
    ui_size = 9.2,
    ui_size_y = 11.5,
    allow_renaming = true,
    renaming_formspec = "field[0.2,6.7;5,0.6;rename;Name of storinator;${infotext}]",
    groups = { matter = 1 },
    material = "sbz_meteorites:neutronium",
})


minetest.register_craft({
    output = "sbz_resources:storinator",
    recipe = {
        { "sbz_power:simple_charged_field",  "sbz_resources:matter_plate",   "sbz_resources:retaining_circuit" },
        { "sbz_resources:matter_plate",      "sbz_resources:simple_circuit", "sbz_resources:matter_plate" },
        { "sbz_resources:retaining_circuit", "sbz_resources:matter_plate",   "sbz_resources:retaining_circuit" }
    }
})
