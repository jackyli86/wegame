local skynet = require "skynet"
local netpack = require "skynet.netpack"
local socket = require "skynet.socket"

local WATCHDOG
local client_fd

local CMD = {}


skynet.register_protocol {
	name = "client",
	id = skynet.PTYPE_CLIENT,
	unpack = function (msg, sz)
		-- todo self testing
		return skynet.tostring(msg,sz)
	end,
	dispatch = function (fd, _, msg)
		assert(fd == client_fd)	-- You can use fd to reply message

		--skynet.ignoreret()	-- session is fd, don't call skynet.ret
		--skynet.trace()		

		skynet.error(msg)
		
		skynet.ret("hello client",string.len("hello client"))
	end
}

function CMD.start(conf)
	local fd = conf.client
	local gate = conf.gate
	WATCHDOG = conf.watchdog

	client_fd = fd
	skynet.call(gate, "lua", "forward", fd)
end

function CMD.disconnect()
	-- todo: do something before exit
	skynet.exit()
end

skynet.start(function()
	skynet.dispatch("lua", function(_,_, command, ...)
		-- skynet.trace()
		local f = CMD[command]
		skynet.ret(skynet.pack(f(...)))
	end)
end)
