onResourceStart = function()
	local createTable = MySQL.query.await("CREATE TABLE IF NOT EXISTS msk_banking (`identifier` varchar(80) NOT NULL, PRIMARY KEY (`identifier`));")
	local createTableTransactions = MySQL.query.await("CREATE TABLE IF NOT EXISTS msk_banking_transactions (`id` int(11) NOT NULL AUTO_INCREMENT, `receiver_iban` varchar(255) NOT NULL, `receiver_name` varchar(255) NOT NULL, `sender_iban` varchar(255) NOT NULL, `sender_name` varchar(255) NOT NULL, `reason` varchar(255) DEFAULT NULL, `date` varchar(255) NOT NULL, `amount` int(50) NOT NULL, `type` varchar(255) NOT NULL, `account` varchar(255) DEFAULT NULL, PRIMARY KEY (`id`));")
	local msk_banking_alterTable = MySQL.query.await("ALTER TABLE msk_banking ADD COLUMN IF NOT EXISTS `accounts` longtext DEFAULT NULL, ADD COLUMN IF NOT EXISTS `pincode` varchar(50) DEFAULT NULL, ADD COLUMN IF NOT EXISTS `invest` varchar(255) NOT NULL DEFAULT '0';")
	local items = MySQL.query.await("SELECT * FROM items WHERE name = @name", {['@name'] = Config.Bankcard.item})

	if not items[1] then
		logging('debug', '^1 Item ^3 ' .. Config.Bankcard.item .. ' ^1 not exists, inserting item... ^0')
		local insertItem = MySQL.query.await("INSERT INTO `items` (`name`, `label`, `weight`, `rare`, `can_remove`) VALUES ('" .. Config.Bankcard.item .. "', 'Bankcard', 1, 0, 1);")
		if insertItem then
			logging('debug', '^2 Successfully ^3 inserted ^2 Item ^3 ' .. Config.Bankcard.item .. ' ^2 in ^3 items ^0')
		end
	end

	if createTable.warningStatus == 0 then
		logging('debug', '^2 Successfully ^3 created ^2 table ^3 msk_banking ^0')
	end

	if createTableTransactions.warningStatus == 0 then
		logging('debug', '^2 Successfully ^3 created ^2 table ^3 msk_banking_transactions ^0')
	end

	if msk_banking_alterTable.warningStatus == 0 then
		logging('debug', '^2 Successfully ^3 altered ^2 table ^3 msk_banking ^0')
	end

	if Config.Society.enable then
		logging('debug', '^2 Inserting Societies into database... ^0')

		if Config.Society.addon_account then
			for jobName, job in pairs(Config.Society.jobs) do
				MySQL.query('SELECT * FROM addon_account_data WHERE account_name = @account_name', {
					['@account_name'] = 'society_' .. jobName
				}, function(result)
					if result[1] and not result[1].owner then
						if Config.Society.addon_account_sync_money then
							local data = MySQL.query.await('SELECT * FROM msk_banking WHERE identifier = @identifier', {['@identifier'] = jobName})

							if data[1] and data[1].accounts then 
								local accounts = json.decode(data[1].accounts)

								MySQL.update.await('UPDATE addon_account_data SET owner = @iban, money = @money WHERE account_name = @account_name', {
									['@iban'] = Config.IBAN.prefix .. job.iban,
									['@money'] = accounts['society'].money,
									['@account_name'] = 'society_' .. jobName
								})
							else
								MySQL.update.await('UPDATE addon_account_data SET owner = @iban WHERE account_name = @account_name', {
									['@iban'] = Config.IBAN.prefix .. job.iban,
									['@account_name'] = 'society_' .. jobName
								})
							end
						else
							MySQL.update.await('UPDATE addon_account_data SET owner = @iban WHERE account_name = @account_name', {
								['@iban'] = Config.IBAN.prefix .. job.iban,
								['@account_name'] = 'society_' .. jobName
							})
						end

						createAddonAccount({name = 'society_' .. jobName, label = job.label, owner = result[1].owner, money = result[1].money})
					elseif not result[1] then
						MySQL.insert.await('INSERT INTO addon_account_data (account_name, money, owner) VALUES (@account_name, @money, @iban)', {
							['@account_name'] = 'society_' .. jobName,
							['@money'] = 0,
							['@iban'] = Config.IBAN.prefix .. job.iban
						})

						createAddonAccount({name = 'society_' .. jobName, label = job.label, owner = Config.IBAN.prefix .. job.iban, money = 0})
					end
				end)

				MySQL.query('DELETE FROM msk_banking WHERE identifier = @identifier', { 
					['@identifier'] = jobName
				})
			end
		else
			for jobName, job in pairs(Config.Society.jobs) do
				local sync = {[1] = {money = 0}}

				if Config.Society.addon_account_sync_money then
					sync = MySQL.query.await('SELECT * FROM addon_account_data WHERE account_name = @account_name', { 
						["@account_name"] = 'society_' .. jobName
					})
				end

				MySQL.query('SELECT * FROM msk_banking WHERE identifier = @identifier', {
					['@identifier'] = jobName
				}, function(results)
					if #results == 0 then
						local accounts = {['society'] = {iban = Config.IBAN.prefix .. job.iban, money = sync[1].money}}
						
						MySQL.query('INSERT INTO msk_banking (identifier, accounts) VALUES (@identifier, @accounts)', {
							['@identifier'] = jobName,
							['@accounts'] = json.encode(accounts),
						})
					end
				end)

				MySQL.query('UPDATE addon_account_data SET owner = @iban WHERE account_name = @account_name', {
					['@account_name'] = 'society_' .. jobName,
					['@iban'] = NULL,
				})
			end
		end

		logging('debug', '^2 Registration and Updating Societies done. ^0')
	end
	
	registerSharedAccounts()
end
onResourceStart()

registerPlayerData = function()
	local data = MySQL.query.await('SELECT * FROM msk_banking')

	for k, v in pairs(data) do
		playerPINs[v.identifier] = tonumber(v.pincode)

		if Config.Investment.enable then
			if not Investment then Investment = {} end
			Investment[v.identifier] = {amount = MSK.Round(tonumber(v.invest))} 
		end
	end
end
registerPlayerData()