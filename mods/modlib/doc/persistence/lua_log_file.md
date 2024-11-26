# Lua Log Files

A data log file based on Lua statements. High performance. Example from `test.lua`:

```lua
local logfile = persistence.lua_log_file.new(mod.get_resource"logfile.test.lua", {})
logfile:init()
logfile.root = {}
logfile:rewrite()
logfile:set_root({a = 1}, {b = 2, c = 3})
logfile:close()
logfile:init()
assert(table.equals(logfile.root, {[{a = 1}] = {b = 2, c = 3}}))
```

Both strings and tables are stored in a reference table. Unused strings won't be garbage collected as Lua doesn't allow marking them as weak references.
This means that setting lots of temporary strings will waste memory until you call `:rewrite()` on the log file. An alternative is to set the third parameter, `reference_strings`, to `false` (default value is `true`):

```lua
persistence.lua_log_file.new(mod.get_resource"logfile.test.lua", {}, false)
```

This will prevent strings from being referenced, possibly bloating file size, but saving memory.
