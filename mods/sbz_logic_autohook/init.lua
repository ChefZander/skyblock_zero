local IE = core.request_insecure_environment()
if IE then
    local MP = core.get_modpath("sbz_logic_autohook")
    IE.package.cpath = MP .. "/bin/?.so;" .. IE.package.cpath
    local ok, errmsg = IE.pcall(function()
        sbz_api.autohook = IE.require("autohook").autohook
    end)
    if not ok then
        core.log("warning",
            "[sbz_logic_autohook] - You have trusted this mod but didn't compile the C parts, autohook.so could not load, error message: \n" ..
            errmsg
        )
    end
end
IE = nil


-- //--test--//

-- local co = coroutine.create(function()
--     while true do end
-- end)
-- jit.off(true, true)
-- sbz_api.autohook.autohook()
-- local e = { coroutine.resume(co) }
-- error(dump(e))
