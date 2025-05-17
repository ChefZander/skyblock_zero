-- rgb_to_hsl and hsl_to_rgb and rotate_hue have been AI generated!

function sbz_api.rgb_to_hsl(r, g, b)
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
    return h, s, l
end

function sbz_api.hsl_to_rgb(h, s, l)
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

    return math.floor(r * 255), math.floor(g * 255), math.floor(b * 255)
end

function sbz_api.rotate_hue(rgb_color, angle)
    local r, g, b = rgb_color.r, rgb_color.g, rgb_color.b
    local h, s, l = sbz_api.rgb_to_hsl(r, g, b)
    h = (h + angle) % 360
    local result = { sbz_api.hsl_to_rgb(h, s, l) }

    return { r = result[1], g = result[2], b = result[3] }
end
