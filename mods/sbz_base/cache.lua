sbz_api.all_caches = {}

function sbz_api.make_cache(name)
    local cache = { data = {} }
    sbz_api.all_caches[name] = cache
    return cache
end

sbz_api.cache_clear_globalstep = function()
    for k, v in pairs(sbz_api.all_caches) do
        v.data = {}
    end
end

core.register_globalstep(sbz_api.cache_clear_globalstep)
