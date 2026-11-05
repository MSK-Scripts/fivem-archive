local datastring = LoadResourceFile(GetCurrentResourceName(), "database.json")
database = json.decode(datastring)

ChannelsWithPassword = {}
tokoVoipChannels = {}

saveDatabase = function(data)
    SaveResourceFile(GetCurrentResourceName(), "database.json", json.encode(data, { indent = true }), -1)
end

getDatabase = function()
    return database
end
exports('getDatabase', getDatabase)

getIsResourceLoaded = function()
    if Config.VoiceSystem == 'saltychat' then
        return GetResourceState("saltychat")
    elseif Config.VoiceSystem == 'pma' then
        return GetResourceState("pma-voice")
    elseif Config.VoiceSystem == 'tokovoip' then
        return GetResourceState("tokovoip_script")
    end
end

loadingChannels = function()
    for channel, password in pairs(database) do
        ChannelsWithPassword[channel] = {
            password = password,
            members = {}
        }
    end

    if getIsResourceLoaded() ~= 'missing' then
        if getIsResourceLoaded() ~= 'started' then
            while getIsResourceLoaded() ~= 'started' do
                Wait(100)
            end
        end
    end

    if not getChannelMembers then
        while not getChannelMembers do
            Wait(100)
        end
    end

    for channel, password in pairs(ChannelsWithPassword) do
        ChannelsWithPassword[channel].members = getChannelMembers(channel)
    end
end
loadingChannels()

logging = function(code, ...)
    if not Config.Debug then return end
    MSK.Logging(code, ...)
end

GithubUpdater = function()
    local GetCurrentVersion = function()
	    return GetResourceMetadata(GetCurrentResourceName(), "version")
    end

	local isVersionIncluded = function(Versions, cVersion)
		for k, v in pairs(Versions) do
			if v.version == cVersion then
				return true
			end
		end

		return false
	end
    
    local CurrentVersion = GetCurrentVersion()
    local resourceName = "^0[^2"..GetCurrentResourceName().."^0]"

    if Config.VersionChecker then
        PerformHttpRequest('https://raw.githubusercontent.com/Musiker15/VERSIONS/main/Radio.json', function(errorCode, jsonString, headers)
			if not jsonString then 
                print(resourceName .. '^1Update Check failed ^3Please Update to the latest Version: ^9https://keymaster.fivem.net/^0')
                print(resourceName .. '^2 ✓ Resource loaded^0 - ^5Current Version: ^0' .. CurrentVersion)
                return
            end

			local decoded = json.decode(jsonString)
            local version = decoded[1].version

            if CurrentVersion == version then
                print(resourceName .. '^2 ✓ Resource is Up to Date^0 - ^5Current Version: ^2' .. CurrentVersion .. '^0')
            elseif CurrentVersion ~= version then
                print(resourceName .. '^1 ✗ Resource Outdated. Please Update!^0 - ^5Current Version: ^1' .. CurrentVersion .. '^0')
                print('^5Latest Version: ^2' .. version .. '^0 - ^6Download here: ^9https://keymaster.fivem.net/^0')
				print('')
				if not string.find(CurrentVersion, 'beta') then
					for i=1, #decoded do 
						if decoded[i]['version'] == CurrentVersion then
							break
						elseif not isVersionIncluded(decoded, CurrentVersion) then
							print('^1You are using an^3 UNSUPPORTED VERSION^1 of ^0' .. resourceName)
							break
						end

						if decoded[i]['changelogs'] then
							print('^3Changelogs v' .. decoded[i]['version'] .. '^0')

							for _, c in ipairs(decoded[i]['changelogs']) do
								print(c)
							end
						end
					end
				else
					print('^1You are using the^3 BETA VERSION^1 of ^0' .. resourceName)
				end
            end
        end)
    else
        print(resourceName .. '^2 ✓ Resource loaded^0 - ^5Current Version: ^2' .. CurrentVersion .. '^0')
    end
end
GithubUpdater()