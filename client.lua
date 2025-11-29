local QBCore = exports['qb-core']:GetCoreObject()
local PlayerData = {}
local lastTargetTime = 0
local cooldown = 1000

RegisterNetEvent('QBCore:Client:OnPlayerLoaded', function()
    PlayerData = QBCore.Functions.GetPlayerData()
end)

RegisterNetEvent('QBCore:Client:OnJobUpdate', function(JobInfo)
    PlayerData.job = JobInfo
end)

function PlayIDAnimation()
    local ped = PlayerPedId()
    
    RequestAnimDict("mp_common")
    while not HasAnimDictLoaded("mp_common") do
        Wait(10)
    end
    
    TaskPlayAnim(ped, "mp_common", "givetake1_a", 8.0, -8.0, -1, 0, 0, false, false, false)

    Citizen.CreateThread(function()
        Wait(2000)
        StopAnimTask(ped, "mp_common", "givetake1_a", 1.0)
    end)
end

function ShowNotification(msg, type)
    if Config.NotificationType == 'ox' then
        lib.notify({
            title = 'ID System',
            description = msg,
            type = type or 'inform',
            position = 'top'
        })
    elseif Config.NotificationType == 'okok' then
        exports['okokNotify']:Alert("ID SYSTEM", msg, 5000, type or 'info')
    elseif Config.NotificationType == 'mythic' then
        exports['mythic_notify']:DoHudText('inform', msg)
    elseif Config.NotificationType == 'qb' then
        QBCore.Functions.Notify(msg, type or 'primary', 5000)
    else
        lib.notify({
            title = 'ID System',
            description = msg,
            type = type or 'inform',
            position = 'top'
        })
    end
end

exports.ox_target:addGlobalPlayer({
    {
        name = 'show_player_id',
        icon = 'fas fa-id-card',
        label = 'Show Player ID',
        distance = 2.5,
        onSelect = function(data)
            local currentTime = GetGameTimer()

            if currentTime - lastTargetTime < cooldown then
                ShowNotification("Please wait before checking another ID", 'error')
                return
            end
            
            lastTargetTime = currentTime
            
            local targetEntity = data.entity
            
            if DoesEntityExist(targetEntity) and IsEntityAPed(targetEntity) then
                local playerId = GetPlayerServerId(NetworkGetEntityOwner(targetEntity))
                
                if playerId > 0 and playerId ~= GetPlayerServerId(PlayerId()) then
                    if Config.ShowAnimation then
                        PlayIDAnimation()
                    end

                    ShowNotification("Player ID: " .. playerId, 'success')
                   
                    if Config.Debug then
                        print("[ShowID] Displayed ID: " .. playerId)
                    end
                else
                    ShowNotification("Cannot check your own ID", 'error')
                end
            else
                ShowNotification("No valid player targeted", 'error')
            end
        end,
        canInteract = function(entity, distance, data)
            if not IsPedAPlayer(entity) then return false end
            local targetPlayerId = GetPlayerServerId(NetworkGetEntityOwner(entity))
            return targetPlayerId ~= GetPlayerServerId(PlayerId())
        end
    }
})

RegisterCommand('myid', function()
    local playerId = GetPlayerServerId(PlayerId())
    ShowNotification("Your Player ID: " .. playerId, 'inform')
    
    if Config.Debug then
        print("[ShowID] My ID: " .. playerId)
    end
end, false)

TriggerEvent('chat:removeSuggestion', '/myid')
TriggerEvent('chat:addSuggestion', '/myid', 'Show your own player ID', {})

if Config.EnableKeybind then
    RegisterKeyMapping('myid', 'Show Your Player ID', 'keyboard', Config.Keybind)

    Citizen.CreateThread(function()
        while true do
            Wait(10000)
            if Config.ShowKeybindHelp then
                print("[ShowID] Press " .. Config.Keybind .. " or type /myid to see your player ID")
            end
        end
    end)
end

if Config.ShowFloatingText then
    Citizen.CreateThread(function()
        while true do
            local sleep = 1000
            local playerCoords = GetEntityCoords(PlayerPedId())
            
            for _, player in ipairs(GetActivePlayers()) do
                local targetPed = GetPlayerPed(player)
                local targetCoords = GetEntityCoords(targetPed)
                local distance = #(playerCoords - targetCoords)
                
                if distance < 10.0 and targetPed ~= PlayerPedId() then
                    sleep = 0
                    local playerId = GetPlayerServerId(player)
                    local text = "ID: " .. playerId

                    lib.drawText3D({
                        coords = vector3(targetCoords.x, targetCoords.y, targetCoords.z + 1.0),
                        text = text,
                        size = 0.3,
                        color = {255, 255, 255, 255}
                    })
                end
            end
            
            Wait(sleep)
        end
    end)
end

if Config.Debug then
    RegisterCommand('showid_debug', function()
        print("=== ShowID Debug Information ===")
        print("Player ID: " .. GetPlayerServerId(PlayerId()))
        print("Resource Name: " .. GetCurrentResourceName())
        print("OX Target Available: " .. tostring(exports.ox_target ~= nil))
        print("QB Core Available: " .. tostring(exports['qb-core'] ~= nil))
        print("Notification Type: " .. Config.NotificationType)
        print("=================================")
    end, false)
end
