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

if ie and jit then
    local MP = core.get_modpath("libox")
    local lib
    if jit.os == 'Windows' then
        lib = MP .. "/autohook/libautohook.dll"
    else -- Linux/Unix-like
        lib = MP .. "/autohook/libautohook.so"
    end
    -- Use package.loadlib() instad of require() to prevent using
    -- system/other apps' libraries with the same name
    local errmsg
    libox_autohook_module, errmsg = ie.package.loadlib(lib, 'luaopen_autohook')()
    while true do
        if not libox_autohook_module or errmsg then
            core.log("error", ('Autohook feature NOT available. Failed loading autohook C module %s:\n%s'):format(lib, errmsg))
            break
        end

        local version_file = io.open(MP .. "/autohook/module-version.txt")
        local module_version = libox_autohook_module.version
        if not version_file or not module_version then
            core.log("warning", 'Autohook feature available, but could not verify its C module compatibility')
            break
        end
        local current_version = version_file:read("*n")
        version_file:close()

        if current_version ~= libox_autohook_module.version() then
            core.log("warning", 'Autohook feature available, but its C module version is incompatible')
            break
        end

        core.log("info", 'Autohook feature available')
        break
    end
else
    core.log("info", 'Autohook feature NOT available')
end

local MP = minetest.get_modpath(minetest.get_current_modname())
dofile(MP .. "/main.lua")

-- Files that are executed sync only, coroutine.lua and *.test.lua
dofile(MP .. "/coroutine.lua")

libox_autohook_module = nil

-- async files
minetest.register_async_dofile(MP .. "/main.lua")

local test = MP .. "/test"
dofile(test .. "/basic_testing.lua")
dofile(test .. "/coroutine.test.lua")
dofile(test .. "/normal.test.lua")