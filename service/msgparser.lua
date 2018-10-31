local skynet = require "skynet"
local msgrouter = require "msgrouter"
local protobuf = require "protobuf"
    
local CMD = {}


skynet.start(function()

    root_path = skynet.getenv('root')
    local pb_files = {
        '../proto/test.pb'
    }

    -- 注册pb files
    for pbfile in ipairs(bp_files) do
        protobuf.register_file(root_path .. pbfile)
    end

    skynet.dispatch("lua", function(_, _, msgid,msg)
        assert(msgrouter[msgid])
        local msgRegInfo = msgrouter[msgid];
        skynet.ret(skynet.pack(protobuf.decode(msgRegInfo.c2s,msg)))
    end)
    
    skynet.name('.msgparser',skynet.self())
end)