Config = {}

Config.DevMode                   = false

Config.DisplayStress             = true

Config.SaltyChat                 = false
Config.DefaultMicRange           = 8

-- This is used only when Salty Chat is not active (false).
Config.VoiceKey                  = 0x4BC9DABB
Config.VoicePressingDelay        = 500

Config.UpdateHUDDelay            = 1000 -- Currently updating HUD every 1 second for better server performance. The time is in milliseconds.

-- If you're having tpz_leveling then set it to true.
Config.tpz_leveling              = true

-- If you're having tp_realistic_flieswamping then set it to true.
Config.tp_realistic_flieswamping = false


-- You can use rgb, rgba & hashes.
Config.TemperatureColors = {
    ['Default'] = "rgba(0, 0, 0, 0.623)",
    ['Cold']    = {temp = 0,  rgba = "rgb(22, 62, 126)" },
    ['Hot']     = {temp = 40, rgba = "rgb(129, 31, 31)" },
}
