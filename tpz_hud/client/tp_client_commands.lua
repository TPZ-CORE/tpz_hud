
RegisterCommand('hud:hideall', function(source, args, rawCommand)
	ClientData.HasHUDDisplayed = not ClientData.HasHUDDisplayed
	DisplayRadar(ClientData.HasHUDDisplayed)
end)

RegisterCommand('hud:hidenui', function(source, args, rawCommand)
	ClientData.HasHUDDisplayed = not ClientData.HasHUDDisplayed
	DisplayRadar(true)
end)

RegisterCommand('hud:hideleveling', function(source, args, rawCommand)
	ClientData.HasLevelingLoaded = not ClientData.HasLevelingLoaded 
	
	SendNUIMessage({ action = "SET_LEVELING_DISPLAY_STATUS", status = ClientData.HasLevelingLoaded})
end)
