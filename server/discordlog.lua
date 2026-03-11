-- Insert you Discord Webhook here
local webhookLink = ""

addWebhook = function(botColor, botName, botAvatar, title, description, fields, footer, time)
	if not Config.DiscordLog then return end -- Do NOT Delete this!!

	MSK.AddWebhook(webhookLink, botColor, botName, botAvatar, title, description, fields, footer, time)
end

-- Deposit or Withdraw or Transfer
function sendTransferMoney(xName, money, method, account, tranfer)
	local desc

	if method == 'deposit' then
		desc = ('%s **DEPOSTIED** $%s to %s'):format(xName, money, account)
	elseif method == 'withdraw' then
		desc =  ('%s **WITHDRAWED** $%s from %s'):format(xName, money, account)
	elseif method == 'transfer' then
		desc =  ('%s **TRANSFERED** $%s from %s to %s'):format(xName, money, account, tranfer)
	end

	local botColor = Config.botColor
	local botName = Config.botName
	local botAvatar = Config.botAvatar
	local title = "MSK Banking"
	local description = desc
	local fields = false
	local footer = {
		text = "© MSK Scripts", 
		link = "https://i.imgur.com/PizJGsh.png"
	}
	local time = "%d/%m/%Y %H:%M:%S" -- format: "day/month/year hour:minute:second"

	addWebhook(botColor, botName, botAvatar, title, description, fields, footer, time)
end

-- Create or Delete Bankaccount
function sendBankAccounts(xName, iban, action, account)
	if action == 'create' then
		action = '**CREATED**'
	elseif action == 'delete' then
		action = '**DELETED**'
	end

	if account == 'main' then
		account = 'Main'
	elseif account == 'second' then
		account = 'Second'
	end

	local botColor = Config.botColor
	local botName = Config.botName
	local botAvatar = Config.botAvatar
	local title = "MSK Banking"
	local description = ("%s %s his %s Bankaccount %s"):format(xName, action, account, iban)
	local fields = {
		{name = "Name", value = xName, inline = true},
		{name = "IBAN", value = iban, inline = true},
	}
	local footer = {
		text = "© MSK Scripts", 
		link = "https://i.imgur.com/PizJGsh.png"
	}
	local time = "%d/%m/%Y %H:%M:%S" -- format: "day/month/year hour:minute:second"

	addWebhook(botColor, botName, botAvatar, title, description, fields, footer, time)
end

-- Change IBAN
function sendChangeIBAN(xName, iban, account)
	if account == 'bank' then
		account = 'Mainaccount'
	elseif account == 'secondBank' then
		account = 'Secondaccount'
	end

	local botColor = Config.botColor
	local botName = Config.botName
	local botAvatar = Config.botAvatar
	local title = "MSK Banking"
	local description = ("%s changed the IBAN of his %s to %s"):format(xName, account, iban)
	local fields = {
		{name = "Name", value = xName, inline = true},
		{name = "Account", value = account, inline = true},
		{name = "IBAN", value = iban, inline = false},
	}
	local footer = {
		text = "© MSK Scripts", 
		link = "https://i.imgur.com/PizJGsh.png"
	}
	local time = "%d/%m/%Y %H:%M:%S" -- format: "day/month/year hour:minute:second"

	addWebhook(botColor, botName, botAvatar, title, description, fields, footer, time)
end

-- Investments
function sendInvestment(xName, money, method)
	if method then
		method = 'DEPOSITED'
	else
		method = 'WITHDRAWED'
	end

	local botColor = Config.botColor
	local botName = Config.botName
	local botAvatar = Config.botAvatar
	local title = "MSK Banking"
	local description = ("%s %s $%s to the Investment"):format(xName, method, money)
	local fields = {
		{name = "Name", value = xName, inline = true},
		{name = "Method", value = method, inline = true},
		{name = "Money", value = "$" .. money, inline = false},
	}
	local footer = {
		text = "© MSK Scripts", 
		link = "https://i.imgur.com/PizJGsh.png"
	}
	local time = "%d/%m/%Y %H:%M:%S" -- format: "day/month/year hour:minute:second"

	addWebhook(botColor, botName, botAvatar, title, description, fields, footer, time)
end