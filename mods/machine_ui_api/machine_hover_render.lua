-- very inspired by mindustry
local max_items = 6
local max_items_in_one_row = 3
local thickness = 0.001
local size = 0.5

---@return string
local function get_tile(tiles, indx)
    local tile = tiles[indx]
    if type(tile) == 'string' then return tile end
    if type(tile) == 'table' then
        if tile.name then return tile.name end
        if tile[1] then return tile[1] end
        if indx ~= 1 then
            return get_tile(tiles, 1)
        else
            return 'blank.png'
        end
    end
    if type(tile) == 'nil' then
        if indx == 1 then return 'blank.png' end
        return get_tile(tiles, 1)
    end
    return tile
end

---@return string
local function get_inventory_image(stack)
    local def = (stack:get_definition() or {})
    if def.inventory_image and def.inventory_image ~= '' then return def.inventory_image end

    if def.tiles then
        return core.inventorycube(get_tile(def.tiles, 1), get_tile(def.tiles, 2), get_tile(def.tiles, 3))
    end

    return 'blank.png'
end

machine_ui_api.render_inventory_hover = function(font, character_size_w, character_size_h, lists)
    local items = {}

    lists = table.copy(lists)
    local listkeys = {}
    for k, _ in pairs(lists) do
        listkeys[#listkeys + 1] = k
    end
    table.sort(listkeys)

    for _, listkey in ipairs(listkeys) do
        for _, item in ipairs(lists[listkey]) do
            if not item:is_empty() then table.insert(items, item) end
        end
    end

    local organised_items = {}
    local row = 0
    for i = 1, #items do
        if (i - 1) % max_items_in_one_row == 0 then row = row + 1 end
        if i > max_items then break end
        organised_items[row] = organised_items[row] or {}
        table.insert(organised_items[row], items[i])
    end

    local image = {}

    for y, row in ipairs(organised_items) do
        for x, item in ipairs(row) do
            local count = item:get_count()
            local item_image = get_inventory_image(item)
            local count_image = machine_ui_api.font.render(font, character_size_w, character_size_h, tostring(count))

            table.insert(image, {
                x = (x - 1) * size,
                y = (y - 1) * size,
                z = -0.01,
                size = { x = size, y = size, z = thickness },
                image = 'blank.png^[invert:rgba^[colorize:#1D2021:255',
            })

            table.insert(image, {
                x = (x - 1) * size,
                y = (y - 1) * size,
                size = { x = size, y = size, z = thickness },
                image = item_image,
            })

            table.insert(image, {
                x = (((x - 1) - 0.3) + (count_image.width >= 3 and ((count_image.width - 2) * 0.2) or 0)) * size,
                y = ((y - 1) - 0.3) * size,
                z = thickness,
                size = {
                    x = (0.5 / 2) * count_image.width * size,
                    y = (1 / 2) * count_image.height * size,
                    z = thickness,
                },
                image = count_image.image,
            })
        end
    end

    return image
end

local default_font = 'FONT_TMP_REMOVE.png'
local default_font_w, default_font_h = 16, 32
function machine_ui_api.inventory_hover(pos)
    local meta = core.get_meta(pos)
    local inv = meta:get_inventory()
    local lists = inv:get_lists()
    local imgs = machine_ui_api.render_inventory_hover(default_font, default_font_w, default_font_h, lists)

    for _, img in ipairs(imgs) do
        local ipos = vector.add(pos, vector.new(img.x, img.y, (img.z or 0) + 0.56))
        core.add_entity(ipos, 'machine_ui_api:machine_hover_visual'):set_properties {
            visual_size = img.size,
            textures = {
                img.image,
                img.image,
                img.image,
                img.image,
                img.image,
                img.image,
            },
        }
    end
end

core.register_entity('machine_ui_api:machine_hover_visual', {
    initial_properties = {
        hp_max = 10,
        light_source = 14,
        visual = 'cube',
        static_save = false,
        physical = false,
        pointable = false,
    },
})

-- //lua render_image_TEST(pos, machine_ui_api.render_inventory_hover('FONT_TMP_REMOVE.png', 16, 32, {{ItemStack('sbz_resources:matter_blob 9'), ItemStack('sbz_resources:antimatter_dust 99'), ItemStack('sbz_resources:matter_dust 999')},{ItemStack('pipeworks:tube_1')}}))
