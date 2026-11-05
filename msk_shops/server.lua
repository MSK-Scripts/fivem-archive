itemStorage = {} -- !!! Yes, without a local !!!

RegisterServerEvent('msk_shops:buyLicense')
AddEventHandler('msk_shops:buyLicense', function(license, method, addon_account) -- license = type, label, name, price
	local src = source
	local xPlayer = ESX.GetPlayerFromId(src)
	local account = xPlayer.getAccount(method)

	if account.money >= license.price then
		if license.type == 'license' then
			xPlayer.removeAccountMoney(method, license.price)
			TriggerEvent('esx_license:addLicense', src, license.name)
			Config.Notification(src, Translation[Config.Locale]['bought_license']:format(license.label), 'success')
		elseif license.type == 'item' then
			xPlayer.removeAccountMoney(method, license.price)
			xPlayer.addInventoryItem(license.name, 1)
			Config.Notification(src, Translation[Config.Locale]['bought_license']:format(license.label), 'success')
		end

		if addon_account.enable then 
			TriggerEvent('esx_addonaccount:getSharedAccount', addon_account.society, function(account)
				account.addMoney(license.price)
			end)
		end

		sendDiscordLogLicense(xPlayer, method, license)
	else
		if method == 'money' then
			Config.Notification(src, Translation[Config.Locale]['not_enough_money'], 'error')
		elseif method == 'bank' then
			Config.Notification(src, Translation[Config.Locale]['not_enough_money_bank'], 'error')
		elseif method == 'black_money' then
			Config.Notification(src, Translation[Config.Locale]['not_enough_money_black'], 'error')
		end
	end
end)

RegisterServerEvent('msk_shops:actionItem')
AddEventHandler('msk_shops:actionItem', function(action, method, amount, item, addon_account) -- item = type, label, name, license, price, sellPrice
	local src = source
	actionItem(src, action, method, amount, item, addon_account)
end)

ESX.RegisterServerCallback('msk_shops:actionItem', function(source, cb, action, method, amount, item, addon_account)
	local src = source
	local data = actionItem(src, action, method, amount, item, addon_account)
	cb(data)
end)

actionItem = function(source, action, method, amount, item, addon_account) -- item = type, label, name, license, price, sellPrice
	local src = source
	local xPlayer = ESX.GetPlayerFromId(src)
	local account = xPlayer.getAccount(method)
	local cbValue = false

	if action == 'buy' then
		logging('debug', 'action = buy')

		if item.type == 'item' then
			logging('debug', 'type = item')

			if account.money >= item.price * amount then
				xPlayer.removeAccountMoney(method, item.price * amount)
				xPlayer.addInventoryItem(item.name, amount)

				if addon_account.enable then 
					TriggerEvent('esx_addonaccount:getSharedAccount', addon_account.society, function(account)
						account.removeMoney(item.price * amount)
					end)
				end

				cbValue = true
				sendDiscordLog(xPlayer, action, method, amount, item)
				Config.Notification(src, Translation[Config.Locale]['bought_item']:format(amount, item.label, item.price * amount), 'success')
			else
				if method == 'money' then
					Config.Notification(src, Translation[Config.Locale]['not_enough_money'], 'error')
				elseif method == 'bank' then
					Config.Notification(src, Translation[Config.Locale]['not_enough_money_bank'], 'error')
				elseif method == 'black_money' then
					Config.Notification(src, Translation[Config.Locale]['not_enough_money_black'], 'error')
				end
			end
		elseif item.type == 'weapon' then
			logging('debug', 'type = weapon')

			if account.money >= item.price then
				local hasWeapon = xPlayer.getWeapon(item.name)

				if not hasWeapon then
					xPlayer.removeAccountMoney(method, item.price)
					xPlayer.addWeapon(item.name, item.ammo)

					if addon_account.enable then 
						TriggerEvent('esx_addonaccount:getSharedAccount', addon_account.society, function(account)
							account.removeMoney(item.price * amount)
						end)
					end

					cbValue = true
					sendDiscordLog(xPlayer, action, method, amount, item)
					Config.Notification(src, Translation[Config.Locale]['bought_item']:format('1', item.label, item.price), 'success')
				else
					Config.Notification(src, Translation[Config.Locale]['already_has_weapon'], 'info')
				end
			else
				if method == 'money' then
					Config.Notification(src, Translation[Config.Locale]['not_enough_money'], 'error')
				elseif method == 'bank' then
					Config.Notification(src, Translation[Config.Locale]['not_enough_money_bank'], 'error')
				elseif method == 'black_money' then
					Config.Notification(src, Translation[Config.Locale]['not_enough_money_black'], 'error')
				end
			end
		end
	elseif action == 'sell' then
		logging('debug', 'action = sell')

		if item.type == 'item' then
			logging('debug', 'type = item')
			local hasItem = xPlayer.getInventoryItem(item.name)

			if hasItem and hasItem.count >= amount then
				xPlayer.addAccountMoney(method, item.sellPrice * amount)
				xPlayer.removeInventoryItem(item.name, amount)

				if addon_account.enable then 
					TriggerEvent('esx_addonaccount:getSharedAccount', addon_account.society, function(account)
						account.addMoney(item.price * amount)
					end)
				end

				cbValue = true
				sendDiscordLog(xPlayer, action, method, amount, item)
				Config.Notification(src, Translation[Config.Locale]['sold_item']:format(amount, item.label, item.sellPrice * amount), 'success')
			else
				Config.Notification(src, Translation[Config.Locale]['not_enough_items'], 'info')
			end
		elseif item.type == 'weapon' then
			logging('debug', 'type = weapon')
			local hasWeapon = xPlayer.getWeapon(item.name)

			if hasWeapon then
				xPlayer.addAccountMoney(method, item.sellPrice)
				xPlayer.removeWeapon(item.name)

				if addon_account.enable then 
					TriggerEvent('esx_addonaccount:getSharedAccount', addon_account.society, function(account)
						account.addMoney(item.price * amount)
					end)
				end

				cbValue = true
				sendDiscordLog(xPlayer, action, method, amount, item)
				Config.Notification(src, Translation[Config.Locale]['sold_item']:format('1', item.label, item.sellPrice), 'success')
			else
				Config.Notification(src, Translation[Config.Locale]['not_has_weapon'], 'info')
			end
		end
	end

	return cbValue
end

MSK.RegisterCallback('msk_shops:checkLicense', function(source, cb, method, license)
    local src = source
	local xPlayer = ESX.GetPlayerFromId(src)
	local hasLicense = false

	if method == 'item' then
		local hasItem = xPlayer.getInventoryItem(license)

		if hasItem and hasItem.count >= 1 then hasLicense = true end
	elseif method == 'license' then
		local data = MySQL.query.await('SELECT * FROM user_licenses WHERE type = @type AND owner = @identifier', {
			['@type'] = license,
			['@identifier'] = xPlayer.identifier
		})

		if data and data[1] then hasLicense = true end
	end

	cb(hasLicense)
end)

MSK.RegisterCallback('msk_shops:hasItem', function(source, cb, item, amount)
    local src = source
	local xPlayer = ESX.GetPlayerFromId(src)
	local hasItem = xPlayer.getInventoryItem(item)

	if xPlayer then
		if hasItem and hasItem.count >= amount then
			logging('debug', 'hasItem')
			cb(true)
		else
			logging('debug', 'not hasItem')
			cb(false)
		end
	end
end)

MSK.RegisterCallback('msk_shops:getItemAmount', function(source, cb, shopId, item)
	if shopId and item then
		if itemStorage[shopId] and itemStorage[shopId][item] then 
			cb(itemStorage[shopId][item].amount) 
		else 
			logging('error', 'ShopID ' .. shopId .. ' not found in table itemStorage, Returning 0 as Itemamount.') 
			cb(0) 
		end
	else
		cb(itemStorage)
	end
end)

RegisterNetEvent('msk_shops:setItemAmount')
AddEventHandler('msk_shops:setItemAmount', function(data)
    itemStorage = data
	TriggerClientEvent('msk_shops:getItemStorage', itemStorage)
end)

AddEventHandler('onResourceStop', function(resourceName)
	if GetCurrentResourceName() == resourceName then
		local shopItems = {}

		for shopId, shop in pairs(itemStorage) do
			shopItems[shopId] = {}
			logging('debug', '^2onResourceStop', shopId, shop, '^0')

			for itemName, item in pairs(shop) do
				logging('debug', 'onResourceStop', item.item, item.amount)
				table.insert(shopItems[shopId], {name = item.item, amount = item.amount})
			end
		end

		for shopId, items in pairs(shopItems) do
			logging('debug', '^2Uploading Items...', shopId, '^0')

			MySQL.query('UPDATE msk_shops SET items = @items WHERE shopId = @shopId', {
				['@shopId'] = shopId,
				['@items'] = json.encode(items)
			})
		end
	end
end)