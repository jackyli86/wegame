local skynet = require "skynet"
local netpack = require "skynet.netpack"
local socket = require "skynet.socket"

local cfg_msgparser = '.msgparser';

-- 注意upvalue
local WATCHDOG
local client_fd

local function send_package(pack)
	socket.write(client_fd, pack)
end

local CMD = {}

skynet.register_protocol {
	name = "client",
	id = skynet.PTYPE_CLIENT,
	unpack = function (msg, sz)	
		return msg,sz
	end,
	dispatch = function (fd, _,msg,sz)
		assert(fd == client_fd)	-- You can use fd to reply message

		skynet.ignoreret()	-- session is fd, don't call skynet.ret
		--skynet.trace()

		-- unpack
		--msgid,msg,name,command skynet.redirect(agent, c.client, "client", fd, msg, sz)
		local msgid,msg,name,command = skynet.call(cfg_msgparser,'lua','unpack',skynet.tostring(msg,sz))
		print(msgid,msg,name,command)
		local msg_ret = skynet.call(name ,'lua' ,command ,msgid ,msg )
		-- pack
		local msg_send = skynet.call(cfg_msgparser,'lua','pack',msgid,1,msg_ret)
		send_package(msg_send);
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
