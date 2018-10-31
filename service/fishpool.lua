local skynet = require "skynet"
require "skynet.manager"


local CMD = {}

function CMD.msg_dispatch(msg)
	skynet.error(msg)
    return msg
end

skynet.start(function()
	skynet.dispatch("lua", function(_,_, command, ...)
		-- skynet.trace()
		local f = CMD[command]
		skynet.ret(skynet.pack(f(...)))
	end)

	skynet.name('.fishpool',skynet.self())
end)