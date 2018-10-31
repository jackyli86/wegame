
local msg_router = {}

local template = {
    msgid 	= 1,            -- 消息ID
    name  	= '.fishpool',  -- 要发往的服务名字
    command = 'command',    -- 在服务中处理的函数的名字
    c2s 	= 'c2s_login',  -- 对应proto的消息结构
    s2c     = 's2c_loginret'-- 对应proto的消息结构
}

local function MsgRegister(msgid,name,command,c2s_struct,s2c_struct)
    assert(msg_router[msgid] == nil)

    msg_router[msgid] = {
        msgid       = msgid,
        name        = name,
        command     = command,
        c2s         = c2s_struct,
        s2c         = s2c_struct,
    }
end

--[[

]]

MsgRegister(1,'.fishpool','login','c2s_login','s2c_loginret')
MsgRegister(2,'.fishpool','login','c2s_login','s2c_loginret')
MsgRegister(3,'.fishpool','login','c2s_login','s2c_loginret')



return msg_router