if core ~= nil then error('DO NOT RUN THIS FROM LUANTI') end


option('Iluajit')
    set_showmenu(true)
    set_description('Custom LuaJIT includes/ directory')
option_end()

option('Lluajit')
    set_showmenu(true)
    set_description('Custom LuaJIT libs/ directory')
option_end()

add_requires('luajit', { system = true, configs = { shared = false }, optional = true})

local clang_flags = {
    "-Wall", "-Wextra", "-Wpedantic", "-Weverything",
    -- useless/meh warnings --
    "-Wno-extra-semi-stmt", "-Wno-newline-eof",
    "-Wno-declaration-after-statement", "-Wno-unused-parameter",
    "-Wno-unused-function", "-Wno-missing-prototypes", "-Wno-unused-macros",
    "-Wno-switch-default",
    -- other warnings --
    -- only a problem if you're using some wacky compiler
    "-Wno-gnu-zero-variadic-macro-arguments",

    -- C + Lua doesn't provide easy ways to protect from this. ignoring...
    "-Wno-unsafe-buffer-usage"
}
local gcc_flags = {
    "-Wall", "-Wextra", "-Wpedantic",
    -- uhh idk
}

target('autohook')
    set_kind('shared')
    set_basename('autohook')
    set_targetdir('.')
    add_files('autohook.c', 'utils.c')
    set_configdir('.')
    add_configfiles('autohook.h.in')

    set_languages("c11")

    add_packages('luajit')

    on_load(function(target)
        import('core.tool.compiler')
        local cc = compiler.compargv('dummy.c', { target = target })
        if cc and path.basename(cc):match('clang') then
            for i=1,#clang_flags do
                target:add('cflags', clang_flags[i])
            end
        else
            for i=1,#gcc_flags do
                target:add('cflags', gcc_flags[i])
            end
        end

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


    before_build(function(target)
        printf('checking for LuaJIT version ... ')

        local get_luajit_version = [[
#include <stdio.h>
#include <luajit.h>
int main(int argc, char** argv) {
    puts(LUAJIT_VERSION);
    return 0;
}]]
        local ok, luajit_version = target:check_csnippets({ test = get_luajit_version }, {
            tryrun = true,
            output = true,
            -- includes = {"path/to/headers.h"},
            configs = {languages = 'c11'}})

        local errmsg = ('Outdated LuaJIT version! Please update it or build a LuaJIT rolling release (current: %s)'):format(luajit_version)

        -- must at least be 2.1.*
        assert(luajit_version:startswith('LuaJIT 2.1.'), errmsg)

        -- this is exactly how LuaJIT developer wants downstream users to check
        -- the rolling release versions. the beta versions are 2.1.0. but it's
        -- more robust if we can just put which commit to cut off support. Also
        -- people might build LuaJIT version that default to 2.1.ROLLING cuz
        -- they didn't allow the build script to determine the last commit
        -- timestamp.
        local supported = 1692580715 -- commit c3459468 first 2.1.ROLLING release
        assert(luajit_version == 'LuaJIT 2.1.ROLLING'
            or tonumber(luajit_version:sub(12):match('^%d+')) >= supported, errmsg)

        cprint('${bright green}' ..luajit_version)
    end)