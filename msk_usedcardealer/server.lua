local vehicles = {}

AddEventHandler('onResourceStart', function(resource)
    if resource == GetCurrentResourceName() then
        local createTable = MySQL.query.await("CREATE TABLE IF NOT EXISTS msk_usedcardealer (`name` longtext DEFAULT NULL, `plate` varchar(50) DEFAULT NULL, `price` int(20) DEFAULT 0, `text` longtext DEFAULT NULL, `playerId` varchar(50) DEFAULT NULL, `identifier` varchar(80) DEFAULT NULL, PRIMARY KEY (`plate`));")
		
		if createTable.warningStatus == 0 then
			logging('debug', '^2 Successfully^3 created^2 table^3 msk_usedcardealer ^0')
		end

        local data = MySQL.query.await('SELECT * FROM msk_usedcardealer')
        for k, v in pairs(data) do
            logging('debug', 'StartUP', 'Name: ' .. v.name, 'Plate: ' .. v.plate, 'Price: ' .. v.price, 'Freitext: ' .. v.text, 'PlayerId: ' .. v.playerId, 'Identifier: ' .. v.identifier or nil)
            vehicles[v.plate] = {name = v.name, plate = v.plate, price = v.price, text = v.text, playerId = v.playerId, identifier = v.identifier or nil}
        end
    end
end)

if Config.Framework:match('ESX') then
    ESX = exports["es_extended"]:getSharedObject()

    ESX.RegisterUsableItem(Config.Item, function(source)    
        TriggerClientEvent('msk_usedcardealer:useItem', source)
    end)
elseif Config.Framework:match('QBCore') then
    QBCore = exports['qb-core']:GetCoreObject()

    QBCore.Functions.CreateUseableItem(Config.Item, function(source)
        TriggerClientEvent('msk_usedcardealer:useItem', source)
    end)
end

if Config.Command.enable then
    MSK.RegisterCommand(Config.Command.command, 'user', function(source, args, showError)
        TriggerClientEvent('msk_usedcardealer:useItem', source)
    end, false, false, {help = 'Verkaufe dein Fahrzeug'})
end

lib.callback.register('msk_usedcardealer:getVehiclesData', function(source)
    return vehicles
end)

RegisterNetEvent('msk_usedcardealer:syncToServer')
AddEventHandler('msk_usedcardealer:syncToServer', function(data, plateToDelete)
    vehicles = data

    if plateToDelete then
        local trimmedPlate = plateToDelete:gsub("^%s*(.-)%s*$", "%1")

        MySQL.query('DELETE FROM msk_usedcardealer WHERE (plate = @plate or plate = @trimmedPlate)', {
			['@plate'] = plateToDelete,
            ['@trimmedPlate'] = trimmedPlate
		}, function(result)
			if result.affectedRows == 1 then
				logging('debug', 'Deleted: ' .. plateToDelete)
			else
				logging('debug', 'Error while deleting: ' .. plateToDelete)
			end
		end)
    end

    for plate, v in pairs(vehicles) do
        logging('debug', 'SyncToServer', 'Plate: ' .. plate, 'Price: ' .. v.price, 'Freitext: ' .. v.text, 'PlayerId: ' .. v.playerId, 'Identifier: ' .. v.identifier)

        local trimmedPlate = plate:gsub("^%s*(.-)%s*$", "%1")
        local data = MySQL.query.await('SELECT * FROM msk_usedcardealer WHERE (plate = @plate or plate = @trimmedPlate)', {
            ['@plate'] = plate,
            ['@trimmedPlate'] = trimmedPlate
        })

        if data and data[1] then
            MySQL.query('UPDATE msk_usedcardealer SET name = @name, price = @price, text = @text, playerId = @playerId, identifier = @identifier WHERE (plate = @plate or plate = @trimmedPlate)', {
                ['@plate'] = plate,
                ['@trimmedPlate'] = trimmedPlate,
                ['@name'] = v.name,
                ['@price'] = v.price,
				['@text'] = v.text,
				['@playerId'] = v.playerId,
                ['@identifier'] = v.identifier
            })
        else
            MySQL.query('INSERT INTO msk_usedcardealer (name, plate, price, text, playerId, identifier) VALUES (@name, @plate, @price, @text, @playerId, @identifier)', {
                ['@name'] = v.name,
                ['@plate'] = plate,
				['@price'] = v.price,
				['@text'] = v.text,
				['@playerId'] = v.playerId,
                ['@identifier'] = v.identifier
			})
        end
    end
end)

lib.callback.register('msk_usedcardealer:isVehicleOwned', function(source, plate)
    local src = source
    local isOwned = false
    local identifier = nil
    local vehicle = nil

    if Config.Framework:match('ESX') then
        local xPlayer = ESX.GetPlayerFromId(src)

        vehicle = MySQL.query.await('SELECT * FROM owned_vehicles WHERE owner = @identifier AND plate = @plate', {
            ['@identifier'] = xPlayer.identifier,
            ['@plate'] = plate
        })
    elseif Config.Framework:match('QBCore') then
        local Player = QBCore.Functions.GetPlayer(src)

        vehicle = MySQL.query.await('SELECT * FROM player_vehicles WHERE citizenid = @identifier AND plate = @plate', {
            ['@identifier'] = Player.PlayerData.citizenid,
            ['@plate'] = plate
        })
    end

    if vehicle and vehicle[1] then isOwned = true end

    return isOwned
end)

RegisterNetEvent('msk_usedcardealer:buyVehicle')
AddEventHandler('msk_usedcardealer:buyVehicle', function(method, name, plate, price, playerId, identifier)
    local src = source
    local trimmedPlate = plate:gsub("^%s*(.-)%s*$", "%1")

    if Config.Framework:match('ESX') then
        local xPlayer = ESX.GetPlayerFromId(playerId)
        local xTarget = ESX.GetPlayerFromId(src)

        if xPlayer then
            xPlayer.addAccountMoney('bank', price)
            addWebhook(xPlayer.name, xTarget, name, plate, price, identifier)
        else
            local data = MySQL.query.await('SELECT * FROM users WHERE identifier = @identifier', {
                ['@identifier'] = identifier
            })

            if data and data[1] then
                local accounts = json.decode(data[1].accounts)
                accounts.bank = accounts.bank + price

                MySQL.query('UPDATE users SET accounts = @accounts WHERE identifier = @identifier', {
                    ['@identifier'] = identifier,
                    ['@accounts'] = json.encode(accounts),
                })
            end
            addWebhook(nil, xTarget, name, plate, price, identifier)
        end

        xTarget.removeAccountMoney(method, price)

        MySQL.query('UPDATE owned_vehicles SET owner = @identifier WHERE (plate = @plate or plate = @trimmedPlate)', {
            ['@identifier'] = xTarget.identifier,
            ['@plate'] = plate,
            ["@trimmedPlate"] = trimmedPlate
        })
    elseif Config.Framework:match('QBCore') then
        local Player = QBCore.Functions.GetPlayer(playerId)
        local Target = QBCore.Functions.GetPlayer(src)

        if Player then
            Player.Functions.AddMoney(method, price)
            addWebhook(Player.PlayerData.firstname .. ' ' .. Player.PlayerData.lastname, {name = Target.PlayerData.firstname .. ' ' .. Target.PlayerData.lastname, source = Target.PlayerData.source}, name, plate, price, identifier)
        else
            local data = MySQL.query.await('SELECT * FROM players WHERE citizenid = @identifier', {
                ['@identifier'] = identifier
            })

            if data and data[1] then
                local accounts = json.decode(data[1].money)
                accounts.bank = accounts.bank + price

                MySQL.query('UPDATE players SET money = @money WHERE citizenid = @identifier', {
                    ['@identifier'] = identifier,
                    ['@money'] = json.encode(accounts),
                })
            end
            addWebhook(nil, {name = Target.PlayerData.firstname .. ' ' .. Target.PlayerData.lastname, source = Target.PlayerData.source}, name, plate, price, identifier)
        end

        Target.Functions.RemoveMoney(method, price)

        MySQL.query('UPDATE player_vehicles SET citizenid = @identifier WHERE (plate = @plate or plate = @trimmedPlate)', {
            ['@identifier'] = Target.PlayerData.citizenid,
            ['@plate'] = plate,
            ["@trimmedPlate"] = trimmedPlate
        })
    end

    Config.Notification(src, Translation[Config.Locale]['bought_vehicle']:format(name, plate), 'success', 5000, true)
    Config.Notification(playerId, Translation[Config.Locale]['sold_vehicle']:format(name, plate), 'success', 5000, true)
end)

logging = function(code, ...)
    if not Config.Debug then return end
    MSK.Logging(script, code, ...)
end

addWebhook = function(xPlayerName, xTarget, name, plate, price, identifier)
    local webhookLink = 'https://discord.com/api/webhooks/'
    local description = ('%s (ID: %s) hat das Fahrzeug %s mit dem Kennzeichen %s von %s für $%s abgekauft.'):format(xTarget.name, xTarget.source, name, plate, xPlayerName or identifier, price)
	MSK.AddWebhook(webhookLink, "6205745", "MSK Scripts", "https://i.imgur.com/PizJGsh.png", 'MSK UsedCarDealer', description, fields, {text = "© MSK Scripts", link = "https://i.imgur.com/PizJGsh.png"}, "%d/%m/%Y %H:%M:%S")
end

GithubUpdater = function()
    GetCurrentVersion = function()
	    return GetResourceMetadata( GetCurrentResourceName(), "version" )
    end
    
    local CurrentVersion = GetCurrentVersion()
    local resourceName = "[^2"..GetCurrentResourceName().."^0]"

    if Config.VersionChecker then
        PerformHttpRequest('https://raw.githubusercontent.com/MSK-Scripts/msk_usedcardealer/main/VERSION', function(Error, NewestVersion, Header)
            print("###############################")
            if CurrentVersion == NewestVersion then
                print(resourceName .. '^2 ✓ Resource is Up to Date^0 - ^5Current Version: ^2' .. CurrentVersion .. '^0')
            elseif CurrentVersion ~= NewestVersion then
                print(resourceName .. '^1 ✗ Resource Outdated. Please Update!^0 - ^5Current Version: ^1' .. CurrentVersion .. '^0')
                print('^5Newest Version: ^2' .. NewestVersion .. '^0 - ^6Download here:^9 https://github.com/MSK-Scripts/msk_usedcardealer/releases/tag/v'.. NewestVersion .. '^0')
            end
            print("###############################")
        end)
    else
        print("###############################")
        print(resourceName .. '^2 ✓ Resource loaded^0 - ^5Current Version: ^2' .. CurrentVersion .. '^0')
        print("###############################")
    end
end
GithubUpdater()