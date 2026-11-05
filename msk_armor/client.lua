local isWearingArmor, isPlayerLoaded = false, false
local currentItem = {}

AddEventHandler('onResourceStart', function(resource)
    if GetCurrentResourceName() == resource then
        isPlayerLoaded = ESX.IsPlayerLoaded()
    end
end)

RegisterNetEvent('esx:playerLoaded')
AddEventHandler('esx:playerLoaded', function(xPlayer, isNew, skin)
    Wait(1000) -- Please Do Not Touch! // This is for slower PCs

    if isNew then 
        isPlayerLoaded = true 
        return logging('debug', 'Character is not created yet.', 'Returning...')
    end

    if not xPlayer then 
        isPlayerLoaded = true 
        return logging('error', 'xPlayer not found on Event esx:playerLoaded!', 'Returning...') 
    end

    if not Config.LoadStatus.health and not Config.LoadStatus.armor then 
        isPlayerLoaded = true 
        return logging('debug', 'Config.LoadStatus.health AND Config.LoadStatus.armor is deactivated in config.lua', 'Returning...')
    end

    while not ESX.PlayerData.ped do Wait(10) end

    local playerPed = PlayerPedId()
    local health, armor, item = MSK.Trigger('msk_armor:getStatusFromDB')
    health, armor = tonumber(health), tonumber(armor)
    logging('debug', 'TriggerCallback: getStatusFromDB on Event playerLoaded')
    logging('debug', 'playerHealth: ' .. health, 'playerArmor: ' .. armor, 'Item: ' .. (item or 'nil'))

    if Config.LoadStatus.health then 
        if ESX.PlayerData.metadata and ESX.PlayerData.metadata.health then
            local maxHealth = math.max(health, tonumber(ESX.PlayerData.metadata.health))
            maxHealth = tonumber(maxHealth)
            SetEntityHealth(playerPed, maxHealth)
        else
            SetEntityHealth(playerPed, health)
        end
    end

    if Config.LoadStatus.armor then 
        local setArmor = 0
        if ESX.PlayerData.metadata and ESX.PlayerData.metadata.armor then
            local maxArmor = math.max(armor, tonumber(ESX.PlayerData.metadata.armor))
            maxArmor = tonumber(maxArmor)
            setArmor = maxArmor
        else
            setArmor = armor
        end

        if setArmor > 100 then SetPlayerMaxArmour(playerPed, setArmor) end
        SetPedArmour(playerPed, setArmor)

        if item then 
            currentItem.item = item
            currentItem.percent = Config.Armories[item].percent
        end
    end

    if Config.LoadStatus.restoreVest then
        if armor > 0 then
            logging('debug', 'skin bproof', skin.bproof_1)
                
            if skin and skin.bproof_1 == 0 then
                logging('debug', 'bproof_1 is not set. Setting bproof Skin...')

                if skin.sex == 0 then -- Male
                    local bproof = Config.defaultSkin.Male
                    if item then bproof = Config.Armories[item].skin.Male end
                    TriggerEvent('skinchanger:loadClothes', skin, bproof)
                else -- Female
                    local bproof = Config.defaultSkin.Female
                    if item then bproof = Config.Armories[item].skin.Female end
                    TriggerEvent('skinchanger:loadClothes', skin, bproof)
                end
                saveSkin()
            end

            if Config.giveNoBProof then
                logging('debug', 'TriggerEvent giveNoBProofItem on Event: playerLoaded')
                TriggerServerEvent('msk_armor:giveNoBProofItem')
            end

            isWearingArmor = true
        else
            logging('debug', 'Armor is 0 on playerLoaded')
        end
    end

    isPlayerLoaded = true
end)

if Config.Refresh.enable then
    CreateThread(function()
        while true do
            local sleep = Config.Refresh.time * 1000

            if isPlayerLoaded then
                if Config.Refresh.debug then logging('debug', 'isWearingArmor:', isWearingArmor) end

                if isWearingArmor and GetPedArmour(PlayerPedId()) <= 0 then
                    logging('debug', 'Set isWearingArmor = false', 'Remove Vest on Event: refreshArmour')
                    TriggerEvent('msk_armor:setDelArmor')
                    TriggerServerEvent('msk_armor:removeNoBProofItem')
                end
            end

            Wait(sleep)
        end
    end)
end

if Config.Hotkey.enable then 
    CreateThread(function()
        while true do 
            local sleep = 0

            if IsControlJustPressed(0, Config.Hotkey.key) then 
                local itemName, item = MSK.Trigger('msk_armor:setHotkey', Config.Hotkey.item)

                if item then 
                    TriggerEvent('msk_armor:setArmor', itemName, item)
                else
                    Config.Notification(nil, 'You can not put on a Vest without a Vest!')
                end
            end

            Wait(sleep)
        end
    end)
end

RegisterNetEvent('msk_armor:setArmor')
AddEventHandler('msk_armor:setArmor', function(itemName, item)
    local playerPed = PlayerPedId()

    taskAnimation(Config.Animations.dict, Config.Animations.anim, Config.Animations.time * 1000)
    logging('debug', 'setArmor Item:', itemName, item.percent)

    if item.skin.enable then
        TriggerEvent('skinchanger:getSkin', function(skin)
            if Config.alreadySet then
                if skin.sex == 0 then -- Male
                    TriggerEvent('skinchanger:loadClothes', skin, Config.Armories[itemName].skin.male)
                else -- Female
                    TriggerEvent('skinchanger:loadClothes', skin, Config.Armories[itemName].skin.female)
                end
                saveSkin()
            end
        end)
    end

    currentItem.item = itemName
    currentItem.percent = item.percent

    if item.percent > 100 then SetPlayerMaxArmour(playerPed, item.percent) end
    SetPedArmour(playerPed, item.percent)
    TriggerServerEvent('msk_armor:refreshArmour', GetEntityHealth(playerPed), item.percent, itemName)
    isWearingArmor = true
end)

RegisterNetEvent('msk_armor:setDelArmor')
AddEventHandler('msk_armor:setDelArmor', function()
    local playerPed = PlayerPedId()

    if Config.giveBackVest and GetPedArmour(playerPed) == currentItem.percent then
        TriggerServerEvent('msk_armor:giveBackVest', currentItem.item)
    end

    taskAnimation(Config.Animations.dict, Config.Animations.anim, Config.Animations.time * 1000)

    TriggerEvent('skinchanger:getSkin', function(skin)
        TriggerEvent('skinchanger:loadClothes', skin, {['bproof_1'] = 0, ['bproof_2'] = 0})
        saveSkin()
    end)

    if currentItem.percent > 100 then SetPlayerMaxArmour(playerPed, 100) end
    SetPedArmour(playerPed, 0)
    TriggerServerEvent('msk_armor:refreshArmour', GetEntityHealth(playerPed), 0, 'remove')
    currentItem = {}
    isWearingArmor = false
end)

taskAnimation = function(dict, anim, time)
    local playerPed = PlayerPedId()

    ESX.Streaming.RequestAnimDict(dict, function()
		TaskPlayAnim(playerPed, dict, anim, 8.0, 1.0, -1, 49, 0, false, false, false) -- Standing
        -- TaskPlayAnim(playerPed, dict, anim, 8.0, -8, -1, 32, 0, false, false, false) -- Kneeing
		RemoveAnimDict(dict)
	end)

	Wait(time)
	ClearPedTasks(playerPed)
end

saveSkin = function()
    if not Config.saveSkin then return end
    Wait(100)

    TriggerEvent('skinchanger:getSkin', function(skin)
        TriggerServerEvent('esx_skin:save', skin)
    end)
end

logging = function(code, ...)
    if not Config.Debug then return end
    MSK.Logging(code, ...)
end