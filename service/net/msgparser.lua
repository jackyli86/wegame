local skynet = require "skynet"
require "skynet.manager"
local msgrouter = require "msgrouter"
local protobuf = require "protobuf"
local json     = require "json.json"
    
local CMD = {}

function CMD.pack(msg_id,decode_key,msg_body)
    
    local msg_header_src = protobuf.encode(
        'msg_header',
        {
            msg_id = msg_id,
            decode_key = decode_key
        }
    )

    local msg_header = string.pack(">s2", msg_header_src)
    assert(msgrouter[msg_id])
    local struct_body = msgrouter[msg_id]

    local msg_body = protobuf.encode(struct_body.s2c,msg_body)
    return string.pack(">s2", msg_header .. msg_body)
end

function CMD.unpack(msg,sz)
    local _msg = skynet.tostring(msg,sz)
    local msg_header_len = _msg:byte(1)*256 + _msg:byte(2)    
    skynet.error("header len : " .. msg_header_len)

    local _msg_offset = 2;
    local msg_header = _msg:sub(1 + _msg_offset,msg_header_len + _msg_offset);

    _msg_offset = _msg_offset + msg_header_len
    local msg_body = _msg:sub(1 + _msg_offset);

    local struct_header = msgrouter[0];
    local header = protobuf.decode(struct_header.c2s,msg_header)
    assert(header and header.msg_id and header.decode_key)

    assert(msgrouter[header.msg_id])
    local struct_body = msgrouter[header.msg_id]
    -- msgid msg name command
    return header.msg_id,protobuf.decode(struct_body.c2s,msg_body),struct_body.name,struct_body.command
end

function CMD.pack_json(msg_id,decode_key,msg_body)
    msg_body['msg_id'] = msg_id   
    return string.pack(">s2", json.encode(msg_body))
end

function CMD.unpack_json(msg_body)
    msg_body = json.decode(msg_body)
    msg_id = msg_body['msg_id']  

    assert(msgrouter[msg_id])
    local struct_body = msgrouter[msg_id]
    -- msgid msg name command
    return msg_id,msg_body,struct_body.name,struct_body.command
end

skynet.start(function()

    root_path = skynet.getenv('root')
    local pb_files = {
        '../proto/test.pb'
    }

    -- 注册pb files
    for _,pbfile in ipairs(pb_files) do
        protobuf.register_file(root_path .. pbfile)
    end

    skynet.dispatch("lua", function(_, _,command, ...)
        assert(CMD[command])
        local f = CMD[command]
        skynet.ret(skynet.pack(f(...)))
    end)
    
    skynet.name('.msgparser',skynet.self())
end)