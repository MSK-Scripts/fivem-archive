-- Insert you Discord Webhook here
local webhookLink = ""

function sendDiscordLog(xPlayer, location, coords)
	if Config.DiscordLog then
		local botColor = Config.botColor
		local botName = Config.botName
		local botAvatar = Config.botAvatar
		local title = Config.botTitle
		local description = xPlayer.name .. " (ID: " .. xPlayer.source .. ") teleported to Location: " .. location
		local fields = {
			{name = "Name", value = xPlayer.name .. ' (ID: ' .. xPlayer.source .. ')', inline = false},
			{name = "Coords", value = coords, inline = false},
		}
		local footer = {
			text = "© MSK Scripts",
			icon_url = 'https://i.imgur.com/PizJGsh.png'
		}
		local time = "%d/%m/%Y %H:%M:%S" -- format: "day/month/year hour:minute:second"

		MSK.AddWebhook(webhookLink, botColor, botName, botAvatar, title, description, fields, footer, time)
	end
end