ESX = exports["es_extended"]:getSharedObject()

RegisterNetEvent('msk_saveCoordsMenu:openMenu') 
AddEventHandler('msk_saveCoordsMenu:openMenu', function()
    local customCoords = MSK.TriggerCallback('msk_saveCoordsMenu:checkCoords')
    openSaveCoordMenu(customCoords)
end)

-- NativeUI
_menuPool = NativeUI.CreatePool()
local mainMenu

CreateThread(function()
	while true do
        local sleep = 200
		if _menuPool:IsAnyMenuOpen() then 
            sleep = 0
            _menuPool:ProcessMenus()
        end
		Wait(sleep)
	end
end)

function openSaveCoordMenu(customCoords)
    if mainMenu and mainMenu:Visible() then
        mainMenu:Visible(false)
    end
    
    mainMenu = NativeUI.CreateMenu(Translation[Config.Locale]['menu_header'], '~b~')
    _menuPool:Add(mainMenu)

    addCoords = _menuPool:AddSubMenu(mainMenu, Translation[Config.Locale]['add'], Translation[Config.Locale]['add_sub'])
    addCoords.ParentItem:RightLabel('~b~')

    addCoordsName = NativeUI.CreateItem(Translation[Config.Locale]['add_name'], '~b~')
    addCoordsName:RightLabel('~b~→→→')
    addCoords:AddItem(addCoordsName)

    addCoordsName.Activated = function(sender, index)
        local input = CreateDialog(Translation[Config.Locale]['add_name'])

        if input and tostring(input) then
            logging('debug', tostring(input))
            logging('debug', GetEntityCoords(PlayerPedId()))

            TriggerServerEvent('msk_saveCoordsMenu:addCoords', tostring(input), GetEntityCoords(PlayerPedId()))
        else
            MSK.Notification({ message = Translation[Config.Locale]['invalid_input'] })
        end
        _menuPool:CloseAllMenus()
    end

    placeholder = NativeUI.CreateItem('', '~b~')
    mainMenu:AddItem(placeholder)

    for k, dCoords in pairs(Config.DefaultCoords) do
        coordList = NativeUI.CreateItem(dCoords.name, '~b~' .. dCoords.coords.x .. ' ' .. dCoords.coords.y .. ' ' .. dCoords.coords.z)
        coordList:RightLabel('~g~→→→')
        mainMenu:AddItem(coordList)

        coordList.Activated = function(sender, index)
            logging('debug', dCoords.name)
            logging('debug', dCoords.coords.x .. ' ' .. dCoords.coords.y .. ' ' .. dCoords.coords.z)

            SetEntityCoords(PlayerPedId(), dCoords.coords.x, dCoords.coords.y, dCoords.coords.z, false, false, false, true)
            TriggerServerEvent('msk_saveCoordsMenu:sendDiscordLog', dCoords.name, vector3(dCoords.coords.x, dCoords.coords.y, dCoords.coords.z))
            _menuPool:CloseAllMenus()
        end
    end

    placeholder2 = NativeUI.CreateItem('', '~b~')
    mainMenu:AddItem(placeholder2)

    if customCoords then
        for k2, cCoords in pairs(customCoords) do
            cCoordList = _menuPool:AddSubMenu(mainMenu, cCoords.name, '~b~' .. cCoords.coords.x .. ' ' .. cCoords.coords.y .. ' ' .. cCoords.coords.z)
            cCoordList.ParentItem:RightLabel('~b~→→→')

            cCoordTeleport = NativeUI.CreateItem(Translation[Config.Locale]['teleport'], '~b~')
            cCoordTeleport:RightLabel('~g~→→→')
            cCoordList:AddItem(cCoordTeleport)

            cCoordDelete = NativeUI.CreateItem(Translation[Config.Locale]['delete'], '~b~')
            cCoordDelete:RightLabel('~r~→→→')
            cCoordList:AddItem(cCoordDelete)

            cCoordTeleport.Activated = function(sender, index)
                logging('debug', cCoords.name)
                logging('debug', cCoords.coords.x .. ' ' .. cCoords.coords.y .. ' ' .. cCoords.coords.z)

                SetEntityCoords(PlayerPedId(), cCoords.coords.x, cCoords.coords.y, cCoords.coords.z, false, false, false, true)
                TriggerServerEvent('msk_saveCoordsMenu:sendDiscordLog', cCoords.name, vector3(cCoords.coords.x, cCoords.coords.y, cCoords.coords.z))
                _menuPool:CloseAllMenus()
            end

            cCoordDelete.Activated = function(sender, index)
                logging('debug', cCoords.name)
                logging('debug', cCoords.coords.x .. ' ' .. cCoords.coords.y .. ' ' .. cCoords.coords.z)

                TriggerServerEvent('msk_saveCoordsMenu:deleteCoords', cCoords.name, vector3(cCoords.coords.x, cCoords.coords.y, cCoords.coords.z))
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
exports("openSaveCoordMenu", openSaveCoordMenu) -- exports["msk_saveCoordMenu"]:openSaveCoordMenu()

---- Functions ----

logging = function(code, msg, msg2, msg3)
    if Config.Debug then
        local script = "[^2"..GetCurrentResourceName().."^0]"
        MSK.logging(script, code, msg, msg2, msg3)
    end
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