# The libox environment
- mods *will* extend this, there is nothing really useful that you can do with this if not extended

# Globals (*)
- assert = unchanged
- error = unchanged
- collectgarbage(arg) = the only valid arg is `count`, may be changed idk
- ipairs = unchanged
- pairs = unchanged
- next = unchanged
- select = unchanged
- unpack = basically unchanged...
- pcall = libox.safe.pcall => pcall doesnt catch timeout errors
- xpcall = libox.safe.xpcall => xpcall doesnt catch timeout errors
- tonumber = unchanged
- tostring = unchanged
- type = unchanged
- loadstring(code) = libox.safe.get_loadstring(env) => does the lame sandboxing stuff like limiting environment, turning off JIT optimizations for the function, also you can't provide a chunkname
- _G = points back to the sandbox environment
- traceback = libox.traceback

# String library (string.* or (""):* )

- byte = unchanged
- char = unchanged
- dump = unchanged
- find = forced to not match patterns
- format = unchanged,
- len = unchanged,
- lower = unchanged,
- rep = changed to not allow creating GIGANTIC strings,
- reverse = unchanged,
- sub = unchanged,
- upper = unchanged,
- trim = unchanged, from minetest
- split = forced to not match patterns, from minetest

# Table library (table.*)

- insert = unchanged
- maxn = unchanged
- remove = unchanged
- sort = unchanged
- indexof = unchanged, from minetest
- copy = unchanged, from minetest
- insert_all = unchanged, from minetest
- key_value_swap = unchanged, from minetest
- shuffle = unchanged, from minetest
- move = unchanged, LUAJIT ONLY
- concat = unchanged

# Math library (math.*)

- `abs`, `acos`, `asin`, `atan`, `atan2`, `ceil`, `cos`, `cosh`, `deg`, `exp`, `floor`,
- `fmod`, `frexp`, `huge`, `ldexp`, `log`, `log10`, `max`, `min`, `modf`, `pi`, `pow`,
- `rad`, `random`, `sin`, `sinh`, `sqrt`, `tan`, `tanh`,

-  `hypot`, `sign`, `factorial`, `round`  - from minetest

# Bit library (bit.*)
- Copied, unchanged

# Vector library (vector.*)
- Copied, removed `vector.metatable`

# os library (os.*)

- clock = unchanged,
- datetable = from luacontroller, a date table...,
- difftime = uncahnged,
- time = unchanged,
- date = mooncontroller's safe_date, made to prevent segfaults,


# minetest library (minetest.*)

- formspec_escape = unchanged*,
- explode_table_event = unchanged*,
- explode_textlist_event = unchanged*,
- explode_scrollbar_event = unchanged*,
- inventorycube = unchanged*,
- urlencode = unchanged*,
- rgba = unchanged*,
- encode_base64 = unchanged*,
- decode_base64 = unchanged*,
- get_us_time = unchanged*,

\* All of theese functions fail when you give them gigantic string inputs

# pattern library (pat.*)
- Pure lua implementations of functions `find`, `match`, `gmatch`, and they support patterns
# extra environment stuffs (*) mostly from minetest
- `dump` `dump2` = unchanged
- `PcgRandom` = you are given an interface, where `rand_normal_dist` has limited amount of tries and you call the functions by doing `my_random.func` not `my_random:func`
- `PerlinNoise` = Changed to give an interface, call it like `my_perlin.func` not `my_perlin:func`, also the types in the noiseparams are strict, if it detects a type mismatch it will give you 2 values: `false` and a string, that string being the faulty element (its shallow)

# notes to mod devs
- Don't be afraid to use userdata, but be afraid where it can get to, it should not be serialized, never.