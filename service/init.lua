local skynet = require "skynet"

local max_client = 64

skynet.start(function()
	skynet.error("Server start")

    skynet.newservice("gameserver");

	-- 该端口已被禅道占用
    --skynet.newservice("gameserver_8888");
	skynet.exit()
end)