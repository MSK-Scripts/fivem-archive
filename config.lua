Config = {}
----------------------------------------------------------------
Config.Locale = 'de'
Config.Debug = true
Config.VersionChecker = true
----------------------------------------------------------------
-- !!! This function is clientside AND serverside !!!
Config.Notification = function(source, message, info)
    if IsDuplicityVersion() then -- serverside
        MSK.Notification(source, { title = 'MSK Radio', message = message, type = info })
    else -- clientside
        MSK.Notification({ title = 'MSK Radio', message = message, type = info })
    end
end
----------------------------------------------------------------
Config.Framework = 'ESX' -- Set to 'ESX' or 'QBCore'

Config.VoiceSystem = 'pma' -- Set to 'saltychat', 'pma' or 'tokovoip'

Config.showMemberListButton = true -- Show Members in your Radio Channel
Config.showSpeakerButton = true -- Share radio talk with nearby players // Only for saltychat

Config.RadioAnimation = true -- Animation while radio is open
Config.RadioAnimationTalking = true -- Animation while talking

Config.DisconnectOnItemRemove = true -- Enable if you want to disconnect from radio if you dont have radio
----------------------------------------------------------------
Config.Command = {
    enable = true, -- Use the Command to open the Radio
    command = 'radio',
    checkItem = true -- Enable if you want to check if the player has the Item
}

Config.Hotkey = {
    enable = false, -- Use the Hotkey to open the Radio // Only works if Command is set to true
    hotkey = 'J'
}

Config.Item = {
    enable = true, -- Use the item to open the Radio
    item = 'radio'
}
----------------------------------------------------------------
Config.EncryptedChannels = {
    [1] = {'police'},
    [1.1] = {'police'},
    [2] = {'fib'},
    [2.1] = {'fib'},
    [3] = {'ambulance'},
    [4] = {'doj'},
}