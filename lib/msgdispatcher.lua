
local msg_dispatcher = {}

local function MsgRegister(msgid,name,c2s_struct,s2c_struct)
    assert(msg_dispatcher[msgid] == nil)

    msg_dispatcher[msgid] = {
        name = name,
        c2s = c2s_struct,
        s2c = s2c_struct,
    }
end

--[[

]]

MsgRegister(1,'.fishpool','c2s_login','s2c_loginret')
MsgRegister(2,'.fishpool','c2s_login','s2c_loginret')
MsgRegister(3,'.fishpool','c2s_login','s2c_loginret')

return msg_dispatcher