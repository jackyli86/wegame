local skynet = require "skynet"
local netpack = require "skynet.netpack"
local socket = require "skynet.socket"

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
		return skynet.tostring(msg,sz),sz
	end,
	dispatch = function (fd, _,msg,sz)
		assert(fd == client_fd)	-- You can use fd to reply message

		skynet.ignoreret()	-- session is fd, don't call skynet.ret
		--skynet.trace()

		local msg_header_len = string.byte(msg,1)*256 + string.byte(msg,2)		
		local msg_without_header = string.sub(msg,2 + 1)
		local msg_header = string.sub(msg_without_header,1,msg_header_len)
		local msg_body   = string.sub(msg_without_header,msg_header_len + 1)	

		skynet.error("msglen:" .. sz,"headerlen:" .. msg_header_len,"bodylen:" .. (sz - 2 - msg_header_len))
		skynet.error("msglen:" .. msg:len(),"headerlen:" .. msg_header:len(),"bodylen:" .. msg_body:len())

		-- name,command,msg
		local _,_,msg_header = skynet.call('.msgparser','lua',0,msg_header)
		print(msg_header.msg_id)
		print(msg_header.decode_key)

	
		local name,command,msg_body = skynet.call('.msgparser','lua',msg_header.msg_id,msg_body)
		skynet.error(name,command)
		local msg_body = skynet.call(name ,'lua' ,command ,msg_id ,msg_body )
		skynet.error("uuid:" .. msg_body.uuid)
		send_package(msg_body);	
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
