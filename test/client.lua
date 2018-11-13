package.cpath = "luaclib/?.so;../luaclib/?.so"
package.path = "lualib/?.lua;examples/?.lua;../lib/?.lua"

if _VERSION ~= "Lua 5.3" then
	error "Use lua 5.3"
end

local socket = require "client.socket"
local protobuf = require "protobuf"
local msgrouter = require "msgrouter"

protobuf.register_file("../proto/test.pb");

local fd = assert(socket.connect("127.0.0.1", 8001))

local function say_bye(fd)
	local pack = "quit"
	if(pack == "quit") then
		socket.close(fd)
		print("bye,skynet")
	end
end

local function send_msg(fd,msg_id,decode_key,msg_table)
	local msg_header = protobuf.encode('msg_header',{
		msg_id = msg_id,
		decode_key = decode_key
	})


	local msg_header = string.pack(">s2", msg_header)
	assert(msgrouter[msg_id])
	local msg_def = msgrouter[msg_id]

	local msg_body = protobuf.encode(msg_def.c2s,msg_table)
	msg_send = string.pack(">s2", msg_header .. msg_body)

	socket.send(fd,msg_send)
end

local function unpack_package(text)
	local size = #text
	if size < 2 then
		return nil, text
	end
	local s = text:byte(1) * 256 + text:byte(2)
	if size < s+2 then
		return nil, text
	end

	return text:sub(3,2+s), text:sub(3+s)
end

local function recv_package(last)
	local result
	result, last = unpack_package(last)
	if result then
		return result, last
	end
	local r = socket.recv(fd)
	if not r then
		return nil, last
	end
	if r == "" then
		error "Server closed"
	end
	return unpack_package(last .. r)
end

local session = 0


local last = ""

local function dispatch_package()
	while true do
		local v
		v, last = recv_package(last)
		if not v then
			break
		end

		print(v)
	end
end

--send_package(fd,"handshake")
while true do
	dispatch_package()
	local cmd = socket.readstdin()
	if cmd then
		if cmd == "quit" then
			say_bye(fd)
		else
			send_msg(fd,1,1,{uuid=cmd})
		end
	else
		socket.usleep(100)
	end
end
