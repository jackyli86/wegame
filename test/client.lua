package.cpath = "luaclib/?.so"
package.path = "lualib/?.lua;examples/?.lua"

if _VERSION ~= "Lua 5.3" then
	error "Use lua 5.3"
end

local socket = require "client.socket"

local fd = assert(socket.connect("127.0.0.1", 8001))

local function send_package(fd, pack)
	local package = string.pack(">s2", pack)
	socket.send(fd, package)

	if(pack == "quit") then
		socket.closed(fd)
		print("bye,skynet")
	end
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

send_package(fd,"handshake")
while true do
	dispatch_package()
	local cmd = socket.readstdin()
	if cmd then
		if cmd == "quit" then
			send_package(fd,"quit")
		else
			send_package(fd,cmd)
		end
	else
		socket.usleep(100)
	end
end
