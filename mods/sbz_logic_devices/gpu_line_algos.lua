-- https://en.wikipedia.org/wiki/Xiaolin_Wu%27s_line_algorithm

local floor, round, abs = math.floor, math.round, math.abs

local function fpart(x)
    return x - floor(x)
end

local function rfpart(x)
    return 1 - fpart(x)
end

local function brightness(r, g, b, d)
    local function t(x)
        return x * d
    end
    return t(r), t(g), t(b)
end

local function xiaolin_wu(buf_t, x1, y1, x2, y2, color)
    local buf = buf_t.buffer
    local sizex = buf_t.xsize
    local steep = abs(y2 - y1) > abs(x2 - x1)

    local r, g, b = color:byte(1), color:byte(2), color:byte(3)

    local function plot(x, y, c)
        local r, g, b = brightness(r, g, b, c)
        buf[((y - 1) * sizex) + x] = minetest.colorspec_to_bytes({ r = r, g = g, b = b })
    end

    if steep then
        x1, y1 = y1, x1
        x2, y2 = y2, x2
    end
    if x1 > x2 then
        x1, x2 = x2, x1
        y1, y2 = y2, y1
    end

    local dx = x2 - x1
    local dy = y2 - y1

    local gradient = 0
    if dx == 0 then
        gradient = 1.0
    else
        gradient = dy / dx
    end

    -- handle first endpoint
    local xend = round(x1)
    local yend = y1 + gradient * (xend - x1)
    local xgap = rfpart(x1 + 0.5)
    local xpxl1 = xend -- this will be used in the main loop
    local ypxl1 = floor(yend)

    if steep then
        plot(ypxl1, xpxl1, rfpart(yend) * xgap)
        plot(ypxl1 + 1, xpxl1, fpart(yend) * xgap)
    else
        plot(xpxl1, ypxl1, rfpart(yend) * xgap)
        plot(xpxl1, ypxl1 + 1, fpart(yend) * xgap)
    end
    local intery = yend + gradient -- first y-intersection for the main loop

    -- handle second endpoint
    xend = round(x2)
    yend = y2 + gradient * (xend - x2)
    xgap = fpart(x2 + 0.5)
    local xpxl2 = xend --this will be used in the main loop
    local ypxl2 = floor(yend)
    if steep then
        plot(ypxl2, xpxl2, rfpart(yend) * xgap)
        plot(ypxl2 + 1, xpxl2, fpart(yend) * xgap)
    else
        plot(xpxl2, ypxl2, rfpart(yend) * xgap)
        plot(xpxl2, ypxl2 + 1, fpart(yend) * xgap)
    end

    -- main loop
    if steep then
        for x = xpxl1 + 1, xpxl2 - 1 do
            plot(floor(intery), x, rfpart(intery))
            plot(floor(intery) + 1, x, fpart(intery))
            intery = intery + gradient
        end
    else
        for x = xpxl1 + 1, xpxl2 - 1 do
            plot(x, floor(intery), rfpart(intery))
            plot(x, floor(intery) + 1, fpart(intery))
            intery = intery + gradient
        end
    end
end

--[[
    The function "bresenham" was from https://github.com/kikito/bresenham.lua/blob/master/bresenham.lua
    (HEAVILY MODIFIED)
    Licensed as:
    Copyright (c) 2012 Enrique García Cota

Permission is hereby granted, free of charge, to any person obtaining a
copy of this software and associated documentation files (the
"Software"), to deal in the Software without restriction, including
without limitation the rights to use, copy, modify, merge, publish,
distribute, sublicense, and/or sell copies of the Software, and to
permit persons to whom the Software is furnished to do so, subject to
the following conditions:

The above copyright notice and this permission notice shall be included
in all copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS
OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF
MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT.
IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY
CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT,
TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE
SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
]]

local function bresenham(buf_t, x1, y1, x2, y2, color)
    local sx, sy, dx, dy
    local buf, sizex = buf_t.buffer, buf_t.xsize

    if x1 < x2 then
        sx = 1
        dx = x2 - x1
    else
        sx = -1
        dx = x1 - x2
    end

    if y1 < y2 then
        sy = 1
        dy = y2 - y1
    else
        sy = -1
        dy = y1 - y2
    end

    local err, e2 = dx - dy, nil

    buf[((y1 - 1) * sizex) + x1] = color

    while not (x1 == x2 and y1 == y2) do
        e2 = err + err
        if e2 > -dy then
            err = err - dy
            x1  = x1 + sx
        end
        if e2 < dx then
            err = err + dx
            y1  = y1 + sy
        end
        buf[((y1 - 1) * sizex) + x1] = color
    end

    return true
end

--- https://en.wikipedia.org/wiki/Midpoint_circle_algorithm
local function midpoint_circle(buf_t, x, y, r, color)
    local t1 = r / 16
    local x_ = r
    local y_ = 0

    local t2 = 0

    local real_buf = buf_t.buffer

    local function plot(x__, y__) -- my variable naming skills are peak
        real_buf[((y__ + y - 1) * buf_t.xsize) + x__ + x] = color
    end
    repeat
        plot(x_, y_)
        plot(x_, -y_)
        plot(-x_, y_)
        plot(-x_, -y_)

        plot(y_, x_)
        plot(y_, -x_)
        plot(-y_, x_)
        plot(-y_, -x_)

        y_ = y_ + 1

        t1 = t1 + y_
        t2 = t1 - x_

        if t2 >= 0 then
            t1 = t2
            x_ = x_ - 1
        end
    until x_ < y_
end

return bresenham, xiaolin_wu, midpoint_circle
