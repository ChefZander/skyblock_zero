# Luanti LuaLS Definitions
- **Status:** DRAFT 2 WIP (see [this issue tracker](https://github.com/corpserot/luanti_lsp_definitions/issues/6))
- **Luanti commit coverage:** `421835a3` (`5.14.X`)
- **Target projects when testing:**
  - [Minetest Game (MTG)](https://github.com/luanti-org/minetest_game) commit `0ebe46e4`\
    With a custom LuaLS config (To be published).
- **Scheduled breaking changes**: Anytime, still in development.
<!--
  - This follows Luanti's minor releases, meaning we will schedule a breaking release when the target minor release is published.
  - Breaking changes matters for writing annotations on top of library definition. Otherwise, it's inconsequential meaning you don't have to care about this if you merely want type checking.
  - All changes, breaking or otherwise, are recorded in `CHANGELOG.md`
-->

# Why to use
This enables a lua language server to operate with Luanti APIs and types. This in turn allows for IDE-like capabilities including but not limited to:
- Typed annotation system called LuaCATS a la JSDoc annotations. Has definition files like Typescript `.d.ts` files.
- Diagnostics through semantic analysis, replacing [luacheck](https://github.com/mpeterv/luacheck) completely
- Autocompletion and hover information for API symbols, types, fields and more.

# How to use
- Install [Lua Language Server, LuaLS](https://luals.github.io/) or [EmmyLua](https://github.com/EmmyLuaLs/emmylua-analyzer-rust) for your favourite text editor. Make sure it works first! ^v^
  - For VSCode users, you get first-class support with extra features enabled. So, please visit relevant first-party guides.
  - For Neovim users, you have many ways to configure your language server. As of 2025-08-25 there isn't any (easy and simple) setup that interactively asks you whether to enable an addon for a workspace/project.
- Manual setup for single library definitions (Recommended for one-off uses):
  - Git clone this repository.
  - In your personal project config, add entries below. Optionally, manually inject whatever is inside `config.json` > `"settings"` into your LuaLS config. That entry contains recommended settings for Luanti game and mod development.
    ```json
    {
      "workspace.library": ["/path/to/luanti-lsp-definitions/library"],
      // e.g. selecting this specifically from "settings.Lua" entry in config.json:
      "diagnostics.disable": [
        "lowercase-global"
      ],
    }
    ```
- Manual setup for collection of library definitions (Recommended for multiple library definition uses):
  - Git clone this repository into this file structure: `luals_addons/luanti-lsp-definitions`. This allows you to add more addons under the same directory, e.g. `luals_addons/busted` for the testing suite.
  - in your config, add entries below. The `Apply` value allows the LSP to read library definitions without asking, provided you matched the criteria to enable it.
    ```json
    {
      "workspace.checkThirdParty": "Apply",
      "workspace.userThirdParty": ["/path/to/luals_addons"]
    }
    ```
- Automatic setup: WIP as this project is still in development.

## Using this as a Luanti game/mod developer
After following the above instructions, in the context of annotations, you are left with two types of dependencies for your game/mod: Annotated dependencies and Un-annotated dependencies

- *Annotated dependencies* and *Un-annotated dependencies* as-is:
  - Game developers simply just include them in their project without any further additions.

  - Mod developers should put them inside a `.gitignore`d directory where you can safely fetch/clone your dependencies without distributing them. `.git/info/exclude` is an alternative choice.

  - You may notice errors due to how language server configurations are applied project-wide instead of scoped to the dependencies. Unfortunately, this approach means that you need to apply the same project-wide diagnostics configuration.
    - Please do not rely on setting project-wide diagnostics in your game/mod. Instead use file-scoped or line diagnostics directives.\
    e.g `---@diagnostic disable-next-line: lowercase-global`

- *Un-annotated dependencies* and you wish to annotate it:
  - There's two ways of approaching this:
    1. (*Simple, recommended*) Annotate the dependency's code.
    2. (*Complicated, niche needs*) Annotate a separate library definition. This is the approach used by this Luanti library definition.
  - There are benefits to either or both approaches, however the usual approach is to annotate the dependency's code.


### Namespace reservation
If you use this library definition, you acknowledge that it reserves the following type namespaces
- `_.*`
- `core.*`
- `corelib.*`
- vector "primitive" types.

Helper types are listed below. More may be added.
- `OneOrMany`
- `SparseList`

It's recommended that you own annotations sit inside a namespace i.e. `<mod or game name>.MyType`

# File Structure
- `.luarc.json` is the default LuaLS project configuration. You're expected to override it with your editor's personal project configuration.
- (NYI) `.emmyrc.json` is the default EmmyLua project configuration. You're expected to override it with your editor's personal project configuration.
- `config.json` is this library definition's configuration file. The `"settings"` portion should be minimal to encourage the developer to decide their own language server configurations.
- `MAINTAINENCE.md` is the guide for maintaining this project. Please read it if you would like to contribute.
- `library/` has definition files related to engine API. There is a short description at the top of each file. The contents are arranged following `lua_api.md`
  - `library/classes/` has definition files related to classes.
  - `library/core/` has definition files related to the `core` namespace.
  - `library/vector` has definition files related to vectors
  - `library/defs/` has definition files catching the rest of the `lua_api.md` contents.

# Questions and Answers
## If i use this, do i have to use a LGPL-compliant license for my game/mod?
***Disclaimer: I am not a lawyer, and nothing in this material should be taken as legal advice. It may even be inaccurate. No attorney–client relationship is created by your use of this information provided for informative purposes. You should not act or rely on any information provided here without seeking the advice of a qualified attorney licensed in your jurisdiction. I disclaim all liability for actions you take or fail to take based on any content provided.***

You may skip this if you're well-informed about copyleft software licenses.

The answer is probably not... well, it depends. You can embed or use this library definition alongside your game/mod. However, please don't copy-paste contents of this library definition straight into your code. Particularly, the documentation text itself has to be treated a bit more carefully.

**Example:** Person A wrote a mod with a permissive license like MIT or 0BSD. If person A carelessly include content of this library definition into the mod's `init.lua`, then a portion of that file is at risk of being subjected to LGPL terms due to documentation text.

If you would like to modify or derive contents of this library definition, it's recommended to treat your derived work like a separate module from your game/mod. It could be simply a separate directory or file.

**Example:** Person A, being careful this time, copy-pastes parts of this library definition into a separate definition file `.defs.lua`. This would help isolate where LGPL terms apply.

## How do i extend types?
You can extend existing classes like so:
```lua
---@class core.ItemDef
---@field _mymod_rarity integer

--- Sometimes, you'll have to work with internal classes
---@class _.ObjectProperties.__base
---@field _mymod_power integer
```

However, it's expected that you need delve into this project's definitions as you're likely to extend the wrong type or an alias (cannot be extended using this technique).

Be on the lookout for scheduled breaking changes.

## I think this primitive type should get a name, like how `core.Formspec` is just a `string`!
Please open an issue for discusssion. In particular, you're encouraged to read about [*Nominal types*](https://github.com/corpserot/luanti_lsp_definitions/blob/master/MAINTENANCE.md#nominal-types) to help you justify why it should get a name. You should also search in this repo's issues if it's already discussed or not.

## Why not contribute to [`luanti-lls-definitions by @fgaz`](https://codeberg.org/fgaz/luanti-lls-definitions)?
For context, that is the existing solution before this library definition was conceived.

(by @frog) So i tried to use luanti-lls-definitions but those were really incomplete, and i didn't feel like contributing back to them\
And i felt like it would be easier to start from scratch than to attempt to complete them.

(by @corpserot) Well, there's a couple of reasons:
1. first and foremost that project uses an unreliable method to extract information from `lua_api.md` using TCL (seriously??)
2. @fgaz is very inactive in updating the definition files (check commits since project inception). It's very incomplete.
3. It uses EUPL license, which overcomplicates matters as it resembles closer to AGPLv3.0 than LGPLv2.1. Yet, it won't deter people that are already set on violating FOSS licenses. We don't use any definitions from that project, obviously.
4. I don't think @fgaz actually uses the definitions themself (dogfooding).

## Why not contribute to [luanti-api by @archie](https://git.minetest.land/archie/luanti-api/)?
See this issue: [luanti-api#21](https://git.minetest.land/archie/luanti-api/issues/21)