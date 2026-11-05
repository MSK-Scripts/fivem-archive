RegisterNetEvent('msk_simcard:openMenu')
AddEventHandler('msk_simcard:openMenu', function()
    if Config.dialogBox then
        if Config.StartingDigit.enable then
            if Config.numberFormat:match('number') then
                exports['an_dialogBox']:showDialog('simcard', Translation[Config.Locale]['nativeHeader'], Config.StartingDigit.value, Translation[Config.Locale]['dialogBox'] .. Config.numberLength .. Translation[Config.Locale]['dialogBox2'], onSubmit, onCancel)
            elseif Config.numberFormat:match('gc') then
                exports['an_dialogBox']:showDialog('simcard', Translation[Config.Locale]['nativeHeader'], Config.StartingDigit.value .. '-' .. '000', Translation[Config.Locale]['dialogBox'] .. '8' .. Translation[Config.Locale]['dialogBox2'], onSubmit, onCancel)
            elseif Config.numberFormat:match('canada') then
                exports['an_dialogBox']:showDialog('simcard', Translation[Config.Locale]['nativeHeader'], Config.StartingDigit.value .. '-' .. '000' .. '-' .. '000', Translation[Config.Locale]['dialogBox'] .. '12' .. Translation[Config.Locale]['dialogBox2'], onSubmit, onCancel)
            end
        else
            if Config.numberFormat:match('number') then
                exports['an_dialogBox']:showDialog('simcard', Translation[Config.Locale]['nativeHeader'], '', Translation[Config.Locale]['dialogBox'] .. Config.numberLength .. Translation[Config.Locale]['dialogBox2'], onSubmit, onCancel)
            elseif Config.numberFormat:match('gc') then
                exports['an_dialogBox']:showDialog('simcard', Translation[Config.Locale]['nativeHeader'], '000' .. '-' .. '000', Translation[Config.Locale]['dialogBox'] .. '8' .. Translation[Config.Locale]['dialogBox2'], onSubmit, onCancel)
            elseif Config.numberFormat:match('canada') then
                exports['an_dialogBox']:showDialog('simcard', Translation[Config.Locale]['nativeHeader'], '000' .. '-' .. '000' .. '-' .. '0000', Translation[Config.Locale]['dialogBox'] .. '12' .. Translation[Config.Locale]['dialogBox2'], onSubmit, onCancel)
            end
        end
    else
        openMenuNativeUI()
    end
end)

if not Config.dialogBox then
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

    function openMenuNativeUI()
        _menuPool:Remove()
        _menuPool = NativeUI.CreatePool()
        local newNumber = nil

        mainMenu = NativeUI.CreateMenu(Translation[Config.Locale]['nativeHeader'], Translation[Config.Locale]['nativeDesc'])
        _menuPool:Add(mainMenu)

        local setnumber = NativeUI.CreateItem(Translation[Config.Locale]['number'], '')
        setnumber:RightLabel('~b~')
        mainMenu:AddItem(setnumber)
        local confirm = NativeUI.CreateItem(Translation[Config.Locale]['confirm'], Translation[Config.Locale]['saveNumber'])
        confirm:RightLabel('~b~→→→')
        mainMenu:AddItem(confirm)

        mainMenu.OnItemSelect = function(sender, item, index)
            if item == setnumber then
                logging('debug', 'item = number')
                if Config.StartingDigit.enable then
                    if Config.numberFormat:match('number') then
                        local inserted = KeyboardInput(Translation[Config.Locale]['nativeDesc'], Config.StartingDigit.value, Config.numberLength)
                        if tonumber(inserted) then
                            newNumber = tostring(inserted)
                            setnumber:RightLabel(newNumber)
                        else
                            Config.Notification(nil, Translation[Config.Locale]['noNumber'])

                        end
                    elseif Config.numberFormat:match('gc') then
                        local inserted = KeyboardInput(Translation[Config.Locale]['nativeDesc'], Config.StartingDigit.value, 8)
                        if tostring(inserted) then
                            newNumber = tostring(inserted)
                            setnumber:RightLabel(newNumber)
                        end
                    elseif Config.numberFormat:match('canada') then
                        local inserted = KeyboardInput(Translation[Config.Locale]['nativeDesc'], Config.StartingDigit.value, 12)
                        if tostring(inserted) then
                            newNumber = tostring(inserted)
                            setnumber:RightLabel(newNumber)
                        end
                    end
                else
                    if Config.numberFormat:match('number') then
                        local inserted = KeyboardInput(Translation[Config.Locale]['nativeDesc'], '', Config.numberLength)
                        if tonumber(inserted) then
                            newNumber = tostring(inserted)
                            setnumber:RightLabel(newNumber)
                        else
                            Config.Notification(nil, Translation[Config.Locale]['noNumber'])

                        end
                    elseif Config.numberFormat:match('gc') then
                        local inserted = KeyboardInput(Translation[Config.Locale]['nativeDesc'], '', 8)
                        if tostring(inserted) then
                            newNumber = tostring(inserted)
                            setnumber:RightLabel(newNumber)
                        end
                    elseif Config.numberFormat:match('canada') then
                        local inserted = KeyboardInput(Translation[Config.Locale]['nativeDesc'], '', 12)
                        if tostring(inserted) then
                            newNumber = tostring(inserted)
                            setnumber:RightLabel(newNumber)
                        end
                    end
                end
            elseif item == confirm then
                logging('debug', 'item = confirm')
                if newNumber ~= nil then
                    logging('debug', 'newNumber:')
                    logging('debug', newNumber)

                    mainMenu:Visible(false)
                    TriggerServerEvent('msk_simcard:changeNumberDB', newNumber, Config.wishItem)
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
end

KeyboardInput = function(TextEntry, ExampleText, MaxStringLenght)
	AddTextEntry('FMMC_KEY_TIP1', TextEntry) 
	DisplayOnscreenKeyboard(1, "FMMC_KEY_TIP1", "", ExampleText, "", "", "", MaxStringLenght)
	blockinput = true

	while UpdateOnscreenKeyboard() ~= 1 and UpdateOnscreenKeyboard() ~= 2 do
		Wait(0)
	end
		
	if UpdateOnscreenKeyboard() ~= 2 then
		local result = GetOnscreenKeyboardResult()
		Wait(500)
		blockinput = false 
		return result 
	else
		Wait(500) 
		blockinput = false
		return nil
	end
end

function onSubmit(newNumber)
    if Config.numberFormat == 'number' then
        if tonumber(newNumber) then
            if string.len(tostring(newNumber)) == Config.numberLength then
                TriggerServerEvent('msk_simcard:changeNumber', tostring(newNumber), Config.wishItem)
            else
                Config.Notification(nil, Translation[Config.Locale]['notcorrectdigits'] .. Config.numberLength .. Translation[Config.Locale]['notcorrectdigits2'])
            end
        else
            Config.Notification(nil, Translation[Config.Locale]['noNumber'])
        end
    elseif Config.numberFormat == 'gc' then
        if tostring(newNumber) then
            if string.len(tostring(newNumber)) == 8 then
                TriggerServerEvent('msk_simcard:changeNumber', tostring(newNumber), Config.wishItem)
            else
                Config.Notification(nil, Translation[Config.Locale]['notcorrectdigits'] .. '7' .. Translation[Config.Locale]['notcorrectdigits2'])
            end
        end
    elseif Config.numberFormat == 'canada' then
        if tostring(newNumber) then
            if string.len(tostring(newNumber)) == 12 then
                TriggerServerEvent('msk_simcard:changeNumber', tostring(newNumber), Config.wishItem)
            else
                Config.Notification(nil, Translation[Config.Locale]['notcorrectdigits'] .. '12' .. Translation[Config.Locale]['notcorrectdigits2'])
            end
        end
    end
end

function onCancel()
    return
end