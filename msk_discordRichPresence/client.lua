CreateThread(function()
	while true do
		local sleep = Config.Refresh * 1000

		local onlinePlayers = MSK.Trigger('msk_discordRichPresence:getPlayers')
		local id = GetPlayerServerId(PlayerId())
		local name = GetPlayerName(PlayerId())
		-- print("Online players", #onlinePlayers)

		SetDiscordAppId(Config.AppId)
		SetDiscordRichPresenceAsset(Config.Asset)
		SetDiscordRichPresenceAssetText(Config.ServerName)
		SetDiscordRichPresenceAssetSmall(Config.Asset)
		SetDiscordRichPresenceAssetSmallText(Config.ServerName)
		SetRichPresence(#onlinePlayers .. "/" .. Config.ServerSlots .. " - ID: " .. id .. " | Name: " .. name)

		local button = Config.Buttons
		if button['0'] then SetDiscordRichPresenceAction(0, button['0'].name, button['0'].link) end
		if button['1'] then SetDiscordRichPresenceAction(1, button['1'].name, button['1'].link) end
		
		Wait(sleep)
	end
end)