RegisterServerEvent('msk_armor:giveNoBProofItem')
AddEventHandler('msk_armor:giveNoBProofItem', function()
    local xPlayer = ESX.GetPlayerFromId(source)
    local hasItem = xPlayer.getInventoryItem('nobproof')

    if not hasItem or hasItem.count == 0 then
        xPlayer.addInventoryItem('nobproof', 1)
        logging('debug', 'Item nobproof added on Event giveNoBProofItem')
    end
end)

RegisterServerEvent('msk_armor:removeNoBProofItem')
AddEventHandler('msk_armor:removeNoBProofItem', function()
    local xPlayer = ESX.GetPlayerFromId(source)
    local hasItem = xPlayer.getInventoryItem('nobproof')

    if hasItem and hasItem.count >= 1 then
        xPlayer.removeInventoryItem('nobproof', hasItem.count)
        logging('debug', 'Item nobproof deleted on Event removeNoBProofItem')
    end
end)

MSK.Register('msk_armor:setHotkey', function(source, itemName)
    local src = source
    local xPlayer = ESX.GetPlayerFromId(src)
    local hasItem = xPlayer.getInventoryItem(itemName)

    if hasItem and hasItem.count >= 1 then
        xPlayer.removeInventoryItem(itemName, 1)

        return itemName, {label = Config.Armories[itemName].label, percent = Config.Armories[itemName].percent, skin = Config.Armories[itemName].skin, removeItem = Config.Armories[itemName].removeItem}
    else
        return itemName, false
    end
end)

for k, v in pairs(Config.Armories) do
    ESX.RegisterUsableItem(k, function(source)
        local src = source
        local xPlayer = ESX.GetPlayerFromId(src)
        local hasItem = xPlayer.getInventoryItem('nobproof')

        if not v.jobs.enable or (v.jobs.enable and MSK.Table_Contains(v.jobs.jobs, xPlayer.job.name)) then
            if hasItem and hasItem.count >= 1 then
                xPlayer.removeInventoryItem('nobproof', hasItem.count)
            end
            
            xPlayer.triggerEvent('msk_armor:setArmor', k, v)

            if v.removeItem then
                xPlayer.removeInventoryItem(k, 1)
            end

            if Config.giveNoBProof then
                xPlayer.addInventoryItem('nobproof', 1)
            end
            Config.Notification(src, _U('used_bproof'))
        else
            Config.Notification(src, _U('no_job'))
        end
    end)
end

ESX.RegisterUsableItem('nobproof', function(source)
    local src = source
	local xPlayer = ESX.GetPlayerFromId(src)
    local hasItem = xPlayer.getInventoryItem('nobproof')
    
    if hasItem and hasItem.count >= 1 then
        xPlayer.removeInventoryItem('nobproof', hasItem.count)
    end

    xPlayer.triggerEvent('msk_armor:setDelArmor')
    Config.Notification(src, _U('used_nobproof'))
end)

MSK.Register('msk_armor:getStatusFromDB', function(source)
    local src = source
    local xPlayer = ESX.GetPlayerFromId(src)
    local vest = {health = 200, armor = 0, item = nil}

    if xPlayer then
        local data = MySQL.query.await('SELECT * FROM users WHERE identifier = @identifier', { 
            ["@identifier"] = xPlayer.identifier
        })
        local item = MySQL.query.await('SELECT * FROM msk_armor WHERE identifier = @identifier', { 
            ["@identifier"] = xPlayer.identifier
        })

        if data[1] then
            if data[1].health then vest.health = data[1].health end
            if data[1].armour then vest.armor = data[1].armour end
        end

        if item[1] then
            if item[1].item then vest.item = item[1].item end
        end

        logging('debug', 'playerHealth: ' .. vest.health, 'playerArmor: ' .. vest.armor, 'Item: ' .. (vest.item or 'nil'))
        return vest.health, vest.armor, vest.item
    else
        logging('error', '^1 xPlayer not found on Callback: getStatusFromDB ^0')
        return 200, 0, nil
    end
end)

RegisterServerEvent('msk_armor:giveBackVest')
AddEventHandler('msk_armor:giveBackVest', function(item)
    local src = source
    local xPlayer = ESX.GetPlayerFromId(src)

    xPlayer.addInventoryItem(item, 1)
end)

RegisterServerEvent('msk_armor:refreshArmour')
AddEventHandler('msk_armor:refreshArmour', function(playerHealth, playerArmor, item)
    local src = source

    saveStatus({source = src}, playerHealth, playerArmor)

    if item then
        local xPlayer = ESX.GetPlayerFromId(src)

        if item == 'remove' then
            MySQL.query('DELETE FROM msk_armor WHERE identifier = @identifier', { 
                ['@identifier'] = xPlayer.identifier
            })
        else
            local data = MySQL.query.await('SELECT * FROM msk_armor WHERE identifier = @identifier', { 
                ["@identifier"] = xPlayer.identifier
            })

            if data and data[1] then
                MySQL.query('UPDATE msk_armor SET item = @item WHERE identifier = @identifier', {
                    ['@identifier'] = xPlayer.identifier,
                    ['@item'] = item,
                })
            else
                MySQL.query('INSERT INTO msk_armor (identifier, item) VALUES (@identifier, @item)', {
                    ['@identifier'] = xPlayer.identifier,
                    ['@item'] = item
                })
            end
        end
    end
end)

RegisterNetEvent('esx:playerLogout')
AddEventHandler('esx:playerLogout', function(source)
    local playerId = source
    local playerPed = GetPlayerPed(playerId)

    saveStatus({source = playerId}, GetEntityHealth(playerPed), GetPedArmour(playerPed))
end)

RegisterNetEvent('esx:playerDropped')
AddEventHandler('esx:playerLogout', function(playerId, reason)
	local playerId = playerId
	local playerPed = GetPlayerPed(playerId)

	saveStatus({source = playerId}, GetEntityHealth(playerPed), GetPedArmour(playerPed))
end)

saveStatus = function(player, playerHealth, playerArmor)
    if not player then return logging('error', '^1Player not found on function ^3saveStatus^0') end
    local xPlayer

    if player.source then 
        xPlayer = ESX.GetPlayerFromId(player.source)
    elseif player.identifier then
        xPlayer = ESX.GetPlayerFromIdentifier(player.identifier)
    elseif player.player then
        xPlayer = player.player
    end

    if not xPlayer then return logging('error', '^1xPlayer not found on function ^3saveStatus^0') end

    MySQL.query("UPDATE users SET armour = @armour, health = @health WHERE identifier = @identifier", { 
        ['@armour'] = tonumber(playerArmor),
        ['@health'] = tonumber(playerHealth),
        ['@identifier'] = xPlayer.identifier
    })

    if Config.Refresh.debug then
        logging('debug', '^2Update Status^0', ('Health: %s, Armor: %s'):format(playerHealth, playerArmor))
    end
end
exports('saveStatus', saveStatus)

logging = function(code, ...)
    if not Config.Debug then return end
    MSK.Logging(code, ...)
end