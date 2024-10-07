# Api docs

## Disclaimers
- ***DO NOT EVER CALL FUNCTIONS FROM THE ENVIRONMENT (once the environment is defined) AND DO NOT CALL ANY FUNCTIONS RETURNED BY THE SANDBOX*** that will just bypass the debug hook and allow someone to `repeat until false` and *stop* the server that way
- anything coming out of the sandbox should *not* be called, and be checked for every single detail (like you are writing a digiline device)

## Definitions
- microsecond: milisecond * 1000
- hook: a lua function that runs every `n` instructions
- environment: The values that the sandboxed code can work with
- string sandbox: when the `__index` field of a string's metatable gets replaced with the sandboxes `string` (basically, a thing to prevent the sandbox from using unsafe string functions through `"":unsafe_function()`) 

## Differences from luac-like sandboxing
- The basic environment is much more permissive (but still maintains safety)
- You get limited not by instructions (luacontroller calls them events for some reason??? even if it calls *triggers* events too??? this is so dumb) but by time *by default*
- You get a traceback *by default*

## Utilities
`libox.get_default_hook(max_time)` - Get the hook function that will terminate the program in `max_time` microseconds

`libox.traceback(...)` - a function that gives a friendlier traceback, now safe to expose to sandbox

`msg, cost = libox.digiline_sanitize(input, allow_functions, wrap)` - use this instead of your own clean_and_weigh_digiline_message implementation, `wrap` is a function that accepts a function and returns another one, this gets called on user functions

`libox.sandbox_lib_f(f, ...)` - use this if you want to escape the string sandbox (do this if you are not 100% sure that your code is free of `"":this_stuff()`) **don't use this on functions that run user 

`libox.disabled = true/false` - use when you want to disable libox (e.g. when using jitprofiler) 

**functions**

`libox.type_check(thing, check)`
- `thing` = untrusted data
- `check` a function or a table with the following format:
```lua
    {
        something = function(value) return true end,
        a_table = {
            other_key = libox.type("number"),
            x = libox.type_vector, -- this is how type_vector is supposed to be used, don't do libox.type_vector() in this case
        }
    }
```
- runs a series of checks on the `thing` using the check table
- if the `thing` table contains an extra property, not defined in the `check` table, it will return false too
- if the `thing` table lacks a property in the `check` table, it will return false
- returns a boolean, and a string (success, faulty element)

`libox.type(type)` - returns a function that checks a type
- for example, when given `"number"`, it returns a function: `function(x) return type(x) == "number" end`

`libox.type_vector(x)` - is a function that checks if `x` is a vector, use `vector.check` if you want to also check the vector metatable

`libox.shorten_path(path)` - use this to shorten a path, it will convert `/home/user/blabla/.minetest/modname/x.lua` into `modname:x.lua` - if the `dbg` mod is avaliable, it will simply use `dbg.shorten_path`
## Environment
`libox.create_basic_environment()` - get a basic secure environment already set up for you

`libox.supply_additional_environment(env)` - a function that lets other mods extend the environment, gets called after environment creation, by default is `function(...) return ... end`

`libox.safe.*` - safe functions/classes, used in libox.create_basic_environment, used internally, you shouldn't modify this table

## "Normal" sandbox

`libox.normal_sandbox(def)`
- A sandbox that executes lua code securely based on parameters in `def` (table)
### The def table
`def.code` - the code...  
`def.env` - The environment of the function  
`def.error_handler` - A function inside the `xpcall`, by default `libox.traceback`  
`def.in_hook` - The hook function, by default `libox.get_default_hook(def.max_time)`  
`def.max_time` - Maximum allowed execution time, in microseconds, only used if `def.in_hook` was not defined  
`def.hook_time` - The hook function will execute every `def.hook_time` instructions, by default 50
`def.function_wrap` - transforms a function, by default `function(f) return f end`

## "Coroutine" sandbox
- Optionally requires trusted environment for weighing local variables and upvalues
    - without it someone can overfill your memory, but libox has protections against that *somewhat, though i don't think it's a good idea to rely on them*

### What is it?
A sandbox that allows the user to **yield** => temporarily stop execution; then be able to resume from that point


### garbage collection
`libox.coroutine.settings`
- memory_treshold: in gigabytes, if lua's memory reaches above this limit, the hook will error, the user is meant to configure this to their needs *also this is what i meant about those overfill protections, not exactly reliable*
- gc settings:
    - time_treshold: if a sandbox has been untouched for this long, collect it, in seconds
    - number_of_sandboxes: the garbage collection will trigger if the number of stored sandboxes is above this limit
    - auto: if true, garbage collection will automatically activate, i don't think this is nessesary if you have trusted the libox mod 
    - interval: in seconds, when to trigger the garbage collection

All of theese are configurable by the user

`libox.coroutine.garbage_collect()` - trigger the garbage collection

### the docs
- When libox is a trusted mod, it exposes `debug.getlocal` and `debug.getupvalue`

`libox.coroutine.active_sandboxes` - A table containing all the active sandboxes, where the key is the sandbox's id, and the value is the sandbox definition and thread

`libox.coroutine.create_sandbox(def)`
- returns an ID to the sandbox (can be used in libox.coroutine.* functions or just be able to see the sandbox yourself with `libox.coroutine.active_sandboxes[id]`)

- `def.ID` - A custom id, by default random text
- `def.code` - the code
- `def.is_garbage_collected` - if this sandbox should be garbage collected, by default true
- `def.env` - the environment, by default a blank table
- `def.in_hook` - the function that runs in the hook, by default `libox.coroutine.get_default_hook(def.time_limit or 3000)`, see `libox.coroutine.get_default_hook` on how to use, it is different to how normal sandbox handles it
- `def.time_limit` - used if debug.in_hook is not avaliable, by default 3000
- `last_ran` - not set by you, but is the last time the sandbox was ran, used for garbage collection
- `def.hook_time` - The hook function will execute every `def.hook_time` instructions, by default 10
- `def.size_limit` - in *bytes*, the size limit of the sandbox, if trusted then upvalues and local variables are counted in too, by default 5 *megabytes*, aka `1024*1024*5` bytes
- `def.function_wrap` - transforms a function, by default `function(f) return f end`

`libox.coroutine.get_default_hook(max_time)` - a function that returns a function that returns a function.... ok but no what it really is is that it just yeah...

`libox.coroutine.run_sandbox(ID, value_passed)`
- `value_passed` - the value passed to the coroutine.resume function, so that in the sandbox it could: `local vals = coroutine.yield("blabla")`
- Returns ok, errmsg_or_value (the `"blabla"` in `coroutine.yield("blabla")`)

`libox.coroutine.size_check(env, lim, thread)`
- `env` - environment of the thread
- `lim` - the limit
- `thread` - the thread
- returns if its size (computed using `get_size`) is less than the lim
- used internally

`libox.coroutine.get_size(env, seen, thread, recursed)` 
- get the size in bytes of a thread, used by size_check
- normal usage: `libox.coroutine.get_size(env, {}, thread, false)`

`libox.coroutine.is_sandbox_dead(id)`
- detects if the sandbox is dead


# Async
- everything else other than the coroutine sandbox is avaliable in both sync and async environments

coroutine sandbox is not avaliable in async because 

1) I cannot import the debug.getlocal and debug.getupvalue functions into the async environment
2) I cannot import a coroutine in the async environment

# Examples
- [libox controller](https://github.com/TheEt1234/libox_controller)

# Todos
- proper examples
- ~~Maybe automatic yielding? depends on how possible that is~~ it's not really...