local skynet = require "skynet"
require "skynet.manager"

local max_client = 64

skynet.start(function()
    
    skynet.error("Server start")

    skynet.newservice("msgparser")
    skynet.newservice("fishpool")

    skynet.newservice("aoid")

    skynet.newservice("AccountMgr")

    skynet.newservice("gameserver")
    -- skynet.newservice("taoid")
    
	-- 该端口已被禅道占用
    --skynet.newservice("gameserver_8888");
	skynet.exit()
end)
