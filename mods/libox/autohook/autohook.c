#include <lua.h>
#include <lauxlib.h>
#include <luajit.h>
#include <stdlib.h>
#include <stdbool.h>
#include <time.h>
#include "autohook.h"
#include "utils.c"

// module-version.txt tracks the current C source hash, so always re-build the C module
// for any change. OR if you can't (or too lazy) do that, just do something like:
// cat autohook.c utils.c | sha256sum | awk '{ print $1 }' >module-version.txt
// or on powershell: hash.ps1 autohook.c utils.c > module-version.txt

static double prev_time = 0;
static double get_time_ms(void) {
    // On Windows, clock_t is 32-bit, meaning after 24 days and 20 hours it
    // becomes UB. So uh... don't run your server for longer than that. - ACorp
    clock_t now = clock();
    return ((double)now) / CLOCKS_PER_SEC * 1000.0;
}

static double time_limit = 0;
static int attempts = 0; // THIS is to avoid a "yield across C-call boundary" error
#define MAX_ATTEMPTS 10

static lua_Subidx module_idx = LUA_NOREF;
enum ModuleIdxs {
    IN_HOOK_IDX = 1,
    MAX_IDX,
};

#define KILL_CMD "SANDBOX KILL"

// checks error message (stack peek) starts with given msg
// lua errors is in this format "<source>:<line>: <message>"
static bool lua_error_startswith(lua_State *L, lua_Idx idx, cstr msg, size_t count) {
    assert_ptr(msg, 3);
    L_assert_string(idx);

    // lua manages the string, so we don't need to free() it ourselves :D
    size_t errfull_count;
    cstr errfull = lua_tolstring(L, idx, &errfull_count);

    if (errfull_count < count) { return false; }
    if (errfull_count == count ) {
        return string_eq(errfull, errfull_count, msg, count);
    }

    // 0: initial search
    // 1: past <source>:
    // 2: past <line>:
    int state = 0;
    cstr errmsg = errfull;
    for (size_t i = 0; state < 3 && i < errfull_count - count; ++i) {
        switch (state) {
        case 0:
        case 1:
            if (errfull[i] == ':') {
                ++state;
                if (i < errfull_count - count) {
                    errmsg = errfull + i + 1; // if there's no whitespace, just search here
                }
            }
            break;

        case 2:
            if (errfull[i] != ' ') {
                ++state;
                errmsg = errfull + i;
            }
            break;
        }
    }

    return string_startswith(errmsg,
        errfull_count - (size_t)(errmsg - errfull), msg, count);
}

#ifdef DEBUG
// lua: $globals.core.log(level, msg)
static void luanti_log(lua_State *L, cstr restrict level, cstr restrict msg) {
    assert_str(level, 2);
    assert_ptr(msg, 4);

    if (L_deepget_field(LUA_GLOBALS, "core", "log")) {
        luaL_error(L, "Unable to deep get $global.core.log");
    }
    lua_pushstring(L, level);
    lua_pushstring(L, msg);
    lua_call(L, 2, 0);
}
#else
#define luanti_log(...)
#endif

static void hookf(lua_State *L, lua_Debug *ar) {
    const lua_Idx reset = lua_gettop(L);

    if (L_deepget_subi(LUA_CREGISTRY, module_idx, IN_HOOK_IDX)) {
        luaL_error(L, "Unable to deep get $module[IN_HOOK_IDX]");
    }
    if (lua_isfunction(L, -1)) {
        // lua: errcode, (stack push) = pcall(in_hook)
        const int errcode = lua_pcall(L, 0, 0, 0);
        if (errcode != 0) {
            // lua: errmsg_len, errmsg = #(stack peek), (stack peek)
            if (lua_error_startswith(L, -1, KILL_CMD, CSTR_COUNT(KILL_CMD))) {
                lua_error(L);
            // lua: else debug.sethook(); yield(); end
            } else {
                if (lua_isyieldable(L) || attempts >= MAX_ATTEMPTS) {
                    lua_settop(L, reset);
                    lua_sethook(L, nil, 0, 0);
                    lua_yield(L, 0);
                    return;
                } else {
                    ++attempts;
                }
                return;
            }
        }
        return;
    }

    if (get_time_ms() - prev_time > time_limit) {
        if (lua_isyieldable(L) || attempts >= MAX_ATTEMPTS) {
            prev_time = get_time_ms();
            lua_settop(L, reset);
            lua_sethook(L, nil, 0, 0);
            lua_yield(L, 0);
        } else {
            ++attempts;
        }
    }
}

/// autohook(int hook_time, double time_limit, lua_function|nil|none in_hook)
/// hook_time: same as in libox.coroutine.create_sandbox. Instructions per hook trigger
/// time_limit: same as in libox.coroutine.create_sandbox, but in ms.
///     Allowed execution time limit for the coroutine sandbox in milliseconds(!)
static int autohook(lua_State *L) {
    const lua_Idx n = lua_gettop(L);
    if (n < 2 || n > 3) {
        luaL_error(L, "attach autohook() takes 2 or 3 arguments");
    }

    int hook_time;
    L_assert_number(1);
    L_assert_number(2);
    if ((hook_time = (int)lua_tointeger(L, 1)) < 0) {
        L_arg_expect_ll(1, "positive number", "negative number");
    }
    if ((time_limit = lua_tonumber(L, 2)) < 0) {
        L_arg_expect_ll(2, "positive number", "negative number");
    }

    if (lua_isfunction(L, 3)) {
        if (L_deepset_subi(LUA_CREGISTRY, module_idx, IN_HOOK_IDX)) {
            luaL_error(L, "Unable to deep set $module[IN_HOOK_IDX]");
        }
    } else if (!lua_isnoneornil(L, 3)) {
        L_arg_expect_la(3, "function or nil");
    }
    lua_settop(L, 0);

    prev_time = get_time_ms();
    attempts = 0;
    lua_sethook(L, hookf, LUA_MASKCOUNT, hook_time);
    return 0;
}

static int version(lua_State *L) {
    lua_pushstring(L, AUTOHOOK_HASH);
    lua_pushstring(L, LUAJIT_VERSION);
    return 2;
}

// the autohook module's table
static const luaL_Reg funcs [] = {
    {"autohook", autohook},
    {"version", version},
    {nil, nil}
};

int luaopen_autohook(lua_State *L) {;
    lua_createtable(L, MAX_IDX, 0);
    module_idx = L_stack2ref();
    luaL_register(L, "autohook", funcs);
    return 1;
}
