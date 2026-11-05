-- Insert you Discord Webhook here
local webhookLink = ""

function sendDiscordLog(xPlayer, action, method, amount, item)
	if Config.DiscordLog then
		if action == 'buy' then 
			action = 'bought'
		elseif action == 'sell' then
			action = 'sold'
		end

		local botColor = Config.botColor
		local botName = Config.botName
		local botAvatar = Config.botAvatar
		local title = "MSK Shops"
		local description = xPlayer.name .. " (ID: " .. xPlayer.source .. ") " .. action .. " " .. amount .. "x " .. item.label .. " (" .. item.name .. ")"
		local fields = {
			{name = "Name", value = xPlayer.name .. " (ID: " .. xPlayer.source .. ")", inline = true},
			{name = "Method", value = method, inline = true},
			{name = "Action", value = action, inline = false},
			{name = "Amount", value = amount, inline = true},
			{name = "Item", value = item.label .. " (" .. item.name .. ")", inline = true}
		}
		local footer = {
			text = "© MSK Scripts", 
			link = "https://i.imgur.com/PizJGsh.png"
		}
		local time = "%d/%m/%Y %H:%M:%S" -- format: "day/month/year hour:minute:second"

		addDiscordLog(webhookLink, botColor, botName, botAvatar, title, description, fields, footer, time)
	end
end

function sendDiscordLogLicense(xPlayer, method, license)
	if Config.DiscordLog then
		local botColor = Config.botColor
		local botName = Config.botName
		local botAvatar = Config.botAvatar
		local title = "MSK Shops"
		local description = xPlayer.name .. " (ID: " .. xPlayer.source .. ") bought the license " .. license.label .. " (" .. license.name .. ")"
		local fields = {
			{name = "Name", value = xPlayer.name .. " (ID: " .. xPlayer.source .. ")", inline = true},
			{name = "Method", value = method, inline = true},
			{name = "License", value = license.label .. " (" .. license.name .. ")"}
		}
		local footer = {
			text = "© MSK Scripts", 
			link = "https://i.imgur.com/PizJGsh.png"
		}
		local time = "%d/%m/%Y %H:%M:%S" -- format: "day/month/year hour:minute:second"

		addDiscordLog(webhookLink, botColor, botName, botAvatar, title, description, fields, footer, time)
	end
end

addDiscordLog = function(webhook, botColor, botName, botAvatar, title, description, fields, footer, time)
	MSK.AddWebhook(webhook, botColor, botName, botAvatar, title, description, fields, footer, time)
end