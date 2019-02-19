local skynet = require "skynet"
require "skynet.manager"

local CMD = {}

local fmod = math.fmod
local random = math.random

local npcBornId = 2;
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
                pos_x = random(1,30),
                pos_y = random(1,30),
            }  
        end
    
        for npcid , npcinfo in pairs(npcset) do
            -- skynet.error("enter_1")
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
    
            if npcinfo.pos_x > 30 then
                npcinfo.pos_x = 1
            end
    
            if npcinfo.pos_y > 30 then
                npcinfo.pos_y = 1
            end        
        end

        counter = counter + 1
        -- skynet.error("counter:"..counter)
        skynet.sleep(50)
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
        if cmd == nil then
            return
        end
        
        -- must call skynet.ret ,otherwise the call actor would be block
        skynet.ret(skynet.pack(CMD[cmd](...)))
    end)

    skynet.name('.taoid',skynet.self())

    skynet.fork(mainloop);    
end)