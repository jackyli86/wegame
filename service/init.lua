local skynet = require "manager"

local max_client = 64


local function tproto()
    protobuf = require "protobuf"
    
    root_path = skynet.getenv('root')

    protobuf.register_file(root_path .. '../proto/test.pb')

    stringbuffer = protobuf.encode("at",{
        aa = 1222 
    })


    local data = protobuf.decode("at",stringbuffer)

    skynet.error("proto test : " .. data.aa)

end

skynet.start(function()

    tproto()
    
    skynet.error("Server start")

    skynet.newservice("gameserver")

    fishpool = skynet.newservice("fishpool")
    skynet.name('.fishpool',fishpool)
	-- 该端口已被禅道占用
    --skynet.newservice("gameserver_8888");
	skynet.exit()
end)
