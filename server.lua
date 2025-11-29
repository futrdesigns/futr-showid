print("[ShowID] Server script loaded - Player ID Display System")

RegisterNetEvent('ShowID:logIDCheck', function(checkerId, targetId)
    if Config.Debug then
        print(string.format("[ShowID] Player %d checked ID of player %d", checkerId, targetId))
    end
end)
