{
    depfiles = "utils.o: utils.c\
",
    depfiles_format = "gcc",
    files = {
        "utils.c"
    },
    values = {
        "/usr/bin/gcc",
        {
            "-m64",
            "-fPIC",
            "-std=c11",
            "-Ibuild/.gens/autohook/linux/x86_64/release/platform/windows/idl",
            "-isystem",
            "/usr/include/luajit-2.1",
            "-Wall",
            "-Wextra",
            "-Wpedantic",
            "-Wall",
            "-Wextra",
            "-Weffc++",
            "-Wno-extra-semi-stmt",
            "-Wno-newline-eof",
            "-Wno-declaration-after-statement",
            "-Wno-unused-parameter",
            "-Wno-unused-function",
            "-Wno-missing-prototypes",
            "-Wno-unused-macros",
            "-Wno-switch-default",
            "-Wno-gnu-zero-variadic-macro-arguments",
            "-Wno-unsafe-buffer-usage"
        }
    }
}