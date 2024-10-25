local function explodebits(input, count)
    local output = {}
    count = count or 8
    for i = 0, count - 1 do
        output[i] = input % (2 ^ (i + 1)) >= 2 ^ i
    end
    return output
end

local function implodebits(input, count)
    local output = 0
    count = count or 8
    for i = 0, count - 1 do
        output = output + (input[i] and 2 ^ i or 0)
    end
    return output
end

local packtable = {}
local unpacktable = {}
for i = 0, 25 do
    packtable[i] = string.char(i + 65)
    packtable[i + 26] = string.char(i + 97)
    unpacktable[string.char(i + 65)] = i
    unpacktable[string.char(i + 97)] = i + 26
end
for i = 0, 9 do
    packtable[i + 52] = tostring(i)
    unpacktable[tostring(i)] = i + 52
end
packtable[62] = "+"
packtable[63] = "/"
unpacktable["+"] = 62
unpacktable["/"] = 63

local function packpixel(pixel)
    pixel = tonumber(pixel, 16)
    if not pixel then
        return "AAAA"
    end

    local bits = explodebits(pixel, 24)
    local block1 = {}
    local block2 = {}
    local block3 = {}
    local block4 = {}
    for i = 0, 5 do
        block1[i] = bits[i]
        block2[i] = bits[i + 6]
        block3[i] = bits[i + 12]
        block4[i] = bits[i + 18]
    end
    local char1 = packtable[implodebits(block1, 6)] or "A"
    local char2 = packtable[implodebits(block2, 6)] or "A"
    local char3 = packtable[implodebits(block3, 6)] or "A"
    local char4 = packtable[implodebits(block4, 6)] or "A"
    return char1 .. char2 .. char3 .. char4
end

local function unpackpixel(pack)
    local block1 = unpacktable[pack:sub(1, 1)] or 0
    local block2 = unpacktable[pack:sub(2, 2)] or 0
    local block3 = unpacktable[pack:sub(3, 3)] or 0
    local block4 = unpacktable[pack:sub(4, 4)] or 0
    local out = block1 + (2 ^ 6 * block2) + (2 ^ 12 * block3) + (2 ^ 18 * block4)
    return string.format("%06X", out)
end

local function rgbtohsv(r, g, b)
    r = r / 255
    g = g / 255
    b = b / 255
    local max = math.max(r, g, b)
    local min = math.min(r, g, b)
    local delta = max - min
    local hue = 0
    if delta > 0 then
        if max == r then
            hue = (g - b) / delta
            hue = (hue % 6) * 60
        elseif max == g then
            hue = (b - r) / delta
            hue = 60 * (hue + 2)
        elseif max == b then
            hue = (r - g) / delta
            hue = 60 * (hue + 4)
        end
        hue = hue / 360
    end
    local sat = 0
    if max > 0 then
        sat = delta / max
    end
    return math.floor(hue * 255), math.floor(sat * 255), math.floor(max * 255)
end

local function hsvtorgb(h, s, v)
    h = h / 255 * 360
    s = s / 255
    v = v / 255
    local c = s * v
    local x = (h / 60) % 2
    x = 1 - math.abs(x - 1)
    x = x * c
    local m = v - c
    local r = 0
    local g = 0
    local b = 0
    if h < 60 then
        r = c
        g = x
    elseif h < 120 then
        r = x
        g = c
    elseif h < 180 then
        g = c
        b = x
    elseif h < 240 then
        g = x
        b = c
    elseif h < 300 then
        r = x
        b = c
    else
        r = c
        b = x
    end
    r = r + m
    g = g + m
    b = b + m
    return math.floor(r * 255), math.floor(g * 255), math.floor(b * 255)
end

local function bitwiseblend(srcr, dstr, srcg, dstg, srcb, dstb, mode)
    local srbits = explodebits(srcr)
    local sgbits = explodebits(srcg)
    local sbbits = explodebits(srcb)
    local drbits = explodebits(dstr)
    local dgbits = explodebits(dstg)
    local dbbits = explodebits(dstb)
    for i = 0, 7 do
        if mode == "and" then
            drbits[i] = srbits[i] and drbits[i]
            dgbits[i] = sgbits[i] and dgbits[i]
            dbbits[i] = sbbits[i] and dbbits[i]
        elseif mode == "or" then
            drbits[i] = srbits[i] or drbits[i]
            dgbits[i] = sgbits[i] or dgbits[i]
            dbbits[i] = sbbits[i] or dbbits[i]
        elseif mode == "xor" then
            drbits[i] = srbits[i] ~= drbits[i]
            dgbits[i] = sgbits[i] ~= dgbits[i]
            dbbits[i] = sbbits[i] ~= dbbits[i]
        elseif mode == "xnor" then
            drbits[i] = srbits[i] == drbits[i]
            dgbits[i] = sgbits[i] == dgbits[i]
            dbbits[i] = sbbits[i] == dbbits[i]
        elseif mode == "not" then
            drbits[i] = not srbits[i]
            dgbits[i] = not sgbits[i]
            dbbits[i] = not sbbits[i]
        elseif mode == "nand" then
            drbits[i] = not (srbits[i] and drbits[i])
            dgbits[i] = not (sgbits[i] and dgbits[i])
            dbbits[i] = not (sbbits[i] and dbbits[i])
        elseif mode == "nor" then
            drbits[i] = not (srbits[i] or drbits[i])
            dgbits[i] = not (sgbits[i] or dgbits[i])
            dbbits[i] = not (sbbits[i] or dbbits[i])
        end
    end
    return string.format("%02X%02X%02X",
        implodebits(drbits), implodebits(dgbits), implodebits(dbbits))
end

local function blend(src, dst, mode, transparent)
    local srcr = tonumber(string.sub(src, 1, 2), 16)
    local srcg = tonumber(string.sub(src, 3, 4), 16)
    local srcb = tonumber(string.sub(src, 5, 6), 16)
    local dstr = tonumber(string.sub(dst, 1, 2), 16)
    local dstg = tonumber(string.sub(dst, 3, 4), 16)
    local dstb = tonumber(string.sub(dst, 5, 6), 16)
    local op = "normal"
    if type(mode) == "string" then
        op = string.lower(mode)
    end
    if op == "normal" then
        return src
    elseif op == "nop" then
        return dst
    elseif op == "overlay" then
        return string.upper(src) == string.upper(transparent) and dst or src
    elseif op == "add" then
        local r = math.min(255, srcr + dstr)
        local g = math.min(255, srcg + dstg)
        local b = math.min(255, srcb + dstb)
        return string.format("%02X%02X%02X", r, g, b)
    elseif op == "sub" then
        local r = math.max(0, dstr - srcr)
        local g = math.max(0, dstg - srcg)
        local b = math.max(0, dstb - srcb)
        return string.format("%02X%02X%02X", r, g, b)
    elseif op == "isub" then
        local r = math.max(0, srcr - dstr)
        local g = math.max(0, srcg - dstg)
        local b = math.max(0, srcb - dstb)
        return string.format("%02X%02X%02X", r, g, b)
    elseif op == "average" then
        local r = math.min(255, (srcr + dstr) / 2)
        local g = math.min(255, (srcg + dstg) / 2)
        local b = math.min(255, (srcb + dstb) / 2)
        return string.format("%02X%02X%02X", r, g, b)
    elseif op == "and"
        or op == "or"
        or op == "xor"
        or op == "xnor"
        or op == "not"
        or op == "nand"
        or op == "nor"
    then
        return bitwiseblend(srcr, dstr, srcg, dstg, srcb, dstb, op)
    elseif op == "tohsv"
        or op == "rgbtohsv"
    then
        return string.format("%02X%02X%02X", rgbtohsv(srcr, srcg, srcb))
    elseif op == "torgb"
        or op == "hsvtorgb"
    then
        return string.format("%02X%02X%02X", hsvtorgb(srcr, srcg, srcb))
    end

    return src
end

return explodebits, implodebits, packpixel, unpackpixel, rgbtohsv, hsvtorgb, bitwiseblend, blend
