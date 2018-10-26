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

		skynet.ignoreret()	-- session is fd, don't call skynet.ret
		--skynet.trace()		

		--[[
			msgid,
			cmd,			
			data,

			解析出msgid,cmd
			解析出消息结构

			function Msg(msgid,serviceName)
				local msg_processor = {
					'begin' = begin,
					'end' = end,
					'name' = serviceName
				}
				return msg_processor
			end
		--]]

		local msg = skynet.call('.fishpool','lua','msg_dispatch','agent => fishpool => agent my-mgs=>' .. msg)
		
		send_package(msg);	
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
		skynet.error(command)
		local f = CMD[command]
		skynet.ret(skynet.pack(f(...)))
	end)
end)
