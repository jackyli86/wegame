local skynet = require "skynet"
local netpack = require "skynet.netpack"
local socket = require "skynet.socket"

local json = require "json.json"
local protobuf = require "protobuf"
local root_path = skynet.getenv('root')
local pb_files = {
	'../proto/test.pb'
}

-- 注册pb files
for _,pbfile in ipairs(pb_files) do
	protobuf.register_file(root_path .. pbfile)
end

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
		local _msg = skynet.tostring(msg,sz)
		local msg_header_len = _msg:byte(1)*256 + _msg:byte(2)	

		local _msg_offset = 2;
		local msg_header = _msg:sub(1 + _msg_offset,msg_header_len + _msg_offset);

		_msg_offset = _msg_offset + msg_header_len
		local msg_body = _msg:sub(1 + _msg_offset);

		return msg_header,msg_body
	end,
	dispatch = function (fd, _,src_msg_header,src_msg_body)
		assert(fd == client_fd)	-- You can use fd to reply message

		skynet.ignoreret()	-- session is fd, don't call skynet.ret
		--skynet.trace()
		--[[
			local msg_header_len = string.byte(msg,1)*256 + string.byte(msg,2)		
			local msg_without_header = string.sub(msg,2 + 1)
			local msg_header = string.sub(msg_without_header,1,msg_header_len)
			local msg_body   = string.sub(msg_without_header,msg_header_len + 1)	
			
			skynet.error("msglen:" .. sz,"headerlen:" .. msg_header_len,"bodylen:" .. (sz - 2 - msg_header_len))
			skynet.error("msglen:" .. msg:len(),"headerlen:" .. msg_header:len(),"bodylen:" .. msg_body:len())
		]]

		-- msg,name,command
		local msg_header = skynet.call('.msgparser','lua',0,src_msg_header)

		-- msg,name,command
		local msg_body,name,command = skynet.call('.msgparser','lua',msg_header.msg_id,src_msg_body)
		-- skynet.error(name,command)
		local msg_ret = skynet.call(name ,'lua' ,command ,msg_header.msg_id ,msg_body )
		local msg_json_ret = json.encode(msg_ret)
		
		send_package(string.pack('>s2',msg_json_ret));	
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
