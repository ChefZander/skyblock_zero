#include <lua.h>
#include <lauxlib.h>
#include <luajit.h>
#include <stdbool.h>
#include <stdlib.h>

// a bit of macros never hurt nobody
// also, it's safe to assume that most compilers handle , ##__VA_ARGS__ like GCC
#define MAX_VA_ARGS(a1,a2,a3,a4,a5,a6,a7,a8,a9,a10,a11,a12,a13,a14,a15,a16,a17,a18,...) a18
#define VA_COUNT(...) MAX_VA_ARGS(dummy, ##__VA_ARGS__, 16,15,14,13,12,11,10,9,8,7,6,5,4,3,2,1,0)

typedef const char* cstr;
typedef char* cstr_mut;
#define CSTR_COUNT(x) sizeof(x)-1

// like home
#define nil NULL

static bool string_eq(
    cstr restrict s1, size_t count1,
    cstr restrict s2, size_t count2) {

    if (count1 != count2) { return false; }
    for (size_t i = 0; i < count1; ++i) {
        if (s1[i] != s2[i]) { return false; }
    }
    return true;
}

static bool string_startswith(
    cstr restrict long_str, size_t long_count,
    cstr restrict short_str, size_t short_count) {

    if (long_count < short_count) { return false; }
    for (size_t i = 0; i < short_count; ++i) {
        if (long_str[i] != short_str[i]) { return false; }
    }
    return true;
}

#define LUA_CREGISTRY LUA_REGISTRYINDEX
#define LUA_GLOBALS LUA_GLOBALSINDEX

// indexes the stack, or a pseudo-index
typedef int lua_Idx;

// indexes a lua list/array/table, including the tables from pseudo-indices
typedef int lua_Subidx;

#define L_arg_expect_xx(idx, expect, got) luaL_argerror(L, (idx), \
    lua_pushfstring(L, "%s expected, got %s", (expect), (got)))
#define L_arg_expect_lx(idx, expect, got) luaL_argerror(L, (idx), \
    lua_pushfstring(L, expect " expected, got %s", (got)))
#define L_arg_expect_ll(idx, expect, got) luaL_argerror(L, (idx), expect "expected, got " got)
#define L_arg_expect_xa(idx, expect) luaL_argerror(L, (idx), \
    lua_pushfstring(L, "%s expected, got %s", (expect), luaL_typename(L, (idx))))
#define L_arg_expect_la(idx, expect) luaL_argerror(L, (idx), \
    lua_pushfstring(L, expect " expected, got %s", luaL_typename(L, (idx))))

#define L_carg_expect_xxx(narg, expect, got) \
    luaL_error(L, lua_pushfstring(L, "bad argument #%f to C function '%s' (%s expected, got %s)", (narg), __func__, (expect), (got)))
#define L_carg_expect_xll(narg, expect, got) \
    luaL_error(L, lua_pushfstring(L, "bad argument #%f to C function '%s' (" expect " expected, got " got ")", (narg), __func__))

// checks if the pointer is nil/NULL. raise error to Lua runtime
#define assert_ptr(p, narg) \
    if ((p) == nil) { L_carg_expect_xll(narg, "valid pointer", "nil/NULL"); }
// check nil AND non-empty
#define assert_str(p, narg) assert_ptr(p, narg); \
    if ((p)[0] == '\0') { L_carg_expect_xll(narg, "non-empty string", "empty string"); }

#define L_stack2ref() luaL_ref(L, LUA_CREGISTRY)
static bool lua_ref2stack(lua_State* L, const lua_Subidx ref) {
    if (ref == LUA_NOREF || ref == LUA_REFNIL) { return false; }
    lua_rawgeti(L, LUA_CREGISTRY, ref);
    luaL_unref(L, LUA_CREGISTRY, ref);
    return true;
}
#define L_ref2stack(ref) lua_ref2stack(L, ref)

static bool lua_is_container(lua_State *L, const lua_Idx idx) {
    return idx == LUA_CREGISTRY || idx == LUA_GLOBALS || lua_istable(L, idx);
}
#define L_assert_container(idx) \
    if (!lua_is_container(L, (idx))) { L_arg_expect_la(idx, "table or pseudo-index"); }

#define L_assert_number(idx) \
    if (!lua_isnumber(L, (idx))) { L_arg_expect_la(idx, "number"); }

#define L_assert_string(idx) \
    if (!lua_isstring(L, (idx))) { L_arg_expect_la(idx, "string"); }

/* ------------------------ deep getters and setters ------------------------ */

static bool lua_deepget_subi(lua_State *L, lua_Idx idx, size_t count, const lua_Subidx* subis) {
    L_assert_container(idx);
    assert_ptr(subis, 4);
    if (count < 1) {
        L_carg_expect_xll(3, "positive number of subidx", "bad number of subidx");
    }
    if (count == 1) {
        lua_rawgeti(L, idx, subis[0]);
        // waste of compute... bro just use rawgeti
        return false;
    }

    const lua_Idx reset = lua_gettop(L);
    lua_rawgeti(L, idx, subis[0]);
    for (size_t i = 1; i < count; ++i) {
        if (!lua_istable(L, -1)) {
            lua_settop(L, reset);
            return true;
        }
        lua_rawgeti(L, -1, subis[i]);
    }
    const lua_Idx got = L_stack2ref();
    lua_settop(L, reset);
    L_ref2stack(got);
    return false;
}
// lua: (push stack) = (table at idx)[subi1][subi2][subi3][...]
#define L_deepget_subi(idx, ...) \
    lua_deepget_subi(L, (idx), VA_COUNT(__VA_ARGS__), (lua_Subidx[]){ __VA_ARGS__ })

static bool lua_deepset_subi(lua_State *L, lua_Idx idx, bool fill_in, size_t count, const lua_Subidx* subis) {
    L_assert_container(idx);
    assert_ptr(subis, 4);
    if (count < 1) {
        L_carg_expect_xll(3, "positive number of subidx", "bad number of subidx");
    }
    if (count == 1) {
        lua_rawseti(L, idx, subis[0]);
        // waste of compute... bro just use rawseti
        return true;
    }

    bool filling_in = false;
    const lua_Idx value = L_stack2ref();
    const lua_Idx reset = lua_gettop(L);
    lua_rawgeti(L, idx, subis[0]);
    if (!lua_istable(L, -1)) {
        if (!(filling_in || (fill_in && lua_isnil(L, -1)))) {
            lua_settop(L, reset);
            return true;
        }
        filling_in = true;
        lua_pop(L, 1);
        lua_createtable(L, 0, 1);
        lua_pushvalue(L, -1);
        lua_rawseti(L, idx, subis[0]);
    }

    const size_t last = count - 1;
    for (size_t i = 1; i < last; ++i) {
        lua_rawgeti(L, -1, subis[i]);
        if (!lua_istable(L, -1)) {
            if (!(filling_in || (fill_in && lua_isnil(L, -1)))) {
                lua_settop(L, reset);
                return true;
            }
            filling_in = true;
            lua_pop(L, 1);
            lua_createtable(L, 0, 1);
            lua_pushvalue(L, -1);
            lua_rawseti(L, -2, subis[0]);
        }
    }
    L_ref2stack(value);
    lua_rawseti(L, -2, subis[last]);
    lua_settop(L, reset);
    return false;
}
// lua: (table at idx)[subi1][subi2][subi3][...] = (stack pop)
#define L_deepset_subi(idx, ...) \
    lua_deepset_subi(L, (idx), false, VA_COUNT(__VA_ARGS__), (lua_Subidx[]){ __VA_ARGS__ })
// lua: (table at idx)[subi1][subi2][subi3][...] = (stack pop)
// fills the subtable in if it's created yet. good for initializing table
#define L_deepset_fill_subi(idx, ...) \
    lua_deepset_subi(L, (idx), true, VA_COUNT(__VA_ARGS__), (lua_Subidx[]){ __VA_ARGS__ })
