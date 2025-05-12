sbz_api.all_caches = {}

function sbz_api.make_cache(name, timer)
    timer = timer or 0
    local cache = { data = {} }
    sbz_api.all_caches[name] = {
        cache = cache,
        timer_max = timer,
        timer = 0,
    }
    return cache
end

sbz_api.cache_clear_globalstep = function(dtime)
    for k, v in pairs(sbz_api.all_caches) do
        local timer = v.timer
        timer = timer + dtime
        if timer > v.timer_max then
            v.timer = 0
            v.cache.data = {}
        end
    end
end

core.register_globalstep(sbz_api.cache_clear_globalstep)
