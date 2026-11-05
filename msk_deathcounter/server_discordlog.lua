-- Insert you Discord Webhook here
local webhookLink = ""

function sendDiscordLog(xPlayer, deaths, maxDeaths)
	if Config.DiscordLog then
		local content = {{
			["title"] = "MSK Deathcounter",
			["description"] = Config.botDescription,
			["color"] = Config.botColor,
			["fields"] = {
				{name = "Name", value = xPlayer.name, inline = true},
				{name = "Deaths", value = deaths .. " / " .. maxDeaths, inline = true},
			},
			["footer"] = {
				["text"] = "© MSK Scripts",
				["icon_url"] = 'https://i.imgur.com/PizJGsh.png'
			},
		}}

		PerformHttpRequest(webhookLink, function(err, text, headers) end, 'POST', json.encode({
			username = Config.botName,
			embeds = content,
			avatar_url = Config.botAvatar
		}), {
			['Content-Type'] = 'application/json'
		})
	end
end