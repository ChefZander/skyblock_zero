-- a color util

local color = {}
sbz_api.color = color


-- rgb2hsl and hsl2rgb and rotate_hue have been AI generated
-- and modified
-- cuz there is no way i'm figuring that out on my own

function color.rgb2hsl(rgb)
    local r, g, b = rgb.r, rgb.g, rgb.b
    r, g, b = r / 255, g / 255, b / 255
    local max, min = math.max(r, g, b), math.min(r, g, b)
    local l = (max + min) / 2
    local h, s = 0, 0

    if max ~= min then
        local d = max - min
        s = (l > 0.5) and (d / (2 - max - min)) or (d / (max + min))

        if max == r then
            h = (g - b) / d + (g < b and 6 or 0)
        elseif max == g then
            h = (b - r) / d + 2
        else
            h = (r - g) / d + 4
        end
        h = h * 60
    end
    return { h = h, s = s, l = l }
end

function color.hsl2rgb(hsl)
    local h, s, l = hsl.h, hsl.s, hsl.l
    local function hue_to_rgb(p, q, t)
        if t < 0 then t = t + 1 end
        if t > 1 then t = t - 1 end
        if t < 1 / 6 then return p + (q - p) * 6 * t end
        if t < 1 / 2 then return q end
        if t < 2 / 3 then return p + (q - p) * (2 / 3 - t) * 6 end
        return p
    end

    local q = l < 0.5 and (l * (1 + s)) or (l + s - l * s)
    local p = 2 * l - q

    local r = hue_to_rgb(p, q, h / 360 + 1 / 3)
    local g = hue_to_rgb(p, q, h / 360)
    local b = hue_to_rgb(p, q, h / 360 - 1 / 3)

    return { r = math.floor(r * 255), g = math.floor(g * 255), b = math.floor(b * 255) }
end

function color.rotate_hue(rgb, angle)
    local a = rgb.a
    local hsl = color.rgb2hsl(rgb)
    hsl.h = (hsl.h + angle) % 360
    local result = color.hsl2rgb(hsl)
    result.a = a -- keep rgba if there was
    return result
end
