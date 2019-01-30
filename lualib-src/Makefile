
SKYNET_LIBS := -lpthread -lm
SHARED := -fPIC --shared
EXPORT := -Wl,-E

LUA_CLIB_PATH ?= luaclib
BUILD_PATH ?= .
CFLAGS = -g -O2 -Wall -I$(LUA_INC) -I$(AOI_INC)

LUA_INC ?= ../skynet/3rd/lua
AOI_INC ?= aoi
CC ?= gcc


LUA_CLIB_SKYNET = \
  lua-aoi.c \


aoi.so : $(addprefix lualib-src/,$(LUA_CLIB_SKYNET)) | $(LUA_CLIB_PATH)
	$(CC) $(CFLAGS) $(SHARED) $^ -o $@ -Iskynet-src -Ilualib-src