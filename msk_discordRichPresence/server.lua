MSK.Register('msk_discordRichPresence:getPlayers', function(source)
    local OnlinePlayers = {}

    for k, playerId in pairs(GetPlayers()) do
        OnlinePlayers[#OnlinePlayers + 1] = playerId
    end
    
    return OnlinePlayers
end)