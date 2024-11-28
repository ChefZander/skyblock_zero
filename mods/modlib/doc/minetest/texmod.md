# Texture Modifiers

## Specification

Refer to the following "specifications", in this order of precedence:

1. [Minetest Docs](https://github.com/minetest/minetest_docs/blob/master/doc/texture_modifiers.adoc)
2. [Minetest Lua API](https://github.com/minetest/minetest/blob/master/doc/lua_api.txt), section "texture modifiers"
3. [Minetest Sources](https://github.com/minetest/minetest/blob/master/src/client/tile.cpp)

## Implementation

### Constructors ("DSL")

Constructors are kept close to the original forms and perform basic validation. Additionally, texture modifiers can directly be created using `texmod{type = "...", ...}`, bypassing the checks.

### Writing

The naive way to implement string building would be to have a
`tostring` function recursively `tostring`ing the sub-modifiers of the current modifier;
each writer would only need a stream (often passed in the form of a `write` function).

The problem with this is that applying escaping quickly makes this run in quadratic time.

A more efficient approach passes the escaping along with the `write` function. Thus a "writer" object `w` encapsulating this state is passed around.

The writer won't necessarily produce the *shortest* or most readable texture modifier possible; for example, colors will be converted to hexadecimal representation, and texture modifiers with optional parameters may have the default values be written.
You should not rely on the writer to produce any particular of the various valid outputs.

### Reading

**The reader does not attempt to precisely match the behavior of Minetest's shotgun "parser".** It *may* be more strict in some instances, rejecting insane constructs Minetest's parser allows.
It *may* however sometimes also be more lenient (though I haven't encountered an instance of this yet), accepting sane constructs which Minetest's parser rejects due to shortcomings in its implementation.

The parser is written *to spec*, in the given order of precedence.
If a documented construct is not working, that's a bug. If a construct which is incorrect according to the docs is accepted, that's a bug too.
Compatibility with Minetest's parser for all reasonable inputs is greatly valued. If an invalid input is notably used in the wild (or it is reasonable that it may occur in the wild) and supported by Minetest, this parser ought to support it too.

Recursive descent parsing is complicated by the two forms of escaping texture modifiers support: Reading each character needs to handle escaping. The current depth and whether the parser is inside an inventorycube need to be saved in state variables. These could be passed on the stack, but it's more comfortable (and possibly more efficient) to just share them across all functions and restore them after leaving an inventorycube / moving to a lower level.
