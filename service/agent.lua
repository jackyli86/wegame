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
	socket.write(client_fd, pack)
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
