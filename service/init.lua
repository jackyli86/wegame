local skynet = require "skynet"
require "skynet.manager"

local max_client = 64


local function tproto()
    protobuf = require "protobuf"
    
    root_path = skynet.getenv('root')

    protobuf.register_file(root_path .. '../proto/test.pb')
    local test_msg = {
        header = {
            msg_id = 1,
            decode_key = 2,
        },
        bb = 22,
        cc = 33
    }

    stringbuffer = protobuf.encode("at",test_msg)


    local data1 = protobuf.decode("msg_header",stringbuffer)

    local data2 = protobuf.decode("at",stringbuffer)

    dump(data1)
    dump(data2)

    skynet.error("proto test : " .. data1.header.msg_id .. data1.header.decode_key)
    skynet.error("proto test : " .. data2.aa)

end

skynet.start(function()
    
    skynet.error("Server start")

    skynet.newservice("gameserver")

    skynet.newservice("msgparser")
    skynet.newservice("fishpool")

    skynet.newservice("aoid")
    -- skynet.newservice("taoid")
    
	-- 该端口已被禅道占用
    --skynet.newservice("gameserver_8888");
	skynet.exit()
end)
