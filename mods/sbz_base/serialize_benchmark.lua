local amount = 1000
local mg_limit = 65534 / 2

local function table_equals(t1, t2)
    if type(t1) ~= "table" or type(t2) ~= "table" then
        return t1 == t2 -- Direct comparison for non-tables
    end

    -- Check all keys and values in t1
    for k, v in pairs(t1) do
        if not table_equals(v, t2[k]) then
            return false
        end
    end

    -- Check if t2 has extra keys not in t1
    for k in pairs(t2) do
        if t1[k] == nil then
            return false
        end
    end
    return true
end

sbz_api.serialize.benchmark = function()
    local args = {}
    local serialized_result

    for i = 1, amount do
        args[i] = vector.new(
            math.random(-mg_limit, mg_limit),
            math.random(-mg_limit, mg_limit),
            math.random(-mg_limit, mg_limit)
        )
    end
    sbz_api.benchmark("vec3_array_32bit - serialize - Large amount of stuff", function()
        local buf = {}
        for i = 1, amount do
            serialized_result = sbz_api.serialize.vec3_array_32bit(args, buf)
        end
    end)
    sbz_api.benchmark("vec3_array_32bit - deserialize - Large amount of stuff", function()
        local buf = {}
        for i = 1, amount do
            sbz_api.deserialize.vec3_array_32bit(serialized_result, buf)
        end
    end)

    assert(table_equals(sbz_api.deserialize.vec3_array_32bit(serialized_result, {}), args),
        "vec3_array_32bit doesn't serialize properly")
    core.debug("vec3_array_32bit is correct!")

    sbz_api.benchmark("minetest.serialize - Large amount of stuff", function()
        for i = 1, amount do
            serialized_result = core.serialize(args)
        end
    end)
    sbz_api.benchmark("minetest.deserialize - Large amount of stuff", function()
        local buf = {}
        for i = 1, amount do
            core.deserialize(serialized_result, buf)
        end
    end)
end
