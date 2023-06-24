ESX = exports.es_extended:getSharedObject()

local isBlackout = false -- msk_blackout
AddEventHandler('msk_blackout:powerOn', blackoutPowerOn)
AddEventHandler('msk_blackout:powerOff', blackoutPowerOff)

local startedBlackmoney, successBlackmoneyTeleport = false, false
local printedMoney, printedMoneyEnd, cuttedMoney, countedMoney = false, false, false, false
local printLocations, JobBlips = {}, {}

CreateThread(function()
    ESX.PlayerData = ESX.GetPlayerData()
end)

RegisterNetEvent('esx:playerLoaded')
AddEventHandler('esx:playerLoaded', function(xPlayer)
    ESX.PlayerData = xPlayer
end)
        
RegisterNetEvent('esx:setJob')
AddEventHandler('esx:setJob', function(job)
    ESX.PlayerData.job = job
end)

CreateThread(function()
    if Config.startPoint.blip.enable and isAllowed() then
        local blip = AddBlipForCoord(Config.Locations['startWashmoney'].x, Config.Locations['startWashmoney'].y, Config.Locations['startWashmoney'].z)

        SetBlipSprite(blip, Config.startPoint.blip.id)
        SetBlipScale(blip, Config.startPoint.blip.scale)
        SetBlipDisplay(blip, 4)
        SetBlipColour(blip, Config.startPoint.blip.color)
        SetBlipAsShortRange(blip, true)
        BeginTextCommandSetBlipName('STRING') 
        AddTextComponentString(Config.startPoint.blip.label)
        EndTextCommandSetBlipName(blip)
    end
end)

RegisterNetEvent('msk_blackmoney:startBlackmoney')
AddEventHandler('msk_blackmoney:startBlackmoney', function(coords)
    if not coords then return end
    local dist = #(GetEntityCoords(PlayerPedId()) - coords)

    if dist <= 2.5 and isAllowed() then
        startedBlackmoney = true
        blackmoneyTeleport()
    end
end)

CreateThread(function()
    while true do
        local sleep = 200
        local playerPed = PlayerPedId()
        local dist = #(GetEntityCoords(playerPed) - Config.startPoint.coords)

        if dist <= 2.5 and isAllowed() then
            sleep = 0
            MSK.HelpNotification('Drücke ~g~E~s~ um Schwarzgeld Heist zu starten')

            if Config.startPoint.marker.enable then
				DrawMarker(Config.startPoint.marker.type, Config.startPoint.coords.x, Config.startPoint.coords.y, Config.startPoint.coords.z - 1.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, Config.startPoint.marker.size.a, Config.startPoint.marker.size.b, Config.startPoint.marker.size.c, Config.startPoint.marker.color.a, Config.startPoint.marker.color.b, Config.startPoint.marker.color.c, 100, false, true, 0, false)
			end

            if IsControlJustPressed(0, Config.Hotkey) then
                local blackmoney = MSK.TriggerCallback('msk_blackmoney:getBlackmoney')

                if blackmoney and blackmoney.money > 0 then
                    local hasItem = MSK.HasItem(Config.neededItem)

                    if hasItem and hasItem.count > 0 then
                        if Config.SkillCheck.animation.enable then
                            RequestAnimDict(Config.SkillCheck.animation.dict)
                            while not HasAnimDictLoaded(Config.SkillCheck.animation.dict) do
                                Wait(0)
                            end
                            TaskPlayAnim(playerPed, Config.SkillCheck.animation.dict, Config.SkillCheck.animation.anim, 8.0, 1.0, -1, 49, 0, false, false, false)
                        end

                        local success = lib.skillCheck({Config.SkillCheck.difficulty['1'], Config.SkillCheck.difficulty['2'], {areaSize = 60, speedMultiplier = 2}, Config.SkillCheck.difficulty['3']}, Config.SkillCheck.inputs)

                        if Config.SkillCheck.animation.enable then
                            RemoveAnimDict(Config.SkillCheck.animation.dict)
                            ClearPedTasks(playerPed)
                        end

                        if success then
                            startedBlackmoney = true
                            blackmoneyTeleport()
                        end

                        local random = math.random(1, 100)
                        if random >= Config.SkillCheck.percent then
                            TriggerServerEvent('msk_blackmoney:removeItem', Config.neededItem)
                        end
                    else
                        Config.Notification(nil, ('Du benötigst einen %s'):format(hasItem.label))
                    end
                else
                    Config.Notification(nil, 'Du hast kein Schwarzgeld!')
                end
            end
        end

        Wait(sleep)
    end
end)

blackmoneyTeleport = function()
    local playerPed = PlayerPedId()
	
	SetEntityCoords(playerPed, Config.Locations['startWashmoney'][1], Config.Locations['startWashmoney'][2], Config.Locations['startWashmoney'][3], false, false, false, true)
	SetEntityHeading(playerPed, Config.Locations['startWashmoney'][4])
    successBlackmoneyTeleport = true
    addPrintLocations()
    TriggerServerEvent('msk_blackmoney:notifyJobs')
end

CreateThread(function()
    while true do
        local sleep = 200
        local playerPed = PlayerPedId()
        local dist = #(GetEntityCoords(playerPed) - vec3(Config.Locations['startWashmoney'][1], Config.Locations['startWashmoney'][2], Config.Locations['startWashmoney'][3]))

        if dist <= 1.5 then
            sleep = 0
            MSK.HelpNotification('Drücke ~g~E~s~ um das Gebäude zu verlassen')

            if IsControlJustPressed(0, Config.Hotkey) then
                SetEntityCoords(playerPed, Config.startPoint.coords.x, Config.startPoint.coords.y, Config.startPoint.coords.z, false, false, false, true)
	            --SetEntityHeading(playerPed, 0.0)
                startedBlackmoney = false
                successBlackmoneyTeleport = false
            end
        end

        Wait(sleep)
    end
end)

CreateThread(function()
    while true do
        local sleep = 200

        if startedBlackmoney and successBlackmoneyTeleport then
            local playerPed = PlayerPedId()
            local playerCoords = GetEntityCoords(playerPed)
            
            for k, v in pairs(printLocations) do        
                local dist = #(playerCoords - v.coords)

                if dist <= Config.Locations['wash_money'].distance then
                    sleep = 0

                    if Config.Locations['wash_money'].marker.enable then
                        DrawMarker(Config.Locations['wash_money'].marker.type, v.coords.x, v.coords.y, v.coords.z - 1.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, Config.Locations['wash_money'].marker.size.a, Config.Locations['wash_money'].marker.size.b, Config.Locations['wash_money'].marker.size.c, Config.Locations['wash_money'].marker.color.a, Config.Locations['wash_money'].marker.color.b, Config.Locations['wash_money'].marker.color.c, 100, false, true, 0, false)
                    end

                    if dist <= 1.0 then
                        MSK.HelpNotification('Drücke ~g~E~s~ um Geld zu drucken')

                        if IsControlJustPressed(0, Config.Hotkey) then
                            local done = false
                            local dict = 'mini@sprunk' -- 'anim@apt_trans@buzzer'
                            local anim = 'plyr_buy_drink_pt1' -- 'buzz_reg'

                            if Config.SkillCheck.animation.enable then
                                RequestAnimDict(dict)
                                while not HasAnimDictLoaded(dict) do
                                    Wait(0)
                                end
                                TaskPlayAnim(playerPed, dict, anim, 8.0, 1.0, -1, 49, 0, false, false, false)
                            end

                            exports['levitate_progress']:startUI(v.time * 1000)

                            local timeout = MSK.AddTimeout(v.time * 1000, function()
                                done = true

                                if Config.SkillCheck.animation.enable then
                                    RemoveAnimDict(dict)
                                    ClearPedTasks(playerPed)
                                end

                                table.remove(printLocations, k)
                            end)

                            while not done do
                                Wait(0)
                                DisableAllControlActions(0)
                                EnableControlAction(0, 1, true) -- Camera Movement
                                EnableControlAction(0, 2, true) -- Camera Movement
                                EnableControlAction(0, 245, true) -- T
                            end
                        end
                    end
                end
            end

            if printLocations then
                if #printLocations == 0 then
                    startedBlackmoney = false
                    successBlackmoneyTeleport = false
                    printedMoney = true
                end
            end
        end

        Wait(sleep)
    end
end)

CreateThread(function()
    while true do
        local sleep = 200

        if printedMoney then
            local playerPed = PlayerPedId()
            local playerCoords = GetEntityCoords(playerPed)
            local dist = #(playerCoords - Config.Locations['wash_money'].moneyPrintEnd.coords)

            if dist <= Config.Locations['wash_money'].distance then
                sleep = 0

                if Config.Locations['wash_money'].marker.enable then
                    DrawMarker(Config.Locations['wash_money'].marker.type, Config.Locations['wash_money'].moneyPrintEnd.coords.x, Config.Locations['wash_money'].moneyPrintEnd.coords.y, Config.Locations['wash_money'].moneyPrintEnd.coords.z - 1.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, Config.Locations['wash_money'].marker.size.a, Config.Locations['wash_money'].marker.size.b, Config.Locations['wash_money'].marker.size.c, Config.Locations['wash_money'].marker.color.a, Config.Locations['wash_money'].marker.color.b, Config.Locations['wash_money'].marker.color.c, 100, false, true, 0, false)
                end

                if dist <= 1.0 then
                    MSK.HelpNotification('Drücke ~g~E~s~ um das Geld zu sammeln')

                    if IsControlJustPressed(0, Config.Hotkey) then
                        local done = false
                        local dict = 'anim@heists@prison_heiststation@cop_reactions'
                        local anim = 'cop_b_idle'

                        if Config.SkillCheck.animation.enable then
                            RequestAnimDict(dict)
                            while not HasAnimDictLoaded(dict) do
                                Wait(0)
                            end
                            TaskPlayAnim(playerPed, dict, anim, 8.0, 1.0, -1, 49, 0, false, false, false)
                        end

                        exports['levitate_progress']:startUI(Config.Locations['wash_money'].moneyPrintEnd.time * 1000)

                        local timeout = MSK.AddTimeout(Config.Locations['wash_money'].moneyPrintEnd.time * 1000, function()
                            done = true

                            if Config.SkillCheck.animation.enable then
                                RemoveAnimDict(dict)
                                ClearPedTasks(playerPed)
                            end

                            printedMoney = false
                            printedMoneyEnd = true
                        end)

                        while not done do
                            Wait(0)
                            DisableAllControlActions(0)
                            EnableControlAction(0, 1, true) -- Camera Movement
                            EnableControlAction(0, 2, true) -- Camera Movement
                            EnableControlAction(0, 245, true) -- T
                        end
                    end
                end
            end
        end

        Wait(sleep)
    end
end)

CreateThread(function()
    while true do
        local sleep = 200

        if printedMoneyEnd then
            local playerPed = PlayerPedId()
            local playerCoords = GetEntityCoords(playerPed)
            local dist = #(playerCoords - Config.Locations['wash_money'].moneyCut.coords)

            if dist <= Config.Locations['wash_money'].distance then
                sleep = 0

                if Config.Locations['wash_money'].marker.enable then
                    DrawMarker(Config.Locations['wash_money'].marker.type, Config.Locations['wash_money'].moneyCut.coords.x, Config.Locations['wash_money'].moneyCut.coords.y, Config.Locations['wash_money'].moneyCut.coords.z - 1.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, Config.Locations['wash_money'].marker.size.a, Config.Locations['wash_money'].marker.size.b, Config.Locations['wash_money'].marker.size.c, Config.Locations['wash_money'].marker.color.a, Config.Locations['wash_money'].marker.color.b, Config.Locations['wash_money'].marker.color.c, 100, false, true, 0, false)
                end

                if dist <= 1.0 then
                    MSK.HelpNotification('Drücke ~g~E~s~ um das Geld zu schneiden')

                    if IsControlJustPressed(0, Config.Hotkey) then
                        if Config.SkillCheck.animation.enable then
                            RequestAnimDict(Config.SkillCheck.animation.dict)
                            while not HasAnimDictLoaded(Config.SkillCheck.animation.dict) do
                                Wait(0)
                            end
                            TaskPlayAnim(playerPed, Config.SkillCheck.animation.dict, Config.SkillCheck.animation.anim, 8.0, 1.0, -1, 49, 0, false, false, false)
                        end

                        local success = lib.skillCheck({Config.SkillCheck.difficulty['1'], Config.SkillCheck.difficulty['2'], {areaSize = 60, speedMultiplier = 2}, Config.SkillCheck.difficulty['3']}, Config.SkillCheck.inputs)

                        if success then
                            local done = false

                            exports['levitate_progress']:startUI(Config.Locations['wash_money'].moneyCut.time * 1000)

                            local timeout = MSK.AddTimeout(Config.Locations['wash_money'].moneyCut.time * 1000, function()
                                done = true

                                if Config.SkillCheck.animation.enable then
                                    RemoveAnimDict(dict)
                                    ClearPedTasks(playerPed)
                                end

                                printedMoneyEnd = false
                                cuttedMoney = true
                            end)

                            while not done do
                                Wait(0)
                                DisableAllControlActions(0)
                                EnableControlAction(0, 1, true) -- Camera Movement
                                EnableControlAction(0, 2, true) -- Camera Movement
                                EnableControlAction(0, 245, true) -- T
                            end
                        else
                            if Config.SkillCheck.animation.enable then
                                RemoveAnimDict(dict)
                                ClearPedTasks(playerPed)
                            end
                        end
                    end
                end
            end
        end

        Wait(sleep)
    end
end)

RegisterNetEvent('msk_blackmoney:skipSkillCheck')
AddEventHandler('msk_blackmoney:skipSkillCheck', function(coords)
    if not coords then return end
    local dist = #(GetEntityCoords(PlayerPedId()) - coords)

    if dist <= 1.0 and isAllowed() then
        local done = false

        if Config.SkillCheck.animation.enable then
            RequestAnimDict(Config.SkillCheck.animation.dict)
            while not HasAnimDictLoaded(Config.SkillCheck.animation.dict) do
                Wait(0)
            end
            TaskPlayAnim(playerPed, Config.SkillCheck.animation.dict, Config.SkillCheck.animation.anim, 8.0, 1.0, -1, 49, 0, false, false, false)
        end

        exports['levitate_progress']:startUI(Config.Locations['wash_money'].moneyCut.time * 1000)

        local timeout = MSK.AddTimeout(Config.Locations['wash_money'].moneyCut.time * 1000, function()
            done = true

            if Config.SkillCheck.animation.enable then
                RemoveAnimDict(Config.SkillCheck.animation.dict)
                ClearPedTasks(playerPed)
            end

            printedMoneyEnd = false
            cuttedMoney = true
        end)

        while not done do
            Wait(0)
            DisableAllControlActions(0)
            EnableControlAction(0, 1, true) -- Camera Movement
            EnableControlAction(0, 2, true) -- Camera Movement
            EnableControlAction(0, 245, true) -- T
        end
    end
end)

CreateThread(function()
    while true do
        local sleep = 200

        if cuttedMoney then
            local playerPed = PlayerPedId()
            local playerCoords = GetEntityCoords(playerPed)
            local dist = #(playerCoords - Config.Locations['wash_money'].moneyCount.coords)

            if dist <= Config.Locations['wash_money'].distance then
                sleep = 0

                if Config.Locations['wash_money'].marker.enable then
                    DrawMarker(Config.Locations['wash_money'].marker.type, Config.Locations['wash_money'].moneyCount.coords.x, Config.Locations['wash_money'].moneyCount.coords.y, Config.Locations['wash_money'].moneyCount.coords.z - 1.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, Config.Locations['wash_money'].marker.size.a, Config.Locations['wash_money'].marker.size.b, Config.Locations['wash_money'].marker.size.c, Config.Locations['wash_money'].marker.color.a, Config.Locations['wash_money'].marker.color.b, Config.Locations['wash_money'].marker.color.c, 100, false, true, 0, false)
                end

                if dist <= 1.0 then
                    MSK.HelpNotification('Drücke ~g~E~s~ um das Geld zu zählen')

                    if IsControlJustPressed(0, Config.Hotkey) then
                        local done = false

                        if Config.SkillCheck.animation.enable then
                            RequestAnimDict(Config.SkillCheck.animation.dict)
                            while not HasAnimDictLoaded(Config.SkillCheck.animation.dict) do
                                Wait(0)
                            end
                            TaskPlayAnim(playerPed, Config.SkillCheck.animation.dict, Config.SkillCheck.animation.anim, 8.0, 1.0, -1, 49, 0, false, false, false)
                        end

                        exports['levitate_progress']:startUI(Config.Locations['wash_money'].moneyCount.time * 1000)

                        local timeout = MSK.AddTimeout(Config.Locations['wash_money'].moneyCount.time * 1000, function()
                            done = true

                            if Config.SkillCheck.animation.enable then
                                RemoveAnimDict(Config.SkillCheck.animation.dict)
                                ClearPedTasks(playerPed)
                            end

                            cuttedMoney = false
                            TriggerServerEvent('msk_blackmoney:getMoneyAfterWashing')
                        end)

                        while not done do
                            Wait(0)
                            DisableAllControlActions(0)
                            EnableControlAction(0, 1, true) -- Camera Movement
                            EnableControlAction(0, 2, true) -- Camera Movement
                            EnableControlAction(0, 245, true) -- T
                        end
                    end
                end
            end
        end

        Wait(sleep)
    end
end)

RegisterNetEvent('msk_blackmoney:sendJobBlipNotify')
AddEventHandler('msk_blackmoney:sendJobBlipNotify', function()
	sendJobBlipNotify()

    local timeout = MSK.AddTimeout(Config.notifyJobs.dispatchTime * 60000, function()
        sendJobBlipNotify(true)
    end)
end)

sendJobBlipNotify = function(notify)
	CreateThread(function()
        for k, v in pairs(JobBlips) do
            RemoveBlip(v)
            JobBlips = {}
        end

		if notify then return end
        if isBlackout then return end

		if Config.notifyJobs.blip.enable then
			local blip = AddBlipForRadius(Config.startPoint.coords.x, Config.startPoint.coords.y, Config.startPoint.coords.z, 50.0)

			SetBlipColour(blip, Config.notifyJobs.blip.color)
			SetBlipAlpha(blip, 128)
			
			table.insert(JobBlips, blip)
		end
	end)
end

isAllowed = function()
    for k, v in pairs(Config.allowed.jobs) do
        if k == ESX.PlayerData.job.name and v <= ESX.PlayerData.job.grade then
            return true
        end
    end

    for k, v in pairs(Config.allowed.character) do
        if v == ESX.PlayerData.identifier then
            return true
        end
    end

    return false
end

addPrintLocations = function()
    printLocations = {}

    for k, v in pairs(Config.Locations['wash_money'].printCoords) do
		table.insert(printLocations, v)
	end
end

blackoutPowerOn = function()
    isBlackout = false
end

blackoutPowerOff = function()
    isBlackout = true
end

logging = function(code, ...)
    if Config.Debug then
        local script = "[^2"..GetCurrentResourceName().."^0]"
        MSK.logging(script, code, ...)
    end
end