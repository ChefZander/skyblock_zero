# Autohook
Autohook is a feature that allows coroutine sandboxes to automatically yield once they've reached their limits, controlled by `def.time_limit` in coroutine sandbox spec. The way this works is by hooking to the Lua runtime through its C API in order to bypass `yield across C-call boundary` limitation by yielding in C instead of Lua. Because of this, the C module is a bit system-dependent and may require knowledge in C and the general build process to troubleshoot it.

To enable this feature, game and mod developers need to do a couple of things:

1. Enable (`def.autohook = true`) when creating your sandbox. It's disabled by default.
2. Ask players to put libox in trusted mods list. An error message will be logged if libox found the C module but encountered problems loading it.
3. Ask players to compile the `libautohook.so/.dll` linking with the same LuaJIT library used with Luanti. Players, please read further below on how to compile it.

If any of the conditions needed for autohook to work is unfulfilled, autohook is NOT available. As such, libox will safely fallback to regular coroutine sandbox behaviour where manual `yield()` is required. Check `libox.has_autohook`.

# C Hook behaviour
The autohook uses `def.hook_time` in a normal way to set the C hook, being instruction counts needed to trigger the hook. The default autohook checks if the sandbox has elapsed `def.time_limit` and yields it. It is the auto-yielding form of `libox.coroutine.get_default_hook(def.time_limit or libox.default_time_limit)`.

If `def.in_hook` is a function, then the C hook will call it instead of its default behaviour. Whenever `def.in_hook` throws an error, the C hook will yield. To kill the sandbox from `def.in_hook`, start your error message with `SANDBOX KILL`. This means that by default, `def.in_hook` unaware of the kill command will always yield. Please update `def.in_hook` accordingly when you enable autohook.

# Compile the autohook C module
## Compile: Linux/Unix-like systems
1. Get [xmake](https://xmake.io/) either through its installer script or through your package manager.
2. Install LuaJIT. You may install LuaJIT using your system's package manager, or with [xrepo](https://xrepo.xmake.io/).
3. Go to this directory: `libox/autohook/` (the directory where this file is in)
4. `xmake config -c && xmake`
   - `--Iluajit=...` is an `xmake config` option specifying where to find LuaJIT header files
   - `--Lluajit=...` is an `xmake config` option specifying where to find LuaJIT libraries
5. Done! You can clean up by deleting these directories and files: `rm -r .xmake build`

## Compile: Windows
The official release of luanti on Windows is cross-compiled from [Ubuntu LTS 22.04](https://releases.ubuntu.com/jammy/) through the [LLVM-MinGW toolchain with Clang under Window's Universal C Runtime](https://github.com/mstorsjo/llvm-mingw/) linked with [pre-compiled libraries by the Luanti team](https://github.com/luanti-org/luanti/blob/5.12.0/util/buildbot/buildwin64.sh#31). This makes it difficult and hard to translate the CMake build scripts for autohook's C module. Currently, no one has yet to successfully build a working autohook DLL with the same approach, hence why `libautohook.dll` isn't vendored directly for Windows. A PRs to fix this is welcome. Please compare with [prior attempt by Acorp/corpserot](https://github.com/corpserot/luanti-win-clang64).

For now, we'll be going with a simpler setup on Windows natively. You will build luanti from scratch and playing on that build instead of the official release. This is a bit complicated but should be easy to follow. There's a shortcut: Use (and trust) [ACorp's/corpserot's luanti build](https://github.com/corpserot/luanti-win-clang64) which includes a pre-built `libautohook.dll`. Of course, it's always more secure to compile `libautohook.dll` on your own.

1. Download the source code for the Luanti version you want to play on. For example, click the **Source code** (zip or tar.gz) asset in the [github release page for version 5.12.0](https://github.com/luanti-org/luanti/releases/tag/5.12.0). Extract it.

2. Follow instructions in the official documentation for engine devs to [compile Luanti on Windows using MSYS2 + Clang64 environment](https://docs.luanti.org/for-engine-devs/compiling/windows/). Don't use the MSVC + vcpkg approach, it's not really well-maintained as other methods. (e.g. using a really, really years old LuaJIT)

   **WARNING**: the typical size of the tools installed is ~2GB.

3. With luanti compiled, it's recommended you bundle your DLLs since right now it will only run in the Clang64 environment. Follow the [instructions to bundle the DLLs](https://docs.luanti.org/for-engine-devs/compiling/windows/#bundling-dlls) in the same document. You'll be using [rollerozxa's bundledll bash script](https://github.com/rollerozxa/msys2-bundledlls)

4. Install xmake (and LuaJIT if you haven't): `pacman -Syu mingw-w64-clang-x86_64-luajit mingw-w64-clang-x86_64-xmake`.

5. Build the C module by running `xmake config --toolchain=clang -c && xmake`. For more advanced needs/wants, here are extra options you can use:
   - `--Iluajit=...` is an `xmake config` option specifying where to find LuaJIT header files
   - `--Lluajit=...` is an `xmake config` option specifying where to find LuaJIT libraries

6. Done! You may even uninstall MSYS2 if you like, but I suggest keeping it for future Luanti versions. You can also clean up by deleting these directories and files: `rm -r .xmake build*`

# For developers
## C module versioning
`module-version.txt` tracks the current C source hash, so always re-build the C module
for any change. OR if you can't (or too lazy) do that, just do something like:

```sh
cat autohook.c utils.c | sha256sum | awk '{ print $1 }' >module-version.txt
```

or on powershell:

```pwsh
pwsh hash.ps1 autohook.c utils.c > module-version.txt
```

## Debug builds
On release builds, the C module disables its own logging capabilities. Logging
occurs through `core.log`, bypassing the sandbox. Logging capabilities is
available in debug builds. So, if you want to log things from the autohook, you
should create a debug build:

```sh
xmake config -m debug -c && xmake
```

## All diagnostics when building
By default, xmake cuts off the diagnostics to a certain number of lines. To see
all of them:

```sh
xmake config -c && xmake -D
```

## Verbose xmake configure and building
In order to debug and inspect what might go wrong in the xmake configuration and
build steps, you can use flags like so:

```sh
xmake config -c -vD && xmake -vD
```

It is very noisy, so perhaps you should each step one-by-one.

## Obtaining `compile_commands.json`
Pretty much all C/C++ LSPs/IDEs make use of this in order to know all the
required C source code, headers, library, etc. needed to build your target. It's
how any build system can "communicate" with your LSP. You can generate one by running:

```sh
xmake project -k compile_commands
```