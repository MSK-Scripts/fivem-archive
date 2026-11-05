-- Insert you Discord Webhook here
local webhookLink = ""

function sendDiscordLog(name, item, count, itemType)
	if Config.DiscordLog then
		local countName
		if itemType == 'item' then
			countName = "Count"
		elseif itemType == 'weapon' then
			countName = "Ammo"
		end

		local botColor = Config.botColor
		local botName = Config.botName
		local botAvatar = Config.botAvatar
		local title = "MSK Crafting"
		local description = Config.botDescription
		local fields = {
			{name = "Name", value = name, inline = false},
			{name = "Item", value = item, inline = true},
			{name = countName, value = count, inline = true},
		}
		local footer = {
			text = "© MSK Scripts", 
			link = "https://i.imgur.com/PizJGsh.png"
		}
		local time = "%d/%m/%Y %H:%M:%S" -- format: "day/month/year hour:minute:second"

		MSK.AddWebhook(webhookLink, botColor, botName, botAvatar, title, description, fields, footer, time)
	end
end