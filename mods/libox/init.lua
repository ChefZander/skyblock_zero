local ie = minetest.request_insecure_environment()
if ie == nil and (debug.getupvalue == nil and debug.getlocal == nil) then
    minetest.log("warning", [[
====Hello, this message is for server owners====
Libox needs to be a trusted mod for weighing of coroutine sandboxes to work properly.
If it isn't, coroutine sandboxes could fill up your server's memory with local variables and upvalues.

Libox can re-use debug.getlocal and debug.getupvalue if it is already avaliable in the environment
When adding libox to secure.trusted_mods, be aware that it will expose debug.getlocal and debug.getupvalue
================================================
]])
elseif debug.getlocal == nil or debug.getupvalue == nil and ie ~= nil then
    -- luacheck:ignore
    debug.getlocal = ie.debug.getlocal
    debug.getupvalue = ie.debug.getupvalue
end

ie = nil -- luacheck: ignore

local MP = minetest.get_modpath(minetest.get_current_modname())
dofile(MP .. "/main.lua")

-- Files that are executed sync only, coroutine.lua and *.test.lua
dofile(MP .. "/coroutine.lua")

-- async files
minetest.register_async_dofile(MP .. "/main.lua")

local test = MP .. "/test"
dofile(test .. "/basic_testing.lua")
dofile(test .. "/coroutine.test.lua")
dofile(test .. "/normal.test.lua")
