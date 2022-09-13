Core = nil
if VRConfig.NewCore then
    Core = exports[VRConfig.Exports]:GetCoreObject()
else
    while Core == nil do
        Wait(10)
        TriggerEvent(VRConfig.Core .. ":GetSharedObject", function(obj) Core = obj end)
    end
end
canBeSeen = false
toggled = false
playerLoaded = false
menuToggled = false
job = {}


RegisterNetEvent(VRConfig.Core .. ":Client:OnPlayerLoaded")
AddEventHandler(VRConfig.Core..":Client:OnPlayerLoaded", function()
    playerLoaded = true
    job = Core.Functions.GetPlayerData().job or {}
    
    if job and CheckValidJob(job.name) then
        TriggerServerEvent('vr-employeelist:server:addToList', job.name, job.onduty)
        toggleList(true)
        Core.Functions.TriggerCallback('vr-10system:server:GetTagsColorsAndJob', function (tagColors, job_)
            SendNUIMessage({
                action = 'updatelist',
                tagstable = tagColors[job_]
            })
        end)
        if VRConfig.ShowOnOffDuty then
            if job.onduty then
                canBeSeen = true
            end
        else
            canBeSeen = true
        end
    else
        canBeSeen = false
    end
end)

AddEventHandler(VRConfig.Core .. ":Client:OnPlayerUnload", function()
    TriggerServerEvent('vr-10system:server:removeFromList')
end)

Citizen.CreateThread(function()
    Wait(1000)
    if playerLoaded then
        job = Core.Functions.GetPlayerData().job

        if CheckValidJob(job.name) then
            TriggerServerEvent('vr-employeelist:server:addToList', job.name, job.onduty)
            toggleList(true)
            Core.Functions.TriggerCallback('vr-10system:server:GetTagsColorsAndJob', function(tagColors, job_)
                SendNUIMessage({
                    action = 'updatelist',
                    tagstable = tagColors[job_]
                })
            end)
            if VRConfig.ShowOnOffDuty then
                if job.onduty then
                    canBeSeen = true
                end
            else
                canBeSeen = true
            end
        else
            canBeSeen = false
        end
    end
end)

RegisterNetEvent(VRConfig.Core .. ':Client:OnJobUpdate')
AddEventHandler(VRConfig.Core..':Client:OnJobUpdate', function(job_)
    job = job_
    if CheckValidJob(job.name) then
        TriggerServerEvent('vr-10system:server:removeFromList')
        TriggerServerEvent('vr-employeelist:server:addToList', job.name, job.onduty)
        if VRConfig.ShowOnOffDuty then
            if job.onduty then
                toggleList(true)
                canBeSeen = true
            end
        else
            canBeSeen = true
        end
    else
        canBeSeen = false
        TriggerServerEvent('vr-10system:server:removeFromList')
        SendNUIMessage({ action = "close" })
    end
end)

local playerConnected = {}

RegisterNetEvent('vr-10system:client:updateList')
AddEventHandler('vr-10system:client:updateList', function(data)
    playerConnected = data
    local id = GetPlayerServerId(PlayerId())
    for k,v in pairs(data) do
        if v.job.name == job.name then
            if v.src == id then
                v.me = true
            end
            if job.grade then
                v.job = job.grade.level
            end
        end
    end
    SendNuiMessage(json.encode({
        action = 'update',
        jobinfo = Core.Shared.Jobs[job.name],
        sortby = VRConfig.WhitelistedJobs[job.name].SortBy,
        showjob = VRConfig.ShowJob,
        data = data
    }))
    
end)

RegisterNetEvent('vr-10system:client:updateTagsColorsList')
AddEventHandler('vr-10system:client:updateTagsColorsList', function(tags)
    SendNUIMessage({
        action = 'updatelist',
        tagstable = tags
    })
end)


function toggleList(toggle)
    if toggle then
        SendNUIMessage({
            action = 'open',
            jobinfo = Core.Shared.Jobs[job.name],
            sortby = VRConfig.WhitelistedJobs[job.name].SortBy,
            showjob = VRConfig.ShowJob,
            data = playerConnected
        })
    else
        SendNUIMessage({
            action = 'close',
        })
    end
end

function toggleMenu(job)
    if canBeSeen then
        Core.Functions.TriggerCallback('vr-10system:server:GetTagsColors', function (tagColors)
            SendNUIMessage({
                action = 'menu',
                isboss = job.isboss,
                colorstags = tagColors[job.name]
            })
            SetNuiFocus(true, true)
        end)
    end
end

RegisterNUICallback("toggleList", function(data)
    toggleList(data.toggled)
end)

RegisterNUICallback("saveChanges", function(data)
    TriggerServerEvent('vr-10system:server:updateCallsign', data.callsign)
end)

RegisterNUICallback("toggleFocus", function(toggle)
    SetNuiFocus(toggle, toggle)
end)

RegisterNUICallback("closeMenu", function()
    SetNuiFocus(false, false)
end)

RegisterNUICallback("saveTags", function(tagsTable)
    tagsTable = tagsTable.alltags
    TriggerServerEvent('vr-10system:server:saveTagsColors', tagsTable)
end)

RegisterNUICallback("saveNewTags", function(tagsTable)
    tagsTable = tagsTable.alltags
    TriggerServerEvent('vr-10system:server:saveNewTagsColors', tagsTable)
end)

RegisterCommand("+vr10system", function(source)
    if canBeSeen then
        toggleMenu(job)
    end
end)


RegisterKeyMapping("+vr10system", "Toggle vr-10system", 'keyboard', "EQUALS")
