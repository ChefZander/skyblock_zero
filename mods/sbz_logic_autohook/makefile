# chat gippity go brr
CC = gcc
CFLAGS = -Wall -fPIC
LUA_INCLUDE = /usr/include/luajit-2.1
LUA_LIB = -lluajit-5.1
TARGET = bin/autohook.so
SRC = src/autohook.c

all: $(TARGET)

$(TARGET): $(SRC)
	$(CC) $(CFLAGS) -I$(LUA_INCLUDE) -shared -o $@ $^ $(LUA_LIB)

clean:
	rm -f $(TARGET)