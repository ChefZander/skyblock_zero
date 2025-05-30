#include <lua.h>
#include <lauxlib.h>
#include <luajit.h>
#include <stdio.h>
#include <stdlib.h>
#include <stdbool.h>
#include <time.h>
#include "autohook.h"

// module-version.txt tracks the current autohook.c hash, so always re-build the C module
// for any change. OR if you can't (or too lazy) do that, just do something like:
// sha256sum autohook.c | awk '{ print $1 }' >module-version.txt

// i'm over-documenting the lua equivalents so it's easy for people
// unexperienced with using Lua from C to understand what's going on. - ACorp

// TODO debug macro variable that enables core.log from C.

// like home
#define nil NULL

#define LUA_POSITIVE(var, check, stackpos) \
    var = check(L, stackpos); \
    if (var < 0) luaL_error(L, "argument must be a positive integer")

static bool string_startswith(
    const char *restrict s1, size_t ch_count1,
    const char *restrict s2, size_t ch_count2) {

    size_t shortest = ch_count1 < ch_count2 ? ch_count1 : ch_count2;
    for (size_t i = 0; i < shortest; ++i) {
        if (s1[i] != s2[i]) { return false; }
    }
    return true;
}

static double prev_time = 0;
static double get_time_ms() {
    // On Windows, clock_t is 32-bit, meaning after 24 days and 20 hours it
    // becomes UB. So uh... don't run your server for longer than that. - ACorp
    return ((double)clock()) / CLOCKS_PER_SEC * 1000.0L;
}

static double time_limit = 0;
static int attempts = 0; // THIS is to avoid a "yield across C-call boundary" error
#define MAX_ATTEMPTS 10
#define MODULE_KEY "__libox_autohook"
#define IN_HOOK_KEY "in_hook"
#define KILL_CMD "SANDBOX KILL"

static void hookf(lua_State *L, lua_Debug *ar) {
    // TODO: find a way for this hook to detect whether it's inside a libox coroutine sandbox or not.
    int reset = lua_gettop(L);

    // lua: (alias) in_hook = __cregistry[MODULE][IN_HOOK]
    // lua: if isfunction(in_hook) then ... end
    lua_getfield(L, LUA_REGISTRYINDEX, MODULE_KEY);
    lua_getfield(L, -1, IN_HOOK_KEY);
    if (lua_isfunction(L, -1)) {
        // lua: errcode, errmsg = pcall(in_hook)
        // lua: if not errcode then ... end
        const int errcode = lua_pcall(L, 0, 0, 0);
        if (errcode != LUA_OK) {
            // lua: if ~isstring(errmsg) then error(...) end
            if (!lua_isstring(L, -1)) {
                lua_pushstring(L, "bad error type from in_hook() hook: expected a string");
                lua_error(L);
            }

            // lua: errmsg_len = #errmsg
            size_t errmsg_len;
            const char* errmsg = lua_tolstring(L, -1, &errmsg_len);
            // lua: if errmsg:startswith(KILL_CMD) then error(errmsg)
            // lua: else debug.sethook(); yield(); end
            if (errmsg == nil || string_startswith(errmsg, errmsg_len, KILL_CMD, sizeof(KILL_CMD) - 1)) {
                lua_error(L);
            } else {
                lua_settop(L, reset);
                lua_sethook(L, nil, 0, 0);
                lua_yield(L, 0);
                return;
            }
        }
        return;
    }

    if (get_time_ms() - prev_time > time_limit) {
        if (lua_isyieldable(L) || attempts >= MAX_ATTEMPTS) {
            prev_time = get_time_ms();
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
    const int n = lua_gettop(L);
    if (n < 2 || n > 3) {
        luaL_error(L, "attach autohook() takes 2 or 3 arguments");
    }

    lua_Integer hook_time;
    LUA_POSITIVE(hook_time, luaL_checkinteger, 1);
    LUA_POSITIVE(time_limit, luaL_checknumber, 2);

    if (lua_isnoneornil(L, 3)) {
        // lua: __cregistry[MODULE][IN_HOOK] = nil
        lua_getfield(L, LUA_REGISTRYINDEX, MODULE_KEY);
        lua_pushnil(L);
        lua_setfield(L, -2, IN_HOOK_KEY);
    } else if (lua_isfunction(L, 3)) {
        // lua: __cregistry[MODULE][IN_HOOK] = args[3]
        lua_getfield(L, LUA_REGISTRYINDEX, MODULE_KEY);
        lua_pushvalue(L, 3);
        lua_setfield(L, -2, IN_HOOK_KEY);
    } else {
        luaL_typerror(L, 3, "function or nil");
    }

    prev_time = get_time_ms();
    attempts = 0;
    lua_sethook(L, hookf, LUA_MASKCOUNT, hook_time);
    return 0;
}

static int version(lua_State *L) {
    lua_pushstring(L, AUTOHOOK_HASH);
    return 1;
}

// the autohook module's table
static const luaL_Reg funcs [] = {
    {"autohook", autohook},
    {"version", version},
    {nil, nil}
};

int luaopen_autohook(lua_State *L) {;
    // lua: __cregistry[MODULE] = {}
    lua_createtable(L, 0, 2);
    lua_setfield(L, LUA_REGISTRYINDEX, MODULE_KEY);

    luaL_register(L, "autohook", funcs);
    return 1;
};

// ngl its nice being here but take me back to luajit please