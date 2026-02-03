assert(bit, 'No bit library found? Update your luanti version or use luaJIT.')

--[[
    The goal of this file is to have faster serialization of some specific types
    Basically, faster at the cost of being less general.

    - No vector.new should be used here
    - You should try to make as high performance of a serialization as you can, who cares if it doesn't matter, it's fun!
    - ***Make code for the fun of it :D***
    - Procrastinate here
    - I would definitely involve ffi in this if i could xD, be glad ffi is off limits xD
    - i feel like i'm one step closer to re-making something found commonly in modlib
]]

sbz_api.serialize = {}
sbz_api.deserialize = {}

local band, rshift, lshift = bit.band, bit.rshift, bit.lshift
local char, byte, sub = string.char, string.byte, string.sub
local concat = table.concat
local pairs = pairs

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
            band(rshift(x, 24), 0xFF),
            band(rshift(x, 16), 0xFF),
            band(rshift(x, 8), 0xFF),
            band(x, 0xFF),
            band(rshift(y, 24), 0xFF),
            band(rshift(y, 16), 0xFF),
            band(rshift(y, 8), 0xFF),
            band(y, 0xFF),
            band(rshift(z, 24), 0xFF),
            band(rshift(z, 16), 0xFF),
            band(rshift(z, 8), 0xFF),
            band(z, 0xFF)
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
            z = lshift(zc1, 24) + lshift(zc2, 16) + lshift(zc3, 8) + zc4,
        }
    end
    return out
end

function sbz_api.serialize.vec3_32bit(vec)
    local x, y, z = vec.x, vec.y, vec.z
    return char(
        band(rshift(x, 24), 0xFF),
        band(rshift(x, 16), 0xFF),
        band(rshift(x, 8), 0xFF),
        band(x, 0xFF),
        band(rshift(y, 24), 0xFF),
        band(rshift(y, 16), 0xFF),
        band(rshift(y, 8), 0xFF),
        band(y, 0xFF),
        band(rshift(z, 24), 0xFF),
        band(rshift(z, 16), 0xFF),
        band(rshift(z, 8), 0xFF),
        band(z, 0xFF)
    )
end

function sbz_api.deserialize.vec3_32bit(str)
    assert(#str == 12, 'Corrupted data!')
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
    if int == 1 then
        return true
    else
        return false
    end
end

--[[
    Links is a table like so:
    links = {
        [name] = {v1, vN}
    }
    v1 = {x=int,y=int,z=int}
    vN = {x=int,y=int,z=int}

    -- Basically, a hashmap and like.. yeah
]]
---@param links table<string, vectorT[]>
---@return string
function sbz_api.serialize.links(links)
    local out = {}
    local rope = 0
    local current_vec
    local x, y, z
    for name, vec_arr in pairs(links) do
        rope = rope + 1
        assert(#name <= 255, 'sbz_api.serialize.links: Name too large!')
        out[rope] = char(#name)
        rope = rope + 1
        assert(#vec_arr <= 255, 'sbz_api.serialize.links: Vector array too large!')
        out[rope] = char(#vec_arr)
        rope = rope + 1
        out[rope] = name
        -- [#name][#vec][1st char of name][2nd char of name][#name char of name][first vector's x coordinate first part (1/4)][blabla bla bla i can't continue this]
        -- hope it makes sense
        for i = 1, #vec_arr do
            current_vec = vec_arr[i]
            x, y, z = current_vec.x, current_vec.y, current_vec.z

            rope = rope + 1
            out[rope] = char(
                band(rshift(x, 24), 0xFF),
                band(rshift(x, 16), 0xFF),
                band(rshift(x, 8), 0xFF),
                band(x, 0xFF),
                band(rshift(y, 24), 0xFF),
                band(rshift(y, 16), 0xFF),
                band(rshift(y, 8), 0xFF),
                band(y, 0xFF),
                band(rshift(z, 24), 0xFF),
                band(rshift(z, 16), 0xFF),
                band(rshift(z, 8), 0xFF),
                band(z, 0xFF)
            )
        end
    end
    return concat(out)
end

function sbz_api.deserialize.links(serialized)
    local val = {}
    local i = 1
    local name_length, num_of_vectors, name, rope, vec_arr
    local xc1, xc2, xc3, xc4, yc1, yc2, yc3, yc4, zc1, zc2, zc3, zc4

    while true do
        name_length, num_of_vectors = byte(serialized, i, i + 1)
        if not name_length or not num_of_vectors then break end

        i = i + 2
        name = sub(serialized, i, (i + name_length) - 1)

        vec_arr = {}
        val[name] = vec_arr
        i = i + name_length

        rope = 0
        for j = 1, num_of_vectors do
            xc1, xc2, xc3, xc4, yc1, yc2, yc3, yc4, zc1, zc2, zc3, zc4 =
                byte(serialized, i + ((j - 1) * 12), i + (j * 12) - 1)
            rope = rope + 1
            vec_arr[rope] = {
                x = lshift(xc1, 24) + lshift(xc2, 16) + lshift(xc3, 8) + xc4,
                y = lshift(yc1, 24) + lshift(yc2, 16) + lshift(yc3, 8) + yc4,
                z = lshift(zc1, 24) + lshift(zc2, 16) + lshift(zc3, 8) + zc4,
            }
        end
        i = i + (num_of_vectors * 12)
    end
    return val
end
