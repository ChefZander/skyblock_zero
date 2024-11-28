# ![Logo](logo.svg) Modding Library (`modlib`)

Multipurpose Minetest Modding Library

## At a glance

No dependencies. Licensed under the MIT License. Written by Lars Mueller aka LMD or appguru(eu). Requires Lua 5.1 / LuaJIT.

### Acknowledgement

* [luk3yx](https://github.com/luk3yx): Various suggestions, bug reports and fixes
* [grorp](https://github.com/grorp) (Gregor Parzefall): [Bug reports & proposed fixes for node box code](https://github.com/appgurueu/modlib/pull/8)
* [NobWow](https://github.com/NobWow/): [Another bugfix](https://github.com/appgurueu/modlib/pull/7)

### Principles

* Game-agnostic: Modlib aims to provide nothing game-specific;
* Minimal invasiveness: Modlib should not disrupt other mods;
  even at the expense of syntactic sugar, changes to the global
  environment - apart from the addition of the modlib scope - are forbidden
* Architecture: Modlib is organized hierarchically
* Performance: Modlib tries to not compromise performance for convenience; modlib loads lazily

## Tests

The tests are located in a different repo, [`modlib_test`](https://github.com/appgurueu/modlib_test), as they are quite heavy due to testing the PNG reader using PngSuite. Reading the tests for examples of API usage is recommended.

## API

(Incomplete) documentation resides in the `doc` folder; you'll have to dive into the code for everything else.

The mod namespace is `modlib`, containing all modules which in turn contain variables & functions.

Modules are lazily loaded by indexing the `modlib` table. Do `_ = modlib.<module>` to avoid file load spikes at run time.

Localizing modules (`local <module> = modlib.<module>`) is recommended.
