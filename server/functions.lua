getPlayerPin = function(identifier)
	local pin = false

	if playerPINs[identifier] then
		pin = playerPINs[identifier]
	else
		local data = MySQL.single.await('SELECT pincode FROM msk_banking WHERE identifier = ? LIMIT 1', {identifier})

		if data and data.pincode then
			pin = data.pincode
		end
	end

	return pin
end
exports('getPlayerPin', getPlayerPin)

addTransaction = function(receiver_iban, receiver_name, sender_iban, sender_name, amount, reason, action, account)
	MySQL.query('INSERT INTO msk_banking_transactions (receiver_iban, receiver_name, sender_iban, sender_name, reason, date, amount, type, account) VALUES (@receiver_iban, @receiver_name, @sender_iban, @sender_name, @reason, @date, @amount, @type, @account)', {
		['@receiver_iban'] = receiver_iban,
		['@receiver_name'] = receiver_name,
		['@sender_iban'] = sender_iban,
		['@sender_name'] = sender_name,
		['@reason'] = reason,
		['@date'] = os.date("%d.%m.%Y %H:%M"),
		['@amount'] = amount,
		['@type'] = action,
		['@account'] = account,
	})
end
exports('addTransaction', addTransaction) -- exports.msk_banking:addTransaction(receiver_iban, receiver_name, sender_iban, sender_name, amount, reason, action, account)

getIBANFromIdentifier = function(identifier, account)
	if not account then account = 'main' end
	
	for iban, v in pairs(SharedAccounts) do
		if identifier == v.identifier and account == v.account then
			return iban
		end
	end

	return false
end
exports('getIBANFromIdentifier', getIBANFromIdentifier) -- exports.msk_banking:getIBANFromIdentifier(identifier, account)

getAccount = function(iban)
	for k, v in pairs(SharedAccounts) do
		if iban == k then
			return v
		end
	end

	return false
end
exports('getAccount', getAccount) -- exports.msk_banking:getAccount(iban)

getAccountFromJob = function(jobname)
	if Config.Society.addon_account then
		for iban, v in pairs(SharedAccounts) do
			if 'society_' .. jobname == v.identifier then
				return v
			end
		end
	else
		for iban, v in pairs(SharedAccounts) do
			if jobname == v.identifier then
				return v
			end
		end
	end

	return false
end
exports('getAccountFromJob', getAccountFromJob) -- exports.msk_banking:getAccountFromJob(jobname)

getNameFromIdentifier = function(identifier)
	local xPlayer = ESX.GetPlayerFromIdentifier(identifier)
		
	if xPlayer then
		return xPlayer.name
	else
		local data = MySQL.query.await('SELECT * FROM users WHERE identifier = @identifier', { 
			["@identifier"] = identifier
		})

		if data[1] then
			return data[1].firstname .. ' ' .. data[1].lastname
		end
	end
end
exports('getNameFromIdentifier', getNameFromIdentifier) -- exports.msk_banking:getNameFromIdentifier(identifier)

getSocietyLabel = function(jobName)
	if Config.Society.jobs[jobName] then
		return Config.Society.jobs[jobName].label or 'Unknown'
	end

	logging('error', 'Requested JobLabel on ^3getSocietyLabel ^2' .. jobName ..'^0 is not configured in config.lua')
	return 'Unknown'
end
exports('getSocietyLabel', getSocietyLabel) -- exports.msk_banking:getSocietyLabel(jobName)

createAddonAccount = function(society_data)
    TriggerEvent('esx_addonaccount:getSharedAccount', society_data.name, function(account)
		if not account then
			exports.esx_addonaccount:AddSharedAccount(society_data, society_data.money)
		end
	end)
end

getCartridgeBursted = function(playerId)
	local bursted = false
	if cartridge_bursts[src] and cartridge_bursts[src].bursted then bursted = true end
	return bursted
end
exports('getCartridgeBursted', getCartridgeBursted)

logging = function(code, ...)
    if not Config.Debug then return end
    MSK.Logging(code, ...)
end