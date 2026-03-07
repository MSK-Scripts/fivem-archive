ESX = exports["es_extended"]:getSharedObject()

local currentCrafting = nil
local hadSpeak, isBought, isMenuOpen, isDead = false, false, false, false
local craftingTimerActive, craftingTimerTask, craftingSet = false, false, false
local Blips, isPedLoaded = {}, {}

AddEventHandler('esx:onPlayerDeath', function() isDead = true end)
AddEventHandler('esx:onPlayerSpawn', function(spawn) isDead = false end)

RegisterNetEvent('esx:playerLoaded')
AddEventHandler('esx:playerLoaded', function(xPlayer)
    ESX.PlayerData = xPlayer
    resetShopBlips()
end)

RegisterNetEvent('esx:playerLogout') 
AddEventHandler('esx:playerLogout', function(xPlayer)
    resetShopBlips()
end)

RegisterNetEvent('esx:setJob')
AddEventHandler('esx:setJob', function(job)
    ESX.PlayerData.job = job
    resetShopBlips()
end)

CreateThread(function()
    local shown = false

    while true do
        local sleep = 200
        currentCrafting = nil
        shown = false

        for k, crafting in pairs(Config.Crafting) do
            for k2, location in pairs(crafting.locations) do
                if not crafting.jobs.enable or ESX.PlayerData.job and job_contains(crafting.jobs.jobs, ESX.PlayerData.job.name) and grade_contains(crafting.jobs.jobs, ESX.PlayerData.job.grade) then
                    local distance = #(GetEntityCoords(PlayerPedId()) - vec3(location.x, location.y, location.z))

                    if crafting.pedmodel.enable then
                        local pedmodel = GetHashKey(crafting.pedmodel.model)
                        local npcID = pedmodel .. '-' .. k .. '-' .. k2

                        if distance < crafting.pedmodel.distance then
                            if not isPedLoaded[npcID] or not isPedLoaded[npcID].loaded then
                                isPedLoaded[npcID] = {}

                                RequestModel(pedmodel)
                                while not HasModelLoaded(pedmodel) do
                                    Wait(1)
                                end
                                local npc = CreatePed(4, pedmodel, location.x, location.y, location.z - 1.0, location.h, false, true)
                                FreezeEntityPosition(npc, true)	
                                SetEntityHeading(npc, location.h)
                                SetEntityInvincible(npc, true)
                                SetBlockingOfNonTemporaryEvents(npc, true)

                                logging('debug', 'Set NPC', 'NPC: ' .. npc, 'NPCID: ' .. npcID)

                                isPedLoaded[npcID].loaded = true
                                isPedLoaded[npcID].inDistance = true
                                isPedLoaded[npcID].hasSpeak = false
                                isPedLoaded[npcID].hash = pedmodel
                                isPedLoaded[npcID].pedmodel = crafting.pedmodel.model
                                isPedLoaded[npcID].npc = npc
                                isPedLoaded[npcID].npcID = npcID
                                isPedLoaded[npcID].location = vec3(location.x, location.y, location.z)
                            end
                        else
                            if isPedLoaded[npcID] and isPedLoaded[npcID].loaded then
                                isPedLoaded[npcID].inDistance = false
                            end
                        end

                        if Config.npcVoice.enable then
                            for _, v in pairs(isPedLoaded) do
                                if isPedLoaded[v.npcID] and isPedLoaded[v.npcID].loaded then
                                    local dist = #(GetEntityCoords(PlayerPedId()) - isPedLoaded[v.npcID].location)

                                    if dist < Config.npcVoice.inRange and not isPedLoaded[v.npcID].hasSpeak then
                                        PlayPedAmbientSpeechNative(isPedLoaded[v.npcID].npc, 'GENERIC_HI', 'SPEECH_PARAMS_FORCE_NO_REPEAT_FRONTEND')
                                        isPedLoaded[v.npcID].hasSpeak = true
                                    elseif dist > Config.npcVoice.outRange and isPedLoaded[v.npcID].hasSpeak then
                                        PlayPedAmbientSpeechNative(isPedLoaded[v.npcID].npc, 'GENERIC_BYE', 'SPEECH_PARAMS_FORCE_NO_REPEAT_FRONTEND')
                                        isPedLoaded[v.npcID].hasSpeak = false
                                    end
                                end
                            end
                        end
                    else
                        if distance <= crafting.marker.distance then 
                            if crafting.marker.enable then
                                DrawMarker(crafting.marker.type, location.x, location.y, location.z - 1.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, crafting.marker.size.a, crafting.marker.size.b, crafting.marker.size.c, crafting.marker.color.a, crafting.marker.color.b, crafting.marker.color.c, 100, false, true, 0, false)
                            end

                            if crafting.text3d.enable then
                                MSK.Draw3DText(location, crafting.text3d.label, crafting.text3d.size)
                            end
                        end
                    end

                    if distance <= 5.0 then
                        sleep = 0
                    end

                    if distance <= 2.5 then
                        currentCrafting = crafting
                        inRange = true

                        if not isMenuOpen and not isDead then
                            if not shown then
                                if Config.defaultTextUI then
                                    MSK.HelpNotification(Translation[Config.Locale]['open_crafting']:format(crafting.label))
                                elseif not Config.defaultTextUI then 
                                    Config.openTextUI(currentCrafting)
                                end
                            end

                            if IsControlJustReleased(0, Config.Hotkey) then
                                shown = true

                                if currentCrafting.license.enable then
                                    if currentCrafting.license.type == 'license' then
                                        ESX.TriggerServerCallback('esx_license:checkLicense', function(hasLicense)
                                            isBought = hasLicense
                                            openCraftingMenu()
                                        end, GetPlayerServerId(PlayerId()), currentCrafting.license.name)
                                    elseif currentCrafting.license.type == 'item' then
                                        local hasLicense = MSK.TriggerCallback('msk_crafting:checkLicenseItem', currentCrafting.license)
                                        isBought = hasLicense
                                        openCraftingMenu()
                                    end
                                else
                                    isBought = true
                                    openCraftingMenu()
                                end
                            end
                        else
                            if shown then
                                if not Config.defaultTextUI then 
                                    Config.closeTextUI()
                                end
                            end
                        end
                    end
                end
            end
        end

        if not currentCrafting then
            if craftingTimerActive and craftingSet then
                startCraftingTimer()
            end

            if isMenuOpen then
                shown = false
                _menuPool:CloseAllMenus()
            end
        end

        for k, v in pairs(isPedLoaded) do
            if v.loaded and not v.inDistance then
                logging('debug', 'Delete NPC', 'NPC: ' .. v.npc, 'NPCID: ' .. v.npcID)
                DeleteEntity(v.npc)
                SetModelAsNoLongerNeeded(v.hash)
                isPedLoaded[v.npcID] = {}
            end
        end

        Wait(sleep)
    end
end)

---- NativeUI ----
_menuPool = NativeUI.CreatePool()
local mainMenu

CreateThread(function()
	while true do
        local sleep = 200
        isMenuOpen = false

		if _menuPool:IsAnyMenuOpen() then 
            sleep = 0
            isMenuOpen = true
            _menuPool:ProcessMenus()
        end

		Wait(sleep)
	end
end)

function openCraftingMenu()
    logging('debug', currentCrafting.label)
    local background = nil

    if currentCrafting.customBanner.enable then
        if currentCrafting.customBanner.removeTitle then
            mainMenu = NativeUI.CreateMenu(nil, '~b~')
        else
            mainMenu = NativeUI.CreateMenu(currentCrafting.label, '~b~')
        end

        background = Sprite.New(currentCrafting.customBanner.banner, currentCrafting.customBanner.banner, 0, 0, currentCrafting.customBanner.x, currentCrafting.customBanner.y)
        mainMenu:SetBannerSprite(background, true)
    else
        mainMenu = NativeUI.CreateMenu(currentCrafting.label, '~b~')
    end
    _menuPool:Add(mainMenu)

    for k, item in pairs(currentCrafting.items) do
        local itemList = _menuPool:AddSubMenu(mainMenu, item.label)
        itemList.ParentItem:RightLabel('~b~→→→')

        if currentCrafting.customBanner.enable then
            itemList:SetBannerSprite(background, true)
        end

        if currentCrafting.license.enable and currentCrafting.license.buyLicense and item.license and not isBought then
            local license = _menuPool:AddSubMenu(itemList, Translation[Config.Locale]['license'] .. currentCrafting.license.label)
            license.ParentItem:RightLabel('~b~' .. currentCrafting.license.price .. '$')

            if currentCrafting.customBanner.enable then
                license:SetBannerSprite(background, true)
            end

            local buyMoney = NativeUI.CreateItem(Translation[Config.Locale]['money'], '~b~')
            buyMoney:RightLabel('~b~→→→')
            license:AddItem(buyMoney)

            local buyBank = NativeUI.CreateItem(Translation[Config.Locale]['bank'], '~b~')
            buyBank:RightLabel('~b~→→→')
            license:AddItem(buyBank)

            buyMoney.Activated = function(sender, index)
                logging('debug', 'license money')
                TriggerServerEvent('msk_crafting:buyLicense', currentCrafting.license, 'money')
                _menuPool:CloseAllMenus()
            end

            buyBank.Activated = function(sender, index)
                logging('debug', 'license bank')
                TriggerServerEvent('msk_crafting:buyLicense', currentCrafting.license, 'bank')
                _menuPool:CloseAllMenus()
            end
        else
            local hasItem = false
            for k2, ingredients in pairs(item.ingredients) do
                for k3, items in pairs(ESX.GetPlayerData().inventory) do
                    if ingredients.name == items.name then
                        needed = NativeUI.CreateItem(Translation[Config.Locale]['needed_Item'] .. ingredients.count .. ' ' .. ingredients.label, Translation[Config.Locale]['has_items'] .. items.count)
                        hasItem = true
                    end
                end

                if not hasItem then
                    needed = NativeUI.CreateItem(Translation[Config.Locale]['needed_Item'] .. ingredients.count .. ' ' .. ingredients.label, Translation[Config.Locale]['has_items'] .. '0')
                end
                itemList:AddItem(needed)
            end

            local space = NativeUI.CreateItem('', '~b~')
            itemList:AddItem(space)

            local craft = NativeUI.CreateItem(Translation[Config.Locale]['craft'], '~b~')
            craft:RightLabel('~g~→→→')
            itemList:AddItem(craft)

            craft.Activated = function(sender, index)
                logging('debug', 'craftItem:', item.name, item.count)
                if item.count == 'self' then
                    Config.Input(item, item.ingredients)
                else
                    TriggerServerEvent('msk_crafting:craft', item, item.ingredients)
                end
                _menuPool:CloseAllMenus()
            end
        end
    end

    mainMenu:Visible(true)
    _menuPool:RefreshIndex()
    _menuPool:MouseControlsEnabled(false)
    _menuPool:MouseEdgeEnabled(false)
    _menuPool:ControlDisablingEnabled(false)
end

---- Events ----

RegisterNetEvent('msk_crafting:checkDistance')
AddEventHandler('msk_crafting:checkDistance', function(item, neededItems, own)
    startCraftingTimer(item, neededItems, own)
end)

---- Functions ----
function startCraftingTimer(item, neededItems, own)
	if craftingTimerActive then
        logging('debug', 'STOP CraftingTimer function')
        craftingSet = false
        craftingTimerActive = false
        Config.Notification(nil, Translation[Config.Locale]['not_inDistance'])
        Config.progressBarSTOP()
		MSK.DelTimeout(craftingTimerTask)
        return
	end
    
    logging('debug', 'START CraftingTimer function')
    craftingSet = true
	craftingTimerActive = true
    if type(item.count) == 'table' then
        local random = math.random(item.count.min, item.count.max)
        Config.progressBarSTART(item.time * random, Translation[Config.Locale]['crafting']:format(item.label))

        craftingTimerTask = MSK.AddTimeout(item.time * 1000 * random, function()
            logging('debug', 'craftingTimerTask Finished')
            craftingSet = false
            craftingTimerActive = false
            TriggerServerEvent('msk_crafting:startCrafting', item, neededItems, own, random)
        end)
    else
        Config.progressBarSTART(item.time * item.count, Translation[Config.Locale]['crafting']:format(item.label))

        craftingTimerTask = MSK.AddTimeout(item.time * 1000 * item.count, function()
            logging('debug', 'craftingTimerTask Finished')
            craftingSet = false
            craftingTimerActive = false
            TriggerServerEvent('msk_crafting:startCrafting', item, neededItems, own)
        end)
    end
end

function resetShopBlips()
    CreateThread(function()
        for k,v in pairs(Blips) do
            RemoveBlip(v)
            Blips = {}
        end

        for k, crafting in pairs(Config.Crafting) do
            if crafting.blip.enable then
                local canSee = true

                if crafting.jobs.enable then
                    if ESX.PlayerData.job then 
                        if job_contains(crafting.jobs.jobs, ESX.PlayerData.job.name) then
                            if grade_contains(crafting.jobs.jobs, ESX.PlayerData.job.grade) then
                                canSee = true
                            else
                                canSee = false
                            end
                        else
                            canSee = false
                        end
                    else
                        canSee = false
                    end
                end

                if canSee then
                    for k2, location in pairs(crafting.locations) do
                        blip = AddBlipForCoord(location.x, location.y, location.z)

                        SetBlipSprite(blip, crafting.blip.id)
                        SetBlipScale(blip, crafting.blip.scale)
                        SetBlipDisplay(blip, 4)
                        SetBlipColour(blip, crafting.blip.color)
                        SetBlipAsShortRange(blip, true)
                        BeginTextCommandSetBlipName('STRING') 
                        AddTextComponentString(crafting.label)
                        EndTextCommandSetBlipName(blip)
                        
                        table.insert(Blips, blip)
                    end
                end
            end
        end
    end)
end
resetShopBlips()

CreateDialog = function(Text)
	AddTextEntry(Text, Text)
	DisplayOnscreenKeyboard(1, Text, "", "", "", "", "", 32)
	while (UpdateOnscreenKeyboard() == 0) do
		DisableAllControlActions(0);
		Wait(0);
	end
	if (GetOnscreenKeyboardResult()) then
		local displayResult = GetOnscreenKeyboardResult()
		return displayResult
	end
end

job_contains = function(table, value)
    for k, v in pairs(table) do
        if v.job == value then
            return true
        end
    end
    return false
end

grade_contains = function(table, value)
    for k, v in pairs(table) do
        if v.grade <= value then
            return true
        end
    end
    return false
end

logging = function(code, ...)
    if Config.Debug then
        local script = "[^2"..GetCurrentResourceName().."^0]"
        MSK.logging(script, code, ...)
    end
end