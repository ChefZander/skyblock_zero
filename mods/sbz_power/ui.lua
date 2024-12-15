function sbz_power.round_power(n)
    return math.round(n * 100) / 100
end

local prefixes = {
    ["k"] = 10 ^ 3,
    ["M"] = 10 ^ 6,
    ["G"] = 10 ^ 9,
    ["T"] = 10 ^ 12,
    -- alright... now no matter how much you stack your power sources, with unmodified skyblock zero, no one should be able to reach these
    ["P (Congratulations i guess you learned how to mod)"] = 10 ^ 15,
    ["E (WTF?)"] = 10 ^ 18,
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
        end
    end
    return prefix, divider
end

function sbz_api.format_power(n, n2)
    local prefix, divider = get_prefix_and_divider(n)
    local prefix_to_use = prefix -- use whichever is larger
    local divider_to_use = divider
    if n2 then
        local prefix2, divider2 = get_prefix_and_divider(n2)
        if divider2 > divider then
            prefix_to_use = prefix2
            divider_to_use = divider2
        end
    end
    prefix_to_use = prefix_to_use .. "Cj"

    return (sbz_power.round_power(n / divider_to_use) .. " " .. prefix_to_use) ..
        (n2 and (" / " .. sbz_power.round_power(n2 / divider_to_use) .. " " .. prefix_to_use) or "")
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
function sbz_power.bar(consumed, max, x, y, postfix, title, tooltip_text)
    return bar({ n = consumed, text = consumed .. " " .. postfix }, { n = max, text = max .. " " .. postfix }, x, y, 5, 5,
        title, tooltip_text)
end

function sbz_power.battery_fs(consumed, max)
    return "formspec_version[7]size[5,5]" ..
        bar(
            { n = consumed, text = sbz_api.format_power(consumed) },
            { n = max, text = sbz_api.format_power(max) },
            0, 0, 5, 5, "Storage", ""
        )
end

function sbz_power.liquid_storage_fs(has, max)
    return "formspec_version[7]size[5,5]" ..
        bar(
            { n = has, text = has .. " source blocks" },
            { n = max, text = max .. " source blocks" },
            0, 0, 5, 5, "Liquid Storage", ""
        )
end
