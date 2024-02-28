
ClientData = { 
	HasHUDDisplayed           = false,
	HasWheelMenuOpen          = false,
	HasMetabolismLoaded       = false, 
	HasLevelingLoaded         = false,

	Thirst                    = 0, 
	Hunger                    = 0, 
	Stress                    = 0,
	StressCooldown            = 0,
	Alcohol                   = 0,
	Temperature               = 0,

	DirtLevel                 = 0,

	IsTalking                 = false,
	VoiceRange                = Config.DefaultMicRange,

	IndicatorStatus           = true,

	HasHiddenStatus           = false,
}

-----------------------------------------------------------
--[[ Events ]]--
-----------------------------------------------------------

AddEventHandler("tpz_leveling:isLoaded", function()
	ClientData.HasLevelingLoaded = true

	if Config.tpz_leveling then
		SendNUIMessage({ action = "SET_LEVELING_DISPLAY_STATUS", status = true})
	end
end)

AddEventHandler("tpz_metabolism:isLoaded", function()
	ClientData.HasMetabolismLoaded = true

	SendNUIMessage({ action = "SET_HUD_DISPLAY_STATUS", status = true, hasLeveling = ClientData.HasLevelingLoaded, hasDirtSystem = Config.tp_dirtsystem, hasStress = Config.DisplayStress})
	ClientData.HasHUDDisplayed = true
end)


AddEventHandler("tpz_metabolism:getCurrentMetabolismValues", function(hunger, thirst, stress, alcohol)
	ClientData.Hunger  = hunger
	ClientData.Thirst  = thirst
	ClientData.Stress  = stress
	ClientData.Alcohol = alcohol
end)

AddEventHandler("tpz_metabolism:getCurrentTemperature", function(temperature)
	ClientData.Temperature = temperature

end)

AddEventHandler("tp_dirtsystem:getCurrentDirtLevel", function(dirtLevel)
	ClientData.DirtLevel = dirtLevel
end)

if not Config.SaltyChat then

	CreateThread(function()
		while true do 
			Wait(Config.VoicePressingDelay)
	
			ClientData.IsTalking = IsControlPressed(0, Config.VoiceKey)

			SendNUIMessage({ action = "UPDATE_VOICE_TALK_STATUS", isTalking = ClientData.IsTalking })
		end
	end)

end


RegisterNetEvent("tpz_hud:setHiddenStatus")
AddEventHandler("tpz_hud:setHiddenStatus", function(cb)
	ClientData.HasHiddenStatus = cb
end)

-----------------------------------------------------------
--[[ SALTY CHAT ]]--
-----------------------------------------------------------

-- @onSaltyChatTalkStateChanged supports Salty Chat when someone is talking.
RegisterNetEvent("tpz_hud:onSaltyChatTalkStateChanged")
AddEventHandler("tpz_hud:onSaltyChatTalkStateChanged", function(cb)
	ClientData.IsTalking = cb
	SendNUIMessage({ action = "UPDATE_VOICE_TALK_STATUS", isTalking = ClientData.IsTalking })
end)

-- @onSaltyChatVoiceRangeChange supports Salty Chat when someone is changing voice range.
RegisterNetEvent("tpz_hud:onSaltyChatVoiceRangeChange")
AddEventHandler("tpz_hud:onSaltyChatVoiceRangeChange", function(range)
	ClientData.VoiceRange = range
end)

-----------------------------------------------------------

-- With the following NUI Message, for first time when loading the client
-- we set the HUD visibility status to false.
Citizen.CreateThread(function ()

	DisplayRadar(false)

	SendNUIMessage({ action = "SET_HUD_DISPLAY_STATUS", status = false, hasLeveling = ClientData.HasLevelingLoaded, hasDirtSystem = Config.tp_dirtsystem, hasStress = Config.DisplayStress})

	if Config.DevMode then

		Citizen.CreateThread(function ()
			
			TriggerEvent("tpz_metabolism:requestMetabolismData")

			ClientData.HasMetabolismLoaded = true
			ClientData.HasLevelingLoaded   = true

			SendNUIMessage({ action = "SET_HUD_DISPLAY_STATUS", status = true, hasLeveling = ClientData.HasLevelingLoaded, hasDirtSystem = Config.tp_dirtsystem, hasStress = Config.DisplayStress})

			ClientData.HasHUDDisplayed     = true

			if Config.tpz_leveling then
				SendNUIMessage({ action = "SET_LEVELING_DISPLAY_STATUS", status = true})
			end

		end)
	
	end

end)

-----------------------------------------------------------
--[[ Functions ]]--
-----------------------------------------------------------

local GetLevelData = function (levelType)
	local data = exports.tpz_leveling:GetLevelTypeExperienceData(levelType)

	return data.level, data.experience
end

-----------------------------------------------------------
--[[ Threads ]]--
-----------------------------------------------------------

Citizen.CreateThread(function()
    while true do
        Citizen.Wait(Config.UpdateHUDDelay)

		local isPaused          = IsPauseMenuActive()
		local isInCimematicMode = Citizen.InvokeNative(0x74F1D22EFA71FAB8)

		if ClientData.HasMetabolismLoaded then

			-- ShowPlayerCores Might required to be used all the time.
			Citizen.InvokeNative(0x50C803A4CD5932C5, true)

			if not ClientData.HasHiddenStatus and ClientData.HasHUDDisplayed and ClientData.IndicatorStatus and not isPaused and not isInCimematicMode and IsAppActive(`MAP`) ~= 1 and not IsScreenFadedOut() then

				if Config.tp_dirtsystem then
	
					if not ClientData.DirtLevel or ClientData.DirtLevel < 100 then
						ClientData.DirtLevel = -1
					else
						ClientData.DirtLevel = ClientData.DirtLevel / 100
					end
	
				end
	
				local tempPercentColor = Config.TemperatureColors['Default']
	
				if ClientData.Temperature <= Config.TemperatureColors['Cold'].temp then
					tempPercentColor = Config.TemperatureColors['Cold'].rgba
	
				elseif ClientData.Temperature >= Config.TemperatureColors['Hot'].temp then
					tempPercentColor = Config.TemperatureColors['Hot'].rgba
				end
	
				local huntingLevel, farmingLevel, miningLevel, lumberjackingLevel, fishingLevel = 1, 1, 1, 1, 1
				local huntingExperience, farmingExperience, miningExperience, lumberjackingExperience, fishingExperience = 0, 0, 0, 0, 0
	

				if ClientData.Hunger == 0 then
					ClientData.Hunger = -1
				end

				if ClientData.Thirst == 0 then
					ClientData.Thirst = -1
				end

				if ClientData.Stress == 0 then
					ClientData.Stress = -1
				end

				if ClientData.Alcohol == 0 then
					ClientData.Alcohol = -1
				end

				if myDirtLevel == 0 then
					myDirtLevel = -1
				end

				if ClientData.HasLevelingLoaded and Config.tpz_leveling then
	
					lumberjackingLevel, lumberjackingExperience = GetLevelData("lumberjack")
					huntingLevel, huntingExperience             = GetLevelData("hunting")
					farmingLevel, farmingExperience             = GetLevelData("farming")
					miningLevel, miningExperience               = GetLevelData("mining")
					fishingLevel, fishingExperience             = GetLevelData("fishing")

					SendNUIMessage({
						action = "UPDATE_HUD_STATUS",
	
						lumberjacking = { level = lumberjackingLevel, experience = ( (lumberjackingExperience * 100) / 1000) },
						hunting       = { level = huntingLevel,       experience = ( (huntingExperience * 100) / 1000) },
						farming       = { level = farmingLevel,       experience = ( (farmingExperience * 100) / 1000) },
						mining        = { level = miningLevel,        experience = ( (miningExperience * 100) / 1000)  },
						fishing       = { level = fishingLevel,       experience = ( (fishingExperience * 100) / 1000) },
	
						hunger = ClientData.Hunger,
						thirst = ClientData.Thirst,
	
						dirt   = myDirtLevel,
	
						temp = math.floor(ClientData.Temperature).."°C",
						tempColor = tempPercentColor,
	
						stress = ClientData.Stress,
						alcohol = ClientData.Alcohol,
	
						voice = (ClientData.VoiceRange * 100) / 32,
					})

				else

					SendNUIMessage({
						action = "UPDATE_HUD_STATUS",

						hunger = ClientData.Hunger,
						thirst = ClientData.Thirst,
	
						dirt   = myDirtLevel,
	
						temp = math.floor(ClientData.Temperature).."°C",
						tempColor = tempPercentColor,
	
						stress = ClientData.Stress,
						alcohol = ClientData.Alcohol,

						voice = (ClientData.VoiceRange * 100) / 32,
					})

				end

				SendNUIMessage({ action = "DISPLAY_HUD", display = true })
	
			else
				SendNUIMessage({ action = "DISPLAY_HUD", display = false })
			end
		end

    end
end)

Citizen.CreateThread(function()

	while true do
		Citizen.Wait(1000)

		if ClientData.HasHUDDisplayed and not IsPauseMenuActive() and IsAppActive(`MAP`) ~= 1 and not ClientData.HasHiddenStatus then
			DisplayRadar(true)
		end

		local isIndicatorsActive = Citizen.InvokeNative(0x2CC24A2A7A1489C4)

		if ClientData.HasMetabolismLoaded then

			if not isIndicatorsActive then

				if ClientData.IndicatorStatus then

					ClientData.IndicatorStatus = false

					SendNUIMessage({ action = "SET_HUD_DISPLAY_STATUS", status = false, hasLeveling = ClientData.HasLevelingLoaded, hasDirtSystem = Config.tp_dirtsystem, hasStress = Config.DisplayStress })

					SendNUIMessage({ action = "SET_LEVELING_DISPLAY_STATUS", status = false})

				end
			else

				if not ClientData.IndicatorStatus then

					ClientData.IndicatorStatus = true

					SendNUIMessage({ action = "SET_HUD_DISPLAY_STATUS", status = true, hasLeveling = ClientData.HasLevelingLoaded, hasDirtSystem = Config.tp_dirtsystem, hasStress = Config.DisplayStress })

					if ClientData.HasLevelingLoaded then
						SendNUIMessage({ action = "SET_LEVELING_DISPLAY_STATUS", status = true})
					end
				end

			end
		end
	end
	
end)

-- The following thread is hiding all the NUI when being on the weapon wheel menu.
Citizen.CreateThread(function()
    while true do 
        Wait(0)

		if IsControlPressed(0, 0xAC4BD4F1) then 

			if not ClientData.HasWheelMenuOpen and ClientData.HasHUDDisplayed then
				ClientData.HasWheelMenuOpen = true

				ClientData.HasHUDDisplayed = false
				DisplayRadar(false) 
			end

		else
			if ClientData.HasWheelMenuOpen and not ClientData.HasHUDDisplayed then

				ClientData.HasWheelMenuOpen = false

				ClientData.HasHUDDisplayed = true
				DisplayRadar(true) 
			end

		end
    end
end)
