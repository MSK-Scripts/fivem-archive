_menuPool = nil
local mainMenu = nil
local currentShop, currentShopId = nil, nil
local hadSpeak, isBought, isMenuOpen, isDead = false, false, false, false
local Blips, isPedLoaded, itemStorage = {}, {}, {}

AddEventHandler('esx:onPlayerDeath', function() isDead = true end)
AddEventHandler('esx:onPlayerSpawn', function(spawn) isDead = false end)

AddEventHandler('onResourceStart', function(resource)
    if resource == GetCurrentResourceName() then
        getItemStorage()
    end
end)

RegisterNetEvent('esx:playerLoaded')
AddEventHandler('esx:playerLoaded', function(xPlayer)
    ESX.PlayerData = xPlayer
    resetBlips()
    getItemStorage()
end)

RegisterNetEvent('esx:playerLogout') 
AddEventHandler('esx:playerLogout', function(xPlayer)
    resetBlips()
end)
        
RegisterNetEvent('esx:setJob')
AddEventHandler('esx:setJob', function(job)
    ESX.PlayerData.job = job
    resetBlips()
end)

RegisterNetEvent('msk_shops:getItemStorage')
AddEventHandler('msk_shops:getItemStorage', function(data)
    itemStorage = data
end)

CreateThread(function()
    local shown = false

    while true do
        local sleep = 200
        currentShop = nil
        currentShopId = nil
        shown = false

        for k, shops in pairs(Config.Shops) do
            for k2, location in pairs(shops.locations) do 
                if not shops.jobs.enable or ESX.PlayerData.job and job_contains(shops.jobs.jobs, ESX.PlayerData.job.name) and grade_contains(shops.jobs.jobs, ESX.PlayerData.job.grade) then
                    local distance = #(GetEntityCoords(PlayerPedId()) - vec3(location.x, location.y, location.z))

                    if shops.pedmodel.enable then
                        local pedmodel = GetHashKey(shops.pedmodel.model)
                        local npcID = pedmodel .. '-' .. k .. '-' .. k2

                        if distance < shops.pedmodel.distance then
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
                                isPedLoaded[npcID].pedmodel = shops.pedmodel.model
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
                            for k, v in pairs(isPedLoaded) do
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
                        if distance <= shops.marker.distance then 
                            if shops.marker.enable then
                                DrawMarker(shops.marker.type, location.x, location.y, location.z - 1.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, shops.marker.size.a, shops.marker.size.b, shops.marker.size.c, shops.marker.color.a, shops.marker.color.b, shops.marker.color.c, 100, false, true, 0, false)
                            end

                            if shops.text3d.enable then
                                MSK.Draw3DText(location, shops.text3d.label, shops.text3d.size)
                            end
                        end
                    end

                    if distance <= 5.0 then
                        sleep = 0
                    end

                    if distance <= 2.5 then
                        currentShop = shops
                        currentShopId = k

                        if not isMenuOpen and not isDead then
                            if not shown then
                                if Config.defaultTextUI then
                                    MSK.HelpNotification(Translation[Config.Locale]['open_shop']:format(shops.label))
                                elseif not Config.defaultTextUI then 
                                    Config.openTextUI(currentShop)
                                end
                            end

                            if IsControlJustReleased(0, Config.Hotkey) then
                                shown = true

                                if currentShop.license and currentShop.license.enable then
                                    local hasLicense = MSK.TriggerCallback('msk_shops:checkLicense', currentShop.license.type, currentShop.license.name)
                                    isBought = hasLicense
    
                                    if Config.useStorage then
                                        openShopMenuStorage()
                                    else
                                        openShopMenu()
                                    end
                                else
                                    isBought = true
    
                                    if Config.useStorage then
                                        openShopMenuStorage()
                                    else
                                        openShopMenu()
                                    end
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

        if not currentShop and isMenuOpen then
            shown = false
            _menuPool:CloseAllMenus()
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

CreateThread(function()
	while true do
        local sleep = 1
        isMenuOpen = false
        
        if _menuPool then
            if _menuPool:IsAnyMenuOpen() then 
                isMenuOpen = true
                _menuPool:ProcessMenus()
            elseif not _menuPool:IsAnyMenuOpen() then 
                _menuPool:Remove()
            end
        end
        
		Wait(sleep)
	end
end)

reopenMenu = function()
    _menuPool:CloseAllMenus()
    
    if Config.useStorage then
        Wait(250)
        openShopMenuStorage()
    else
        openShopMenu()
    end
end

setCustomBanner = function(menu, background)
    if not currentShop.customBanner.enable then return end
    menu:SetBannerSprite(background, true)
end

openShopMenu = function()
    logging('debug', currentShop.label)

    if _menuPool then 
        _menuPool:Remove()
        _menuPool = nil
    end

    _menuPool = NativeUI.CreatePool()
    local background

    if currentShop.customBanner.enable then
        if currentShop.customBanner.removeTitle then
            mainMenu = NativeUI.CreateMenu(nil, '~b~')
        else
            mainMenu = NativeUI.CreateMenu(currentShop.label, '~b~')
        end
        background = Sprite.New(currentShop.customBanner.banner, currentShop.customBanner.banner, 0, 0, currentShop.customBanner.x, currentShop.customBanner.y)
        setCustomBanner(mainMenu, background)
    else
        mainMenu = NativeUI.CreateMenu(currentShop.label, '~b~')
    end
    _menuPool:Add(mainMenu)

    for k2, item in pairs(currentShop.items) do 
        if not currentShop.jobs.enable or (currentShop.jobs.enable and (not item.jobRank or (item.jobRank and item.jobRank <= ESX.PlayerData.job.grade))) then
            local itemList = _menuPool:AddSubMenu(mainMenu, item.label)
            itemList.ParentItem:RightLabel('~b~→→→')
            setCustomBanner(itemList, background)

            if currentShop.license.enable and item.license and not isBought and currentShop.license.buyLicense then
                local license = _menuPool:AddSubMenu(itemList, currentShop.license.label, Translation[Config.Locale]['license_desc']:format(item.label))
                license.ParentItem:RightLabel('~b~' .. currentShop.license.price .. '$')
                setCustomBanner(license, background)

                if MSK.Table_Contains(currentShop.license.method, 'money') then
                    local buyMoney = NativeUI.CreateItem(Translation[Config.Locale]['money'], '~b~')
                    buyMoney:RightLabel('~b~→→→')
                    license:AddItem(buyMoney)

                    buyMoney.Activated = function(sender, index)
                        logging('debug', 'license money')
                        TriggerServerEvent('msk_shops:buyLicense', currentShop.license, 'money', currentShop.addon_account)
                        reopenMenu()
                    end
                end

                if MSK.Table_Contains(currentShop.license.method, 'bank') then
                    local buyBank = NativeUI.CreateItem(Translation[Config.Locale]['bank'], '~b~')
                    buyBank:RightLabel('~b~→→→')
                    license:AddItem(buyBank)
        
                    buyBank.Activated = function(sender, index)
                        logging('debug', 'license bank')
                        TriggerServerEvent('msk_shops:buyLicense', currentShop.license, 'bank', currentShop.addon_account)
                        reopenMenu()
                    end
                end

                if MSK.Table_Contains(currentShop.license.method, 'black_money') then
                    local buyBlack = NativeUI.CreateItem(Translation[Config.Locale]['black_money'], '~b~')
                    buyBlack:RightLabel('~b~→→→')
                    license:AddItem(buyBlack)

                    buyBlack.Activated = function(sender, index)
                        logging('debug', 'license black')
                        TriggerServerEvent('msk_shops:buyLicense', currentShop.license, 'black_money', currentShop.addon_account)
                        reopenMenu()
                    end
                end
            elseif currentShop.license.enable and item.license and not isBought and not currentShop.license.buyLicense then
                local license = NativeUI.CreateItem(currentShop.license.label, Translation[Config.Locale]['license_desc']:format(item.label))
                itemList:AddItem(license)
            else
                if item.price then
                    local buyList = _menuPool:AddSubMenu(itemList, Translation[Config.Locale]['buy'])
                    buyList.ParentItem:RightLabel('~g~' .. item.price .. '$')
                    setCustomBanner(buyList, background)

                    if MSK.Table_Contains(item.method, 'money') then
                        local buyMoney = NativeUI.CreateItem(Translation[Config.Locale]['money'], '~b~')
                        buyMoney:RightLabel('~b~→→→')
                        buyList:AddItem(buyMoney)

                        buyMoney.Activated = function(sender, index)
                            local input = CreateDialog(Translation[Config.Locale]['amount'])
                            if input and tonumber(input) then
                                TriggerServerEvent('msk_shops:actionItem', 'buy', 'money', tonumber(input), item, currentShop.addon_account)
                            end
                            reopenMenu()
                        end
                    end

                    if MSK.Table_Contains(item.method, 'bank') then
                        local buyBank = NativeUI.CreateItem(Translation[Config.Locale]['bank'], '~b~')
                        buyBank:RightLabel('~b~→→→')
                        buyList:AddItem(buyBank)

                        buyBank.Activated = function(sender, index)
                            local input = CreateDialog(Translation[Config.Locale]['amount'])
                            if input and tonumber(input) then
                                TriggerServerEvent('msk_shops:actionItem', 'buy', 'bank', tonumber(input), item, currentShop.addon_account)
                            end
                            reopenMenu()
                        end
                    end

                    if MSK.Table_Contains(item.method, 'black_money') then
                        local buyBlack = NativeUI.CreateItem(Translation[Config.Locale]['black_money'], '~b~')
                        buyBlack:RightLabel('~b~→→→')
                        buyList:AddItem(buyBlack)

                        buyBlack.Activated = function(sender, index)
                            local input = CreateDialog(Translation[Config.Locale]['amount'])
                            if input and tonumber(input) then
                                TriggerServerEvent('msk_shops:actionItem', 'buy', 'black_money', tonumber(input), item, currentShop.addon_account)
                            end
                            reopenMenu()
                        end
                    end
                end

                if item.sellPrice then
                    local sellList = _menuPool:AddSubMenu(itemList, Translation[Config.Locale]['sell'])
                    sellList.ParentItem:RightLabel('~r~' .. item.sellPrice .. '$')
                    setCustomBanner(sellList, background)

                    if MSK.Table_Contains(item.method, 'money') then
                        local sellMoney = NativeUI.CreateItem(Translation[Config.Locale]['money'], '~b~')
                        sellMoney:RightLabel('~b~→→→')
                        sellList:AddItem(sellMoney)

                        sellMoney.Activated = function(sender, index)
                            local input = CreateDialog(Translation[Config.Locale]['amount'])
                            if input and tonumber(input) then
                                TriggerServerEvent('msk_shops:actionItem', 'sell', 'money', tonumber(input), item, currentShop.addon_account)
                            end
                            reopenMenu()
                        end
                    end

                    if MSK.Table_Contains(item.method, 'bank') then
                        local sellBank = NativeUI.CreateItem(Translation[Config.Locale]['bank'], '~b~')
                        sellBank:RightLabel('~b~→→→')
                        sellList:AddItem(sellBank)

                        sellBank.Activated = function(sender, index)
                            local input = CreateDialog(Translation[Config.Locale]['amount'])
                            if input and tonumber(input) then
                                TriggerServerEvent('msk_shops:actionItem', 'sell', 'bank', tonumber(input), item, currentShop.addon_account)
                            end
                            reopenMenu()
                        end
                    end

                    if MSK.Table_Contains(item.method, 'black_money') then
                        local sellBlack = NativeUI.CreateItem(Translation[Config.Locale]['black_money'], '~b~')
                        sellBlack:RightLabel('~b~→→→')
                        sellList:AddItem(sellBlack)

                        sellBlack.Activated = function(sender, index)
                            local input = CreateDialog(Translation[Config.Locale]['amount'])
                            if input and tonumber(input) then
                                TriggerServerEvent('msk_shops:actionItem', 'sell', 'black_money', tonumber(input), item, currentShop.addon_account)
                            end
                            reopenMenu()
                        end
                    end
                end
            end
        end
    end

    mainMenu:Visible(true)
    _menuPool:RefreshIndex()
    _menuPool:MouseControlsEnabled(false)
    _menuPool:MouseEdgeEnabled(false)
    _menuPool:ControlDisablingEnabled(false)
end

openShopMenuStorage = function()
    logging('debug', currentShop.label)

    if _menuPool then 
        _menuPool:Remove()
        _menuPool = nil
    end

    _menuPool = NativeUI.CreatePool()
    local background
    
    if currentShop.customBanner.enable then
        if currentShop.customBanner.removeTitle then
            mainMenu = NativeUI.CreateMenu(nil, '~b~')
        else
            mainMenu = NativeUI.CreateMenu(currentShop.label, '~b~')
        end
        background = Sprite.New(currentShop.customBanner.banner, currentShop.customBanner.banner, 0, 0, currentShop.customBanner.x, currentShop.customBanner.y)
        setCustomBanner(mainMenu, background)
    else
        mainMenu = NativeUI.CreateMenu(currentShop.label, '~b~')
    end
    _menuPool:Add(mainMenu)

    for k2, item in pairs(currentShop.items) do 
        if not currentShop.jobs.enable or (currentShop.jobs.enable and (not item.jobRank or (item.jobRank and item.jobRank <= ESX.PlayerData.job.grade))) then
            local amount = getItemStorage(currentShopId, item.name)

            local itemList = _menuPool:AddSubMenu(mainMenu, item.label)
            itemList.ParentItem:RightLabel(Translation[Config.Locale]['storage'] .. amount)
            setCustomBanner(itemList, background)

            if currentShop.license.enable and item.license and not isBought and currentShop.buyLicense then
                local license = _menuPool:AddSubMenu(itemList, Translation[Config.Locale]['license'] .. currentShop.license.label)
                license.ParentItem:RightLabel('~b~' .. currentShop.license.price .. '$')
                setCustomBanner(license, background)

                if MSK.Table_Contains(currentShop.license.method, 'money') then
                    local buyMoney = NativeUI.CreateItem(Translation[Config.Locale]['money'], '~b~')
                    buyMoney:RightLabel('~b~→→→')
                    license:AddItem(buyMoney)

                    buyMoney.Activated = function(sender, index)
                        logging('debug', 'license money')
                        TriggerServerEvent('msk_shops:buyLicense', currentShop.license, 'money', currentShop.addon_account)
                        reopenMenu()
                    end
                end

                if MSK.Table_Contains(currentShop.license.method, 'bank') then
                    local buyBank = NativeUI.CreateItem(Translation[Config.Locale]['bank'], '~b~')
                    buyBank:RightLabel('~b~→→→')
                    license:AddItem(buyBank)
        
                    buyBank.Activated = function(sender, index)
                        logging('debug', 'license bank')
                        TriggerServerEvent('msk_shops:buyLicense', currentShop.license, 'bank', currentShop.addon_account)
                        reopenMenu()
                    end
                end

                if MSK.Table_Contains(currentShop.license.method, 'black_money') then
                    local buyBlack = NativeUI.CreateItem(Translation[Config.Locale]['black_money'], '~b~')
                    buyBlack:RightLabel('~b~→→→')
                    license:AddItem(buyBlack)

                    buyBlack.Activated = function(sender, index)
                        logging('debug', 'license black')
                        TriggerServerEvent('msk_shops:buyLicense', currentShop.license, 'black_money', currentShop.addon_account)
                        reopenMenu()
                    end
                end
            else
                if amount == 0 then
                    if item.price then
                        local locked = NativeUI.CreateItem(Translation[Config.Locale]['buy'], Translation[Config.Locale]['sold_out'])
                        itemList:AddItem(locked)
                        locked:SetLeftBadge(BadgeStyle.Lock)

                        _menuPool:MouseControlsEnabled(false)
                        _menuPool:MouseEdgeEnabled(false)
                        _menuPool:ControlDisablingEnabled(false)
                    end
                elseif amount > 0 then
                    if item.price then
                        local buyList = _menuPool:AddSubMenu(itemList, Translation[Config.Locale]['buy'])
                        buyList.ParentItem:RightLabel('~g~' .. item.price .. '$')
                        setCustomBanner(buyList, background)

                        if MSK.Table_Contains(item.method, 'money') then
                            local buyMoney = NativeUI.CreateItem(Translation[Config.Locale]['money'], '~b~')
                            buyMoney:RightLabel('~b~→→→')
                            buyList:AddItem(buyMoney)

                            buyMoney.Activated = function(sender, index)
                                local input = CreateDialog(Translation[Config.Locale]['amount'])

                                if input and tonumber(input) then
                                    if tonumber(input) > amount then
                                        Config.Notification(nil, Translation[Config.Locale]['storage_sold_out'], 'error')
                                    else
                                        ESX.TriggerServerCallback('msk_shops:actionItem', function(data)
                                            if data then setItemStorage('remove', item.name, tonumber(input)) end
                                        end, 'buy', 'money', tonumber(input), item, currentShop.addon_account)
                                    end
                                end
                                reopenMenu()
                            end
                        end

                        if MSK.Table_Contains(item.method, 'bank') then
                            local buyBank = NativeUI.CreateItem(Translation[Config.Locale]['bank'], '~b~')
                            buyBank:RightLabel('~b~→→→')
                            buyList:AddItem(buyBank)

                            buyBank.Activated = function(sender, index)
                                local input = CreateDialog(Translation[Config.Locale]['amount'])

                                if input and tonumber(input) then
                                    if tonumber(input) > amount then
                                        Config.Notification(nil, Translation[Config.Locale]['storage_sold_out'], 'error')
                                    else
                                        ESX.TriggerServerCallback('msk_shops:actionItem', function(data)
                                            if data then setItemStorage('remove', item.name, tonumber(input)) end
                                        end, 'buy', 'bank', tonumber(input), item, currentShop.addon_account)
                                    end
                                end
                                reopenMenu()
                            end
                        end

                        if MSK.Table_Contains(item.method, 'black_money') then
                            local buyBlack = NativeUI.CreateItem(Translation[Config.Locale]['black_money'], '~b~')
                            buyBlack:RightLabel('~b~→→→')
                            buyList:AddItem(buyBlack)

                            buyBlack.Activated = function(sender, index)
                                local input = CreateDialog(Translation[Config.Locale]['amount'])

                                if input and tonumber(input) then
                                    if tonumber(input) > amount then
                                        Config.Notification(nil, Translation[Config.Locale]['storage_sold_out'], 'error')
                                    else
                                        ESX.TriggerServerCallback('msk_shops:actionItem', function(data)
                                            if data then setItemStorage('remove', item.name, tonumber(input)) end
                                        end, 'buy', 'black_money', tonumber(input), item, currentShop.addon_account)
                                    end
                                end
                                reopenMenu()
                            end
                        end
                    end
                end
        
                if item.sellPrice then
                    local sellList = _menuPool:AddSubMenu(itemList, Translation[Config.Locale]['sell'])
                    sellList.ParentItem:RightLabel('~r~' .. item.sellPrice .. '$')
                    setCustomBanner(sellList, background)

                    if MSK.Table_Contains(item.method, 'money') then
                        local sellMoney = NativeUI.CreateItem(Translation[Config.Locale]['money'], '~b~')
                        sellMoney:RightLabel('~b~→→→')
                        sellList:AddItem(sellMoney)

                        sellMoney.Activated = function(sender, index)
                            local input = CreateDialog(Translation[Config.Locale]['amount'])

                            if input and tonumber(input) then
                                ESX.TriggerServerCallback('msk_shops:actionItem', function(data)
                                    if data then setItemStorage('add', item.name, tonumber(input)) end
                                end, 'sell', 'money', tonumber(input), item, currentShop.addon_account)
                            end
                            reopenMenu()
                        end
                    end

                    if MSK.Table_Contains(item.method, 'bank') then
                        local sellBank = NativeUI.CreateItem(Translation[Config.Locale]['bank'], '~b~')
                        sellBank:RightLabel('~b~→→→')
                        sellList:AddItem(sellBank)

                        sellBank.Activated = function(sender, index)
                            local input = CreateDialog(Translation[Config.Locale]['amount'])

                            if input and tonumber(input) then
                                ESX.TriggerServerCallback('msk_shops:actionItem', function(data)
                                    if data then setItemStorage('add', item.name, tonumber(input)) end
                                end, 'sell', 'bank', tonumber(input), item, currentShop.addon_account)
                            end
                            reopenMenu()
                        end
                    end

                    if MSK.Table_Contains(item.method, 'black_money') then
                        local sellBlack = NativeUI.CreateItem(Translation[Config.Locale]['black_money'], '~b~')
                        sellBlack:RightLabel('~b~→→→')
                        sellList:AddItem(sellBlack)

                        sellBlack.Activated = function(sender, index)
                            local input = CreateDialog(Translation[Config.Locale]['amount'])
                            
                            if input and tonumber(input) then
                                ESX.TriggerServerCallback('msk_shops:actionItem', function(data)
                                    if data then setItemStorage('add', item.name, tonumber(input)) end
                                end, 'sell', 'black_money', tonumber(input), item, currentShop.addon_account)
                            end
                            reopenMenu()
                        end
                    end
                end
            end
        end
    end

    mainMenu:Visible(true)
    _menuPool:RefreshIndex()
    _menuPool:MouseControlsEnabled(false)
    _menuPool:MouseEdgeEnabled(false)
    _menuPool:ControlDisablingEnabled(false)
end

---- Functions ----

function resetBlips()
    CreateThread(function()
        for k, v in pairs(Blips) do
            RemoveBlip(v)
            Blips = {}
        end

        for k, shops in pairs(Config.Shops) do
            if shops.blip.enable then
                local canSee = true

                if shops.jobs.enable then
                    if ESX.PlayerData.job then 
                        if job_contains(shops.jobs.jobs, ESX.PlayerData.job.name) then 
                            if grade_contains(shops.jobs.jobs, ESX.PlayerData.job.grade) then
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
                    for k2, location in pairs(shops.locations) do
                        blip = AddBlipForCoord(location.x, location.y, location.z)

                        SetBlipSprite(blip, shops.blip.id)
                        SetBlipScale(blip, shops.blip.scale)
                        SetBlipDisplay(blip, 4)
                        SetBlipColour(blip, shops.blip.color)
                        SetBlipAsShortRange(blip, true)
                        BeginTextCommandSetBlipName('STRING') 
                        AddTextComponentString(shops.label)
                        EndTextCommandSetBlipName(blip)
                        table.insert(Blips, blip)
                    end
                end
            end
        end
    end)
end
resetBlips()

getItemStorage = function(shopId, item)
    if not Config.useStorage then return end

    if shopId and item then 
        if itemStorage[shopId] and itemStorage[shopId][item] then 
            return itemStorage[shopId][item].amount 
        else
            logging('error', 'ShopID ' .. shopId .. ' not found in table itemStorage, Returning 0 as Itemamount.')
            return 0
        end
    else
        itemStorage = MSK.TriggerCallback('msk_shops:getItemAmount')
    end
end

setItemStorage = function(action, item, amount)
    logging('debug', action, item, amount)
    
    if action:match('add') then
        itemStorage[currentShopId][item].amount = itemStorage[currentShopId][item].amount + amount
    elseif action:match('remove') then
        itemStorage[currentShopId][item].amount = itemStorage[currentShopId][item].amount - amount
    end

    TriggerServerEvent('msk_shops:setItemAmount', itemStorage)
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

logging = function(code, ...)
    if not Config.Debug then return end
    MSK.logging(code, ...)
end