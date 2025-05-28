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

local test_laggy_stuff = true

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

    if test_laggy_stuff then
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

    local links_args = {}
    for i = 1, math.floor(amount / 4) do
        links_args[i] = vector.new(
            math.random(-mg_limit, mg_limit),
            math.random(-mg_limit, mg_limit),
            math.random(-mg_limit, mg_limit)
        )
    end
    local to_serialize = {
        ["name1"] = links_args,
        ["name2"] = links_args,
        ["name3"] = links_args,
    }
    sbz_api.benchmark("links - serialize - Large amount of stuff", function()
        local buf = {}
        for i = 1, math.floor(amount / 3) do
            serialized_result = sbz_api.serialize.links(to_serialize, buf)
        end
    end)
    local deserialized_result
    sbz_api.benchmark("links - deserialize - Large amount of stuff", function()
        local buf = {}
        for i = 1, amount do
            deserialized_result = sbz_api.deserialize.links(serialized_result, buf)
        end
    end)

    assert(table_equals(deserialized_result, to_serialize),
        "links serialization isn't correct")
    core.debug("links serialization is correct!")

    if test_laggy_stuff then
        sbz_api.benchmark("minetest.serialize - serialize links", function()
            for i = 1, amount do
                serialized_result = core.serialize(to_serialize)
            end
        end)
        sbz_api.benchmark("minetest.deserialize - serialize links", function()
            local buf = {}
            for i = 1, amount do
                core.deserialize(serialized_result, buf)
            end
        end)
    end
end
