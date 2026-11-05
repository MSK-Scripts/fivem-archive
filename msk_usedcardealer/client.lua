if Config.Framework:match('ESX') then
    ESX = exports["es_extended"]:getSharedObject()
elseif Config.Framework:match('QBCore') then
    QBCore = exports['qb-core']:GetCoreObject()
end

if Config.Blip.enable then
    CreateThread(function()
        for k, v in pairs(Config.Blip.coords) do
            local blip = AddBlipForCoord(v.x, v.y, v.z)
    
            SetBlipSprite(blip, Config.Blip.id)
            SetBlipScale(blip, Config.Blip.scale)
            SetBlipDisplay(blip, 4)
            SetBlipColour(blip, Config.Blip.color)
            SetBlipAsShortRange(blip, true)
            BeginTextCommandSetBlipName('STRING') 
            AddTextComponentString(Config.Blip.label)
            EndTextCommandSetBlipName(blip)
        end
    end)
end

local vehicles = {}

RegisterNetEvent('msk_usedcardealer:useItem')
AddEventHandler('msk_usedcardealer:useItem', function()
    local vehicle = lib.getClosestVehicle(GetEntityCoords(PlayerPedId()), 2.5, false)
    local isOwned = lib.callback.await('msk_usedcardealer:isVehicleOwned', false, GetVehicleNumberPlateText(vehicle))

    if vehicle and DoesEntityExist(vehicle) and isOwned then
        local vehicleName = GetLabelText(GetDisplayNameFromVehicleModel(GetEntityModel(vehicle)))
        local plate = GetVehicleNumberPlateText(vehicle)

        local input = lib.inputDialog(Translation[Config.Locale]['input']:format(vehicleName, plate), {
            {type = 'number', label = Translation[Config.Locale]['input_number'], description = Translation[Config.Locale]['input_number_desc'], required = true},
            {type = 'textarea', label = Translation[Config.Locale]['input_text'], description = Translation[Config.Locale]['input_text_desc'], placeholder = 'Optional Text', required = false, autosize = true},
            {type = 'checkbox', label = 'Kaufvertrag löschen?'}
        })

        if not input then return end

        if input[3] then
            if vehicles[plate] then vehicles[plate] = nil end
            freezeVehicle(vehicle, false)
            TriggerServerEvent('msk_usedcardealer:syncToServer', vehicles, plate)
        else
            local identifier
            if Config.Framework:match('ESX') then
                identifier = ESX.PlayerData.identifier
            elseif Config.Framework:match('QBCore') then
                identifier = QBCore.Functions.GetPlayerData().citizenid
            end

            if input[2] then
                vehicles[plate] = {name = vehicleName, plate = plate, playerId = GetPlayerServerId(PlayerId()), identifier = identifier, price = input[1], text = input[2]}
            else
                vehicles[plate] = {name = vehicleName, plate = plate, playerId = GetPlayerServerId(PlayerId()), identifier = identifier, price = input[1]}
            end

            freezeVehicle(vehicle, true)
            TriggerServerEvent('msk_usedcardealer:syncToServer', vehicles)
        end

    else
        Config.Notification(nil, Translation[Config.Locale]['vehicle_not_owned'], 'error', 5000, true)
    end
end)

CreateThread(function()
    while true do
        local sleep = 1500
        local data = lib.callback.await('msk_usedcardealer:getVehiclesData', false)

        if data then vehicles = data end
        
        Wait(sleep)
    end
end)

CreateThread(function()
    while true do
        local sleep = 500
        local playerPed = PlayerPedId()
        local playerCoords = GetEntityCoords(playerPed)
        local nearVehicles = lib.getNearbyVehicles(playerCoords, Config.maxDistance, true) -- v.vehicle, v.coords

        for k, v in pairs(nearVehicles) do
            local vehicle = v.vehicle
            local coords = v.coords
            local vehicleName = GetLabelText(GetDisplayNameFromVehicleModel(GetEntityModel(vehicle)))
            local plate = GetVehicleNumberPlateText(vehicle)

            if vehicles[plate] and DoesEntityExist(vehicle) then
                sleep = 0
                local text = ''

                if vehicles[plate].text and vehicles[plate].text ~= '' then
                    text = Translation[Config.Locale]['vehicle_desc']:format(vehicleName, comma_value(vehicles[plate].price), vehicles[plate].text)
                else
                    text = Translation[Config.Locale]['vehicle_desc2']:format(vehicleName, comma_value(vehicles[plate].price))
                end

                MSK.Draw3DText(vec3(coords.x, coords.y, coords.z + 1.5), text, 0.6)
                freezeVehicle(vehicle, true)

                if #(playerCoords - coords) <= 2.5 then
                    MSK.HelpNotification(Translation[Config.Locale]['help_notification'])

                    if IsControlJustPressed(0, Config.Hotkey) and not lib.callback.await('msk_usedcardealer:isVehicleOwned', false, GetVehicleNumberPlateText(vehicle)) then
                        local account = lib.alertDialog({
                            header = Translation[Config.Locale]['dialog_pay_header'],
                            content = Translation[Config.Locale]['dialog_pay_desc'],
                            centered = true,
                            cancel = true,
                            labels = {
                                confirm = Translation[Config.Locale]['dialog_pay_bank'],
                                cancel = Translation[Config.Locale]['dialog_pay_cash']
                            }
                        })

                        if account == 'confirm' then
                            account = 'bank'
                        elseif account == 'cancel' then
                            account = 'money'
                        end

                        if account then
                            local buy = lib.alertDialog({
                                header = Translation[Config.Locale]['dialog_confirm_header'],
                                content = Translation[Config.Locale]['dialog_confirm_desc']:format(vehicleName, plate, vehicles[plate].price),
                                centered = true,
                                cancel = true
                            })
        
                            if buy == 'confirm' then
                                TriggerServerEvent('msk_usedcardealer:buyVehicle', account, vehicleName, plate, vehicles[plate].price, vehicles[plate].playerId, vehicles[plate].identifier)
                                vehicles[plate] = nil
                                TriggerServerEvent('msk_usedcardealer:syncToServer', vehicles, plate)
                                freezeVehicle(vehicle, false)
                            end
                        end
                    end
                end
            end
        end
        
        Wait(sleep)
    end
end)

freezeVehicle = function(vehicle, set)
    FreezeEntityPosition(vehicle, set)
end

comma_value = function(amount)
    local formatted = amount

    while true do  
        formatted, k = string.gsub(formatted, "^(-?%d+)(%d%d%d)", '%1.%2')

        if (k == 0) then
            break
        end
    end

    return formatted
end

logging = function(code, ...)
    if not Config.Debug then return end
    MSK.Logging(script, code, ...)
end