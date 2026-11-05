Config = {}
----------------------------------------------------------------
Config.Locale = 'de' -- 'de', 'en'
Config.VersionChecker = false
Config.Debug = true
----------------------------------------------------------------
Config.Framework = 'ESX' -- Set to 'ESX' or 'QBCore'
----------------------------------------------------------------
-- !!! This function is clientside AND serverside !!!
Config.Notification = function(source, message, info, duration)
    if IsDuplicityVersion() then -- serverside
        MSK.Notification(source, 'MSK Cardealer', message, info, duration)
    else -- clientside
        MSK.Notification('MSK Cardealer', message, info, duration)
    end
end
----------------------------------------------------------------
Config.Hotkey = 38 -- default: 38 = E
Config.Item = 'dealership' -- Add it in the items table in your database
Config.Command = {enable = false, command = 'dealership'}
Config.maxDistance = 25.0 -- Distance between player and vehicle to show the Text
----------------------------------------------------------------
Config.Blip = {
    enable = true,
    coords = {
        {x = -745.63, y = -1038.56, z = 12.67},
    },
    label = 'Gebrauchtwagenhändler',
    id = 811, --562,
    color = 46,
    scale = 0.8
}