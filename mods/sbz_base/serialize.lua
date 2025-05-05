assert(bit, "No bit library found? Update your luanti version or use luaJIT.") -- great

--[[
    The goal of this file is to have faster serialization of some specific types
    Basically, faster at the cost of being less general.

    - No vector.new should be used here
    - You should try to make as high performance of a serialization as you can, who cares if it doesn't matter, it's fun!
    - Make code for the fun of it :D
    - I would definitely involve ffi in this if i could xD, be glad ffi is off limits xD
    - i feel like i'm one step closer to re-making something found commonly in modlib

    TODO:
        - serialize liquid inv here, and serialize/deserialize it F A S T
]]

sbz_api.serialize = {}
sbz_api.deserialize = {}

local band, rshift, lshift = bit.band, bit.rshift, bit.lshift
local char, byte = string.char, string.byte
local concat = table.concat

---@param vec_arr {x:number, y:number, z:number}[]
---@return string
function sbz_api.serialize.vec3_array_32bit(vec_arr)
    local out = {}
    local size_of_vec_arr = #vec_arr
    local rope = 0
    local vec
    local x, y, z
    for i = 1, size_of_vec_arr do
        vec = vec_arr[i]
        x, y, z = vec.x, vec.y, vec.z

        rope = rope + 1
        out[rope] = char(
            band(rshift(x, 24), 0xFF), band(rshift(x, 16), 0xFF), band(rshift(x, 8), 0xFF), band(x, 0xFF),
            band(rshift(y, 24), 0xFF), band(rshift(y, 16), 0xFF), band(rshift(y, 8), 0xFF), band(y, 0xFF),
            band(rshift(z, 24), 0xFF), band(rshift(z, 16), 0xFF), band(rshift(z, 8), 0xFF), band(z, 0xFF)
        )
    end
    return concat(out)
end

---@param str string
---@return {x:number, y:number, z:number}[]
function sbz_api.deserialize.vec3_array_32bit(str)
    local out = {}
    local str_len = #str / 12 -- 4 chars for each coordinate, 4*3 = 12
    local rope = 0
    local xc1, xc2, xc3, xc4, yc1, yc2, yc3, yc4, zc1, zc2, zc3, zc4
    for i = 1, str_len do
        xc1, xc2, xc3, xc4, yc1, yc2, yc3, yc4, zc1, zc2, zc3, zc4 = byte(str, ((i - 1) * 12) + 1, i * 12)

        rope = rope + 1
        out[rope] = {
            x = lshift(xc1, 24) + lshift(xc2, 16) + lshift(xc3, 8) + xc4,
            y = lshift(yc1, 24) + lshift(yc2, 16) + lshift(yc3, 8) + yc4,
            z = lshift(zc1, 24) + lshift(zc2, 16) + lshift(zc3, 8) + zc4
        }
    end
    return out
end

function sbz_api.serialize.vec3_32bit(vec)
    local x, y, z = vec.x, vec.y, vec.z
    return char(
        band(rshift(x, 24), 0xFF), band(rshift(x, 16), 0xFF), band(rshift(x, 8), 0xFF), band(x, 0xFF),
        band(rshift(y, 24), 0xFF), band(rshift(y, 16), 0xFF), band(rshift(y, 8), 0xFF), band(y, 0xFF),
        band(rshift(z, 24), 0xFF), band(rshift(z, 16), 0xFF), band(rshift(z, 8), 0xFF), band(z, 0xFF)
    )
end

function sbz_api.deserialize.vec3_32bit(str)
    local xc1, xc2, xc3, xc4, yc1, yc2, yc3, yc4, zc1, zc2, zc3, zc4 = byte(str, 1, 12)
    return {
        x = lshift(xc1, 24) + lshift(xc2, 16) + lshift(xc3, 8) + xc4,
        y = lshift(yc1, 24) + lshift(yc2, 16) + lshift(yc3, 8) + yc4,
        z = lshift(zc1, 24) + lshift(zc2, 16) + lshift(zc3, 8) + zc4,
    }
end

-- can this even be called (de)serialization?
-- idk lol

---@param bool boolean
---@return integer
function sbz_api.serialize.bool(bool)
    return bool and 1 or 0
end

---@param int integer
---@return boolean
function sbz_api.deserialize.bool(int)
    if int == 1 then return true else return false end
end
