Config = {}
----------------------------------------------------------------
Config.Locale = 'de' -- 'de', 'en'
Config.VersionChecker = true
Config.Debug = true
----------------------------------------------------------------
-- Add the Webhook Link in server_discordlog.lua
Config.DiscordLog = true
Config.botColor = "6205745"
Config.botDescription = "Someone died, Death will be added to database counter"
Config.botName = "MSK Scripts"
Config.botAvatar = "https://i.imgur.com/PizJGsh.png"
----------------------------------------------------------------
-- true = counts if player is dead (esx:onPlayerDeath)
-- false = counts if player is revived at hospital (Read the Readme.md)
Config.countDeath = false
----------------------------------------------------------------
Config.maxDeaths = 45
Config.Groups = {'superadmin', 'admin'}
----------------------------------------------------------------
-- This command resets the deathcount to 0 from all characters exept the characters that are blocked.
-- If a character is blocked, the deaths will be set to Config.maxDeaths - Config.blockedCount so the character has Config.blockedCount lives again.
Config.resetCommand = 'deathreset' -- That must not be 'deathcounter' otherwise you break all commands
Config.blockedCount = 3
----------------------------------------------------------------
-- !!! This function is clientside AND serverside !!!
Config.Notification = function(source, message)
    if IsDuplicityVersion() then -- serverside
        TriggerClientEvent('esx:showNotification', source, message)
    else -- clientside
        ESX.ShowNotification(message)
    end
end