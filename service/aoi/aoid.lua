local skynet = require "skynet"
require "skynet.manager"
local aoi = require "aoi"

local random = math.random
local table = table

local space
local aoi_msg = {}
local CMD = {}

local function lua_aoi_callback(watcherid,markerid)
    aoi_msg[watcherid] = aoi_msg[watcherid] or {}

    table.insert(aoi_msg[watcherid],markerid)

    --[[
        watchermsg = watcherid
        markermsg = markerid
        msg = '['..watchermsg..'=>'..markermsg..']'
        skynet.error(msg)
    ]]
end

local function mainloop()
    while(true) do  

        aoi.aoi_message(space)

        for watcherid , markers in pairs(aoi_msg) do
            msg = watcherid .. ' => ['
            for markerid in ipairs(markers) do
                msg = msg .. markerid .. ','
            end
            msg = msg .. ' ]'
        
            skynet.error(msg)
            skynet.call(
                '.taoid',
                'lua',
                'aoi_callback',
                watcherid,
                markers
            )
        end
        
        -- clear aoi msg ,put this operate here ,because aoi.aoi_update2d produce aoi_msg too
        aoi_msg = {}  
        skynet.sleep(100)

    end
end

function CMD.aoi_enter(id,mode,pos_x,pos_y)
    skynet.error('aoi_enter:{'..id..','..mode..','..pos_x..','..pos_y..'}')
    aoi.aoi_update2d(space,id,mode,pos_x,pos_y)
end

function CMD.aoi_leave(id)
    skynet.error('aoi_leave:{'..id..'}')
    aoi.aoi_update2d(space,id,'d',0,0)
end

skynet.start(function()

    skynet.dispatch('lua',function(_,source,cmd,...)
        skynet.ignoreret()
        CMD[cmd](...)
    end)

    space = aoi.aoi_create();
    aoi.aoi_set_callback(lua_aoi_callback)

    skynet.name('.aoid',skynet.self())

    skynet.fork(mainloop);
end)