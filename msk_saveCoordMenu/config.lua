Config = {}
----------------------------------------------------------------
Config.Debug = true
Config.Locale = 'de'
Config.VersionChecker = true
----------------------------------------------------------------
-- Add the Webhook Link in server_discordlog.lua
Config.DiscordLog = true
Config.botColor = "6205745" -- https://www.mathsisfun.com/hexadecimal-decimal-colors.html
Config.botName = "MSK Scripts"
Config.botAvatar = "https://i.imgur.com/PizJGsh.png"
Config.botTitle = "MSK SaveCoordMenu"
----------------------------------------------------------------
Config.ESX = 'legacy' -- Set to '1.1' or 'legacy' // 'legacy' is recommended
Config.Command = 'openAdminMenu' -- Command to open the NativeUI
Config.Ranks = {'superadmin', 'admin'} -- Groups that can use the Command

Config.DefaultCoords = {
    {rank = 'superadmin', name = 'Test 1', coords = {x = -2098.43, y = 2868.7, z = 32.81}},
    {rank = 'superadmin', name = 'Test 2', coords = {x = -2133.47, y = 2885.41, z = 32.81}},
}

-- Export um das Menu durch ein anderes Menü zu öffnen:
-- exports["msk_saveCoordMenu"]:openSaveCoordMenu()