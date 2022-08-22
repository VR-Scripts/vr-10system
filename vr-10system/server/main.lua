Core = nil
if VRConfig.NewCore then
    Core = exports[VRConfig.Exports]:GetCoreObject()
else
    while Core == nil do
        Wait(10)
        TriggerEvent(VRConfig.Core .. ":GetSharedObject", function(obj) Core = obj end)
    end
end
Employees = {}

local Codes = json.decode(LoadResourceFile(GetCurrentResourceName(), "codes.json")) or {}
local Colors = json.decode(LoadResourceFile(GetCurrentResourceName(), "colors.json")) or {}

Core.Functions.CreateCallback('vr-10system:server:GetTagsColors', function(source, cb)
	cb(json.decode(LoadResourceFile(GetCurrentResourceName(), "colors.json")) or {})
end)

Core.Functions.CreateCallback('vr-10system:server:GetTagsColorsAndJob', function(source, cb)
    local src = source
    local player = Core.Functions.GetPlayer(src)
	cb(json.decode(LoadResourceFile(GetCurrentResourceName(), "colors.json")) or {}, player.PlayerData.job.name)
end)


Citizen.CreateThread(function()
    for k, v in pairs(VRConfig.WhitelistedJobs) do
        if v.SortBy ~= 'tag' and v.SortBy ~= 'job' then
            while true do
                Wait(1000)
                print("you have problem with the "..k.." config at SortBy it have to be job/tag")
            end
        end
    end

    Wait(1000)
    for k, v in pairs(VRConfig.WhitelistedJobs) do
        Employees[k] = {}
    end
end)


RegisterNetEvent('vr-employeelist:server:addToList', function(jobName, dutyStatus)
    local src = source
    local player = Core.Functions.GetPlayer(src)
    local code = getPlayerInfo(src)
    if player.PlayerData.job.name == jobName then
        Employees[jobName][tostring(src)] = {
            src = src,
            name = player.PlayerData.charinfo.firstname .. " " .. player.PlayerData.charinfo.lastname,
            grade = player.PlayerData.job.grade.name or "Employee",
            gradenumber = player.PlayerData.job.level,
            code = code or VRConfig.DefaultCodename,
            onduty = player.PlayerData.job.onduty or false,
            job = player.PlayerData.job
        }
        for k, v in pairs(Employees[player.PlayerData.job.name]) do
            TriggerClientEvent('vr-10system:client:updateList', k, Employees[player.PlayerData.job.name])
        end
    end
end)

RegisterNetEvent("vr-10system:server:removeFromList")
AddEventHandler("vr-10system:server:removeFromList", function()
    local src = source
    local job = Core.Functions.GetPlayer(src).PlayerData.job
    if job and Employees[job.name] and Employees[job.name][tostring(src)] ~= nil then
        Employees[job.name][tostring(src)] = nil
        for k, v in pairs(Employees[job.name]) do
            TriggerClientEvent('vr-10system:client:updateList', k, Employees[job.name])
        end
    end
end)

RegisterNetEvent(VRConfig.UpdateChannelEvent)
AddEventHandler(VRConfig.UpdateChannelEvent, function(sid,channel)
    local player = Core.Functions.GetPlayer(sid)
    local jobname = player.PlayerData.job.name
    sid = tostring(sid)
    if Employees[jobname][sid] then
        Employees[jobname][sid].channel = channel
        for k, v in pairs(Employees[player.PlayerData.job.name]) do
            TriggerClientEvent('vr-10system:client:updateList', k, Employees[player.PlayerData.job.name])
        end
    end
end)

RegisterNetEvent("vr-10system:server:updateCallsign")
AddEventHandler("vr-10system:server:updateCallsign", function(callsign)
    local src = source
    local Player = Core.Functions.GetPlayer(src)
    Player.Functions.SetMetaData("callsign", callsign)
    if not Codes[Player.PlayerData.job.name] then
        Codes[Player.PlayerData.job.name] = {}
    end
    Codes[Player.PlayerData.job.name][tostring(Player.PlayerData.citizenid)] = callsign
    Employees[Player.PlayerData.job.name][tostring(src)]["code"] = callsign
    SaveResourceFile(GetCurrentResourceName(), "codes.json", json.encode(Codes), -1)
    for k,v in pairs(Employees[Player.PlayerData.job.name]) do    
        TriggerClientEvent('vr-10system:client:updateList', k, Employees[Player.PlayerData.job.name])
    end
end)

RegisterNetEvent(VRConfig.UpdateTalkingEvent)
AddEventHandler(VRConfig.UpdateTalkingEvent, function(state)
    local player = Core.Functions.GetPlayer(source)
    local jobname = player.PlayerData.job.name
    local sid = tostring(source)
    if Employees[jobname][sid] then 
        Employees[jobname][sid].talking = state
        for k, v in pairs(Employees[player.PlayerData.job.name]) do
            TriggerClientEvent('vr-10system:client:updateList', k, Employees[player.PlayerData.job.name])
        end
    end
end)

RegisterNetEvent("vr-10system:server:saveTagsColors")
AddEventHandler("vr-10system:server:saveTagsColors", function(tags)
    local src = source
    local Player = Core.Functions.GetPlayer(src)
    if not Colors[Player.PlayerData.job.name] then
        Colors[Player.PlayerData.job.name] = {}
    end
    for k, v in pairs(tags) do
        local minmaxtags = v.min .."-".. v.max
        Colors[Player.PlayerData.job.name][minmaxtags] = v.color
    end
    SaveResourceFile(GetCurrentResourceName(), "./colors.json", json.encode(Colors), -1)
    TriggerClientEvent('vr-10system:client:updateTagsColorsList', -1, Colors[Player.PlayerData.job.name])
end)

RegisterNetEvent("vr-10system:server:saveNewTagsColors")
AddEventHandler("vr-10system:server:saveNewTagsColors", function(tags)
    local src = source
    local Player = Core.Functions.GetPlayer(src)
    local NewColors = {}
    if not NewColors[Player.PlayerData.job.name] then
        NewColors[Player.PlayerData.job.name] = {}
    end
    for k, v in pairs(tags) do
        local minmaxtags = v.min .."-".. v.max
        NewColors[Player.PlayerData.job.name][minmaxtags] = v.color
    end
    SaveResourceFile(GetCurrentResourceName(), "./colors.json", json.encode(NewColors), -1)
    TriggerClientEvent('vr-10system:client:updateTagsColorsList', -1, NewColors[Player.PlayerData.job.name])
end)




function getPlayerInfo(src)
    local player = Core.Functions.GetPlayer(src)
    if not player then
        return nil
    end
    if Codes[player.PlayerData.job.name] and Codes[player.PlayerData.job.name][tostring(player.PlayerData.citizenid)] then
        return Codes[player.PlayerData.job.name][tostring(player.PlayerData.citizenid)]
    end

    return nil
end 
