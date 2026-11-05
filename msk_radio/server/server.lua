-- Notifications, TextUI and progress bars use the table forms of msk_core 4.1.0.
-- An older msk_core shows broken notifications, so say it loudly on start.
MSK.Check.Dependency('msk_core', '4.1.0', true)

if Config.Framework == 'QBCore' then
    QBCore = exports['qb-core']:GetCoreObject()
end

----------------------------------------------------------------
-- Register all Items
----------------------------------------------------------------
if Config.Item.enable then
    if Config.Framework == 'ESX' then 
        ESX.RegisterUsableItem(Config.Item.item, function(source)
            TriggerClientEvent('msk_radio:openRadio', source)
        end)
    elseif Config.Framework == 'QBCore' then 
        QBCore.Functions.CreateUseableItem(Config.Item.item, function(source, item)
            TriggerClientEvent('msk_radio:openRadio', source)
        end)
    end
end

----------------------------------------------------------------
-- Register Events
----------------------------------------------------------------
RegisterNetEvent('msk_radio:addPlayerToRadio', function(channel)
    local playerId = source

    addPlayerToRadio(playerId, channel)
end)

RegisterNetEvent('msk_radio:removePlayerToRadio', function(channel)
    local playerId = source
    
    removePlayerFromRadio(playerId, channel)
end)

----------------------------------------------------------------
-- Register Callbacks
----------------------------------------------------------------
MSK.Register('msk_radio:getChannelMembers', function(source, channel)
    return getChannelMembers(channel, source) -- source only for tokovoip
end)

MSK.Register('msk_radio:hasChannelPassword', function(source, channel)
    return hasChannelPassword(channel)
end)

MSK.Register('msk_radio:checkChannelPassword', function(source, channel, password)
    return checkChannelPassword(channel, password)
end)

MSK.Register('msk_radio:isFirstInChannel', function(source, channel)
    return isFirstInChannel(channel, source) -- source only for tokovoip
end)