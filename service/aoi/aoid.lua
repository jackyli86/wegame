local skynet = require "skynet"
require "skynet.manager"
local aoi = require "aoi"

local random = math.random

local space
local gen_id = 1
local tickcounter = 1
local objs = {}

local function genid()
    id = gen_id
    gen_id = gen_id + 1
    return id
end


local function lua_aoi_callback(watcherid,markerid)
    watcher = objs[watcherid]
    marker = objs[markerid]

    watchermsg = watcherid..':'..'['..watcher.position[1]..','..watcher.position[1]..']'
    markermsg = markerid..':'..'['..marker.position[1]..','..marker.position[1]..']'

    msg = '['..watchermsg..'=>'..markermsg..']'
    skynet.error(msg)
end

local function walk(objInfo)
    objInfo.position[1] = objInfo.position[1] + objInfo.speed[1]
    objInfo.position[2] = objInfo.position[2] + objInfo.speed[2]
    objInfo.position[3] = objInfo.position[3] + objInfo.speed[3]

    if objInfo.position[1] > 200 then
        objInfo.position[1] = 0;
    end

    if objInfo.position[2] > 200 then
        objInfo.position[2] = 0;
    end

    if objInfo.position[3] > 200 then
        objInfo.position[3] = 0;
    end    
end

local function mainloop()
    while(true) do
        size = count(objs)
        if size < 100 then
            obj_id = genid()
            objs[obj_id] = {
                speed = {1,1,0},
                position = {random(0,200),random(0,200),0},
                mode = 'wm',
            }

            aoi.aoi_update2d(space,obj_id,objs[obj_id].mode,objs[obj_id].position[1],objs[obj_id].position[2])
        end

        for obj_id , objInfo in pairs(objs) do
            walk(objInfo);
            aoi.aoi_update2d(space,obj_id,objInfo.mode,objInfo.position[1],objInfo[2])
        end
        

        skynet.sleep(5000)
    end
end

skynet.start(function()
    space = aoi.aoi_create();
    debug.setupvalue(aoi.aoi_message,1,lua_aoi_callback)
    skynet.fork(mainloop);

    skynet.name('.aoid',skynet.self())
end)