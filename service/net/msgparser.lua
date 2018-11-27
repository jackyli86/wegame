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

    skynet.dispatch("lua", function(_, _,type, header, body)
        -- skynet.error('new_msg:' .. msgid)
        if type == 1 then

        else

        end

        local struct_header = msgrouter[0];
        header = protobuf.decode(struct_header.c2s,header)
        assert(header.msg_id and header.decode_key)
        assert(msgrouter[header.msg_id])
        
        local struct_body = msgrouter[header.msg_id]
        -- msgid msg name command
        skynet.ret(skynet.pack(header.msg_id,protobuf.decode(struct_body.c2s,body),struct_body.name,struct_body.command))
    end)
    
    skynet.name('.msgparser',skynet.self())
end)