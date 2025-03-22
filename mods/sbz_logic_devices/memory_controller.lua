-- memcontroller

local function compress(data)
    return core.compress(data, "zstd")
end
local function decompress(data)
    return core.decompress(data, "zstd")
end

local key_size_limit = 128
local size_limit = 64 * 1024 * 1024 * 1024 -- 64MB
local lag_limit = 50 * 1000                -- 50ms

local default_index_state = {
    size = 0,
}

core.register_node("sbz_logic_devices:memcontroller", {
    description = "Memory Controller",
    info_extra = {
        "Holds " .. (size_limit / 1024 ^ 3) .. "mb",
        "Capable of compressing data",
        "Limited to " .. (lag_limit / 1000) .. "ms/s",
    },
    tiles = {
        "memcontroller_top.png",
        "gpu_bottom.png",
        "memcontroller_side.png",
    },
    drawtype = "nodebox",
    node_box = {
        type = "fixed",
        fixed = {
            -0.5, -0.5, -0.5, 0.5, 0, 0.5 -- slab
        }
    },
    paramtype = "light",
    groups = { ui_logic = 1, matter = 1, charged = 1 },
    on_construct = function(pos)
        local meta = core.get_meta(pos)
        meta:set_string("INDEX", core.serialize(table.copy(default_index_state)))
        meta:mark_as_private("INDEX")
    end,
    on_logic_send = function(pos, msg, from_pos)
        if type(msg) ~= "table" then return end
        if type(msg.type) ~= "string" then return end
        local meta = core.get_meta(pos)
        local lag, measurement_time = meta:get_float("lag"), meta:get_int("measurement_time")
        if lag > lag_limit and measurement_time ~= os.time() then return end

        local notify = sbz_api.logic.get_notify(from_pos, pos)
        local t0 = core.get_us_time()
        msg.type = msg.type:lower()

        local INDEX = core.deserialize(meta:get_string("INDEX"))
        if type(INDEX) ~= "table" then -- corrupted, just reset meta
            meta:from_table({})
            meta:set_string("INDEX", core.serialize(table.copy(default_index_state))); meta:mark_as_private("INDEX")
            INDEX = default_index_state
        end
        local index_dirty = false
        if type(msg.key) == "string" and #msg.key <= key_size_limit then
            local internal_name = "d_" .. msg.key
            local entry = INDEX[internal_name]
            if msg.type == "get" then
                if not entry then
                    notify {
                        type = "get",
                        data = nil,
                    }
                else
                    if entry.compressed then
                        notify {
                            type = msg.type,
                            data = decompress(meta:get_string(internal_name))
                        }
                    else
                        notify {
                            type = msg.type,
                            data = meta:get_string(internal_name)
                        }
                    end
                end
            elseif msg.type == "set" or msg.type == "setc" then
                local should_compress = msg.type == "setc"
                local value = msg.value
                if type(value) ~= "string" then return end
                local old_size = 0
                if entry then
                    old_size = entry.size
                end
                if should_compress then
                    value = compress(value)
                end
                local new_size = #msg.key + #value
                if (INDEX.size - old_size + new_size) > size_limit then
                    notify {
                        type = msg.type,
                        error = "Can't fit data in memory controller."
                    }
                else
                    -- data can be fit, initiate
                    notify {
                        type = msg.type
                    }
                    INDEX[internal_name] = {
                        size = new_size,
                        compressed = should_compress,
                    }
                    INDEX.size = INDEX.size - old_size + new_size
                    index_dirty = true
                    meta:set_string(internal_name, value)
                    meta:mark_as_private(internal_name)
                end
            elseif msg.type == "del" then
                notify { type = msg.type }
                index_dirty = true
                INDEX[internal_name] = nil
                meta:set_string(internal_name, "")
            end
        else
            if msg.type == "reset" then
                notify { type = msg.type }
                meta:from_table({})
                meta:set_string("INDEX", core.serialize(table.copy(default_index_state))); meta:mark_as_private("INDEX")
                INDEX = default_index_state
            end
        end
        if index_dirty then
            meta:set_string("INDEX", core.serialize(INDEX))
            meta:mark_as_private("INDEX")
        end
        local t = core.get_us_time() - t0
        meta:set_float("lag", lag + t)
        meta:set_int("measurement_time", os.time())
        meta:set_string("infotext", ("Memory Controller\nLag: %sms/%sms"):format((lag + t) / 1000, lag_limit / 1000))
    end,
})
