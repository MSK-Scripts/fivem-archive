getChannelMembers = function(channel, source)
    channel = tonumber(channel)
    local channelMembers = {}

    if ChannelsWithPassword[channel] then
        ChannelsWithPassword[channel].members = {}
    end

    if Config.VoiceSystem == 'saltychat' then
        local data = exports['saltychat']:GetPlayersInRadioChannel(channel)

        for k, playerId in pairs(data) do
            local playerName = GetPlayerName(playerId)

            channelMembers[#channelMembers + 1] = {playerId = playerId, name = playerName}

            if ChannelsWithPassword[channel] then
                table.insert(ChannelsWithPassword[channel].members, {playerId = playerId, name = playerName})
            end
        end
    elseif Config.VoiceSystem == 'pma' then
        local data = exports['pma-voice']:getPlayersInRadioChannel(channel)

        for playerId, isTalking in pairs(data) do
            local playerName = GetPlayerName(playerId)

            channelMembers[#channelMembers + 1] = {playerId = playerId, name = playerName}

            if ChannelsWithPassword[channel] then
                table.insert(ChannelsWithPassword[channel].members, {playerId = playerId, name = playerName})
            end
        end
    elseif Config.VoiceSystem == 'tokovoip' then
        local data = MSK.Trigger('msk_radio:getTokovoipPlayers', source, GetPlayers(), channel)

        for k, playerId in pairs(data) do
            local playerName = GetPlayerName(playerId)

            channelMembers[#channelMembers + 1] = {playerId = playerId, name = playerName}

            if ChannelsWithPassword[channel] then
                table.insert(ChannelsWithPassword[channel].members, {playerId = playerId, name = playerName})
            end
        end
    end

    return channelMembers
end
exports('getChannelMembers', getChannelMembers)

hasChannelPassword = function(channel)
    return ChannelsWithPassword[tonumber(channel)] or false
end
exports('hasChannelPassword', hasChannelPassword)

checkChannelPassword = function(channel, password)
    return ChannelsWithPassword[tonumber(channel)].password == password
end
exports('checkChannelPassword', checkChannelPassword)

isFirstInChannel = function(channel, source)
    local channelMembers = getChannelMembers(tonumber(channel), source) -- source only for tokovoip

    return #channelMembers == 0
end

registerChannelPassword = function(channel, password)
    channel = tonumber(channel)
    database[channel] = password

    ChannelsWithPassword[channel] = {
        password = password,
        members = {}
    }

    saveDatabase(database)
end
RegisterNetEvent('msk_radio:registerChannelPassword', registerChannelPassword)

addPlayerToRadio = function(playerId, channel)
    channel = tonumber(channel)
    if not ChannelsWithPassword[channel] then return end
    table.insert(ChannelsWithPassword[channel].members, {playerId = playerId, name = GetPlayerName(playerId)})
end

removePlayerFromRadio = function(playerId, channel)
    channel = tonumber(channel)
    if not ChannelsWithPassword[channel] then return end

    for k, v in pairs(ChannelsWithPassword[channel].members) do
        if v.playerId == playerId then
            ChannelsWithPassword[channel].members[k] = nil
            break
        end
    end

    if #ChannelsWithPassword[channel].members == 0 then
        ChannelsWithPassword[channel] = nil
        database[channel] = nil 
        
        saveDatabase(database)
    end
end