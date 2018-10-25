local skynet = require "skynet"
local netpack = require "skynet.netpack"
local socket = require "skynet.socket"

local WATCHDOG
local client_fd

local CMD = {}

local function send_package(pack)
	local package = string.pack(">s2", pack)
	socket.write(client_fd, package)
end

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

		skynet.call('.fishpool','lua','msg_dispatch','hello fishpool service')		
		
		--send_package("glad to recieve your message");	
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

function CMD.msg_ret(msg)
	send_package(msg)
end

skynet.start(function()
	skynet.dispatch("lua", function(_,_, command, ...)
		-- skynet.trace()
		local f = CMD[command]
		skynet.ret(skynet.pack(f(...)))
	end)
end)
