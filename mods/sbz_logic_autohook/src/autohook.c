// frog here, i don't know how C works soo this will be a dumpster fire but i assume everything i write here will be faster than anything i could do with luajit
// the goal here would be to provide a function that 

#include <luajit-2.1/lua.h> // it took me WAY TOO LOONG to figure this crap out
#include <luajit-2.1/lauxlib.h>
#include <luajit-2.1/luajit.h>
// hey i'm learning!

#define autohook_max_time 10 //in ms, i love this #define stuffs
#define nil NULL // like home

#include <stdio.h>
#include <time.h>
long long get_time_ms(){
    return clock()*1000/CLOCKS_PER_SEC; // thanks chat gippity
}

long long autohook_time = 0;

static void hookf(lua_State *L, lua_Debug *ar){
    if ((get_time_ms() - autohook_time) >= autohook_max_time) {
        // lua_newtable(L); // { ["type"] = "timeout" }
        // lua_pushstring(L, "type");
        // lua_pushstring(L, "timeout");
        // lua_settable(L, -3);
        lua_sethook(L, nil, 0, 0);
        lua_yield(L, 0);
    }
}

static int autohook(lua_State *L){
    autohook_time = get_time_ms();
    lua_sethook(L, hookf, LUA_MASKCOUNT, 50);
    return 0;
};

static const luaL_Reg funcs [] = {
    {"autohook", autohook},
    {nil, nil}
};

int luaopen_autohook(lua_State *L) {;
    luaL_register(L, "autohook", funcs);
    return 1;
};

// ngl its nice being here but take me back to luajit please