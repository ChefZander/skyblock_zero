function sbz_power.round_power(n)
    return math.round(n * 100) / 100
end

local prefixes = {
    ["k"] = 10 ^ 3,
    ["M"] = 10 ^ 6,
    ["G"] = 10 ^ 9,
    ["T"] = 10 ^ 12,

    -- alright... now no matter how much you stack your power sources, with unmodified skyblock zero, no one should be able to reach these
    ["P"] = 10 ^ 15,
    ["E"] = 10 ^ 18,
    ["Z"] = 10 ^ 21,
    ["Y"] = 10 ^ 24,
    -- ok enough thats too big
}

local function get_prefix_and_divider(n)
    local prefix = ""
    local divider = 1
    for k, v in pairs(prefixes) do
        if v > divider then
            if (n / v) >= 1 then
                divider = v
                prefix = k
            end
        else
            break
        end
    end
    return prefix, divider
end

function sbz_api.format_power(n, n2)
    if n2 then
        return sbz_api.format_power(n) .. " / " .. sbz_api.format_power(n2)
    end
    local prefix, divider = get_prefix_and_divider(n)
    local prefix_to_use = prefix -- use whichever is larger
    local divider_to_use = divider
    --[[    if n2 then
        local prefix2, divider2 = get_prefix_and_divider(n2)
        if divider2 > divider then
            prefix_to_use = prefix2
            divider_to_use = divider2
        end
    end
    ]]
    prefix_to_use = prefix_to_use .. "Cj"

    return (sbz_power.round_power(n / divider_to_use) .. " " .. prefix_to_use) --..
    --        (n2 and (" / " .. sbz_power.round_power(n2 / divider_to_use) .. " " .. prefix_to_use) or "")
end

function sbz_api.human_readable_liquid(def, name)
    -- trim extra return values
    local value = string.gsub(def.short_description or def.description or name,
        " Source", "")
    return value
end

function sbz_api.escape_texture_modifier(modifier)
    -- trim extra return values
    local value = string.gsub(modifier, ".",
        {["\\"] = "\\\\", ["^"] = "\\^", [":"] = "\\:"})
    return value
end

---@param consumed { n:number, text: string }
---@param max {n:number, text:string }
---@return string
local function bar(consumed, max, x, y, w, h, title, tooltip_text)
    local offx, offy = 0.5, 0.5
    local title_off, text_off = 0.5, 0.3

    h = h - offy

    local small_x,
    small_y,
    small_w,
    small_h = offx, title_off + offy, 1, h - offy * 2

    local offd = 0.2

    local full_height = (consumed.n / max.n) * small_h

    return ([[
    container[%s,%s]
    tooltip[0,0;%s,%s;%s]
    box[0,0;%s,%s;#001100]
    box[%s,%s;%s,%s;#00FF00FF]

    box[%s,%s;%s,%s;#001100]
    box[%s,%s;%s,%s;#00FF00]


    label[0.2,0.4;%s]
    label[%s,%s;%s]
    label[%s,%s;%s]

    container_end[]
    ]]):format(
        x, y,
        w, h + title_off, minetest.formspec_escape(tooltip_text),
        w, h + title_off,                                                       -- first box
        small_x - offd, small_y - offd, small_w + offd * 2, small_h + offd * 2, -- the deco to the second box
        small_x, small_y, small_w, small_h,                                     -- second box, it's the background box
        small_x, (small_y + small_h) - full_height, small_w, full_height + 0.1, -- the filled in box
        title,
        small_x + small_w + text_off, small_y, max.text,
        small_x + small_w + text_off,
        (small_y + small_h) - math.min(full_height, small_h - 0.5), consumed.text
    )
end


---@generic formspec: string
---@param consumed number
---@param max number
---@param x number
---@param y number
---@param postfix string
---@param title string
---@return formspec
function sbz_api.bar(consumed, max, x, y, postfix, title, tooltip_text)
    return bar({ n = consumed, text = consumed .. " " .. postfix }, { n = max, text = max .. " " .. postfix }, x, y, 5, 5,
        title, tooltip_text)
end

function sbz_api.battery_fs(consumed, max)
    return "formspec_version[7]size[5,5]" ..
        bar(
            { n = consumed, text = sbz_api.format_power(consumed) },
            { n = max, text = sbz_api.format_power(max) },
            0, 0, 5, 5, "Storage", ""
        )
end

function sbz_api.liquid_storage_fs(has, max)
    return "formspec_version[7]size[5,5]" ..
        bar(
            { n = has, text = has .. " source blocks" },
            { n = max, text = max .. " source blocks" },
            0, 0, 5, 5, "Liquid Storage", ""
        )
end

function sbz_api.creative_pump_fs(liquid_list, selected_liquid, flow, is_open)
    -- TODO scrollbar or pagination when the number of liquids is too high
    local fs_buttons = {}

    local n = #liquid_list
    for i,liquid in ipairs(liquid_list) do
        local iz = i - 1
        local padding = (iz >= n - n % 8) and (8 - n % 8) / 2 or 0
        local escaped_liquid = core.formspec_escape(liquid)
        fs_buttons[#fs_buttons + 1] =
            ("item_image_button[%f,%f;0.8,0.8;%s;%s;]"):format(
                0.2 + (iz % 8) + padding,
                1.0 + math.floor(iz / 8),
                escaped_liquid,
                "creative_pump_fs_" .. escaped_liquid:gsub(":", "__")
            )
    end

    local liquid_def = core.registered_nodes[selected_liquid]

    local container_y, tap_x, tap_y, tap_w, tap_h, anim_x, anim_y, anim_size
    -- hardcoded values partying hard
    if n < 8 then
        container_y = 2
        tap_x = 2.7018
        tap_y = 2.3806
        tap_w = 1.7382
        tap_h = 1.2659
        anim_x    = 3.4009
        anim_y    = 3.8166
        anim_size = 1.3982
    else
        container_y = 3
        tap_x = 3.1553
        tap_y = 2.3618
        tap_w = 1.1714
        tap_h = 0.8691
        anim_x    = 3.6276
        anim_y    = 3.3065
        anim_size = 0.9447
    end

    local anim_px = 74 -- idk if there's a way to detect texture size dynamically
    local anim_frames = 8

    -- construct animated image for the fluid flowing
    local animated_image = ""
    if is_open ~= 0 then
        local tile = liquid_def.tiles[1] or ""
        if "table" == type(tile) then tile = tile.name or "" end
        tile = sbz_api.escape_texture_modifier(tile)

        local frame_chunks = {
            ("[combine:%dx%d"):format(anim_px, anim_px * anim_frames)
        }
        for i = 0, anim_frames - 1 do
            -- sadly, i need to upscale before blitting,
            -- otherwise there are visible inaccuracies
            table.insert(frame_chunks, ("0,%d=%s\\^[resize\\:%dx%d")
                :format(anim_px * i, tile, anim_px, anim_px))
        end
        local final_texture = core.formspec_escape(
            table.concat(frame_chunks, ":") .. "^[mask:creative_pump_mask.png"
        )

        animated_image = ("animated_image[%f,%f;%f,%f;;%s;%d;400]"):format(
            anim_x, anim_y, anim_size, anim_size,
            final_texture, anim_frames
        )
    end

    return ([[
    formspec_version[7]
    size[8.2,9]
    label[0.2,0.5;Liquid to output: %s]
    %s
    container[0,%d]
    label[0.2,0.5;Flow in nodes/s (1–%d):]
    field[0.2,1;3.9,0.8;flow;;%d]
    button[4.1,1;3.9,0.8;set_flow_button;Set]
    image[%f,%f;%f,%f;creative_pump_tap.png^[screen:#5b6ee1]
    %s
    container_end[]
    button[0.2,7.8;7.8,1;toggle;%s]
    ]]):format(
        core.formspec_escape(
            sbz_api.human_readable_liquid(liquid_def, selected_liquid)),
        table.concat(fs_buttons),
        container_y,
        liquid_def.stack_max,
        flow,
        tap_x, tap_y, tap_w, tap_h,
        animated_image,
        is_open ~= 0 and "Turn off" or "Turn on"
    )
end
