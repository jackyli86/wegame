local skynet = require "skynet"
require "skynet.manager"

local CMD = {}

local fmod = math.fmod
local random = math.random

local npcBornId = 0;
local npcDeadId = 0;
local npcset = {}
local counter = 0
local bornFrequence = 10
local deadFrequence = 15

local function generateBornId()
    npcBornId = npcBornId + 1
    return npcBornId
end

local function generateDeadId()
    npcDeadId = npcDeadId + 1
    return npcDeadId
end

local function mainloop()

    while(true) do

        if fmod(counter,deadFrequence) == 0 then
            local deadid = generateDeadId()
            npcset[deadid] = nil
            
            skynet.call(
                '.aoid',
                'lua',
                'aoi_leave',
                deadid
            )
        end
        
        if fmod(counter,bornFrequence) == 0 then
            npcset[generateBornId()] = {
                mode  = 'wm',
                speed = random(2,5),
                pos_x = random(1,100),
                pos_y = random(1,100),
            }  
        end
    
        for npcid , npcinfo in pairs(npcset) do
            skynet.call(
                '.aoid',
                'lua',
                'aoi_enter',
                npcid,
                npcinfo.mode,
                npcinfo.pos_x,
                npcinfo.pos_y
            )
    
            npcinfo.pos_x = npcinfo.pos_x + npcinfo.speed
            npcinfo.pos_y = npcinfo.pos_y + npcinfo.speed
    
            if npcinfo.pos_x > 200 then
                npcinfo.pos_x = 1
            end
    
            if npcinfo.pos_y > 200 then
                npcinfo.pos_y = 1
            end        
        end

        counter = counter + 1
        skynet.sleep(10)
    end
end

function CMD.aoi_callback(watcherid,markers)
    msg = watcherid .. ' => ['
    for markerid in ipairs(markers) do
        msg = msg .. markerid .. ','
    end
    msg = msg .. ' ]'

    skynet.error(msg)
end

skynet.start(function()
    skynet.dispatch('lua',function(_,_,cmd,...)
        skynet.ignoreret()
        CMD[cmd](...)
    end)

    skynet.name('.taoid',skynet.self())

    skynet.fork(mainloop);    
end)