local function matrix_transform_2x2(mat, x, y)
    return mat[1][1] * x + mat[1][2] * y,
        mat[2][1] * x + mat[2][2] * y
end

local function matrix_transform_3x3(mat, x, y)
    local z = mat[3][1] * x + mat[3][2] * y + mat[3][3]
    if z == 0 then z = 1 end

    return (mat[1][1] * x + mat[1][2] * y + mat[1][3]) / z,
        (mat[2][1] * x + mat[2][2] * y + mat[2][3]) / z
end


local rounding_function = math.round


local default_color = minetest.colorspec_to_bytes("black"):sub(1, 3)
--m* = max *
-- e.g.: mx1 = max x1
-- but in this case, mx1 = smallest newx
-- and mx2 = biggest newx
-- basically mx* is a square definining the extent of the operation
local function transform_buffer(
    buffer, matrix, x1, y1, x2, y2, mx1, my1, mx2, my2, transparent_color, origin_x, origin_y, is_matrix_2x2
)
    local transformations = {}
    local xsize = buffer.xsize

    local transform_function = is_matrix_2x2 and matrix_transform_2x2 or matrix_transform_3x3

    for y = y1, y2 do
        for x = x1, x2 do
            local nx, ny = transform_function(matrix, x - origin_x, y - origin_y)
            nx = rounding_function(nx) + origin_x
            ny = rounding_function(ny) + origin_y
            transformations[#transformations + 1] = {
                x, y,
                nx, ny
            }
        end
    end

    -- now... this is the scuffed part
    local changed_to_transparent = {}
    local changed_norm = {}

    local real_buffer = buffer.buffer
    for k, v in ipairs(transformations) do
        -- simple and understandable code right here! no explanation needed
        local nx, ny = v[3], v[4]
        local x, y = v[1], v[2]
        local new_pixel = real_buffer[(ny - 1) * xsize + nx]

        changed_to_transparent[#changed_to_transparent + 1] =
        {
            (y - 1) * xsize + x,
            transparent_color or default_color
        }

        if not (
                nx < mx1 or nx > mx2
                or ny < my1 or ny > my2
            ) then
            changed_norm[#changed_norm + 1] = { (y - 1) * xsize + x, new_pixel }
        end
    end
    -- and finally, commit the changes

    for k, v in ipairs(changed_to_transparent) do
        real_buffer[v[1]] = v[2]
    end

    for k, v in ipairs(changed_norm) do
        real_buffer[v[1]] = v[2]
    end
end

-- https://www.youtube.com/watch?v=KuXjwB4LzSA
-- (didnt use any code from it, just used it to understand the concept)
local function convolution_matrix(buffer, matrix, x1, y1, x2, y2)
    local matrix_sizex         = #matrix
    local matrix_sizey         = #matrix[1]
    local buffer_sizex         = buffer.xsize
    local buffer_sizey         = buffer.ysize
    local real_buffer          = buffer.buffer

    local buffer_modifications = {}


    local halfy = math.floor(matrix_sizey / 2)
    local halfx = math.floor(matrix_sizex / 2)

    for y = y1, y2 do
        for x = x1, x2 do
            -- ok now this is going to get funny
            local r, g, b = 0, 0, 0
            for y_off = -halfy, halfy do
                for x_off = -halfx, halfx do
                    local target_x = x + x_off
                    local target_y = y + y_off
                    local pixel = real_buffer[(target_y - 1) * buffer_sizex + target_x]
                    if pixel ~= nil then
                        local multiply_by = matrix[halfy + 1 + y_off][halfx + 1 + x_off]
                        r = r + pixel:byte(1) * multiply_by
                        g = g + pixel:byte(2) * multiply_by
                        b = b + pixel:byte(3) * multiply_by
                    end
                end
            end
            r = math.min(255, math.abs(r))
            g = math.min(255, math.abs(g))
            b = math.min(255, math.abs(b))
            buffer_modifications[#buffer_modifications + 1] = {
                (y - 1) * buffer_sizex + x, string.char(r) .. string.char(g) .. string.char(b)
            }
        end
    end

    for k, v in ipairs(buffer_modifications) do
        real_buffer[v[1]] = v[2]
    end
end

return transform_buffer, convolution_matrix
