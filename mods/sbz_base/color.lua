-- a color util
-- Hopefully you won't be using this anywhere where performance matters (i think outright not using tables is the best here)
-- i mean converting a large amount of colors sounds silly anyway

local color = {}
sbz_api.color = color

---@class sbz.rgb # Unperformant
---@field r integer # 0-255
---@field g integer # 0-255
---@field b integer # 0-255

---@class sbz.hsl # Unperformant
---@field h number # 0-360
---@field s number # 0-1
---@field l number # 0-1

-- math from wikipedia, thanks wikipedia
-- i love wikipedia

---@param rgb sbz.rgb
---@return sbz.hsl hsl
function color.rgb2hsl(rgb)
    local r, g, b = rgb.r / 255, rgb.g / 255, rgb.b / 255
    local V = math.max(r, g, b)
    local Xmin = math.min(r, g, b)

    local C = V - Xmin
    local L = V - (C / 2)

    local H
    if C == 0 then
        H = 0
    elseif V == r then
        H = 60 * (((g - b) / C) % 6)
    elseif V == g then
        H = 60 * (((b - r) / C) + 2)
    elseif V == b then
        H = 60 * (((r - g) / C) + 4)
    end

    local S = 0
    if L ~= 0 and L ~= 1 then S = (V - L) / math.min(L, 1 - L) end

    return { h = H, s = S, l = L }
end

local abs = math.abs

---@param hsl sbz.hsl
---@return sbz.rgb rgb
function color.hsl2rgb(hsl)
    local h, s, l = hsl.h, hsl.s, hsl.l
    local C = (1 - abs(2 * l - 1)) * s
    local hp = h / 60
    local X = C * (1 - abs((hp % 2) - 1))

    local r1, g1, b1
    if hp >= 0 and hp < 1 then
        r1, g1, b1 = C, X, 0
    elseif hp >= 1 and hp < 2 then
        r1, g1, b1 = X, C, 0
    elseif hp >= 2 and hp < 3 then
        r1, g1, b1 = 0, C, X
    elseif hp >= 3 and hp < 4 then
        r1, g1, b1 = 0, X, C
    elseif hp >= 4 and hp < 5 then
        r1, g1, b1 = X, 0, C
    elseif hp >= 5 and hp < 6 then
        r1, g1, b1 = C, 0, X
    end

    local m = l - (C / 2)
    local r, g, b = r1 + m, g1 + m, b1 + m
    return { r = math.round(r * 255), g = math.round(g * 255), b = math.round(b * 255) }
end

function color.rotate_hue(rgb, angle)
    local hsl = color.rgb2hsl(rgb)
    hsl.h = angle
    local result = color.hsl2rgb(hsl)
    result.a = rgb.a
    return result
end
