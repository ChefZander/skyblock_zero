if core ~= nil then error("DO NOT RUN THIS FROM LUANTI") end

option("luajit-root")
    set_showmenu(true)
    set_description("Custom LuaJIT installation directory")
option_end()

if not get_config("luajit-root") then
    add_requires("luajit", { system = true, configs = { shared = false } })
end

target("autohook")
    set_kind("shared")
    set_basename("autohook")
    set_targetdir(".")
    add_files("autohook.c")
    if not get_config("luajit-root") then
        add_packages("luajit")
    end

    on_load(function(target)
        local luajit_root = get_config("luajit-root")
        if luajit_root then
            local include_dir = path.join(luajit_root, "include", "luajit-2.1")
            assert(os.isfile(path.join(include_dir, "luajit.h")),
                "Failed finding LuaJIT headers in: <luajit-root>/include/luajit-2.1")
            add_includedirs(include_dir)

            import("lib.detect.find_library")
            local lib_dir = path.join(luajit_root, "lib")
            local found_lib_51 = find_library("luajit-5.1", { lib_dir }, { kind = "static" })
            local found_lib_simple = find_library("luajit", { lib_dir }, { kind = "static" })
            assert(found_lib_51 or found_lib_simple,
                "Failed finding LuaJIT static library in <luajit-root>/include/luajit-2.1")
            add_linkdirs(lib_dir)
            if found_lib_51 then add_links("luajit-5.1") end
            if found_lib_simple then add_links("luajit") end
        end
    end)