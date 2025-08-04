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
    local BUTTONS_PER_ROW = 7

    local fs_buttons = {}
    -- TODO find a way to highlight the button matching the selected liquid
    local n = #liquid_list
    for i,liquid in ipairs(liquid_list) do
        local iz = i - 1
        local padding = (iz >= n - n % BUTTONS_PER_ROW) and
            (BUTTONS_PER_ROW - n % BUTTONS_PER_ROW) / 2 or 0
        local escaped_liquid = core.formspec_escape(liquid)
        fs_buttons[#fs_buttons + 1] =
            ("item_image_button[%f,%f;0.8,0.8;%s;%s;]"):format(
                0.2 + (iz % BUTTONS_PER_ROW) + padding,
                math.floor(iz / BUTTONS_PER_ROW),
                escaped_liquid,
                "creative_pump_fs_" .. escaped_liquid:gsub(":", "__")
            )
    end

    local liquid_def = core.registered_nodes[selected_liquid]

    -- hardcoded values partying hard
    local pipe_x = 1.568
    local pipe_y = 6.178
    local pipe_w = 5.064
    local pipe_h = 1.247
    local pipe_window_x = 3.3253
    local pipe_window_y = 6.4240
    local pipe_window_w = 1.5493
    local pipe_window_h = 0.7558

    local tile_px = 16 -- is there a way to detect texture size dynamically?
    local anim_frames = 8
    local anim_ms = 120 -- milliseconds per frame

    -- construct an image for the fluid visible through the pipe window
    local fluid_fs_part
    local tile = liquid_def.tiles[1] or ""
    if "table" == type(tile) then tile = tile.name or "" end
    tile = sbz_api.escape_texture_modifier(tile)

    if is_open ~= 0 then
        local ppf = tile_px / anim_frames -- pixels per frame
        local frame_chunks = {
            ("[combine:%dx%d:0,0=%s:%d,0=%s"):format(
                tile_px * 2, tile_px * anim_frames,
                tile,
                tile_px, tile
            )
        }
        for i = 1, anim_frames - 1 do
            frame_chunks[i + 1] = ("%d,%d=%s:%d,%d=%s:%d,%d=%s"):format(
                ppf * i          , tile_px * i, tile,
                ppf * i - tile_px, tile_px * i, tile,
                ppf * i + tile_px, tile_px * i, tile
            )
        end

        fluid_fs_part = ("animated_image[%f,%f;%f,%f;;%s;%d;%d]"):format(
            pipe_window_x, pipe_window_y, pipe_window_w, pipe_window_h,
            core.formspec_escape(table.concat(frame_chunks, ":")),
            anim_frames, anim_ms
        )
    else
        -- if turned off, render immobile fluid
        fluid_fs_part = ("image[%f,%f;%f,%f;%s;]"):format(
            pipe_window_x, pipe_window_y, pipe_window_w, pipe_window_h,
            core.formspec_escape(
                ("[combine:%dx%d:0,0=%s:%d,0=%s"):format(
                    tile_px * 2, tile_px, tile, tile_px, tile
                )
            )
        )
    end

    return ([[
    formspec_version[7]
    size[8.2,9]
    label[0.2,0.5;Liquid to output: %s]
    scroll_container[0.2,1;7.8,3;liquid_list_scrollbar;vertical;;0]
    %s
    scroll_container_end[]
    scrollbar[7.5,1;0.5,3;vertical;liquid_list_scrollbar;]
    label[0.2,4.5;Flow in nodes/s (1–%d):]
    field[0.2,5;3.9,0.8;flow;;%d]
    button[4.1,5;3.9,0.8;set_flow_button;Set]
    %s
    image[%f,%f;%f,%f;%s;]
    button[0.2,7.8;7.8,1;toggle;%s]
    ]]):format(
        core.formspec_escape(
            sbz_api.human_readable_liquid(liquid_def, selected_liquid)
        ),
        table.concat(fs_buttons),
        liquid_def.stack_max,
        flow,
        fluid_fs_part,
        pipe_x, pipe_y, pipe_w, pipe_h, "creative_pump_pipe.png",
        is_open ~= 0 and "Turn off" or "Turn on"
    )
end
