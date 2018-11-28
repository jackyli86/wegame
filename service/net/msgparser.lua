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

    skynet.dispatch("lua", function(_, _,type, ...)
        -- skynet.error('new_msg:' .. msgid)
        local argv = {...}
        if type == 'unpack' then
            local header = argv[1]
            local body   = argv[2]

            local struct_header = msgrouter[0];
            header = protobuf.decode(struct_header.c2s,header)
            assert(header.msg_id and header.decode_key)

            assert(msgrouter[header.msg_id])
            local struct_body = msgrouter[header.msg_id]
            -- msgid msg name command
            skynet.ret(skynet.pack(header.msg_id,protobuf.decode(struct_body.c2s,body),struct_body.name,struct_body.command))
        else
            local msg_id = argv[1]
            local decode_key = argv[2]
            local msg_body = argv[3]

            local msg_header_src = protobuf.encode('msg_header',{
                msg_id = msg_id,
                decode_key = decode_key
            })

            local msg_header = string.pack(">s2", msg_header_src)
            assert(msgrouter[msg_id])
            local struct_body = msgrouter[msg_id]

            local msg_body = protobuf.encode(struct_body.s2c,msg_body)
            msg_send = string.pack(">s2", msg_header .. msg_body)

            --print("header1:"..msg_header_src:len(),"header2:"..msg_header:len(),"body1:"..msg_body:len(),"body2:"..msg_send:len())
            skynet.ret(skynet.pack(msg_send))
        end


    end)
    
    skynet.name('.msgparser',skynet.self())
end)