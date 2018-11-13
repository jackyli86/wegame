local skynet = require "skynet"
require "skynet.manager"
local msgrouter = require "msgrouter"
local protobuf = require "protobuf"
    
local CMD = {}


skynet.start(function()

    root_path = skynet.getenv('root')
    local pb_files = {
        '../proto/test.pb'
    }

    -- 注册pb files
    for _,pbfile in ipairs(pb_files) do
        protobuf.register_file(root_path .. pbfile)
    end

    skynet.dispatch("lua", function(_, _, msgid,msg)
        assert(msgrouter[msgid])
        local msg_def = msgrouter[msgid];
        skynet.ret(skynet.pack(msg_def.name,msg_def.command,protobuf.decode(msg_def.c2s,msg)))
    end)
    
    skynet.name('.msgparser',skynet.self())
end)