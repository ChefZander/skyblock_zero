#include <lua.h>
#include <lauxlib.h>
#include <luajit.h>
#include <stdio.h>
#include <time.h>
#include "autohook.h"

// module-version.txt tracks the current autohook.c hash, so always re-build the C module
// for any change. OR if you can't (or too lazy) do that, just do something like:
// sha256sum autohook.c | awk '{ print $1 }' >module-version.txt

// like home
#define nil NULL

#define LUA_POSITIVE(var, check, narg) \
    var = check(L, narg); \
    if (var < 0) return luaL_error(L, "argument must be a positive integer")


static double prev_time = 0;
static double get_time_ms() {
    // On Windows, clock_t is 32-bit, meaning after 24 days and 20 hours it
    // becomes UB. So uh... don't run your server for longer than that. - ACorp
    return ((double)clock()) / CLOCKS_PER_SEC * 1000.0L;
}

static double time_limit = 0;
static int attempts = 0; // THIS is to avoid a "yield across C-call boundary" error
#define MAX_ATTEMPTS 10

static void hookf(lua_State *L, lua_Debug *ar) {
    // TODO: find a way for this hook to detect whether it's inside a libox coroutine sandbox or not.
    if (get_time_ms() - prev_time > time_limit) {
        if (lua_isyieldable(L) || attempts >= MAX_ATTEMPTS) {
            prev_time = get_time_ms();
            lua_sethook(L, nil, 0, 0); // the problem??
            lua_yield(L, 0);
        } else {
            ++attempts;
        }
    }
}

/// autohook(int hook_time, double time_limit)
/// hook_time: same as in libox.coroutine.create_sandbox. Instructions per hook trigger
/// time_limit: same as in libox.coroutine.create_sandbox, but in ms.
///     Allowed execution time limit for the coroutine sandbox in milliseconds(!)
static int autohook(lua_State *L) {
    int n = lua_gettop(L);
    if (n != 2) {
        return luaL_error(L, "attach autohook() takes exactly 2 argument");
    }

    lua_Integer hook_time;
    LUA_POSITIVE(hook_time, luaL_checkinteger, 1);
    LUA_POSITIVE(time_limit, luaL_checknumber, 2);

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
    luaL_register(L, "autohook", funcs);
    return 1;
};

// ngl its nice being here but take me back to luajit please