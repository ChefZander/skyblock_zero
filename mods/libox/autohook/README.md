# Autohook
Autohook is a work-in-progress experimental feature that allows coroutine sandboxes to automatically yield once they've reached their limits. Currently, the autohook limits are hardcoded in C and that may change. The way this works is by hooking to the Lua runtime through its C API in order to bypass `yield across C-call boundary` limitation by yielding in C instead of Lua. Because of this, the C module is a bit system-dependent and may require knowledge in C and the general build process to troubleshoot it.

To enable this feature, you (game/mod dev) need to do a couple of things:

1. Enable (`def.autohook = true`) when creating your sandbox. It's disabled by default.
2. Ask players to put libox in trusted mods list.
3. (Optional) Ask players to compile the `libautohook.so/.dll` linking with their own libraries (particularly LuaJIT). Players suffering from problems may benefit from this.
4. (Windows players) you need to build Luanti on your own system, then build the `libautohook.dll` linking against the same LuaJIT library using the same C runtime and toolchain. Read below for instructions.

If any of the conditions needed for autohook to work is unfulfilled, the coroutine sandbox will not automatically yield. Effectively, it's like it's disabled. You'll see a warning in the logs if this is the case.

## Compile: Linux/Unix-like systems
1. Get [xmake](https://xmake.io/) either through its installer script or through your package manager.
2. Install LuaJIT. If it's not in your system paths, you can supply its path through `--luajit-root=/path/to/luajit-root`.
   - You may install LuaJIT using your system's package manager, or with [xrepo](https://xrepo.xmake.io/).
   - The C source file expects this header files layout: `<luajit-root>/include/luajit-2.1/<headers>`
   - The Build system expects this library layout: `<luajit-root>/lib/<static LuaJIT library>`
3. Go to this directory: `libox/autohook/` (the directory where this file is in)
4. `xmake config -c && xmake`
5. Done! You can clean up by deleting these directories and files: `rm -r .xmake build libautohook.so.tmp*`

## Compile: Windows
The official release of luanti on Windows (as of v5.12.0) is cross-compiled from [Ubuntu LTS 22.04](https://releases.ubuntu.com/jammy/) through the [LLVM-MinGW toolchain with Clang](https://github.com/mstorsjo/llvm-mingw/) and [pre-compiled libraries (e.g. LuaJIT) by the Luanti team](https://github.com/luanti-org/luanti/blob/5.12.0/util/buildbot/buildwin64.sh#31). This makes it difficult and hard to translate CMake build scripts for autohook's C module. Currently, no one has yet to successfully build a working autohook DLL with the same approach, hence why `libautohook.dll` isn't fully safe to use with the official release.

For now, we'll be going with a simpler setup on Windows natively. You will build luanti from scratch and playing on that build instead of the official release. This is a bit complicated. There's a shortcut: you need to use (and trust) [ACorp's/corpserot's luanti build](https://github.com/corpserot/luanti-win-clang64) as the `libautohook.dll` in libox is compatible with that build. Of course, it's always more secure to compile `libautohook.dll` on your own.

1. Download the source code for the Luanti version you want to play on. For example, click the **Source code** (zip or tar.gz) asset in the [github release page for version 5.12.0](https://github.com/luanti-org/luanti/releases/tag/5.12.0). Extract it.

2. Follow instructions in the official documentation for engine devs to [compile Luanti on Windows using MSYS2 + Clang64 environment](https://docs.luanti.org/for-engine-devs/compiling/windows/). Don't use the MSVC + vcpkg one, it's not really well-maintained as other methods.

   **WARNING**: the typical size of the tools installed is ~2GB.

3. With luanti compiled, it's recommended you bundle your DLLs since right now it will only run in the Clang64 environment. Follow the [instructions to bundle the DLLs](https://docs.luanti.org/for-engine-devs/compiling/windows/#bundling-dlls) in the same document. You'll be using [rollerozxa's bundledll bash script](https://github.com/rollerozxa/msys2-bundledlls)

4. Now, we are ready to compile the autohook C module. First, install `xmake` by running `pacman -Syu mingw-w64-clang-x86_64-xmake`. Afterwards, build the C module by running `xmake config --toolchain=clang -c && xmake`.

5. Done! You may even uninstall MSYS2 if you like, but I suggest keeping it for future luanti versions. You can also clean up by deleting these directories and files: `rm -r .xmake build libautohook.dll.tmp*`