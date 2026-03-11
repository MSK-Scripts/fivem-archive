local robbedATMs = {}
cartridge_bursts = {}

if not playerPINs then playerPINs = {} end

----------------------------------------------------------------
-- Register Events
----------------------------------------------------------------
RegisterServerEvent('msk_banking:investments', function(add, amount)
	local src = source
    local xPlayer = ESX.GetPlayerFromId(src)
	local money = xPlayer.getAccount('money').money
	local invest = getInvestment({player = xPlayer})

	if add then
		if money >= amount then
			xPlayer.removeAccountMoney('money', amount)
			saveInvestment(xPlayer, invest + amount)
			Config.Notification(src, Translation[Config.Locale]['success_deposit']:format(amount), 'success')
			sendInvestment(xPlayer.name, amount, true) -- Discord Log Einzahlen
		else
			Config.Notification(src, Translation[Config.Locale]['not_enough_money'], 'error')
		end
	else
		if invest >= amount then
			xPlayer.addAccountMoney('money', amount)
			saveInvestment(xPlayer, invest - amount)
			Config.Notification(src, Translation[Config.Locale]['success_withdraw']:format(amount), 'success')
			sendInvestment(xPlayer.name, amount, false) -- Discord Log Auszahlen
		else
			Config.Notification(src, Translation[Config.Locale]['invest_not_enough'], 'error')
		end
	end
end)

RegisterServerEvent('msk_banking:buyBankcard', function(method)
	local src = source
    local xPlayer = ESX.GetPlayerFromId(src)

	xPlayer.addInventoryItem(Config.Bankcard.item, 1)
	xPlayer.removeAccountMoney(method, Config.Bankcard.price)
end)

RegisterServerEvent('msk_banking:setPIN', function(checked, pin)
	local src = source
    local xPlayer = ESX.GetPlayerFromId(src)

	playerPINs[xPlayer.identifier] = pin

	MySQL.query('UPDATE msk_banking SET pincode = @pincode WHERE identifier = @identifier', {
		['@identifier'] = xPlayer.identifier,
		['@pincode'] = pin,
	})

	if checked then
		xPlayer.removeAccountMoney('money', Config.PIN.price)
	else
		xPlayer.removeAccountMoney('bank', Config.PIN.price)
	end

	Config.Notification(src, Translation[Config.Locale]['success_change_pin']:format(pin), 'success')
end)

RegisterServerEvent('msk_banking:deleteBankAccount', function(checked, checkedBank, amount, iban)
	local src = source
    local xPlayer = ESX.GetPlayerFromId(src)

	if checked then
		if checkedBank then
			xPlayer.addAccountMoney('bank', amount)
		else
			xPlayer.addAccountMoney('money', amount)
		end
	end

	local data = MySQL.query.await('SELECT * FROM msk_banking WHERE identifier = @identifier', { 
		["@identifier"] = xPlayer.identifier
	})
	local accounts = json.decode(data[1].accounts)
	accounts['1'] = nil

	MySQL.query('UPDATE msk_banking SET accounts = @accounts WHERE identifier = @identifier', {
		['@identifier'] = xPlayer.identifier,
		['@accounts'] = json.encode(accounts),
	})

	MySQL.query('SELECT * FROM msk_banking_transactions WHERE receiver_iban = @identifier OR sender_iban = @identifier', { 
		["@identifier"] = iban
	}, function(transactions)
		if transactions then
			for k, v in pairs(transactions) do
				if v.receiver_iban == iban then
					MySQL.query('UPDATE msk_banking_transactions SET receiver_iban = @deleted WHERE receiver_iban = @identifier', {
						['@deleted'] = 'Deleted Bankaccount',
						['@identifier'] = iban,
					})
					MySQL.query('UPDATE msk_banking_transactions SET sender_iban = @deleted WHERE sender_iban = @identifier', {
						['@deleted'] = 'Deleted Bankaccount',
						['@identifier'] = iban,
					})
				end
			end
		end
	end)

	deleteSharedAccount(iban)
	sendBankAccounts(xPlayer.name, iban, 'delete', 'second') -- Discord Log
end)

RegisterServerEvent('msk_banking:setBankaccount', function(action, genNumber, method, setAccount)
	local src = source
    local xPlayer = ESX.GetPlayerFromId(src)
	local wallet = xPlayer.getAccount(method).money
	local number = string.upper(Config.IBAN.prefix .. genNumber)

	if action == 'bank' then
		if setAccount then -- Create Main Account
			if wallet >= Config.mainAccount.price then
				local accounts = {['main'] = {iban = number}}
				MySQL.query('INSERT INTO msk_banking (identifier, accounts) VALUES (@identifier, @accounts)', {
					['@identifier'] = xPlayer.identifier,
					['@accounts'] = json.encode(accounts),
				})
				xPlayer.removeAccountMoney(method, Config.mainAccount.price)
				if Config.mainAccount.enable then xPlayer.addAccountMoney('bank', Config.mainAccount.amount) end
				refreshSharedAccount(xPlayer.getAccount('bank').money, number, 'main', xPlayer.identifier)
				Config.Notification(src, Translation[Config.Locale]['success_create_account'] .. Config.mainAccount.price, 'success')
				sendBankAccounts(xPlayer.name, number, 'create', 'main') -- Discord Log
			else
				if method == 'money' then
					Config.Notification(src, Translation[Config.Locale]['not_enough_money'], 'error')
				elseif method == 'bank' then
					Config.Notification(src, Translation[Config.Locale]['not_enough_bank'], 'error')
				end
			end
		else -- Change IBAN
			if wallet >= Config.IBAN.price then
				local data = MySQL.query.await('SELECT * FROM msk_banking WHERE identifier = @identifier', {['@identifier'] = xPlayer.identifier})
				local accounts = json.decode(data[1].accounts)

				MySQL.query('UPDATE msk_banking_transactions SET receiver_iban = @newIBAN WHERE receiver_iban = @identifier', {
					['@newIBAN'] = number,
					['@identifier'] = accounts['main'].iban
				})
				MySQL.query('UPDATE msk_banking_transactions SET sender_iban = @newIBAN WHERE sender_iban = @identifier', {
					['@newIBAN'] = number,
					['@identifier'] = accounts['main'].iban
				})

				accounts['main'].iban = number

				MySQL.query('UPDATE msk_banking SET accounts = @accounts WHERE identifier = @identifier', {
					['@identifier'] = xPlayer.identifier,
					['@accounts'] = json.encode(accounts),
				})

				refreshSharedAccount(accounts['main'].money, number, 'main', xPlayer.identifier)
				xPlayer.removeAccountMoney(method, Config.IBAN.price)
				Config.Notification(src, Translation[Config.Locale]['success_change_iban'] .. Config.IBAN.price, 'success')
				sendChangeIBAN(xPlayer.name, number, action) -- Discord Log
			else
				if method == 'money' then
					Config.Notification(src, Translation[Config.Locale]['not_enough_money'], 'error')
				elseif method == 'bank' then
					Config.Notification(src, Translation[Config.Locale]['not_enough_bank'], 'error')
				end
			end
		end
	elseif action == 'secondBank' then
		if setAccount then -- Create Second Account
			if wallet >= Config.bankAccounts.price then
				local data = MySQL.query.await('SELECT * FROM msk_banking WHERE identifier = @identifier', {['@identifier'] = xPlayer.identifier})
				local accounts = json.decode(data[1].accounts)
				table.insert(accounts, {iban = number, money = 0})

				MySQL.query('UPDATE msk_banking SET accounts = @accounts WHERE identifier = @identifier', {
					['@identifier'] = xPlayer.identifier,
					['@accounts'] = json.encode(accounts)
				})

				refreshSharedAccount(0, number, '1', xPlayer.identifier)
				xPlayer.removeAccountMoney(method, Config.bankAccounts.price)
				Config.Notification(src, Translation[Config.Locale]['success_create_account'] .. Config.bankAccounts.price, 'success')
				sendBankAccounts(xPlayer.name, number, 'create', 'second') -- Discord Log
			else
				if method == 'money' then
					Config.Notification(src, Translation[Config.Locale]['not_enough_money'], 'error')
				elseif method == 'bank' then
					Config.Notification(src, Translation[Config.Locale]['not_enough_bank'], 'error')
				end
			end
		else -- Change IBAN
			if wallet >= Config.IBAN.price then
				local data = MySQL.query.await('SELECT * FROM msk_banking WHERE identifier = @identifier', {['@identifier'] = xPlayer.identifier})
				local accounts = json.decode(data[1].accounts)

				MySQL.query('UPDATE msk_banking_transactions SET receiver_iban = @newIBAN WHERE receiver_iban = @identifier', {
					['@newIBAN'] = number,
					['@identifier'] = accounts['1'].iban
				})
				MySQL.query('UPDATE msk_banking_transactions SET sender_iban = @newIBAN WHERE sender_iban = @identifier', {
					['@newIBAN'] = number,
					['@identifier'] = accounts['1'].iban
				})

				accounts['1'].iban = number

				MySQL.query('UPDATE msk_banking SET accounts = @accounts WHERE identifier = @identifier', {
					['@identifier'] = xPlayer.identifier,
					['@accounts'] = json.encode(accounts)
				})

				refreshSharedAccount(accounts['1'].money, number, '1', xPlayer.identifier)
				xPlayer.removeAccountMoney(method, Config.IBAN.price)
				Config.Notification(src, Translation[Config.Locale]['success_change_iban'] .. Config.IBAN.price, 'success')
				sendChangeIBAN(xPlayer.name, number, action) -- Discord Log
			else
				if method == 'money' then
					Config.Notification(src, Translation[Config.Locale]['not_enough_money'], 'error')
				elseif method == 'bank' then
					Config.Notification(src, Translation[Config.Locale]['not_enough_bank'], 'error')
				end
			end
		end
	end
end)

RegisterServerEvent('msk_banking:changeBankAmount', function(action, amount, toIBAN, selfAccount, reason)
	-- selfAccount = {identifier, bank, iban, account} // account is accounts['account'] from database
	local src = source
    local xPlayer = ESX.GetPlayerFromId(src)

	logging('debug', 'selfAccount.account', selfAccount.account)
	
    if action == 'deposit' then -- Einzahlen
		logging('debug', 'deposit')
		local cash = xPlayer.getAccount('money').money

		if amount <= cash then
			xPlayer.removeAccountMoney('money', amount)

			TriggerEvent('msk_banking:getSharedAccount', toIBAN, function(account)
				account.addMoney(amount)
			end)

			Config.Notification(src, Translation[Config.Locale]['success_deposit']:format(amount), 'success')
			addTransaction(selfAccount.iban, xPlayer.name, 'bank', 'Bank Account', amount, nil, 'deposit', selfAccount.account)
			sendTransferMoney(xPlayer.name, amount, 'deposit', toIBAN) -- Discord Log
		else
			Config.Notification(src, Translation[Config.Locale]['not_enough_money'], 'error')
		end
	elseif action == 'withdraw' then -- Auszahlen
		logging('debug', 'withdraw')
		local bankMoney = SharedAccounts[toIBAN].money or 0

		if amount <= tonumber(bankMoney) then
			xPlayer.addAccountMoney('money', amount)

			TriggerEvent('msk_banking:getSharedAccount', toIBAN, function(account)
				account.removeMoney(amount)
			end)

			Config.Notification(src, Translation[Config.Locale]['success_withdraw']:format(amount), 'success')
			addTransaction(selfAccount.iban, xPlayer.name, 'bank', 'Bank Account', amount, nil, 'withdraw', selfAccount.account)
			sendTransferMoney(xPlayer.name, amount, 'withdraw', toIBAN) -- Discord Log
		else
			Config.Notification(src, Translation[Config.Locale]['not_enough_bank'], 'error')
		end
	elseif action == 'transfer' then
		toIBAN = string.upper(Config.IBAN.prefix .. toIBAN)
		logging('debug', 'transfer', amount, toIBAN, selfAccount, job)
		local data = getAccount(toIBAN) -- data = {money, iban, account, identifier}

		if amount <= selfAccount.bank then
			TriggerEvent('msk_banking:getSharedAccount', selfAccount.iban, function(account)
				account.removeMoney(amount)
			end)

			TriggerEvent('msk_banking:getSharedAccount', data.iban, function(account)
				account.addMoney(amount)
			end)
			addTransaction(data.iban, getSocietyLabel(data.identifier) or getNameFromIdentifier(data.identifier), selfAccount.iban, xPlayer.name, amount, reason, 'transfer')

			local xTarget = ESX.GetPlayerFromIdentifier(data.identifier)
			if xTarget then Config.Notification(xTarget.source, Translation[Config.Locale]['get_transfer']:format(amount, selfAccount.iban), 'info') end

			Config.Notification(src, Translation[Config.Locale]['success_transfer']:format(amount, toIBAN), 'success')
        	sendTransferMoney(xPlayer.name, amount, 'transfer', selfAccount.iban, toIBAN) -- Discord Log
		else
			Config.Notification(src, Translation[Config.Locale]['not_enough_bank'], 'error')
		end
	end
end)

RegisterServerEvent('msk_banking:stopRobbery', function(currATM)
	if not currATM then return end
	if not robbedATMs[currATM.coords] then return end
	local src = source
	local xPlayer = ESX.GetPlayerFromId(src)

	if Config.ATMs.robbery.probability.enable and cartridge_bursts[src] then
		local random = math.random(100)

		if random <= Config.ATMs.robbery.probability.percent then
			local money = cartridge_bursts[src].money * Config.ATMs.robbery.probability.removeMoney.percent
			cartridge_bursts[src] = {money = 0, bursted = true}

			Config.Notification(src, Translation[Config.Locale]['cartridge_bursts']:format(MSK.Comma(money)), 'warning')

			if Config.ATMs.robbery.probability.removeMoney.enable then
				xPlayer.removeAccountMoney(Config.ATMs.robbery.money.method, money)
			end
		else
			cartridge_bursts[src] = nil
		end
	end

	local timeout = MSK.AddTimeout(Config.ATMs.robbery.timeout * 60000, function()
		robbedATMs[currATM.coords] = nil
	end)
end)

RegisterServerEvent('msk_banking:robberyJobNotify', function(action, currATM, val)
	local jobs = Config.ATMs.robbery.jobs
	
	if action:match('start') then
		if jobs.notifyDelay.enable then Wait(jobs.notifyDelay.delay * 1000) end

		for i, job in pairs(jobs.notifyJobs) do
			local xPlayers = ESX.GetExtendedPlayers('job', job)

			for k, xPlayer in ipairs(xPlayers) do
				TriggerClientEvent('msk_banking:addRobberyBlip', xPlayer.source, currATM)
			end
		end
	elseif action:match('stop') then
		local notify = Translation[Config.Locale]['jobnotify_stop']
		if val then notify = Translation[Config.Locale]['jobnotify_success'] end

		for i, job in pairs(jobs.notifyJobs) do
			local xPlayers = ESX.GetExtendedPlayers('job', job)

			for k, xPlayer in ipairs(xPlayers) do
				MSK.AdvancedNotification(xPlayer.source, notify, Translation[Config.Locale]['robbery_title'], Translation[Config.Locale]['robbery_subtitle'], 'CHAR_MP_MERRYWEATHER')
				TriggerClientEvent('msk_banking:removeRobberyBlip', xPlayer.source, currATM.blip)
			end
		end
	end
end)

RegisterServerEvent('msk_banking:getRobberyMoney', function()
	local src = source
	local xPlayer = ESX.GetPlayerFromId(src)
	local random = math.random(Config.ATMs.robbery.money.minAmount, Config.ATMs.robbery.money.maxAmount)

	xPlayer.addAccountMoney(Config.ATMs.robbery.money.method, random)
	Config.Notification(src, ('Du hast $%s bekommen'):format(MSK.Comma(random)), 'success')

	if not cartridge_bursts[src] then
		cartridge_bursts[src] = {money = random}
	else
		cartridge_bursts[src].money = cartridge_bursts[src].money + random
	end
end)

----------------------------------------------------------------
-- Register Callbacks
----------------------------------------------------------------
MSK.Register('msk_banking:getPIN', function(source)
	local src = source
    local xPlayer = ESX.GetPlayerFromId(src)
	
	return getPlayerPin(xPlayer.identifier)
end)

MSK.Register('msk_banking:startATMRobbery', function(source, currATM)
	local src = source
	local wasRobbed, jobs, cops = false, Config.ATMs.robbery.jobs, 0
	local xPlayer = ESX.GetPlayerFromId(src)
	local hasItem = true

	if Config.ATMs.robbery.neededItem then 
		local item = xPlayer.getInventoryItem(Config.ATMs.robbery.neededItem.item)
		if item and item.count > 0 then hasItem = true else hasItem = item.label end
	end

	if robbedATMs[currATM.coords] then
		wasRobbed = true
	else
		wasRobbed = false
		robbedATMs[currATM.coords] = currATM
	end

	for i, job in pairs(jobs.notifyJobs) do
		local xPlayers = ESX.GetExtendedPlayers('job', job)
		cops = cops + #xPlayers
	end

	return wasRobbed, cops, hasItem
end)

MSK.Register('msk_banking:getCartridgeBursted', function(source, playerId)
	local src = source
	if playerId then src = playerId end

	return getCartridgeBursted(src)
end)

MSK.Register('msk_banking:getSocietyAccounts', function(source, playerJob)
	if not Config.Society.enable then return end
	logging('debug', 'playerJob', playerJob)

	local account = getAccountFromJob(playerJob)
	logging('debug', 'account', account)
	if not account then return end
	local job = nil

	if Config.Society.addon_account then
		job = {
			identifier = string.gsub(account.identifier, "society_", ""),
			name = account.identifier,
			bank = account.money,
			iban = account.iban,
			label = getSocietyLabel(string.gsub(account.identifier, "society_", ""))
		}
	else
		job = {
			identifier = account.identifier,
			name = 'society_' .. account.identifier,
			bank = account.money,
			iban = account.iban,
			label = getSocietyLabel(account.identifier)
		}
	end

	return job
end)

MSK.Register('msk_banking:getMainAccount', function(source)
	local src = source
    local xPlayer = ESX.GetPlayerFromId(src)
	local iban = getIBANFromIdentifier(xPlayer.identifier, 'main')
	local account = getAccount(iban)

	if not account then return {} end

	local mainAccount = {
		identifier = account.identifier,
		cash = xPlayer.getAccount('money').money,
		bank = account.money,
		iban = account.iban,
		account = account.account
	}

	return mainAccount
end)

MSK.Register('msk_banking:getSecondAccount', function(source)
    local src = source
    local xPlayer = ESX.GetPlayerFromId(src)
	local money = xPlayer.getAccount('money').money
	local iban = getIBANFromIdentifier(xPlayer.identifier, '1')
	local account = getAccount(iban)

	if not account then return {} end

	local secondAccount = {
		identifier = account.identifier,
		bank = account.money,
		iban = account.iban,
		account = account.account
	}

	return secondAccount
end)

MSK.Register('msk_banking:hasBankcard', function(source)
	local xPlayer = ESX.GetPlayerFromId(source)
	local hasItem = xPlayer.getInventoryItem(Config.Bankcard.item)

	if Config.Bankcard.enable then
		if hasItem and hasItem.count >= 1 then
			return true
		else
			return false
		end
	else
		return true
	end
end)

MSK.Register('msk_banking:checkIBAN', function(source, newIBAN)
    local src = source
    local xPlayer = ESX.GetPlayerFromId(src)
	local iban = string.upper(Config.IBAN.prefix .. newIBAN)
	local ibans = {}

	logging('debug', 'checkIBAN: ' .. iban)

	for k, v in pairs(SharedAccounts) do
		ibans[#ibans + 1] = v.iban
	end

	return MSK.TableContains(ibans, iban)
end)

MSK.Register('msk_banking:getTransactions', function(source, identifier)
	local src = source
    local xPlayer = ESX.GetPlayerFromId(src)
	local result = MySQL.query.await('SELECT * FROM msk_banking_transactions WHERE receiver_iban = @identifier OR sender_iban = @identifier ORDER BY id DESC', { 
		["@identifier"] = identifier
	})

	if result then
		return result
	else
		return false
	end
end)

MSK.Register('msk_banking:getBills', function(source)
	local src = source
    local xPlayer = ESX.GetPlayerFromId(src)
	local result
	
	if Config.useBilling == 'okokBilling' then
		result = MySQL.query.await('SELECT * FROM okokbilling WHERE receiver_identifier = @identifier AND status = "unpaid"', { 
			["@identifier"] = xPlayer.identifier 
		})
	else
		result = MySQL.query.await('SELECT * FROM billing WHERE identifier = @identifier', { 
			["@identifier"] = xPlayer.identifier 
		})
	end

	return result
end)

ESX.RegisterServerCallback('msk_banking:payBill', function(source, cb, billId)
	local source = source
	local xPlayer = ESX.GetPlayerFromId(source)

	MySQL.single('SELECT sender, target_type, target, amount FROM billing WHERE id = ?', {billId}, function(result)
		if not result then return end
		local amount = result.amount
		local xTarget = ESX.GetPlayerFromIdentifier(result.sender)

		if result.target_type == 'player' then
			if xTarget then
				MySQL.update('DELETE FROM billing WHERE id = ?', {billId}, function(rowsChanged)
					if rowsChanged == 1 then
						if xPlayer.getAccount('bank').money >= amount then
							xPlayer.removeAccountMoney('bank', amount)
							xTarget.addAccountMoney('bank', amount)

							Config.Notification(source, Translation[Config.Locale]['player_paid_invoice']:format(ESX.Math.GroupDigits(amount)), 'success')
							Config.Notification(xTarget.source, Translation[Config.Locale]['target_paid_invoice']:format(ESX.Math.GroupDigits(amount)), 'success')
						elseif xPlayer.getMoney() >= amount then
							xPlayer.removeMoney(amount)
							xTarget.addMoney(amount)

							Config.Notification(source, Translation[Config.Locale]['player_paid_invoice']:format(ESX.Math.GroupDigits(amount)), 'success')
							Config.Notification(xTarget.source, Translation[Config.Locale]['target_paid_invoice']:format(ESX.Math.GroupDigits(amount)), 'success')
						else
							Config.Notification(source, Translation[Config.Locale]['not_enough_money'], 'error')
							Config.Notification(xTarget.source, Translation[Config.Locale]['target_not_enough_money']:format(ESX.Math.GroupDigits(amount)), 'error')
						end
					end

					cb()
				end)
			else
				Config.Notification(source, Translation[Config.Locale]['player_not_online'], 'error')
				cb()
			end
		else
			TriggerEvent('esx_addonaccount:getSharedAccount', result.target, function(account)
				MySQL.update('DELETE FROM billing WHERE id = ?', {billId}, function(rowsChanged)
					if rowsChanged == 1 then
						if xPlayer.getAccount('bank').money >= amount then
							xPlayer.removeAccountMoney('bank', amount)
							account.addMoney(amount)

							Config.Notification(source, Translation[Config.Locale]['player_paid_invoice']:format(ESX.Math.GroupDigits(amount)), 'success')
							if xTarget then Config.Notification(xTarget.source, Translation[Config.Locale]['target_paid_invoice']:format(ESX.Math.GroupDigits(amount)), 'success') end
						elseif xPlayer.getMoney() >= amount then
							xPlayer.removeMoney(amount)
							account.addMoney(amount)

							Config.Notification(source, Translation[Config.Locale]['player_paid_invoice']:format(ESX.Math.GroupDigits(amount)), 'success')
							if xTarget then Config.Notification(xTarget.source, Translation[Config.Locale]['target_paid_invoice']:format(ESX.Math.GroupDigits(amount)), 'success') end
						else
							Config.Notification(source, Translation[Config.Locale]['not_enough_money'], 'error')
							if xTarget then Config.Notification(xTarget.source, Translation[Config.Locale]['target_not_enough_money']:format(ESX.Math.GroupDigits(amount)), 'error') end
						end
					end

					cb()
				end)
			end)
		end
	end)
end)