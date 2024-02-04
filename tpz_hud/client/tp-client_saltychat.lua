
if Config.SaltyChat then

    local isChangingRange = false
    local changedRange    = 0

    if Config.ChangingRangeData.Enabled then

        -- @param voiceRange 	        float 	current voice range
        -- @param index 	            int 	index of the current voice range (starts at 0)
        -- @param availableVoiceRanges 	int 	count of available voice ranges

        AddEventHandler('SaltyChat_VoiceRangeChanged', function(voiceRange, index, availableVoiceRanges)
    
            changedRange = voiceRange
            isChangingRange = true
        
            Wait(500)
            isChangingRange = false
    
            TriggerEvent("tpz_hud:onSaltyChatVoiceRangeChange", changedRange)
        end)
        
        Citizen.CreateThread(function ()
            while true do
                Citizen.Wait(0)
        
                if isChangingRange then
                    local data   = Config.ChangingRangeData.RGBA
                    local coords = GetEntityCoords(PlayerPedId())
    
                    Citizen.InvokeNative(0x2A32FAA57B937173, 0x94FDAE17, coords.x, coords.y, coords.z - 1.0, 0, 0, 0, 0, 0, 0, changedRange, changedRange, 2.0, 
                    data.r, data.g, data.b, 50, 0, 0, 2, 0, 0, 0, 0)
                end
            end
        end)
    end
    
    -- @param isTalking 	        bool 	true when player starts talking, false when the player stops talking
    AddEventHandler('SaltyChat_TalkStateChanged', function(isTalking)
        TriggerEvent("tpz_hud:onSaltyChatTalkStateChanged", isTalking)
    end)

end    