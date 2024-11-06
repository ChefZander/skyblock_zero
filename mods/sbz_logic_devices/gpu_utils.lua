local function format_color(c)
    ---@diagnostic disable-next-line: param-type-mismatch
    return string.sub(core.colorspec_to_bytes(c) or core.colorspec_to_bytes("black"), 1, 3)
end


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
    return { r = math.floor(hue * 255), g = math.floor(sat * 255), b = math.floor(max * 255) }
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
    return { r = math.floor(r * 255), g = math.floor(g * 255), b = math.floor(b * 255) }
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
    return {
        r = implodebits(drbits), g = implodebits(dgbits), b = implodebits(dbbits)
    }
end

local function blend(src, dst, mode, transparent)
    local srcr = src:byte(1)
    local srcg = src:byte(2)
    local srcb = src:byte(3)
    local dstr = dst:byte(1)
    local dstg = dst:byte(2)
    local dstb = dst:byte(3)
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
        return format_color({ r = r, g = g, b = b })
    elseif op == "sub" then
        local r = math.max(0, dstr - srcr)
        local g = math.max(0, dstg - srcg)
        local b = math.max(0, dstb - srcb)
        return format_color({ r = r, g = g, b = b })
    elseif op == "isub" then
        local r = math.max(0, srcr - dstr)
        local g = math.max(0, srcg - dstg)
        local b = math.max(0, srcb - dstb)
        return format_color({ r = r, g = g, b = b })
    elseif op == "average" then
        local r = math.min(255, (srcr + dstr) / 2)
        local g = math.min(255, (srcg + dstg) / 2)
        local b = math.min(255, (srcb + dstb) / 2)
        return format_color({ r = r, g = g, b = b })
    elseif op == "and"
        or op == "or"
        or op == "xor"
        or op == "xnor"
        or op == "not"
        or op == "nand"
        or op == "nor"
    then
        return format_color(bitwiseblend(srcr, dstr, srcg, dstg, srcb, dstb, op))
    elseif op == "tohsv"
        or op == "rgbtohsv"
    then
        return format_color(rgbtohsv(srcr, srcg, srcb))
    elseif op == "torgb"
        or op == "hsvtorgb"
    then
        return format_color(hsvtorgb(srcr, srcg, srcb))
    end

    return src
end

return blend
