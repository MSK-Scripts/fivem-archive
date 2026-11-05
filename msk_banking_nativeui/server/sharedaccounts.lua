SharedAccounts = {}

registerSharedAccounts = function()
    local societyAccounts = MySQL.query.await("SELECT * FROM msk_banking")
    local debugString = ('^2 Registered ^3%s^2 Personal Accounts^0'):format(#societyAccounts or 0)

    for k, v in pairs(societyAccounts) do
        local accounts = json.decode(v.accounts)

        if accounts['main'] then
            local xPlayer = ESX.GetPlayerFromIdentifier(v.identifier)
            
            if xPlayer then
                SharedAccounts[accounts['main'].iban] = CreateSharedAccount(xPlayer.getAccount('bank').money, accounts['main'].iban, 'main', v.identifier)
            else
                local data = MySQL.query.await('SELECT * FROM users WHERE identifier = @identifier', {['@identifier'] = v.identifier})

                if data and data[1] then
                    local account = json.decode(data[1].accounts)
                    SharedAccounts[accounts['main'].iban] = CreateSharedAccount(account.bank, accounts['main'].iban, 'main', v.identifier)
                end
            end
        end

        if accounts['1'] then
            SharedAccounts[accounts['1'].iban] = CreateSharedAccount(accounts['1'].money, accounts['1'].iban, '1', v.identifier)
        end

        if accounts['society'] then
            SharedAccounts[accounts['society'].iban] = CreateSharedAccount(accounts['society'].money, accounts['society'].iban, 'society', v.identifier)
        end
    end

    if Config.Society.enable and Config.Society.addon_account then
        for jobName, job in pairs(Config.Society.jobs) do
            TriggerEvent('esx_addonaccount:getSharedAccount', 'society_' .. jobName, function(account)
                SharedAccounts[Config.IBAN.prefix .. job.iban] = CreateSharedAccount(account.money, Config.IBAN.prefix .. job.iban, 'society', 'society_' .. jobName)
            end)
        end

        debugString = debugString .. ('^2 and ^3%s^2 Society Accounts ^0'):format(getJobCount())
    end

    logging('debug', debugString)
end

getJobCount = function()
    local count = 0

    for k, v in pairs(Config.Society.jobs) do
        count = count + 1
    end

    return count
end

AddEventHandler('msk_banking:getSharedAccount', function(iban, cb)
	cb(GetSharedAccount(iban))
end)

GetSharedAccount = function(iban)
    return SharedAccounts[iban] or false
end
exports('GetSharedAccount', GetSharedAccount)

refreshSharedAccount = function(money, iban, account, identifier)
    SharedAccounts[iban] = CreateSharedAccount(money, iban, account, identifier)
end
exports('refreshSharedAccount', refreshSharedAccount)

deleteSharedAccount = function(iban)
    if not SharedAccounts[iban] then return end
    SharedAccounts[iban] = nil
end

-- With Addon_Account the ifentifier is always account_name f.e.: society_police
CreateSharedAccount = function(money, iban, account, identifier)
	local self = {}

	self.money      = tonumber(money)
    self.iban       = iban
    self.account    = account
    self.identifier = identifier

	function self.addMoney(amount)
        self.setMoney(self.money + tonumber(amount))
	end

	function self.removeMoney(amount)
        self.setMoney(self.money - tonumber(amount))
	end

	function self.setMoney(amount)
		self.money = tonumber(amount)
        TriggerEvent('msk_banking:setSharedAccountMoney', {money = self.money, iban = self.iban, account = self.account, identifier = self.identifier})
		self.save()
	end

	function self.save()
        if self.account == 'main' then
            local xPlayer = ESX.GetPlayerFromIdentifier(self.identifier)

            if xPlayer then
                if xPlayer.getAccount('bank').money ~= self.money then
                    xPlayer.setAccountMoney('bank', self.money)
                end
            else
                local data = MySQL.query.await('SELECT * FROM users WHERE identifier = @identifier', {['@identifier'] = self.identifier})
                local accounts = json.decode(data[1].accounts)

                accounts.bank = self.money
                MySQL.update('UPDATE users SET accounts = ? WHERE identifier = ?', {json.encode(accounts), self.identifier})
            end
        elseif self.account == '1' then
            local data = MySQL.query.await('SELECT * FROM msk_banking WHERE identifier = @identifier', {['@identifier'] = self.identifier})
            local accounts = json.decode(data[1].accounts)

            accounts['1'].money = self.money
            MySQL.update('UPDATE msk_banking SET accounts = ? WHERE identifier = ?', {json.encode(accounts), self.identifier})
        elseif self.account == 'society' then
            if Config.Society.addon_account then
                TriggerEvent('esx_addonaccount:getSharedAccount', self.identifier, function(society)
                    if society.money ~= self.money then
                        society.setMoney(self.money)
                    end
                end)
            else
                local accounts = {['society'] = {money = self.money, iban = self.iban}}

                MySQL.update('UPDATE msk_banking SET accounts = ? WHERE identifier = ?', {json.encode(accounts), self.identifier})
            end
        end
	end

	return self
end

AddEventHandler('esx_addonaccount:addMoney', function(society, money)
    local iban = getIBANFromIdentifier(society, 'society')

    if iban and SharedAccounts[iban] then
        logging('debug', 'esx_addonaccount:addMoney', iban, society, money)
        TriggerEvent('msk_banking:getSharedAccount', iban, function(account)
            account.addMoney(money)
        end)
    end
end)

AddEventHandler('esx_addonaccount:removeMoney', function(society, money)
    local iban = getIBANFromIdentifier(society, 'society')

    if iban and SharedAccounts[iban] then
        logging('debug', 'esx_addonaccount:removeMoney', iban, society, money)
        TriggerEvent('msk_banking:getSharedAccount', iban, function(account)
            account.removeMoney(money)
        end)
    end
end)

AddEventHandler('esx_addonaccount:setMoney', function(society, money)
    local iban = getIBANFromIdentifier(society, 'society')

    if iban and SharedAccounts[iban] then
        logging('debug', 'esx_addonaccount:setMoney', iban, society, money)
        TriggerEvent('msk_banking:getSharedAccount', iban, function(account)
            account.setMoney(money)
        end)
    end
end)

AddEventHandler('esx:setAccountMoney', function(playerId, account, money)
    local xPlayer = ESX.GetPlayerFromId(playerId)
    if not xPlayer then return end
    
    if account == 'bank' then
        local iban = getIBANFromIdentifier(xPlayer.identifier, 'main')

        if iban and SharedAccounts[iban] then
            logging('debug', 'esx:setAccountMoney', iban, money)
            TriggerEvent('msk_banking:getSharedAccount', iban, function(account)
                account.setMoney(money)
            end)
        end
    end
end)

AddEventHandler('esx:addAccountMoney', function(playerId, account, money)
    local xPlayer = ESX.GetPlayerFromId(playerId)
    if not xPlayer then return end
    
    if account == 'bank' then
        local iban = getIBANFromIdentifier(xPlayer.identifier, 'main')

        if iban and SharedAccounts[iban] then
            logging('debug', 'esx:addAccountMoney', iban, money)
            TriggerEvent('msk_banking:getSharedAccount', iban, function(account)
                account.addMoney(money)
            end)
        end
    end
end)

AddEventHandler('esx:removeAccountMoney', function(playerId, account, money)
    local xPlayer = ESX.GetPlayerFromId(playerId)
    if not xPlayer then return end
    
    if account == 'bank' then
        local iban = getIBANFromIdentifier(xPlayer.identifier, 'main')

        if iban and SharedAccounts[iban] then
            logging('debug', 'esx:removeAccountMoney', iban, money)
            TriggerEvent('msk_banking:getSharedAccount', iban, function(account)
                account.removeMoney(money)
            end)
        end
    end
end)