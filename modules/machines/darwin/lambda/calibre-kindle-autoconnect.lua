-- Reuse KOReader's native Calibre transport; never switch Wi-Fi on for syncing.
local UIManager = require('ui/uimanager')
local NetworkMgr = require('ui/network/manager')
local Event = require('ui/event')
local socket = require('socket')
local ports = {54982,48123,39001,44044,59678}
local function serverAvailable()
    local udp = socket.udp4()
    if not udp then return false end
    udp:setoption('broadcast', true)
    local ok = udp:setsockname('*', 8134)
    if not ok then udp:close(); return false end
    udp:settimeout(1.5)
    for _,port in ipairs(ports) do
        udp:sendto('hello','255.255.255.255',port)
    end
    local data = udp:receivefrom()
    udp:close()
    return data ~= nil and data:match('calibre wireless device client') ~= nil
end
local function connect()
    if G_reader_settings:isTrue('calibre_auto_connect') and NetworkMgr:isConnected() then
        local ok, available = pcall(serverAvailable)
        if ok and available then
            UIManager:broadcastEvent(Event:new('StartWirelessConnection'))
        end
    end
end
local function retry()
    UIManager:scheduleIn(180, retry)
    connect()
end
UIManager:scheduleIn(8, retry)
local userpatch = require('userpatch')
userpatch.registerPatchPluginFunc('calibre', function(plugin)
    plugin.onNetworkConnected = function() UIManager:scheduleIn(3, connect) end
    plugin.onResume = function() UIManager:scheduleIn(8, connect) end
end)
