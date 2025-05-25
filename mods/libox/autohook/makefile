# Override with pkg-config, if available.
USE_PKG_CONFIG := true

SRC = autohook.c
FOUND_MINGW := $(findstring windows,$(shell clang -dumpmachine))

ifneq ($(FOUND_MINGW),) # Windows
CC = clang
# Don't need -fPIC, that's just how it is by default.
# Skip -Wl,--out-implib,libautohook.a because we don't need to further link the autohook.dll
CFLAGS = -Wall
MINGW_PREFIX ?= /clang64
# Uncomment this to use the MSYS2-provided LuaJIT (Recommended)
LUA_CFLAGS = -I$(MINGW_PREFIX)/include/luajit-2.1
LUA_LIBS   = -lluajit-5.1

# Uncomment this to use your own LuaJIT build
# LUA_CFLAGS = -IC:/Users/USER/Documents/Luanti/luajit/src
# LUA_LIBS   = -LC:/Users/USER/Documents/Luanti/luajit/src -lluajit

TARGET = autohook.dll

else # Linux/Unix-like
CC = gcc
CFLAGS = -Wall -fPIC
LUA_CFLAGS = -I/usr/include/luajit-2.1
LUA_LIBS   = -lluajit-5.1
TARGET = autohook.so
endif

ifeq ($(USE_PKG_CONFIG),true)
ifneq ($(shell which pkg-config 2>/dev/null),)
ifneq ($(shell pkg-config --exists luajit 2>/dev/null && echo y),)
LUA_CFLAGS = $(shell pkg-config --cflags luajit)
LUA_LIBS   = $(shell pkg-config --libs luajit)
else ifneq ($(shell pkg-config --exists luajit-2.1 2>/dev/null && echo y),)
LUA_CFLAGS = $(shell pkg-config --cflags luajit-2.1)
LUA_LIBS   = $(shell pkg-config --libs luajit-2.1)
endif
endif
endif

all: $(TARGET)

$(TARGET): $(SRC)
	@mkdir -p $(dir $@)
	$(CC) $(CFLAGS) $(LUA_CFLAGS) -shared -o $@ $^ $(LUA_LIBS)

clean:
	rm -f $(TARGET)

.PHONY: all clean
