local skynet = require "skynet"
local netpack = require "skynet.netpack"
local socket = require "skynet.socket"

local json = require "json.json"

-- 注意upvalue
local WATCHDOG
local client_fd

local function send_package(pack)
	socket.write(client_fd, pack)
end

local protocol_type = skynet.getenv('protocol_type')

local supported_protocols = {
	lua = {
		unpack = function (msg, sz)	
			local _msg = skynet.tostring(msg,sz)
			local msg_header_len = _msg:byte(1)*256 + _msg:byte(2)	
	
			local _msg_offset = 2;
			local msg_header = _msg:sub(1 + _msg_offset,msg_header_len + _msg_offset);
	
			_msg_offset = _msg_offset + msg_header_len
			local msg_body = _msg:sub(1 + _msg_offset);
	
			return msg_header,msg_body
		end,
		dispatch = function (fd, _,msg_header,msg_body)
			assert(fd == client_fd)	-- You can use fd to reply message
	
			skynet.ignoreret()	-- session is fd, don't call skynet.ret
			--skynet.trace()
	
			-- unpack
			--msgid,msg,name,command
			local msgid,msg,name,command = skynet.call('.msgparser','lua','unpack',msg_header,msg_body)
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
