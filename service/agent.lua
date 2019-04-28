local skynet = require "skynet"
local netpack = require "skynet.netpack"
local socket = require "skynet.socket"

-- 注意upvalue
local WATCHDOG
local client_fd

local function send_package(pack)
	socket.write(client_fd, pack)
end

local protocol_type = skynet.getenv('protocol_type')
skynet.error("agent use 【" .. protocol_type .. "】 protocol")
local supported_protocols = {
	lua = {
		unpack = function (msg, sz)	
			skynet.error("recv msg len:" .. sz)
			return msg,sz
		end,
		dispatch = function (fd, _,msg,sz)
			assert(fd == client_fd)	-- You can use fd to reply message
	
			skynet.ignoreret()	-- session is fd, don't call skynet.ret
			--skynet.trace()
	
			-- unpack
			--msgid,msg,name,command skynet.redirect(agent, c.client, "client", fd, msg, sz)
			local msgid,msg,name,command = skynet.call('.msgparser','lua','unpack',skynet.tostring(msg,sz))
			print(msgid,msg,name,command)
			local msg_ret = skynet.call(name ,'lua' ,command ,msgid ,msg )
			-- pack
			local msg_send = skynet.call('.msgparser','lua','pack',msgid,1,msg_ret)
			send_package(msg_send);
		end
	},
	json = {
		unpack = function (msg, sz)	
			return skynet.tostring(msg,sz)
		end,
		dispatch = function (fd, _,msg_body)
			assert(fd == client_fd)	-- You can use fd to reply message
	
			skynet.ignoreret()	-- session is fd, don't call skynet.ret
			--skynet.trace()
	
			-- unpack
			--msgid,msg,name,command
			local msgid,msg,name,command = skynet.call('.msgparser','lua','unpack_json',msg_body)

			local msg_ret = skynet.call(name ,'lua' ,command ,msgid ,msg )
			
			-- pack
			local msg_send = skynet.call('.msgparser','lua','pack_json',msgid,1,msg_ret)
			send_package(msg_send);
		end
	}
}

assert(supported_protocols[protocol_type],"unsupported protocol type")

local CMD = {}

skynet.register_protocol {
	name = "client",
	id = skynet.PTYPE_CLIENT,
	unpack = supported_protocols[protocol_type]['unpack'],
	dispatch = supported_protocols[protocol_type]['dispatch']
}

function CMD.start(conf)
	local fd = conf.client
	local gate = conf.gate
	WATCHDOG = conf.watchdog

	client_fd = fd
	skynet.fork(function()
		local msg_to_client = "hello,I'm skynet,nice to meet you!"
		msg_to_client = string.pack("<s2", msg_to_client)
		--while(true) do
		--	send_package(msg_to_client)
		--	skynet.sleep(10)
		--end
	end)
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
