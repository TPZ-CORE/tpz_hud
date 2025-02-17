
RegisterCommand('hud:hideall', function(source, args, rawCommand)
	local PlayerData = GetPlayerData()

	PlayerData.HasHUDDisplayed = not PlayerData.HasHUDDisplayed
	DisplayRadar(PlayerData.HasHUDDisplayed)
end)

RegisterCommand('hud:hidenui', function(source, args, rawCommand)
	local PlayerData = GetPlayerData()

	PlayerData.HasHUDDisplayed = not PlayerData.HasHUDDisplayed
	DisplayRadar(true)
end)

RegisterCommand('hud:hideleveling', function(source, args, rawCommand)
	local PlayerData = GetPlayerData()
	
	PlayerData.HasLevelingLoaded = not PlayerData.HasLevelingLoaded 
	
	SendNUIMessage({ action = "SET_LEVELING_DISPLAY_STATUS", status = PlayerData.HasLevelingLoaded})
end)
