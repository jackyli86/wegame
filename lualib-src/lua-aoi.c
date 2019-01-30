/**
 * AOI
 */

#define LUA_LIB

#include "skynet_malloc.h"

#include <stdlib.h>
#include <string.h>
#include <stdbool.h>
#include <stdint.h>
#include <assert.h>

#include <lua.h>
#include <lauxlib.h>

#include "aoi.h"

static void *
laoi_alloc(void * ud, void *ptr, size_t sz) {
	if (ptr == NULL) {
		void *p = skynet_malloc(sz);
		return p;
	}
	skynet_free(ptr);
	return NULL;
}

void
laoi_callback(void *ud, uint32_t watcher, uint32_t marker)
{
    lua_State* L = ud;
    struct skynet_context* context = lua_touserdata(L,lua_upvalueindex(1));

    lua_rawgetp(L, LUA_REGISTRYINDEX, laoi_callback);
    // luaL_checktype(L,-1,)
    lua_pushinteger(L,watcher);
    lua_pushinteger(L,marker);

    int r = lua_pcall(L,2,0,0);
	if (r == LUA_OK) {
		return 0;
	}

    /*
	const char * self = skynet_command(context, "REG", NULL);
	switch (r) {
	case LUA_ERRRUN:
		skynet_error(context, "lua call [%x to %s : %d msgsz = %d] error : " KRED "%s" KNRM, source , self, session, sz, lua_tostring(L,-1));
		break;
	case LUA_ERRMEM:
		skynet_error(context, "lua memory error : [%x to %s : %d]", source , self, session);
		break;
	case LUA_ERRERR:
		skynet_error(context, "lua error in error : [%x to %s : %d]", source , self, session);
		break;
	case LUA_ERRGCMM:
		skynet_error(context, "lua gc error : [%x to %s : %d]", source , self, session);
		break;
	};

	lua_pop(L,1);
    */

	return 0;
}

static int
laoi_create(lua_State* L)
{
    struct aoi_space* space = aoi_create(laoi_alloc,NULL);
    lua_pushlightuserdata(L,space);
    return 1;
}

static int
laoi_release(lua_State* L)
{
    assert(lua_islightuserdata(L,1));
    struct aoi_space* space = lua_touserdata(L,1);
    aoi_release(space);

    return 0;
}

/**
 *  aoi_space*  space
 *  int         obj_id
 *  const char* mode  ['wmd']
 *  float pos_x 
 *  float pos_y
 */
static int
laoi_update2d(lua_State* L)
{
    assert(lua_islightuserdata(L,1)&&lua_gettop(L)==5);
    struct aoi_space* space = lua_touserdata(L,1);
    int obj_id = lua_tointeger(L,2);
    const char* mode = lua_tostring(L,3);

    float pos_x = lua_tonumber(L,4);
    float pos_y = lua_tonumber(L,5);
    float pos_z = 0;

    float pos[] = {pos_x,pos_y,pos_z};
    aoi_update(space,obj_id,mode,pos);
    
    return 0;
}

/**
 *  aoi_space*  space
 *  int         obj_id
 *  const char* mode  ['wmd']
 *  float pos_x 
 *  float pos_y
 *  float pos_z
 */
static int
laoi_update3d(lua_State* L)
{
    assert(lua_islightuserdata(L,1)&&lua_gettop(L)==6);
    struct aoi_space* space = lua_touserdata(L,1);
    int obj_id = lua_tointeger(L,2);
    const char* mode = lua_tostring(L,3);
    
    float pos_x = lua_tonumber(L,4);
    float pos_y = lua_tonumber(L,5);
    float pos_z = lua_tonumber(L,6);
    float pos[] = {pos_x,pos_y,pos_z};
    
    aoi_update(space,obj_id,mode,pos);

    return 0;
}

static int
laoi_message(lua_State* L)
{
    assert(lua_islightuserdata(L,1));
    struct aoi_space* space = lua_touserdata(L,1);

    aoi_message(space,laoi_callback,L);

    return 0;
}

static int 
laoi_set_callback(lua_State* L)
{
    luaL_checktype(L,1,LUA_TFUNCTION);
    lua_settop(L,1);
    lua_rawsetp(L, LUA_REGISTRYINDEX, laoi_callback);

    lua_pushboolean(L,1);
    return 1;
}

static const luaL_Reg aoilib[] = {
  {"aoi_create", laoi_create},
  {"aoi_release", laoi_release},
  {"aoi_update2d",laoi_update2d},
  {"aoi_update3d",laoi_update3d},
  {"aoi_message",laoi_message},
  {"aoi_set_callback",laoi_set_callback},
  {NULL, NULL}
};

LUA_API int 
luaopen_aoi(lua_State* L)
{
    luaL_newlib(L,aoilib);

    return 1;
}