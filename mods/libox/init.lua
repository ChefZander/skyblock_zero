local ie = minetest.request_insecure_environment()
if ie == nil and (debug.getupvalue == nil and debug.getlocal == nil) then
    minetest.log("warning", [[
===== ATTENTION (this is mainly for servers)=======
Libox is not included in trusted mods,
this means that libox cannot measure local variables and upvalues inside coroutine sandboxes
(it needs debug.getlocal and debug.getupvalue to do it)

LIBOX WILL EXPOSE AND USE debug.getlocal AND debug.getupvalue
also MAKE SURE TO TRUST ALL MODS IF YOU MAKE LIBOX A TRUSTED MOD
(but also this is very hard to abuse unless your mods store the insecure environment somewhere)

If you don't use coroutine sandboxes, feel free to ignore this warning
Libox can also reuse debug.getlocal and getupvalue if it is already avaliable in the environment
========== ATTENTION END ==========
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
