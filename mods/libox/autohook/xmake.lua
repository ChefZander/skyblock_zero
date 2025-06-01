if core ~= nil then error('DO NOT RUN THIS FROM LUANTI') end


option('Iluajit')
    set_showmenu(true)
    set_description('Custom LuaJIT includes/ directory')
option_end()

option('Lluajit')
    set_showmenu(true)
    set_description('Custom LuaJIT libs/ directory')
option_end()

if not get_config('Iluajit') and not get_config('Lluajit') then
    add_requires('luajit', { system = true, configs = { shared = false } })
end

target('autohook')
    set_kind('shared')
    set_basename('autohook')
    set_targetdir('.')
    add_files('autohook.c', 'utils.c')
    set_configdir('.')
    add_configfiles('autohook.h.in')

    add_cflags("-Wall", "-Wextra", "-Wpedantic", "-Weverything",
        -- useless/meh warnings --
        "-Wno-extra-semi-stmt", "-Wno-newline-eof",
        "-Wno-declaration-after-statement", "-Wno-unused-parameter",
        "-Wno-unused-function", "-Wno-missing-prototypes", "-Wno-unused-macros",
        "-Wno-switch-default",
        -- other warnings --
        -- only a problem if you're using some wacky compiler
        "-Wno-gnu-zero-variadic-macro-arguments",

        -- C + Lua doesn't provide easy ways to protect from this. ignoring...
        "-Wno-unsafe-buffer-usage")
    set_languages("c11")

    if not get_config('Iluajit') and not get_config('Lluajit') then
        add_packages('luajit')
    end

    on_load(function(target)
        local luajit_include = get_config('Iluajit')
        if luajit_include then
            assert(os.isfile(path.join(luajit_include, 'luajit.h')),
                    ('Failed finding LuaJIT headers in <Iluajit>'):format(luajit_include))
            target:add('includedirs', luajit_include)
        end

        local luajit_lib = get_config('Lluajit')
        if luajit_lib then
            import('lib.detect.find_library')
            local found_lib_51 = find_library('luajit-5.1', { luajit_lib }, { kind = 'static' })
            local found_lib_simple = find_library('luajit', { luajit_lib }, { kind = 'static' })

            assert(found_lib_51 or found_lib_simple,
                ('Failed finding LuaJIT library in <Lluajit>: '):format(luajit_lib))
            target:add('linkdirs', luajit_lib)
            if found_lib_51 then target:add('links', 'luajit-5.1') end
            if found_lib_simple then target:add('links', 'luajit') end
        end

        import('helpers')
        local hash = helpers.get_sha256{'autohook.c', 'utils.c'}
        target:set('configvar', 'AUTOHOOK_HASH', hash)
        io.writefile("module-version.txt", hash)
    end)