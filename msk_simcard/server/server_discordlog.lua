-- Insert you Discord Webhook here
local webhookLink = ""

function sendDiscordLog(playerData, newNumber, item)
	if not Config.DiscordLog then return end
	
	local content = {{
		["title"] = "MSK Simcard",
		["description"] = ('%s (ID: %s) changed the Phonenumber'):format(playerData.name, playerData.playerId),
		["color"] = Config.botColor,
		["fields"] = {
			{name = "Name", value = ('%s (ID: %s)'):format(playerData.name, playerData.playerId), inline = true},
			{name = "New Number", value = newNumber, inline = true},
			{name = "Item", value = item}
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