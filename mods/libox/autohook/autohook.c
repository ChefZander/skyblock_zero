#include <luajit-2.1/lua.h>
#include <luajit-2.1/lauxlib.h>
#include <luajit-2.1/luajit.h>
// hey i'm learning! -- frog

//in ms, i love this #define stuffs
#define MAX_SBOX_TIME 10.0L
// like home
#define nil NULL

#include <stdio.h>
#include <time.h>

long double prev_time = 0;
long double get_time_ms() {
    // On Windows, clock_t is 32-bit, meaning after 24 days and 20 hours it
    // becomes UB. So uh... don't run your server for longer than that. - ACorp
    return ((long double)clock()) / CLOCKS_PER_SEC * 1000.0L;
}

int attempts = 0; // THIS is to avoid a "yield across C-call boundary" error
// this is like a weird "const" in javascript, i like it
#define max_attempts 10

static void hookf(lua_State *L, lua_Debug *ar) {
    if (get_time_ms() - prev_time > MAX_SBOX_TIME) {
        if (lua_isyieldable(L) || attempts >= max_attempts) {
            prev_time = get_time_ms();
            lua_sethook(L, nil, 0, 0); // the problem??
            lua_yield(L, 0);
        } else {
            ++attempts;
        }
    }
}

static int autohook(lua_State *L) {
    prev_time = get_time_ms();
    attempts = 0;
    lua_sethook(L, hookf, LUA_MASKCOUNT, 50);
    return 0;
}

static const luaL_Reg funcs [] = {
    {"autohook", autohook},
    {nil, nil}
};

int luaopen_autohook(lua_State *L) {;
    luaL_register(L, "autohook", funcs);
    return 1;
};

// ngl its nice being here but take me back to luajit please