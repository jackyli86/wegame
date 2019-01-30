
SKYNET_LIBS := -lpthread -lm
SHARED := -fPIC --shared
EXPORT := -Wl,-E

LUA_CLIB_PATH ?= luaclib
BUILD_PATH ?= .
CFLAGS = -g -O2 -Wall -I$(LUA_INC) -I$(AOI_INC) -I$(SKYNET_INC)

SKYNET_INC ?= ../skynet/skynet-src
LUA_INC ?= ../skynet/3rd/lua
AOI_INC ?= aoi

CC ?= gcc


LUA_CLIB_SKYNET = \
  lua-aoi.c \

all :
	$(CC) $(CFLAGS) $(SHARED) $(LUA_CLIB_SKYNET) -o $(LUA_CLIB_PATH)/aoi.so 

clean :
	rm -f $(LUA_CLIB_PATH)/aoi.so