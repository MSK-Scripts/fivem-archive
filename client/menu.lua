----------------------------------------------------------------
-- Create Bankaccount
----------------------------------------------------------------
createBankMenu = function(mainMenu, background, isBank)
    local createAccount = _menuPool:AddSubMenu(mainMenu, Translation[Config.Locale]['createAccount'])
    createAccount.ParentItem:RightLabel('~b~' .. Config.mainAccount.price .. Translation[Config.Locale]['dollar'])
    setCustomBanner(createAccount, background)

    local buyMoney = NativeUI.CreateItem(Translation[Config.Locale]['cash'], '~b~')
    buyMoney:RightLabel('~g~→→→')
    createAccount:AddItem(buyMoney)

    local buyBank = NativeUI.CreateItem(Translation[Config.Locale]['wallet'], '~b~')
    buyBank:RightLabel('~g~→→→')
    createAccount:AddItem(buyBank)

    buyMoney.Activated = function(sender, index)
        TriggerServerEvent('msk_banking:setBankaccount', 'bank', genNumber(), 'money', true)
        reopenNativeUI(isBank)
    end

    buyBank.Activated = function(sender, index)
        TriggerServerEvent('msk_banking:setBankaccount', 'bank', genNumber(), 'bank', true)
        reopenNativeUI(isBank)
    end
end

----------------------------------------------------------------
-- Billing
----------------------------------------------------------------
billingMenu = function(mainMenu, background, mainAccount, secondAccount, hasBankcard, isBank)
    local bills = MSK.Trigger('msk_banking:getBills')
    local billsMenu

    if #bills > 0 then
        billsMenu = _menuPool:AddSubMenu(mainMenu, Translation[Config.Locale]['billing'], Translation[Config.Locale]['billing_desc']:format(#bills))
        billsMenu.ParentItem:RightLabel('~b~→→→')
        setCustomBanner(billsMenu, background)

        for k, v in ipairs(bills) do
            local label, amount, desc = '', '', ''

            if Config.okokBilling.enable and GetResourceState(Config.okokBilling.scriptname) == "started" then
                if v.society_name == '' or not v.society_name then
                    label = Translation[Config.Locale]['transaction_from'] .. v.author_name
                else
                    label = Translation[Config.Locale]['transaction_from'] .. v.author_name .. ' (' .. v.society_name .. ')'
                end
                amount = v.invoice_value
                desc = Translation[Config.Locale]['billing_reason'] .. v.item
            else
                label = ('From: %s'):format(v.label)
                amount = v.amount
            end

            local bill = NativeUI.CreateItem(label, desc)
            bill:RightLabel(Translation[Config.Locale]['dollar'] .. MSK.Comma(amount, '.'))
            billsMenu:AddItem(bill)

            bill.Activated = function(sender, index)
                if Config.okokBilling.enable and GetResourceState(Config.okokBilling.scriptname) == "started" then
                    TriggerServerEvent('okokBilling:PayInvoice', v.id)
                    reopenNativeUI(isBank)
                elseif not Config.okokBilling.enable then
                    if GetResourceState('esx_billing') == "started" then
                        ESX.TriggerServerCallback('esx_billing:payBill', function()
                            reopenNativeUI(isBank)
                        end, v.id)
                    else
                        ESX.TriggerServerCallback('msk_banking:payBill', function()
                            reopenNativeUI(isBank)
                        end, v.id)
                    end
                else
                    logging('error', 'okokBilling not found! Make sure you have installed it correctly or deactivate it!')
                end
            end
        end
    else
        billsMenu = NativeUI.CreateItem(Translation[Config.Locale]['billing'], Translation[Config.Locale]['billing_desc']:format(#bills))
        billsMenu:SetRightBadge(BadgeStyle.Lock)
        mainMenu:AddItem(billsMenu)
    end
end

----------------------------------------------------------------
-- Investment
----------------------------------------------------------------
investmentMenu = function(mainMenu, background, mainAccount, secondAccount, hasBankcard, isBank)
    local investMenu = _menuPool:AddSubMenu(mainMenu, Translation[Config.Locale]['investment'], Translation[Config.Locale]['invest_desc']:format(Config.Investment.percentage.min, '%', Config.Investment.percentage.max, '%', Config.Investment.time))
    investMenu.ParentItem:RightLabel('~b~→→→')
    setCustomBanner(investMenu, background)

    local investCash = NativeUI.CreateItem(Translation[Config.Locale]['invest_cash'], '~b~')
    investCash:RightLabel(Translation[Config.Locale]['dollar'] .. MSK.Comma(MSK.Trigger('msk_banking:getInvestment'), '.'))
    investMenu:AddItem(investCash)

    local placeholder = NativeUI.CreateItem('', '~b~')
    investMenu:AddItem(placeholder)

    local deposit = NativeUI.CreateItem(Translation[Config.Locale]['deposit'], '~b~')
    deposit:RightLabel('~g~→→→')
    investMenu:AddItem(deposit)

    local withdraw = NativeUI.CreateItem(Translation[Config.Locale]['withdraw'], '~b~')
    withdraw:RightLabel('~r~→→→')
    investMenu:AddItem(withdraw)

    deposit.Activated = function(sender, index)
        MSK.Input.Open(Translation[Config.Locale]['invest_cash'], '', function(input)
            if not input then return end
        
            if tonumber(input) then
                if math.type(tonumber(input)) == 'integer' then
                    TriggerServerEvent('msk_banking:investments', true, tonumber(input))
                    reopenNativeUI(isBank)
                else
                    Config.Notification(nil, Translation[Config.Locale]['only_int_allowed'], 'error')
                end
            else
                Config.Notification(nil, Translation[Config.Locale]['noNumber'], 'error')
            end
        end)
    end

    withdraw.Activated = function(sender, index)
        MSK.Input.Open(Translation[Config.Locale]['invest_cash'], '', function(input)
            if not input then return end
        
            if tonumber(input) then
                if math.type(tonumber(input)) == 'integer' then
                    TriggerServerEvent('msk_banking:investments', false, tonumber(input))
                    reopenNativeUI(isBank)
                else
                    Config.Notification(nil, Translation[Config.Locale]['only_int_allowed'], 'error')
                end
            else
                Config.Notification(nil, Translation[Config.Locale]['noNumber'], 'error')
            end
        end)
    end
end

----------------------------------------------------------------
-- Settings and more
----------------------------------------------------------------
settingsMenu = function(mainMenu, background, mainAccount, secondAccount, hasBankcard, isBank)
    local settings = _menuPool:AddSubMenu(mainMenu, Translation[Config.Locale]['settings'], Translation[Config.Locale]['settings_desc'])
    settings.ParentItem:RightLabel('~b~→→→')
    setCustomBanner(settings, background)

    if Config.PIN.enable then
        local pin, checkBar = nil, false

        local setPINList = _menuPool:AddSubMenu(settings, Translation[Config.Locale]['set_pin'])
        setPINList.ParentItem:RightLabel(Translation[Config.Locale]['dollar'] .. MSK.Comma(Config.PIN.price, '.'))
        setCustomBanner(setPINList, background)

        local setPIN = NativeUI.CreateItem(Translation[Config.Locale]['pin'], '~b~')
        setPINList:AddItem(setPIN)

        local checkBoxPIN = NativeUI.CreateCheckboxItem(Translation[Config.Locale]['pin_payment'], checkBar, Translation[Config.Locale]['pin_payment_desc'])
        setPINList:AddItem(checkBoxPIN)

        local confirmPIN = NativeUI.CreateItem(Translation[Config.Locale]['confirm'], '~b~')
        confirmPIN:RightLabel('~g~→→→')
        setPINList:AddItem(confirmPIN)

        setPIN.Activated = function(sender, index)
            MSK.Input.Open(Translation[Config.Locale]['get_pin'], '', function(input)
                if not input then return end
            
                if tonumber(input) then
                    if math.type(tonumber(input)) == 'integer' then
                        if string.len(input) <= Config.PIN.length then
                            pin = tostring(input)
                            setPIN:RightLabel(pin)
                        else
                            Config.Notification(nil, Translation[Config.Locale]['max_length_reached']:format(tostring(Config.PIN.length)), 'warning')
                        end
                    else
                        Config.Notification(nil, Translation[Config.Locale]['only_int_allowed'], 'error')
                    end
                else
                    Config.Notification(nil, Translation[Config.Locale]['noNumber'], 'error')
                end
            end)
        end

        setPINList.OnCheckboxChange = function(sender, item, checked_)
            if item == checkBoxPIN then
                checkBar = checked_
            end
        end

        confirmPIN.Activated = function(sender, index)
            TriggerServerEvent('msk_banking:setPIN', checkBar, tonumber(pin))
            reopenNativeUI(isBank)
        end
    end

    if Config.Bankcard.enable and not hasBankcard then
        local buyBankcardList = _menuPool:AddSubMenu(settings, Translation[Config.Locale]['buy_bankcard'])
        buyBankcardList.ParentItem:RightLabel(Translation[Config.Locale]['dollar'] .. MSK.Comma(Config.Bankcard.price, '.'))
        setCustomBanner(buyBankcardList, background)

        local buyBankcardMoney = NativeUI.CreateItem(Translation[Config.Locale]['cash'], '~b~')
        buyBankcardMoney:RightLabel('~b~→→→')
        buyBankcardList:AddItem(buyBankcardMoney)

        local buyBankcardBank = NativeUI.CreateItem(Translation[Config.Locale]['wallet'], '~b~')
        buyBankcardBank:RightLabel('~b~→→→')
        buyBankcardList:AddItem(buyBankcardBank)

        buyBankcardMoney.Activated = function(sender, index)
            TriggerServerEvent('msk_banking:buyBankcard', 'money')
            reopenNativeUI(isBank)
        end

        buyBankcardBank.Activated = function(sender, index)
            TriggerServerEvent('msk_banking:buyBankcard', 'bank')
            reopenNativeUI(isBank)
        end
    end

    if Config.bankAccounts.enable and not secondAccount.iban then
        local createAccount = _menuPool:AddSubMenu(settings, Translation[Config.Locale]['createAccount'])
        createAccount.ParentItem:RightLabel(Translation[Config.Locale]['dollar'] .. MSK.Comma(Config.bankAccounts.price, '.'))
        setCustomBanner(createAccount, background)

        local buyMoney = NativeUI.CreateItem(Translation[Config.Locale]['cash'], '~b~')
        buyMoney:RightLabel('~g~→→→')
        createAccount:AddItem(buyMoney)

        local buyBank = NativeUI.CreateItem(Translation[Config.Locale]['wallet'], '~b~')
        buyBank:RightLabel('~g~→→→')
        createAccount:AddItem(buyBank)

        buyMoney.Activated = function(sender, index)
            TriggerServerEvent('msk_banking:setBankaccount', 'secondBank', genNumber(), 'money', true)
            reopenNativeUI(isBank)
        end

        buyBank.Activated = function(sender, index)
            TriggerServerEvent('msk_banking:setBankaccount', 'secondBank', genNumber(), 'bank', true)
            reopenNativeUI(isBank)
        end
    end
end

----------------------------------------------------------------
-- Main Account
----------------------------------------------------------------
mainBankMenu = function(mainMenu, background, mainAccount, secondAccount, hasBankcard, isBank)
    local newIBAN, newAmount, toIBAN, newReason = nil, nil, nil, nil

    local accountMenu = _menuPool:AddSubMenu(mainMenu, Translation[Config.Locale]['main_account'])
    accountMenu.ParentItem:RightLabel(mainAccount.iban)
    setCustomBanner(accountMenu, background)

    --[[ accountMenu.ParentItem.Activated = function(sender, index)
        logging('debug', 'accountMenu.ParentItem.Activated')
    end ]]

    local cash = NativeUI.CreateItem(Translation[Config.Locale]['money'], '~b~')
    cash:RightLabel(Translation[Config.Locale]['dollar'] .. MSK.Comma(mainAccount.cash, '.'))
    accountMenu:AddItem(cash)

    local bank = NativeUI.CreateItem(Translation[Config.Locale]['bank'], '~b~')
    bank:RightLabel(Translation[Config.Locale]['dollar'] .. MSK.Comma(mainAccount.bank, '.'))
    accountMenu:AddItem(bank)

    local iban = NativeUI.CreateItem(Translation[Config.Locale]['iban'], '~b~')
    iban:RightLabel(mainAccount.iban)
    accountMenu:AddItem(iban)

    if Config.Transactions then
        local transactionList = _menuPool:AddSubMenu(accountMenu, Translation[Config.Locale]['transactions'], '~b~')
        transactionList.ParentItem:RightLabel('~b~→→→')
        setCustomBanner(transactionList, background)

        local transactions = MSK.Trigger('msk_banking:getTransactions', mainAccount.iban)
        if transactions then
            local deposits = _menuPool:AddSubMenu(transactionList, Translation[Config.Locale]['transaction_deposit'], '~b~')
            deposits.ParentItem:RightLabel('~b~→→→')

            local withdraws = _menuPool:AddSubMenu(transactionList, Translation[Config.Locale]['transaction_withdraw'], '~b~')
            withdraws.ParentItem:RightLabel('~b~→→→')

            local transfers = _menuPool:AddSubMenu(transactionList, Translation[Config.Locale]['transaction_transfer'], '~b~')
            transfers.ParentItem:RightLabel('~b~→→→')

            local others = _menuPool:AddSubMenu(transactionList, Translation[Config.Locale]['transaction_other'], '~b~')
            others.ParentItem:RightLabel('~b~→→→')

            setCustomBanner(deposits, background)
            setCustomBanner(withdraws, background)
            setCustomBanner(transfers, background)
            setCustomBanner(others, background)
            
            for i, transaction in ipairs(transactions) do
                if not transaction.account or transaction.account == 'main' then
                    local v
                    local from

                    if mainAccount.iban == transaction.receiver_iban then
                        v = '+'
                        from = Translation[Config.Locale]['transaction_from'] .. transaction.sender_name
                    elseif mainAccount.iban ~= transaction.receiver_iban then
                        v = '-'
                        from = Translation[Config.Locale]['transaction_to'] .. transaction.receiver_name
                    end

                    local reason = ''
                    if transaction.reason then
                        reason = '(' .. transaction.reason .. ')'
                    end

                    if transaction.type == 'deposit' then
                        local actionDeposit = NativeUI.CreateItem(transaction.sender_name .. ' ' .. reason .. ' | +' .. transaction.amount .. Translation[Config.Locale]['dollar'], '~b~' .. transaction.date)
                        deposits:AddItem(actionDeposit)
                    elseif transaction.type == 'withdraw' then
                        local actionWithdraw = NativeUI.CreateItem(transaction.sender_name .. ' ' .. reason .. ' | -' .. transaction.amount .. Translation[Config.Locale]['dollar'], '~b~' .. transaction.date)
                        withdraws:AddItem(actionWithdraw)
                    elseif transaction.type == 'transfer' then
                        local actionTransfer = NativeUI.CreateItem(from .. ' ' .. reason .. ' | ' .. v .. transaction.amount .. Translation[Config.Locale]['dollar'], '~b~' .. transaction.date)
                        transfers:AddItem(actionTransfer)
                    else
                        local actionOther = NativeUI.CreateItem(transaction.sender_name .. ' ' .. reason .. ' | ' .. v .. transaction.amount .. Translation[Config.Locale]['dollar'], '~b~' .. transaction.date)
                        others:AddItem(actionOther)
                    end
                end
            end
        end
    end

    local placeholder = NativeUI.CreateItem('', '~b~')
    accountMenu:AddItem(placeholder)

    local deposit = NativeUI.CreateItem(Translation[Config.Locale]['deposit'], '~b~')
    deposit:RightLabel('~g~→→→')
    accountMenu:AddItem(deposit)

    local withdraw = NativeUI.CreateItem(Translation[Config.Locale]['withdraw'], '~b~')
    withdraw:RightLabel('~r~→→→')
    accountMenu:AddItem(withdraw)

    deposit.Activated = function(sender, index)
        MSK.Input.Open(Translation[Config.Locale]['amount'], '', function(input)
            if not input then return end
        
            if tonumber(input) then
                if math.type(tonumber(input)) == 'integer' then
                    TriggerServerEvent('msk_banking:changeBankAmount', 'deposit', tonumber(input), tostring(mainAccount.iban), mainAccount)
                    reopenNativeUI(isBank)
                else
                    Config.Notification(nil, Translation[Config.Locale]['only_int_allowed'], 'error')
                end
            else
                Config.Notification(nil, Translation[Config.Locale]['noNumber'], 'error')
            end
        end)
    end

    withdraw.Activated = function(sender, index)
        MSK.Input.Open(Translation[Config.Locale]['amount'], '', function(input)
            if not input then return end
        
            if tonumber(input) then
                if math.type(tonumber(input)) == 'integer' then
                    TriggerServerEvent('msk_banking:changeBankAmount', 'withdraw', tonumber(input), tostring(mainAccount.iban), mainAccount)
                    reopenNativeUI(isBank)
                else
                    Config.Notification(nil, Translation[Config.Locale]['only_int_allowed'], 'error')
                end
            else
                Config.Notification(nil, Translation[Config.Locale]['noNumber'], 'error')
            end
        end)
    end

    local transferList = _menuPool:AddSubMenu(accountMenu, Translation[Config.Locale]['transfer'], '~b~')
    transferList.ParentItem:RightLabel('~p~→→→')
    setCustomBanner(transferList, background)

    local transferAmount = NativeUI.CreateItem(Translation[Config.Locale]['amount'], '~b~')
    transferList:AddItem(transferAmount)

    local transferIBAN = NativeUI.CreateItem(Translation[Config.Locale]['iban'], '~b~')
    transferList:AddItem(transferIBAN)

    local transferReason = NativeUI.CreateItem(Translation[Config.Locale]['transfer_reason'], '~b~')
    transferList:AddItem(transferReason)

    local transferConfirm = NativeUI.CreateItem(Translation[Config.Locale]['confirm'], '~b~')
    transferConfirm:RightLabel('~g~→→→')
    transferList:AddItem(transferConfirm)

    transferList.OnItemSelect = function(sender, item, index)
        if item == transferAmount then
            logging('debug', 'item = transferAmount')
            MSK.Input.Open(Translation[Config.Locale]['amount'], '', function(input)
                if not input then return end

                if tonumber(input) then
                    if math.type(tonumber(input)) == 'integer' then
                        newAmount = tostring(input)
                        transferAmount:RightLabel(Translation[Config.Locale]['dollar'] .. MSK.Comma(newAmount, '.'))
                    else
                        Config.Notification(nil, Translation[Config.Locale]['only_int_allowed'], 'error')
                    end
                else
                    Config.Notification(nil, Translation[Config.Locale]['noNumber'], 'error')
                end
            end)
        elseif item == transferIBAN then
            logging('debug', 'item == transferIBAN')
            MSK.Input.Open(Translation[Config.Locale]['iban'], Translations[Config.Locale]['without_prefix'], function(input)
                if not input then return end
                
                if string.len(input) <= Config.IBAN.length then
                    logging('debug', 'insertIBAN: ' .. input)
                    toIBAN = tostring(input)
                    transferIBAN:RightLabel(Config.IBAN.prefix .. toIBAN)
                else
                    Config.Notification(nil, Translation[Config.Locale]['max_length_reached_string']:format(tostring(Config.IBAN.length)), 'warning')
                end
            end)
        elseif item == transferReason then
            logging('debug', 'item == transferReason')
            MSK.Input.Open(Translation[Config.Locale]['transfer_reason'], '', function(input)
                if not input then return end

                if string.len(input) <= 12 then
                    newReason = tostring(input)
                    transferReason:RightLabel(newReason)
                else
                    Config.Notification(nil, Translation[Config.Locale]['max_length_reached_string']:format(12), 'warning')
                end
            end)
        elseif item == transferConfirm then
            logging('debug', 'item = transferConfirm')
            if toIBAN and newAmount then
                local isExisting = MSK.Trigger('msk_banking:checkIBAN', toIBAN)

                if isExisting then
                    if mainAccount.iban == toIBAN then
                        Config.Notification(nil, Translation[Config.Locale]['selfTransfer'], 'error')
                    else
                        accountMenu:Visible(false)
                        TriggerServerEvent('msk_banking:changeBankAmount', 'transfer', tonumber(newAmount), tostring(toIBAN), mainAccount, newReason)
                        reopenNativeUI(isBank)
                    end
                else
                    Config.Notification(nil, Translation[Config.Locale]['numbernotExist'], 'error')
                end
            else
                Config.Notification(nil, Translation[Config.Locale]['not_correct_insert'], 'warning')
            end
        end
    end

    if Config.IBAN.enable and currentBank then
        local placeholder2 = NativeUI.CreateItem('', '~b~')
        accountMenu:AddItem(placeholder2)

        local changeIBANList = _menuPool:AddSubMenu(accountMenu, Translation[Config.Locale]['change_iban'], '~b~')
        changeIBANList.ParentItem:RightLabel(Translation[Config.Locale]['dollar'] .. MSK.Comma(Config.IBAN.price, '.'))
        setCustomBanner(changeIBANList, background)

        local changeIBAN = NativeUI.CreateItem(Translation[Config.Locale]['nativeHeader'], '~b~')
        changeIBAN:RightLabel('~b~')
        changeIBANList:AddItem(changeIBAN)

        local confirm = NativeUI.CreateItem(Translation[Config.Locale]['confirm'], '~b~')
        confirm:RightLabel('~g~→→→')
        changeIBANList:AddItem(confirm)

        changeIBANList.OnItemSelect = function(sender, item, index)
            if item == changeIBAN then
                logging('debug', 'item = changeIBAN')
                MSK.Input.Open(Translation[Config.Locale]['nativeDesc'], Translations[Config.Locale]['without_prefix'], function(input)
                    if not input then return end
                
                    if not Config.IBAN.design then -- Only numbers
                        if tonumber(input) then
                            if math.type(tonumber(input)) == 'integer' then
                                if string.len(input) <= Config.IBAN.length then
                                    newIBAN = tostring(input)
                                    changeIBAN:RightLabel(Config.IBAN.prefix .. newIBAN)
                                else
                                    Config.Notification(nil, Translation[Config.Locale]['max_length_reached_number']:format(tostring(Config.IBAN.length)), 'warning')
                                end
                            else
                                Config.Notification(nil, Translation[Config.Locale]['only_int_allowed'], 'error')
                            end
                        else
                            Config.Notification(nil, Translation[Config.Locale]['noNumber'], 'error')
                        end
                    else
                        newIBAN = tostring(input)
                        changeIBAN:RightLabel(string.upper(Config.IBAN.prefix .. newIBAN))
                    end
                end)
            elseif item == confirm then
                logging('debug', 'item = confirm')
                if newIBAN then
                    local isExisting = MSK.Trigger('msk_banking:checkIBAN', newIBAN)

                    if not isExisting then
                        accountMenu:Visible(false)
                        TriggerServerEvent('msk_banking:setBankaccount', 'bank', newIBAN, 'money', false)
                        reopenNativeUI(isBank)
                    else
                        Config.Notification(nil, Translation[Config.Locale]['numberExist'], 'error')
                    end
                end
            end
        end
    end
end

----------------------------------------------------------------
-- Second Account
---------------------------------------------------------------

secondBankMenu = function(mainMenu, background, mainAccount, secondAccount, hasBankcard, isBank)
    local newIBAN, newAmount, toIBAN, newReason = nil, nil, nil, nil

    local accountMenu = _menuPool:AddSubMenu(mainMenu, Translation[Config.Locale]['second_account'])
    accountMenu.ParentItem:RightLabel(secondAccount.iban)
    setCustomBanner(accountMenu, background)

    local cash = NativeUI.CreateItem(Translation[Config.Locale]['money'], '~b~')
    cash:RightLabel(Translation[Config.Locale]['dollar'] .. MSK.Comma(mainAccount.cash, '.'))
    accountMenu:AddItem(cash)

    local bank = NativeUI.CreateItem(Translation[Config.Locale]['bank'], '~b~')
    bank:RightLabel(Translation[Config.Locale]['dollar'] .. MSK.Comma(secondAccount.bank, '.'))
    accountMenu:AddItem(bank)

    local iban = NativeUI.CreateItem(Translation[Config.Locale]['iban'], '~b~')
    iban:RightLabel(secondAccount.iban)
    accountMenu:AddItem(iban)

    if Config.Transactions then
        local transactionSecondList = _menuPool:AddSubMenu(accountMenu, Translation[Config.Locale]['transactions'], '~b~')
        transactionSecondList.ParentItem:RightLabel('~b~→→→')
        setCustomBanner(transactionSecondList, background)

        local transactions = MSK.Trigger('msk_banking:getTransactions', secondAccount.iban)
        if transactions then
            local depositsSecond = _menuPool:AddSubMenu(transactionSecondList, Translation[Config.Locale]['transaction_deposit'], '~b~')
            depositsSecond.ParentItem:RightLabel('~b~→→→')

            local withdrawsSecond = _menuPool:AddSubMenu(transactionSecondList, Translation[Config.Locale]['transaction_withdraw'], '~b~')
            withdrawsSecond.ParentItem:RightLabel('~b~→→→')

            local transfersSecond = _menuPool:AddSubMenu(transactionSecondList, Translation[Config.Locale]['transaction_transfer'], '~b~')
            transfersSecond.ParentItem:RightLabel('~b~→→→')

            local othersSecond = _menuPool:AddSubMenu(transactionSecondList, Translation[Config.Locale]['transaction_other'], '~b~')
            othersSecond.ParentItem:RightLabel('~b~→→→')

            setCustomBanner(depositsSecond, background)
            setCustomBanner(withdrawsSecond, background)
            setCustomBanner(transfersSecond, background)
            setCustomBanner(othersSecond, background)
            
            for i, transaction in ipairs(transactions) do
                if not transaction.account or transaction.account == '1' then
                    local v
                    local from

                    if secondAccount.iban == transaction.receiver_iban then
                        v = '+'
                        from = Translation[Config.Locale]['transaction_from'] .. transaction.sender_name
                    elseif secondAccount.iban ~= transaction.receiver_iban then
                        v = '-'
                        from = Translation[Config.Locale]['transaction_to'] .. transaction.receiver_name
                    end

                    local reason = ''
                    if transaction.reason then
                        reason = '(' .. transaction.reason .. ')'
                    end

                    if transaction.type == 'deposit' then
                        local actionDepositSecond = NativeUI.CreateItem(transaction.sender_name .. ' ' .. reason .. ' | +' .. transaction.amount .. Translation[Config.Locale]['dollar'], '~b~' .. transaction.date)
                        depositsSecond:AddItem(actionDepositSecond)
                    elseif transaction.type == 'withdraw' then
                        local actionWithdrawSecond = NativeUI.CreateItem(transaction.sender_name .. ' ' .. reason .. ' | -' .. transaction.amount .. Translation[Config.Locale]['dollar'], '~b~' .. transaction.date)
                        withdrawsSecond:AddItem(actionWithdrawSecond)
                    elseif transaction.type == 'transfer' then
                        local actionTransferSecond = NativeUI.CreateItem(from .. ' ' .. reason .. ' | ' .. v .. transaction.amount .. Translation[Config.Locale]['dollar'], '~b~' .. transaction.date)
                        transfersSecond:AddItem(actionTransferSecond)
                    else
                        local actionOtherSecond = NativeUI.CreateItem(transaction.sender_name .. ' ' .. reason .. ' | ' .. v .. transaction.amount .. Translation[Config.Locale]['dollar'], '~b~' .. transaction.date)
                        othersSecond:AddItem(actionOtherSecond)
                    end
                end
            end
        end
    end

    local placeholder = NativeUI.CreateItem('', '~b~')
    accountMenu:AddItem(placeholder)

    local depositSecond = NativeUI.CreateItem(Translation[Config.Locale]['deposit'], '~b~')
    depositSecond:RightLabel('~g~→→→')
    accountMenu:AddItem(depositSecond)

    local withdrawSecond = NativeUI.CreateItem(Translation[Config.Locale]['withdraw'], '~b~')
    withdrawSecond:RightLabel('~r~→→→')
    accountMenu:AddItem(withdrawSecond)

    local transferSecondList = _menuPool:AddSubMenu(accountMenu, Translation[Config.Locale]['transfer'], '~b~')
    transferSecondList.ParentItem:RightLabel('~p~→→→')
    setCustomBanner(transferSecondList, background)

    local transferSecondAmount = NativeUI.CreateItem(Translation[Config.Locale]['amount'], '~b~')
    transferSecondList:AddItem(transferSecondAmount)

    local transferSecondIBAN = NativeUI.CreateItem(Translation[Config.Locale]['iban'], '~b~')
    transferSecondList:AddItem(transferSecondIBAN)

    local transferReason = NativeUI.CreateItem(Translation[Config.Locale]['transfer_reason'], '~b~')
    transferSecondList:AddItem(transferReason)

    local transferSecondConfirm = NativeUI.CreateItem(Translation[Config.Locale]['confirm'], '~b~')
    transferSecondConfirm:RightLabel('~g~→→→')
    transferSecondList:AddItem(transferSecondConfirm)

    depositSecond.Activated = function(sender, index)
        MSK.Input.Open(Translation[Config.Locale]['amount'], '', function(input)
            if not input then return end
        
            if tonumber(input) then
                if math.type(tonumber(input)) == 'integer' then
                    TriggerServerEvent('msk_banking:changeBankAmount', 'deposit', tonumber(input), tostring(secondAccount.iban), secondAccount)
                    reopenNativeUI(isBank)
                else
                    Config.Notification(nil, Translation[Config.Locale]['only_int_allowed'], 'error')
                end
            else
                Config.Notification(nil, Translation[Config.Locale]['noNumber'], 'error')
            end
        end)
    end

    withdrawSecond.Activated = function(sender, index)
        MSK.Input.Open(Translation[Config.Locale]['amount'], '', function(input)
            if not input then return end
        
            if tonumber(input) then
                if math.type(tonumber(input)) == 'integer' then
                    TriggerServerEvent('msk_banking:changeBankAmount', 'withdraw', tonumber(input), tostring(secondAccount.iban), secondAccount)
                    reopenNativeUI(isBank)
                else
                    Config.Notification(nil, Translation[Config.Locale]['only_int_allowed'], 'error')
                end
            else
                Config.Notification(nil, Translation[Config.Locale]['noNumber'], 'error')
            end
        end)
    end

    transferSecondList.OnItemSelect = function(sender, item, index)
        if item == transferSecondAmount then
            logging('debug', 'item = transferSecondAmount')
            MSK.Input.Open(Translation[Config.Locale]['amount'], '', function(input)
                if not input then return end

                if tonumber(input) then
                    if math.type(tonumber(input)) == 'integer' then
                        newAmount = tostring(input)
                        transferSecondAmount:RightLabel(Translation[Config.Locale]['dollar'] .. MSK.Comma(newAmount, '.'))
                    else
                        Config.Notification(nil, Translation[Config.Locale]['only_int_allowed'], 'error')
                    end
                else
                    Config.Notification(nil, Translation[Config.Locale]['noNumber'], 'error')
                end
            end)
        elseif item == transferSecondIBAN then
            logging('debug', 'item == transferSecondIBAN')
            MSK.Input.Open(Translation[Config.Locale]['iban'], Translations[Config.Locale]['without_prefix'], function(input)
                if not input then return end
                
                if string.len(input) <= Config.IBAN.length then
                    logging('debug', 'insertIBAN: ' .. input)
                    toIBAN = tostring(input)
                    transferSecondIBAN:RightLabel(Config.IBAN.prefix .. toIBAN)
                else
                    Config.Notification(nil, Translation[Config.Locale]['max_length_reached']:format(tostring(Config.IBAN.length)), 'warning')
                end
            end)
        elseif item == transferReason then
            logging('debug', 'item == transferReason')
            MSK.Input.Open(Translation[Config.Locale]['transfer_reason'], '', function(input)
                if not input then return end

                if string.len(input) <= 12 then
                    newReason = tostring(input)
                    transferReason:RightLabel(newReason)
                else
                    Config.Notification(nil, Translation[Config.Locale]['max_length_reached']:format(12), 'warning')
                end
            end)
        elseif item == transferSecondConfirm then
            logging('debug', 'item = transferSecondConfirm')
            if toIBAN and newAmount then
                local isExisting = MSK.Trigger('msk_banking:checkIBAN', toIBAN)

                if isExisting then
                    if secondAccount.iban == toIBAN then
                        Config.Notification(nil, Translation[Config.Locale]['selfTransfer'], 'error')
                    else
                        accountMenu:Visible(false)
                        TriggerServerEvent('msk_banking:changeBankAmount', 'transfer', tonumber(newAmount), tostring(toIBAN), secondAccount, newReason)
                        reopenNativeUI(isBank)
                    end
                else
                    Config.Notification(nil, Translation[Config.Locale]['numbernotExist'], 'error')
                end
            else
                Config.Notification(nil, Translation[Config.Locale]['not_correct_insert'], 'warning')
            end
        end
    end

    if Config.IBAN.enable and currentBank then
        local placeholder2 = NativeUI.CreateItem('', '~b~')
        accountMenu:AddItem(placeholder2)

        local changeSecondIBANList = _menuPool:AddSubMenu(accountMenu, Translation[Config.Locale]['change_iban'], '~b~')
        changeSecondIBANList.ParentItem:RightLabel(Translation[Config.Locale]['dollar'] .. MSK.Comma(Config.IBAN.price, '.'))
        setCustomBanner(changeSecondIBANList, background)

        local changeSecondIBAN = NativeUI.CreateItem(Translation[Config.Locale]['nativeHeader'], '~b~')
        changeSecondIBAN:RightLabel('~b~')
        changeSecondIBANList:AddItem(changeSecondIBAN)

        local confirmSecondIBAN = NativeUI.CreateItem(Translation[Config.Locale]['confirm'], '~b~')
        confirmSecondIBAN:RightLabel('~g~→→→')
        changeSecondIBANList:AddItem(confirmSecondIBAN)

        changeSecondIBANList.OnItemSelect = function(sender, item, index)
            if item == changeSecondIBAN then
                logging('debug', 'item = changeSecondIBAN')
                MSK.Input.Open(Translation[Config.Locale]['nativeDesc'], Translations[Config.Locale]['without_prefix'], function(input)
                    if not input then return end
                
                    if not Config.IBAN.design then -- Only numbers
                        if tonumber(input) then
                            if math.type(tonumber(input)) == 'integer' then
                                if string.len(input) <= Config.IBAN.length then
                                    newIBAN = tostring(input)
                                    changeSecondIBAN:RightLabel(Config.IBAN.prefix .. newIBAN)
                                else
                                    Config.Notification(nil, Translation[Config.Locale]['max_length_reached_number']:format(tostring(Config.IBAN.length)), 'warning')
                                end
                            else
                                Config.Notification(nil, Translation[Config.Locale]['only_int_allowed'], 'error')
                            end
                        else
                            Config.Notification(nil, Translation[Config.Locale]['noNumber'], 'error')
                        end
                    else
                        newIBAN = tostring(input)
                        changeSecondIBAN:RightLabel(string.upper(Config.IBAN.prefix .. newIBAN))
                    end
                end)
            elseif item == confirmSecondIBAN then
                logging('debug', 'item = confirmSecondIBAN')
                if newIBAN then
                    local isExisting = MSK.Trigger('msk_banking:checkIBAN', newIBAN)

                    if not isExisting then
                        accountMenu:Visible(false)
                        TriggerServerEvent('msk_banking:setBankaccount', 'secondBank', newIBAN, 'money', false)     
                        reopenNativeUI(isBank)
                    else
                        Config.Notification(nil, Translation[Config.Locale]['numberExist'], 'error')
                    end
                end
            end
        end
    end

    if Config.IBAN.delete and currentBank then
        local checked = false
        local checkedBank = false

        local deleteIBAN = _menuPool:AddSubMenu(accountMenu, Translation[Config.Locale]['delete_iban'], '~b~')
        deleteIBAN.ParentItem:RightLabel('~b~→→→')
        setCustomBanner(deleteIBAN, background)

        local checkBox = NativeUI.CreateCheckboxItem(Translation[Config.Locale]['delete_iban_payout'], checked, Translation[Config.Locale]['delete_iban_payout_desc'])
        deleteIBAN:AddItem(checkBox)

        local checkBoxBank = NativeUI.CreateCheckboxItem(Translation[Config.Locale]['delete_iban_payout_bank'], checkedBank, Translation[Config.Locale]['delete_iban_payout_bank_desc'])
        deleteIBAN:AddItem(checkBoxBank)

        local confirmDelete = NativeUI.CreateItem(Translation[Config.Locale]['confirm'], '~b~')
        confirmDelete:RightLabel('~g~→→→')
        deleteIBAN:AddItem(confirmDelete)

        deleteIBAN.OnCheckboxChange = function(sender, item, checked_)
            if item == checkBox then
                checked = checked_
            elseif item == checkBoxBank then
                checkedBank = checked_
            end
        end

        confirmDelete.Activated = function(sender, index)
            TriggerServerEvent('msk_banking:deleteBankAccount', checked, checkedBank, tonumber(secondAccount.bank), secondAccount.iban)
            reopenNativeUI(isBank)
        end
    end
end

----------------------------------------------------------------
-- Society Account
----------------------------------------------------------------

societyBankMenu = function(mainMenu, background, mainAccount, secondAccount, job, hasBankcard, isBank)
    local newIBAN, newAmount, toIBAN, newReason = nil, nil, nil, nil

    local societyaccount = _menuPool:AddSubMenu(mainMenu, Translation[Config.Locale]['society_account'] .. ' ~y~[' .. ESX.PlayerData.job.label .. ']~s~')
    societyaccount.ParentItem:RightLabel(job.iban)
    setCustomBanner(societyaccount, background)

    local cash = NativeUI.CreateItem(Translation[Config.Locale]['money'], '~b~')
    cash:RightLabel(Translation[Config.Locale]['dollar'] .. MSK.Comma(mainAccount.cash, '.'))
    societyaccount:AddItem(cash)

    local bank = NativeUI.CreateItem(Translation[Config.Locale]['bank'], '~b~')
    bank:RightLabel(Translation[Config.Locale]['dollar'] .. MSK.Comma(job.bank, '.'))
    societyaccount:AddItem(bank)

    local iban = NativeUI.CreateItem(Translation[Config.Locale]['iban'], '~b~')
    iban:RightLabel(job.iban)
    societyaccount:AddItem(iban)

    if Config.Transactions then
        local transactionSocietyList = _menuPool:AddSubMenu(societyaccount, Translation[Config.Locale]['transactions'], '~b~')
        transactionSocietyList.ParentItem:RightLabel('~b~→→→')
        setCustomBanner(transactionSocietyList, background)

        local transactions = MSK.Trigger('msk_banking:getTransactions', job.iban)
        if transactions then
            local depositsSociety = _menuPool:AddSubMenu(transactionSocietyList, Translation[Config.Locale]['transaction_deposit'], '~b~')
            depositsSociety.ParentItem:RightLabel('~b~→→→')

            local withdrawsSociety = _menuPool:AddSubMenu(transactionSocietyList, Translation[Config.Locale]['transaction_withdraw'], '~b~')
            withdrawsSociety.ParentItem:RightLabel('~b~→→→')

            local transfersSociety = _menuPool:AddSubMenu(transactionSocietyList, Translation[Config.Locale]['transaction_transfer'], '~b~')
            transfersSociety.ParentItem:RightLabel('~b~→→→')

            local othersSociety = _menuPool:AddSubMenu(transactionSocietyList, Translation[Config.Locale]['transaction_other'], '~b~')
            othersSociety.ParentItem:RightLabel('~b~→→→')

            setCustomBanner(depositsSociety, background)
            setCustomBanner(withdrawsSociety, background)
            setCustomBanner(transfersSociety, background)
            setCustomBanner(othersSociety, background)
            
            for i, transaction in ipairs(transactions) do
                if not transaction.account or transaction.account == 'society' then
                    local v
                    local from 

                    if job.iban == transaction.receiver_iban then
                        v = '+'
                        from = Translation[Config.Locale]['transaction_from'] .. transaction.sender_name
                    elseif job.iban ~= transaction.receiver_iban then
                        v = '-'
                        from = Translation[Config.Locale]['transaction_to'] .. transaction.receiver_name
                    end

                    local reason = ''
                    if transaction.reason then
                        reason = '(' .. transaction.reason .. ')'
                    end

                    if transaction.type == 'deposit' then
                        local actionDepositSociety = NativeUI.CreateItem(transaction.sender_name .. ' ' .. reason .. ' | +' .. transaction.amount .. Translation[Config.Locale]['dollar'], '~b~' .. transaction.date)
                        depositsSociety:AddItem(actionDepositSociety)
                    elseif transaction.type == 'withdraw' then
                        local actionWithdrawSociety = NativeUI.CreateItem(transaction.sender_name .. ' ' .. reason .. ' | -' .. transaction.amount .. Translation[Config.Locale]['dollar'], '~b~' .. transaction.date)
                        withdrawsSociety:AddItem(actionWithdrawSociety)
                    elseif transaction.type == 'transfer' then
                        local actionTransferSociety = NativeUI.CreateItem(from .. ' ' .. reason .. ' | ' .. v .. transaction.amount .. Translation[Config.Locale]['dollar'], '~b~' .. transaction.date)
                        transfersSociety:AddItem(actionTransferSociety)
                    else
                        local actionOtherSociety = NativeUI.CreateItem(transaction.sender_name .. ' ' .. reason .. ' | ' .. v .. transaction.amount .. Translation[Config.Locale]['dollar'], '~b~' .. transaction.date)
                        othersSociety:AddItem(actionOtherSociety)
                    end
                end
            end
        end
    end

    local placeholder = NativeUI.CreateItem('', '~b~')
    societyaccount:AddItem(placeholder)

    local deposit = NativeUI.CreateItem(Translation[Config.Locale]['deposit'], '~b~')
    deposit:RightLabel('~g~→→→')
    societyaccount:AddItem(deposit)

    local withdraw = NativeUI.CreateItem(Translation[Config.Locale]['withdraw'], '~b~')
    withdraw:RightLabel('~r~→→→')
    societyaccount:AddItem(withdraw)

    local transferListSociety = _menuPool:AddSubMenu(societyaccount, Translation[Config.Locale]['transfer'], '~b~')
    transferListSociety.ParentItem:RightLabel('~p~→→→')
    setCustomBanner(transferListSociety, background)

    local transferAmountSociety = NativeUI.CreateItem(Translation[Config.Locale]['amount'], '~b~')
    transferAmountSociety:RightLabel('~p~')
    transferListSociety:AddItem(transferAmountSociety)

    local transferIBANSociety = NativeUI.CreateItem(Translation[Config.Locale]['iban'], '~b~')
    transferIBANSociety:RightLabel('~p~')
    transferListSociety:AddItem(transferIBANSociety)

    local transferReason = NativeUI.CreateItem(Translation[Config.Locale]['transfer_reason'], '~b~')
    transferReason:RightLabel('~p~')
    transferListSociety:AddItem(transferReason)

    local transferConfirmSociety = NativeUI.CreateItem(Translation[Config.Locale]['confirm'], '~b~')
    transferConfirmSociety:RightLabel('~g~→→→')
    transferListSociety:AddItem(transferConfirmSociety)

    deposit.Activated = function(sender, index)
        MSK.Input.Open(Translation[Config.Locale]['amount'], '', function(input)
            if not input then return end
        
            if tonumber(input) then
                if math.type(tonumber(input)) == 'integer' then
                    TriggerServerEvent('msk_banking:changeBankAmount', 'deposit', tonumber(input), tostring(job.iban), job)
                    reopenNativeUI(isBank)
                else
                    Config.Notification(nil, Translation[Config.Locale]['only_int_allowed'], 'error')
                end
            else
                Config.Notification(nil, Translation[Config.Locale]['noNumber'], 'error')
            end
        end)
    end

    withdraw.Activated = function(sender, index)
        MSK.Input.Open(Translation[Config.Locale]['amount'], '', function(input)
            if not input then return end
        
            if tonumber(input) then
                if math.type(tonumber(input)) == 'integer' then
                    TriggerServerEvent('msk_banking:changeBankAmount', 'withdraw', tonumber(input), tostring(job.iban), job)
                    reopenNativeUI(isBank)
                else
                    Config.Notification(nil, Translation[Config.Locale]['only_int_allowed'], 'error')
                end
            else
                Config.Notification(nil, Translation[Config.Locale]['noNumber'], 'error')
            end
        end)
    end

    transferListSociety.OnItemSelect = function(sender, item, index)
        if item == transferAmountSociety then
            logging('debug', 'item = transferAmountSociety')
            MSK.Input.Open(Translation[Config.Locale]['amount'], '', function(input)
                if not input then return end

                if tonumber(input) then
                    if math.type(tonumber(input)) == 'integer' then
                        newAmount = tostring(input)
                        transferAmountSociety:RightLabel(Translation[Config.Locale]['dollar'] .. MSK.Comma(newAmount, '.'))
                    else
                        Config.Notification(nil, Translation[Config.Locale]['only_int_allowed'], 'error')
                    end
                else
                    Config.Notification(nil, Translation[Config.Locale]['noNumber'], 'error')
                end
            end)
        elseif item == transferIBANSociety then
            logging('debug', 'item == transferIBANSociety')
            MSK.Input.Open(Translation[Config.Locale]['iban'], Translations[Config.Locale]['without_prefix'], function(input)
                if not input then return end
                
                if string.len(input) <= Config.IBAN.length then
                    logging('debug', 'insertIBAN: ' .. input)
                    toIBAN = tostring(input)
                    transferIBANSociety:RightLabel(Config.IBAN.prefix .. toIBAN)
                else
                    Config.Notification(nil, Translation[Config.Locale]['max_length_reached']:format(tostring(Config.IBAN.length)), 'warning')
                end
            end)
        elseif item == transferReason then
            logging('debug', 'item == transferReason')
            MSK.Input.Open(Translation[Config.Locale]['transfer_reason'], '', function(input)
                if not input then return end

                if string.len(input) <= 12 then
                    newReason = tostring(input)
                    transferReason:RightLabel(newReason)
                else
                    Config.Notification(nil, Translation[Config.Locale]['max_length_reached']:format(12), 'warning')
                end
            end)
        elseif item == transferConfirmSociety then
            logging('debug', 'item = transferConfirmSociety')
            if toIBAN and newAmount then
                local isExisting = MSK.Trigger('msk_banking:checkIBAN', toIBAN)

                if isExisting then
                    if job.iban == toIBAN then
                        Config.Notification(nil, Translation[Config.Locale]['selfTransfer'], 'error')
                    else
                        mainMenu:Visible(false)
                        TriggerServerEvent('msk_banking:changeBankAmount', 'transfer', tonumber(newAmount), tostring(toIBAN), job, newReason)
                        reopenNativeUI(isBank)
                    end
                else
                    Config.Notification(nil, Translation[Config.Locale]['numbernotExist'], 'error')
                end
            else
                Config.Notification(nil, Translation[Config.Locale]['not_correct_insert'], 'warning')
            end
        end
    end
end