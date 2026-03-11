currentBank, currentATM, bankAccount = nil, nil, false
bankcardProp, cashProp = nil, nil
_menuPool = nil
local mainMenu
local isMenuOpen, hadSpeak, isDead = false, false, false
local npc, currATM = nil, nil
local Blips, isPedLoaded = {}, {}

AddEventHandler('esx:onPlayerDeath', function() isDead = true end)
AddEventHandler('esx:onPlayerSpawn', function(spawn) isDead = false end)

getIsDead = function()
    local isPlayerDead = isDead

    if GetResourceState("visn_are") ~= "missing" then
        local healthBuffer = exports.visn_are:GetHealthBuffer()
        isPlayerDead = healthBuffer.unconscious
    end

    if GetResourceState("osp_ambulance") ~= "missing" then
        local data = exports.osp_ambulance:GetAmbulanceData(GetPlayerServerId(PlayerId()))
        isPlayerDead = data.isDead or data.inLastStand
    end

    return isPlayerDead
end

-- Create Blips
CreateThread(function()
    for k, banks in pairs(Config.Banks) do
        if banks.blip.enable then
            local blip = AddBlipForCoord(banks.location.x, banks.location.y, banks.location.z)
            
            SetBlipSprite(blip, banks.blip.id)
            SetBlipScale(blip, banks.blip.scale)
            SetBlipDisplay(blip, 4)
            SetBlipColour(blip, banks.blip.color)
            SetBlipAsShortRange(blip, true)
            BeginTextCommandSetBlipName('STRING') 
            AddTextComponentString(banks.label)
            EndTextCommandSetBlipName(blip)
        end
    end
end)

----------------------------------------------------------------
-- Banks
----------------------------------------------------------------

CreateThread(function()
    local shown = false

    while true do
        local sleep = 250
        currentBank = nil

        for k, banks in pairs(Config.Banks) do
            local vec3 = vec3(banks.location.x, banks.location.y, banks.location.z)
            local distance = #(GetEntityCoords(PlayerPedId()) - vec3)

            if banks.pedmodel.enable then
                local pedmodel = GetHashKey(banks.pedmodel.model)
                local npcID = pedmodel .. '-' .. k

                if distance <= Config.PedDistance then
                    if not isPedLoaded[npcID] or not isPedLoaded[npcID].loaded then
                        isPedLoaded[npcID] = {}

                        RequestModel(GetHashKey(banks.pedmodel.model))
                        while not HasModelLoaded(GetHashKey(banks.pedmodel.model)) do
                            Wait(1)
                        end
                        npc = CreatePed(4, GetHashKey(banks.pedmodel.model), banks.location.x, banks.location.y, banks.location.z - 1.0, banks.location.w or banks.location.h, false, true)
                        FreezeEntityPosition(npc, true)	
                        SetEntityHeading(npc, banks.location.w or banks.location.h)
                        SetEntityInvincible(npc, true)
                        SetBlockingOfNonTemporaryEvents(npc, true)

                        logging('debug', 'Set NPC Bank', 'NPC:' .. npc, 'NPCID:' .. npcID)

                        isPedLoaded[npcID] = {
                            loaded = true,
                            inDistance = true,
                            hash = pedmodel,
                            pedmodel = banks.pedmodel.model,
                            npc = npc,
                            npcID = npcID,
                            location = vec3
                        }
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
                if distance <= Config.MarkerDistance then 
                    sleep = 1

                    if banks.marker.enable then
                        DrawMarker(banks.marker.type, vec3.x, vec3.y, vec3.z - 1.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, banks.marker.size.a, banks.marker.size.b, banks.marker.size.c, banks.marker.color.a, banks.marker.color.b, banks.marker.color.c, 100, false, true, 0, false)
                    end

                    if banks.draw3dtext.enable then
                        MSK.Draw3DText(vec3, banks.draw3dtext.label, banks.draw3dtext.size)
                    end
                end
            end

            if distance <= Config.BankDistance then
                sleep = 1
                currentBank = banks

                if not IsPedInAnyVehicle(PlayerPedId()) and not isMenuOpen and not getIsDead() then
                    if Config.defaultTextUI then
                        MSK.HelpNotification(Translation[Config.Locale]['open_bank']:format(banks.label))
                    end

                    if IsControlJustPressed(0, Config.Hotkey) then
                        local mainAccount, secondAccount, hasBankcard = getBankingInfo(true)
                        openBankMenu(mainAccount, secondAccount, hasBankcard)
                    end
                end
            end
        end

        if currentBank and not shown and not isMenuOpen then
            shown = true

            if not Config.defaultTextUI then 
                Config.openTextUI(currentBank)
            end
        elseif not currentBank and shown then
            shown = false

            if not Config.defaultTextUI then 
                Config.closeTextUI()
            end
            
            if _menuPool then 
                _menuPool:CloseAllMenus() 
            end
        end

        for k, v in pairs(isPedLoaded) do
            if v.loaded and not v.inDistance then
                logging('debug', 'Delete NPC Garage', 'NPC:' .. v.npc, 'NPCID' .. v.npcID)
                DeleteEntity(v.npc)
                SetModelAsNoLongerNeeded(v.hash)
                isPedLoaded[v.npcID] = {}
            end
        end

        Wait(sleep)
    end
end)

----------------------------------------------------------------
-- ATM's
----------------------------------------------------------------

CreateThread(function()
    local shown = false

    while true do
        local sleep = 500
        currentATM = nil

        if NearATM() then
            sleep = 1

            if not IsPedInAnyVehicle(PlayerPedId()) and not isMenuOpen and not getIsDead() then
                if Config.defaultTextUI then
                    if Config.ATMs.robbery.enable then
                        if not currATM then
                            MSK.HelpNotification(Translation[Config.Locale]['open_atm_robbery'])
                        else
                            MSK.HelpNotification(Translation[Config.Locale]['stop_atm_robbery'])
                        end
                    else
                        MSK.HelpNotification(Translation[Config.Locale]['open_atm'])
                    end
                end

                if IsControlJustReleased(0, Config.ATMs.robbery.hotkey) and Config.ATMs.robbery.enable then
                    startRobbery()
                end

                if IsControlJustReleased(0, Config.Hotkey) then
                    local hasBankcard = MSK.Trigger('msk_banking:hasBankcard')

                    if hasBankcard then
                        if Config.Animation.enable then
                            local playerPed = PlayerPedId()

                            if Config.Animation.useBankcardProp then
                                MSK.Request.Model(GetHashKey(Config.Animation.bankcardProp))
                                bankcardProp = CreateObject(GetHashKey(Config.Animation.bankcardProp), GetEntityCoords(playerPed), true, true, true)
                                AttachEntityToEntity(bankcardProp, playerPed, GetPedBoneIndex(playerPed, 57005), 0.14, 0.04, -0.02, 318.0, 22.0, 2.0, true, true, false, true, 1, true)
                            end

                            -- TaskStartScenarioInPlace(playerPed, Config.Animation.scenario, -1, true)
                            TaskUseNearestScenarioToCoord(playerPed, GetEntityCoords(currentATM), Config.ATMDistance, -1)
                            Wait(2000)
                            removeObject(bankcardProp)
                        end

                        if Config.PIN.enable then
                            checkPin()
                        else
                            openATM()
                        end

                        while not isMenuOpen do
                            Wait(10)
                        end

                        while isMenuOpen do
                            Wait(100)
                        end

                        ClearPedTasks(PlayerPedId())

                        if Config.Animation.useCashProp then
                            Wait(2600)
                            local playerPed = PlayerPedId()
                            MSK.Request.Model(GetHashKey(Config.Animation.cashProp))
                            cashProp = CreateObject(GetHashKey(Config.Animation.cashProp), GetEntityCoords(playerPed), true, true, true)
                            AttachEntityToEntity(cashProp, playerPed, GetPedBoneIndex(playerPed, 57005), 0.14, 0.04, -0.02, 318.0, 22.0, 2.0, true, true, false, true, 1, true)
                            Wait(1000)
                            removeObject(cashProp)
                        end
                    else
                        Config.Notification(nil, Translation[Config.Locale]['no_bankcard'], 'error')
                    end
                end
            end
        end

        if inRange and not shown and not isMenuOpen then
            shown = true

            if not Config.defaultTextUI then 
                if Config.ATMs.robbery.enable then
                    if not currATM then
                        Config.openTextUI(nil, Translation[Config.Locale]['open_atm_textui_robbery'])
                    else
                        Config.openTextUI(nil, Translation[Config.Locale]['stop_atm_textui_robbery'])
                    end
                else
                    Config.openTextUI(nil, Translation[Config.Locale]['open_atm_textui'])
                end
            end
        elseif not inRange and shown then
            shown = false
            currentATM = nil
            stopRobbery()

            if not Config.defaultTextUI then 
                Config.closeTextUI()
            end

            if _menuPool then _menuPool:CloseAllMenus() end
        end

        Wait(sleep)
    end
end)

openATM = function(checkPin)
    if checkPin and Config.PIN.enable then
        checkPin()
        return
    end

    local mainAccount, secondAccount, hasBankcard = getBankingInfo(false)

    if bankAccount then
        openATMMenu(mainAccount, secondAccount, hasBankcard)
    else
        Config.Notification(nil, Translation[Config.Locale]['no_account_found'], 'error')
    end
end
exports('openATM', openATM)

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

openATMMenu = function(mainAccount, secondAccount, hasBankcard)
    logging('debug', 'Current ATM:', currentATM)

    if _menuPool then 
        _menuPool:Remove()
        _menuPool = nil
    end

    _menuPool = NativeUI.CreatePool()
    local background

    if Config.CustomBanner then
        if Config.removeTitle then
            mainMenu = NativeUI.CreateMenu(nil, '~b~')
        else
            mainMenu = NativeUI.CreateMenu(Translation[Config.Locale]['atm'], '~b~')
        end
        background = Config.bannerATM()
        setCustomBanner(mainMenu, background)
    else
        mainMenu = NativeUI.CreateMenu(Translation[Config.Locale]['atm'], '~b~')
        logging('debug', 'Current ATM', Translation[Config.Locale]['atm'])
    end
    _menuPool:Add(mainMenu)

    -- Main Account
    mainBankMenu(mainMenu, background, mainAccount, secondAccount, hasBankcard, false)

    -- Second Account
    if secondAccount.iban then
        secondBankMenu(mainMenu, background, mainAccount, secondAccount, hasBankcard, false)
    end

    -- Society Account
    if canAccessSociety() then
        local job = getSocietyInfo()
        societyBankMenu(mainMenu, background, mainAccount, secondAccount, job, hasBankcard, false)
    end

    if (Config.Bills.enable and Config.Bills.atATM) or (Config.Investment.enable and Config.Investment.atATM) then
        local placeholder = NativeUI.CreateItem('', '')
        mainMenu:AddItem(placeholder)

        -- Billing
        if Config.Bills.enable and Config.Bills.atATM then
            billingMenu(mainMenu, background, mainAccount, secondAccount, hasBankcard, false)
        end

        -- Investment
        if Config.Investment.enable and Config.Investment.atATM then
            investmentMenu(mainMenu, background, mainAccount, secondAccount, hasBankcard, false)
        end
    end

    mainMenu:Visible(true)
    _menuPool:RefreshIndex()
    _menuPool:MouseControlsEnabled(false)
    _menuPool:MouseEdgeEnabled(false)
    _menuPool:ControlDisablingEnabled(false)
end

openBankMenu = function(mainAccount, secondAccount, hasBankcard)
    logging('debug', 'Current Bank:', currentBank.label)

    if _menuPool then 
        _menuPool:Remove()
        _menuPool = nil
    end

    _menuPool = NativeUI.CreatePool()
    local background

    if Config.CustomBanner then
        if Config.removeTitle then
            mainMenu = NativeUI.CreateMenu(nil, '~b~')
        else
            mainMenu = NativeUI.CreateMenu(currentBank.label, '~b~')
        end
        background = Config.bannerBank(currentBank)
        setCustomBanner(mainMenu, background)
    else
        mainMenu = NativeUI.CreateMenu(currentBank.label, '~b~')
    end
    _menuPool:Add(mainMenu)

    if not bankAccount then -- If you don't have a main bankaccount
        createBankMenu(mainMenu, background, true)
    else
        -- Main Account
        mainBankMenu(mainMenu, background, mainAccount, secondAccount, hasBankcard, true)

        -- Second Account
        if secondAccount.iban then
            secondBankMenu(mainMenu, background, mainAccount, secondAccount, hasBankcard, true)
        end

        -- Society Account
        if canAccessSociety() then
            local job = getSocietyInfo()
            societyBankMenu(mainMenu, background, mainAccount, secondAccount, job, hasBankcard, true)
        end

        local placeholder = NativeUI.CreateItem('', '')
        mainMenu:AddItem(placeholder)

        -- Billing
        if Config.Bills.enable then
            billingMenu(mainMenu, background, mainAccount, secondAccount, hasBankcard, true)
        end

        -- Investment
        if Config.Investment.enable then
            local investMenu = investmentMenu(mainMenu, background, mainAccount, secondAccount, hasBankcard, true)
        end

        -- Settings and more
        settingsMenu(mainMenu, background, mainAccount, secondAccount, hasBankcard, true)
    end

    mainMenu:Visible(true)
    _menuPool:RefreshIndex()
    _menuPool:MouseControlsEnabled(false)
    _menuPool:MouseEdgeEnabled(false)
    _menuPool:ControlDisablingEnabled(false)
end

----------------------------------------------------------------
-- ATM Robbery
----------------------------------------------------------------
RegisterNetEvent('msk_banking:addRobberyBlip', function(atm)
	local streetlabel = GetStreetNameAtCoord(atm.coords.x, atm.coords.y, atm.coords.z, Citizen.PointerValueInt(), Citizen.PointerValueInt())
    local street = GetStreetNameFromHashKey(streetlabel)
    MSK.AdvancedNotification(Translation[Config.Locale]['jobnotify_start']:format(street), Translation[Config.Locale]['robbery_title'], Translation[Config.Locale]['robbery_subtitle'], atm.mugshotStr)

    local Blip = AddBlipForCoord(atm.coords)
    currATM.blip = Blip

    SetBlipSprite(Blip, 161)
    SetBlipScale(Blip, 2.0)
    SetBlipColour(Blip, 1)
    SetBlipAsShortRange(Blip, true)
    PulseBlip(Blip)
end)

RegisterNetEvent('msk_banking:removeRobberyBlip', function(blip)
    local timeout = MSK.AddTimeout(60000, function()
        RemoveBlip(blip)
    end)
end)

stopRobbery = function(val)
    ClearPedTasks(PlayerPedId())
    if not currATM then return end
    TriggerServerEvent('msk_banking:stopRobbery', currATM)
    TriggerServerEvent('msk_banking:robberyJobNotify', 'stop', currATM, val)
    RemoveAnimDict(currATM.dict)
    UnregisterPedheadshot(currATM.mugshot)
    currATM = nil
end

startRobbery = function()
    if MSK.TableContains(Config.ATMs.robbery.jobs.blacklistJobs, ESX.PlayerData.job.name) then 
        return Config.Notification(nil, Translation[Config.Locale]['job_blacklist'], 'error') 
    end

    local mugshot, mugshotStr = MSK.GetPedMugshot(PlayerPedId(), true)
    logging('debug', mugshot, mugshotStr)
    currATM = {model = currentATM, coords = GetEntityCoords(currentATM), mugshot = mugshot, mugshotStr = mugshotStr, scenario = Config.ATMs.robbery.animation.scenario, anim = Config.ATMs.robbery.animation.anim, dict = Config.ATMs.robbery.animation.dict}
    local wasRobbed, neededCops, hasItem = MSK.Trigger('msk_banking:startATMRobbery', currATM)

    if not hasItem or type(hasItem) == 'string' then return Config.Notification(nil, Translation[Config.Locale]['missing_item']:format(hasItem), 'error') end

    if neededCops < Config.ATMs.robbery.jobs.neededCops then 
        currATM = nil 
        UnregisterPedheadshot(mugshot)
        return Config.Notification(nil, Translation[Config.Locale]['needed_cops'], 'error')
    end

    if wasRobbed then
        currATM = nil
        UnregisterPedheadshot(mugshot)
        return Config.Notification(nil, Translation[Config.Locale]['was_robbed'], 'error')
    end

    TriggerServerEvent('msk_banking:robberyJobNotify', 'start', currATM)
    startAnimation()

    CreateThread(function()
        while currATM do
            Wait(0)
            if IsControlJustReleased(0, 73) then stopRobbery() return end
        end
    end)

    local times = 0
    CreateThread(function()
        while currATM do
            Wait(Config.ATMs.robbery.money.interval * 1000)

            if currATM then
                times = times + 1

                if times == 1 then 
                    Config.Notification(nil, Translation[Config.Locale]['atm_cracked'], 'success')
                else
                    TriggerServerEvent('msk_banking:getRobberyMoney')
                end

                if times == Config.ATMs.robbery.money.maxTimes + 1 then stopRobbery(true) return end
            end
        end
    end)
end

startAnimation = function()
    if Config.ATMs.robbery.animation.action == 'animation' then
        MSK.Request.AnimDict(currATM.dict)
        TaskPlayAnim(PlayerPedId(), currATM.dict, currATM.anim, 8.0, 1.0, -1, 49, 0, false, false, false)
    elseif Config.ATMs.robbery.animation.action == 'scenario' then
        TaskStartScenarioInPlace(PlayerPedId(), currATM.scenario, 0, true)
    end

    CreateThread(function()
        while currentATM do
            Wait(1000)
            if currATM then PlaySoundFromCoord(-1, "scanner_alarm_os", currATM.coords.x, currATM.coords.y, currATM.coords.z, "dlc_xm_iaa_player_facility_sounds", 1, 50, 0) end
        end
    end)
end

AddEventHandler('onResourceStop', function(resourceName)
    if GetCurrentResourceName() == resourceName then
        stopRobbery()
    end
end)