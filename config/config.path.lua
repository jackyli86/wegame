-- skynet : executable binary path -- 
root = "./"

-- game project path
game_service = root.."../service/?.lua;"..root.."../service/?/init.lua;"

-- skynet inner service 
skynet_service = root.."service/?.lua;"

-- skynet service path --
luaservice = skynet_service .. game_service


-- game require path
game_path = root .. "../lib/?.lua;" .. root .. "../lib/?/init.lua;"

-- skynet inner require path
skynet_path =  root.."lualib/?.lua;"..root.."lualib/?/init.lua;"

-- lua require path --
lua_path = skynet_path .. game_path


-- lua load path 
lua_load_path = ""

-- lua so search path --
lua_cpath = root .. "luaclib/?.so"

-- snax path --
snax = root.."examples/?.lua;"..root.."test/?.lua"

-- lua script loader --
lualoader = root .. "lualib/loader.lua"