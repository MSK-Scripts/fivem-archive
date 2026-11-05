if Config.Framework == 'ESX' then -- ESX Framework
	ESX = exports["es_extended"]:getSharedObject()

	ESX.RegisterUsableItem(Config.usableItem, function(source)
		useSimcardItem(source, Config.usableItem)
	end)

	ESX.RegisterUsableItem(Config.wishItem, function(source)
		useSimcardItem(source, Config.wishItem)
	end)

	-- Events
	RegisterServerEvent('msk_simcard:changeNumber', function(newNumber, item)
		local src = source
		local xPlayer = ESX.GetPlayerFromId(src)

		if checkNumberExists(xPlayer, newNumber) then
			return Config.Notification(src, Translation[Config.Locale]['numberExist2'], newNumber)
		end

		logging('debug', 'Number does not exist, changing number to ' .. newNumber)
		updatePhoneNumber(xPlayer, newNumber, item)
	end)
elseif Config.Framework:match('QBCore') then -- QBCore Framework
	local QBCore = exports['qb-core']:GetCoreObject()

	-- Register Items
	QBCore.Functions.CreateUseableItem(Config.usableItem, function(source)
		useSimcardItem(source, Config.usableItem)
	end)

	QBCore.Functions.CreateUseableItem(Config.wishItem, function(source)
		useSimcardItem(source, Config.wishItem)
	end)

	-- Events
	RegisterServerEvent('msk_simcard:changeNumber', function(newNumber, item)
		local src = source
		local Player = QBCore.Functions.GetPlayer(src)

		if checkNumberExists(Player, newNumber) then
			return Config.Notification(src, Translation[Config.Locale]['numberExist2'], newNumber)
		end

		logging('debug', 'Number does not exist, changing number to ' .. newNumber)
		updatePhoneNumber(Player, newNumber, item)
	end)
else
	print('^1ERROR:^0 Framework not configured in config.lua')
end