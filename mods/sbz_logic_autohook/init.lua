local IE = core.request_insecure_environment()
if IE then
    local MP = core.get_modpath("sbz_logic_autohook")
    sbz_api.autohook = IE.package.loadlib(MP .. "/bin/autohook.so", "luaopen_autohook")().autohook
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
