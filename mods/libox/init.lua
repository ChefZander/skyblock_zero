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
            core.log("error", ('[libox] Autohook feature NOT available. Failed loading autohook C module %s:\n%s'):format(lib, errmsg))
            libox_autohook_module = nil
            break
        end

        local version_file = io.open(MP .. "/autohook/module-version.txt")
        local module_version = libox_autohook_module.version
        if not version_file or not module_version then
            core.log("error", '[libox] Autohook feature NOT available, could not verify its C module compatibility')
            libox_autohook_module = nil
            break
        end
        local current_version = version_file:read("*l")
        version_file:close()

        local module_version, jit_version = module_version()
        if current_version ~= module_version then
            core.log("error", '[libox] Autohook feature NOT available, its C module version is incompatible\n'
                ..('current: %s | available: %s'):format(current_version, module_version))
            libox_autohook_module = nil
            break
        end

        if jit_version ~= jit.version then
            core.log("error", '[libox] Autohook feature NOT available, its compiled against a different LuaJIT version than Luanti\n'
                ..('Luanti: %s | autohook: %s'):format(jit.version, jit_version))
            libox_autohook_module = nil
        end

        core.log("info", '[libox] Autohook feature available')
        break
    end
else
    core.log("info", '[libox] Autohook feature NOT available')
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