useSimcardItem = function(playerId, toggleItem)
    if not Config.needPhone then 
        if toggleItem == Config.usableItem then
            TriggerClientEvent('msk_simcard:useItem', playerId)
        elseif toggleItem == Config.wishItem then
            TriggerClientEvent('msk_simcard:openMenu', playerId)
        end
        return
    end

    local hasPhoneItem = false
    if Config.Framework == 'ESX' then
        local xPlayer = ESX.GetPlayerFromId(playerId)

        for k, item in pairs(Config.phoneItem) do
            local hasItem = xPlayer.hasItem(item)

            if hasItem then
                hasPhoneItem = true
                break
            end
        end
    elseif Config.Framework == 'QBCore' then
        local Player = QBCore.Functions.GetPlayer(source)

        for k, item in pairs(Config.phoneItem) do
            local hasItem = Player.Functions.GetItemByName(item)

            if hasItem then
                hasPhoneItem = true
                break
            end
        end
    end

    if hasPhoneItem then
        if toggleItem == Config.usableItem then
            TriggerClientEvent('msk_simcard:useItem', playerId)
        elseif toggleItem == Config.wishItem then
            TriggerClientEvent('msk_simcard:openMenu', playerId)
        end
    else
        Config.Notification(playerId, Translation[Config.Locale]['noPhone'])
    end
end

checkNumberExists = function(xPlayer, newNumber)
    local numberExists = false

	if Config.Database.numberTB == 'charinfo' then
		local identifier

		if Config.Framework == 'ESX' then
			identifier = xPlayer.identifier
		elseif Config.Framework == 'QBCore' then
			identifier = xPlayer.PlayerData.citizenid
		end

		local result = MySQL.query.await('SELECT * FROM ' .. Config.Database.numberDB .. ' WHERE '.. Config.Database.identifierTB ..' = ?', {identifier})

		if result[1] then
			local char = json.decode(result[1].charinfo)
			local number = char.phone

			if char.phone == newNumber then
				numberExists = true
			end
		end
	else
		local number = MySQL.query.await('SELECT * FROM ' .. Config.Database.numberDB .. ' WHERE '.. Config.Database.numberTB ..' = ?', {newNumber})

		if number[1] then
			numberExists = true
		end
	end

    logging('debug', 'Does number already exists?', numberExists)

    return numberExists
end

updatePhoneNumber = function(xPlayer, newNumber, item)
    local playerData = {}

    if Config.Framework == 'ESX' then
        playerData = {
            name = xPlayer.name,
            playerId = xPlayer.source,
            identifier = xPlayer.identifier
        }

        if Config.changeDefault and (Config.Database.numberDB ~= 'users' or Config.Database.numberTB ~= 'phone_number') then 
            MySQL.update('UPDATE users SET phone_number = ? WHERE identifier = ?', {newNumber, playerData.identifier})
        end

        if Config.removeItem then
            xPlayer.removeInventoryItem(item, 1)
        end
    elseif Config.Framework == 'QBCore' then
        local Player = xPlayer
        playerData = {
            name = Player.PlayerData.charinfo.firstname .. ' ' .. Player.PlayerData.charinfo.lastname,
            playerId = Player.PlayerData.source,
            identifier = Player.PlayerData.citizenid
        }

        if Config.changeDefault and (Config.Database.numberDB ~= 'players' or Config.Database.numberTB ~= 'charinfo') then
            MySQL.query('SELECT charinfo FROM players WHERE citizenid = ?', {playerData.identifier}, function(result)
                if result[1] then
                    local char = json.decode(result[1].charinfo)
                    char.phone = newNumber
            
                    MySQL.update('UPDATE players SET charinfo = ? WHERE citizenid = ?', {json.encode(char), playerData.identifier})
                end
            end)
        end

        if Config.removeItem then
            Player.Functions.RemoveItem(item, 1)
        end

        local charInfo = Player.PlayerData.charinfo
        charInfo.phone = phoneNumber
        Player.Functions.SetPlayerData('charinfo', charInfo)
    end

    if Config.changeDatabase and Config.Database.numberTB == 'charinfo' then
        MySQL.query('SELECT ' .. Config.Database.numberTB .. ' FROM ' .. Config.Database.numberDB .. ' WHERE ' .. Config.Database.identifierTB .. ' = ?', { 
            playerData.identifier
        }, function(result)
            if result[1] then
                local char = json.decode(result[1].charinfo)
                char.phone = newNumber
        
                MySQL.update('UPDATE ' .. Config.Database.numberDB .. ' SET ' .. Config.Database.numberTB .. ' = ? WHERE ' .. Config.Database.identifierTB .. ' = ?', {
                    json.encode(char), playerData.identifier,
                })
            end
        end)
    else
        local imei
        if Config.Phone == 'yphone' then
            imei = exports["yseries"]:GetPhoneImeiBySourceId(playerData.playerId)
        end

        if Config.changeDatabase then
            MySQL.update('UPDATE ' .. Config.Database.numberDB .. ' SET ' .. Config.Database.numberTB .. ' = ? WHERE ' .. Config.Database.identifierTB .. ' = ?', {
                newNumber, imei or playerData.identifier
            })
        end
    end

    Config.updateNumber(playerData.playerId, newNumber)
	sendDiscordLog(playerData, newNumber, item)
end