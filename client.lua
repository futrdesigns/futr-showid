local QBCore = exports['qb-core']:GetCoreObject()
local PlayerData = {}
local lastTargetTime = 0
local cooldown = 1000 -- 1 second cooldown

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
    if Config.NotificationType == 'qb' then
        QBCore.Functions.Notify(msg, type or 'primary', 5000)
    elseif Config.NotificationType == 'okok' then
        exports['okokNotify']:Alert("ID System", msg, 5000, type or 'info')
    elseif Config.NotificationType == 'mythic' then
        exports['mythic_notify']:DoHudText('inform', msg)
    else
        -- Default QB
        QBCore.Functions.Notify(msg, 'primary', 5000)
    end
end

exports['qb-target']:AddGlobalPlayer({
    options = {
        {
            type = "client",
            icon = 'fas fa-id-card',
            label = 'Show Player ID',
            action = function(entity)
                local currentTime = GetGameTimer()
                
                -- Cooldown check
                if currentTime - lastTargetTime < cooldown then
                    ShowNotification("Please wait before checking another ID", 'error')
                    return
                end
                
                lastTargetTime = currentTime
                
                if DoesEntityExist(entity) and IsEntityAPed(entity) then
                    local playerId = GetPlayerServerId(NetworkGetEntityOwner(entity))
                    
                    if playerId > 0 then
                        -- Play animation
                        if Config.ShowAnimation then
                            PlayIDAnimation()
                        end
                        
                        -- Show ID notification
                        ShowNotification("Player ID: " .. playerId, 'success')
                        
                        -- Debug message
                        if Config.Debug then
                            print("[ShowID] Displayed ID: " .. playerId)
                        end
                    else
                        ShowNotification("Invalid player targeted", 'error')
                    end
                else
                    ShowNotification("No valid player targeted", 'error')
                end
            end,
            canInteract = function(entity, distance, data)
                return not IsPedAPlayer(entity) or (IsPedAPlayer(entity) and GetPlayerServerId(NetworkGetEntityOwner(entity)) ~= GetPlayerServerId(PlayerId()))
            end
        }
    },
    distance = 2.5
})

RegisterCommand('myid', function()
    local playerId = GetPlayerServerId(PlayerId())
    ShowNotification("Your Player ID: " .. playerId, 'primary')
end, false)

if Config.EnableKeybind then
    RegisterKeyMapping('myid', 'Show Your Player ID', 'keyboard', Config.Keybind)
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
                    
                    exports['qb-core']:DrawText3D(targetCoords.x, targetCoords.y, targetCoords.z + 1.0, text)
                end
            end
            
            Wait(sleep)
        end
    end)
end
