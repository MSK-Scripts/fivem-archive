Config = {}
----------------------------------------------------------------
Config.Locale = 'de'
Config.Debug = true
Config.VersionChecker = true
----------------------------------------------------------------
-- Add the Webhook Link in server_discordlog.lua
Config.DiscordLog = true
Config.botColor = "6205745"
Config.botName = "MSK Simcard"
Config.botAvatar = "https://i.imgur.com/PizJGsh.png"
----------------------------------------------------------------
Config.Framework = 'ESX' -- 'ESX' or 'QBCore'

Config.Phone = 'yphone' -- 'chezza', 'gcphone', 'dphone', 'gksphone', 'gksphone_v2', 'highphone', 'roadphone', 'qbphone', 'npwd', 'yphone'

-- If false you need NativeUI installed
Config.dialogBox = true -- If true then you need an_dialogBox (https://github.com/notaymanTV/an_dialogBox)
----------------------------------------------------------------
Config.needPhone = true -- Player has to have a phone in inventory
Config.phoneItem = {'phone'} -- {'phone', 'phone2'} // This should be your phone item // You can set multiple items
Config.usableItem = 'simcard' -- Item to generate a random Number // Add this to your items table in database
Config.removeItem = true -- Set to false if you dont want the item to be deleted after use
Config.StartingDigit = {
    enable = true, -- Set false to disable StartingDigit
    value = "097" -- the starting digits for phone number
}
----------------------------------------------------------------
-- If 'number' then the number would be 094XXXXXX if StartingDigit enabled or XXXXXXXXX if StartingDigit disabled
-- If 'gc' then the number would be 094-XXXX if StartingDigit enabled or XXX-XXXX if StartingDigit disabled
-- If 'canada' then the number would be 094-XXX-XXXX if StartingDigit enabled or XXX-XXX-XXXX if StartingDigit disabled
Config.numberFormat = 'number' -- 'number', 'gc' or 'canada'
----------------------------------------------------------------
-- Config.numberLength is only for Config.wishItem
Config.wishItem = 'simcard_wish' -- Item to insert a Number by yourself // Add this to your items table in database
Config.numberLength = 9 -- max numbers // default: 9 - Number would be 094XXXXXX // numberLength doesn't work for 'gc' and 'canada' option!
----------------------------------------------------------------
Config.changeDefault = true -- Should the Script change the default value? Usefull for some MDT Systems // ESX: users, phone_number // QBCore: players, charinfo
Config.changeDatabase = true -- Set false to deactivate changes in database (Config.Database) // recommended: set true

-- Read the README.md for more information
Config.Database = {
    usersDB = 'users', -- Users Table // ESX default: 'users' // QBCore default: 'players'
    usersIdentifierTB = 'identifier', -- identifier for users table // ESX default: 'identifier' // QBCore default: citizenid

    numberDB = 'yphone_ycloud_accounts', -- In which table is the phonenumber located // ESX default: 'users' // QBCore default: 'players'
    numberTB = 'phone_number', -- Column for phonenumber // ESX default: 'phone_number'  // QBCore default: 'charinfo'
    identifierTB = 'phone_imei' -- identifier for numberDB table // ESX default: 'identifier'  // QBCore default: 'citizenid'
}
----------------------------------------------------------------
-- Change the Event in this function to the Event that changes the Number in your Phone.
-- You can add your own Events here

-- !!! This function is serverside !!!
Config.updateNumber = function(source, newNumber)
    if Config.Phone == 'chezza' then -- Chezza Phone V2
        TriggerEvent('phone:changeNumber', source, newNumber)
    elseif Config.Phone == 'gcphone' then -- GcPhone
        TriggerClientEvent("gcPhone:myPhoneNumber", source, newNumber)
    elseif Config.Phone == 'dphone' then -- D-Phone
        TriggerClientEvent("d-phone:client:changenumber", source, newNumber)
    elseif Config.Phone == 'gksphone' then -- GKSphone
        exports['gksphone']:NumberChange(source, tostring(newNumber))
    elseif Config.Phone == 'gksphone_v2' then -- GKSphone
        local phoneData = exports["gksphone"]:GetPhoneDataBySource(source)
        exports["gksphone"]:NewNumber(source, phoneData.uniqID or nil, tostring(newNumber))
    elseif Config.Phone == 'highphone' then -- HighPhone
        exports['high_phone']:setPlayerPhoneNumber(source, tostring(newNumber))
    elseif Config.Phone == 'roadphone' then -- RoadPhone
        TriggerEvent("roadphone:playerLoad", source)
    elseif Config.Phone == 'qbphone' then -- QBCore Phone
        -- Add your own Events here
    elseif Config.Phone == 'npwd' then -- NPWD Phone
        exports['npwd']:setPhoneNumber(source, newNumber)
    elseif Config.Phone == 'yphone' then -- yFlip/ySeries Phone
        local imei = exports['yseries']:GetPhoneImeiBySourceId(source)
        exports['yseries']:ChangePhoneNumber(imei, newNumber)
    end
    
    Config.Notification(source, Translation[Config.Locale]['updateNumber']:format(newNumber), newNumber)
end
----------------------------------------------------------------
-- !!! This function is clientside AND serverside !!!
Config.Notification = function(source, message, newNumber)
    if IsDuplicityVersion() then -- serverside
        if Config.Framework == 'ESX' then
            TriggerClientEvent('esx:showNotification', source, message)
        elseif Config.Framework == 'QBCore' then
            TriggerClientEvent('QBCore:Notify', source, message, 'primary', 5000)
        end
    else -- clientside
        if Config.Framework == 'ESX' then
            ESX.ShowNotification(message)
        elseif Config.Framework == 'QBCore' then
            QBCore.Functions.Notify(message, 'primary', 5000)
        end
    end
end