{
    files = {
        "build/.objs/autohook/linux/x86_64/release/autohook.c.o",
        "build/.objs/autohook/linux/x86_64/release/utils.c.o"
    },
    values = {
        "/usr/bin/g++",
        {
            "-shared",
            "-m64",
            "-fPIC",
            "-lluajit-5.1"
        }
    }
}