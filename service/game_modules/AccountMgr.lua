local skynet = require "skynet"
require "skynet.manager"
local mongo = require "skynet.db.mongo"

local CMD = {}

local function _create_client()
	return mongo.client({
		host=127.0.0.1,
		port=27017,
		username='lihj',
		password='111111'
	})
end

-- 注册账号
function CMD.register(msg)
	local c = _create_client()
	db = c['admin']
	db:auth('lihj', '111111')

	c.accountdb:safe_insert({test_key = 1})
end

-- 登录账号
function CMD.login(msg_id,msg)
	
end

-- 登出账号
function CMD.logout(msg_id,msg)

end

skynet.start(function()
	skynet.dispatch("lua", function(_,_, command, ...)
		-- skynet.trace()
		local f = CMD[command]
		skynet.ret(skynet.pack(f(...)))
	end)

	CMD.register(nil)
	
	skynet.name('.AcountMgr',skynet.self())
end)