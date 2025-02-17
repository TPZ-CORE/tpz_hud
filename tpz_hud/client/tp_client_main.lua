
local PlayerData = { 
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

AddEventHandler("tpz_core:isPlayerReady", function()
    Wait(5000)

    -- If devmode is enabled, we are not running the following code since it already does.
    if Config.DevMode then
        return
    end

	DisplayRadar(false)

	SendNUIMessage({ action = "SET_HUD_DISPLAY_STATUS", status = false, hasLeveling = PlayerData.HasLevelingLoaded, hasDirtSystem = Config.tp_dirtsystem, hasStress = Config.DisplayStress})

	if Config.DevMode then

		Citizen.CreateThread(function ()
			
			TriggerEvent("tpz_metabolism:requestMetabolismData")

			PlayerData.HasMetabolismLoaded = true
			PlayerData.HasLevelingLoaded   = true

			SendNUIMessage({ action = "SET_HUD_DISPLAY_STATUS", status = true, hasLeveling = PlayerData.HasLevelingLoaded, hasDirtSystem = Config.tp_dirtsystem, hasStress = Config.DisplayStress})

			PlayerData.HasHUDDisplayed     = true

			if Config.tpz_leveling then
				SendNUIMessage({ action = "SET_LEVELING_DISPLAY_STATUS", status = true})
			end

		end)
	
	end

end)


AddEventHandler("tpz_leveling:client:playerDataLoaded", function()
	PlayerData.HasLevelingLoaded = true

	if Config.tpz_leveling then
		SendNUIMessage({ action = "SET_LEVELING_DISPLAY_STATUS", status = true})
	end

end)

AddEventHandler("tpz_metabolism:isLoaded", function()
	PlayerData.HasMetabolismLoaded = true

	SendNUIMessage({ action = "SET_HUD_DISPLAY_STATUS", status = true, hasLeveling = PlayerData.HasLevelingLoaded, hasDirtSystem = Config.tp_dirtsystem, hasStress = Config.DisplayStress})
	PlayerData.HasHUDDisplayed = true
end)


AddEventHandler("tpz_metabolism:getCurrentMetabolismValues", function(hunger, thirst, stress, alcohol)
	PlayerData.Hunger  = hunger
	PlayerData.Thirst  = thirst
	PlayerData.Stress  = stress
	PlayerData.Alcohol = alcohol
end)

AddEventHandler("tpz_metabolism:getCurrentTemperature", function(temperature)
	PlayerData.Temperature = temperature

end)

AddEventHandler("tp_dirtsystem:getCurrentDirtLevel", function(dirtLevel)
	PlayerData.DirtLevel = dirtLevel
end)

if not Config.SaltyChat then

	CreateThread(function()
		while true do 
			Wait(Config.VoicePressingDelay)
	
			PlayerData.IsTalking = IsControlPressed(0, Config.VoiceKey)

			SendNUIMessage({ action = "UPDATE_VOICE_TALK_STATUS", isTalking = PlayerData.IsTalking })
		end
	end)

end


RegisterNetEvent("tpz_hud:setHiddenStatus")
AddEventHandler("tpz_hud:setHiddenStatus", function(cb)
	PlayerData.HasHiddenStatus = cb
end)

-----------------------------------------------------------
--[[ SALTY CHAT ]]--
-----------------------------------------------------------

-- @onSaltyChatTalkStateChanged supports Salty Chat when someone is talking.
RegisterNetEvent("tpz_hud:onSaltyChatTalkStateChanged")
AddEventHandler("tpz_hud:onSaltyChatTalkStateChanged", function(cb)
	PlayerData.IsTalking = cb
	SendNUIMessage({ action = "UPDATE_VOICE_TALK_STATUS", isTalking = PlayerData.IsTalking })
end)

-- @onSaltyChatVoiceRangeChange supports Salty Chat when someone is changing voice range.
RegisterNetEvent("tpz_hud:onSaltyChatVoiceRangeChange")
AddEventHandler("tpz_hud:onSaltyChatVoiceRangeChange", function(range)
	PlayerData.VoiceRange = range
end)

-----------------------------------------------------------

-- With the following NUI Message, for first time when loading the client
-- we set the HUD visibility status to false.
if Config.DevMode then

	Citizen.CreateThread(function ()
		
		DisplayRadar(false)
		SendNUIMessage({ action = "SET_HUD_DISPLAY_STATUS", status = false, hasLeveling = PlayerData.HasLevelingLoaded, hasDirtSystem = Config.tp_dirtsystem, hasStress = Config.DisplayStress})
	
		TriggerEvent("tpz_metabolism:requestMetabolismData")

		PlayerData.HasMetabolismLoaded = true
		PlayerData.HasLevelingLoaded   = true

		SendNUIMessage({ action = "SET_HUD_DISPLAY_STATUS", status = true, hasLeveling = PlayerData.HasLevelingLoaded, hasDirtSystem = Config.tp_dirtsystem, hasStress = Config.DisplayStress})

		PlayerData.HasHUDDisplayed     = true

		if Config.tpz_leveling then
			SendNUIMessage({ action = "SET_LEVELING_DISPLAY_STATUS", status = true})
		end

	end)

end

function GetPlayerData()
	return PlayerData
end

-----------------------------------------------------------
--[[ Local Functions ]]--
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

		if PlayerData.HasMetabolismLoaded then

			-- ShowPlayerCores Might required to be used all the time.
			Citizen.InvokeNative(0x50C803A4CD5932C5, true)

			if not PlayerData.HasHiddenStatus and PlayerData.HasHUDDisplayed and PlayerData.IndicatorStatus and not isPaused and not isInCimematicMode and IsAppActive(`MAP`) ~= 1 and not IsScreenFadedOut() then

				if Config.tp_dirtsystem then
	
					if not PlayerData.DirtLevel or PlayerData.DirtLevel < 100 then
						PlayerData.DirtLevel = -1
					else
						PlayerData.DirtLevel = PlayerData.DirtLevel / 100
					end
	
				end
	
				local tempPercentColor = Config.TemperatureColors['Default']
	
				if PlayerData.Temperature <= Config.TemperatureColors['Cold'].temp then
					tempPercentColor = Config.TemperatureColors['Cold'].rgba
	
				elseif PlayerData.Temperature >= Config.TemperatureColors['Hot'].temp then
					tempPercentColor = Config.TemperatureColors['Hot'].rgba
				end
	
				local huntingLevel, farmingLevel, miningLevel, lumberjackingLevel, fishingLevel = 1, 1, 1, 1, 1
				local huntingExperience, farmingExperience, miningExperience, lumberjackingExperience, fishingExperience = 0, 0, 0, 0, 0
	

				if PlayerData.Hunger == 0 then
					PlayerData.Hunger = -1
				end

				if PlayerData.Thirst == 0 then
					PlayerData.Thirst = -1
				end

				if PlayerData.Stress == 0 then
					PlayerData.Stress = -1
				end

				if PlayerData.Alcohol == 0 then
					PlayerData.Alcohol = -1
				end

				if PlayerData.DirtLevel == 0 then
					PlayerData.DirtLevel = -1
				end

				if PlayerData.HasLevelingLoaded and Config.tpz_leveling then

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
	
						hunger = PlayerData.Hunger,
						thirst = PlayerData.Thirst,
	
						dirt   = PlayerData.DirtLevel,
	
						temp = math.floor(PlayerData.Temperature).."°C",
						tempColor = tempPercentColor,
	
						stress = PlayerData.Stress,
						alcohol = PlayerData.Alcohol,
	
						voice = (PlayerData.VoiceRange * 100) / 32,
					})

				else

					SendNUIMessage({
						action = "UPDATE_HUD_STATUS",

						hunger = PlayerData.Hunger,
						thirst = PlayerData.Thirst,
	
						dirt   = PlayerData.DirtLevel,
	
						temp = math.floor(PlayerData.Temperature).."°C",
						tempColor = tempPercentColor,
	
						stress = PlayerData.Stress,
						alcohol = PlayerData.Alcohol,

						voice = (PlayerData.VoiceRange * 100) / 32,
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

		if PlayerData.HasHUDDisplayed and not IsPauseMenuActive() and IsAppActive(`MAP`) ~= 1 and not PlayerData.HasHiddenStatus then
			DisplayRadar(true)
		end

		local isIndicatorsActive = Citizen.InvokeNative(0x2CC24A2A7A1489C4)

		if PlayerData.HasMetabolismLoaded then

			if not isIndicatorsActive then

				if PlayerData.IndicatorStatus then

					PlayerData.IndicatorStatus = false

					SendNUIMessage({ action = "SET_HUD_DISPLAY_STATUS", status = false, hasLeveling = PlayerData.HasLevelingLoaded, hasDirtSystem = Config.tp_dirtsystem, hasStress = Config.DisplayStress })

					SendNUIMessage({ action = "SET_LEVELING_DISPLAY_STATUS", status = false})

				end
			else

				if not PlayerData.IndicatorStatus then

					PlayerData.IndicatorStatus = true

					SendNUIMessage({ action = "SET_HUD_DISPLAY_STATUS", status = true, hasLeveling = PlayerData.HasLevelingLoaded, hasDirtSystem = Config.tp_dirtsystem, hasStress = Config.DisplayStress })

					if PlayerData.HasLevelingLoaded then
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

			if not PlayerData.HasWheelMenuOpen and PlayerData.HasHUDDisplayed then
				PlayerData.HasWheelMenuOpen = true

				PlayerData.HasHUDDisplayed = false
				DisplayRadar(false) 
			end

		else
			if PlayerData.HasWheelMenuOpen and not PlayerData.HasHUDDisplayed then

				PlayerData.HasWheelMenuOpen = false

				PlayerData.HasHUDDisplayed = true
				DisplayRadar(true) 
			end

		end
    end
end)
