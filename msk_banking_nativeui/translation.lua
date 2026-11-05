Translation = {}
----------------------------------------------------------------
Translation = {
    ['de'] = {
        ['dollar'] = '~g~$~s~', -- Wird überall angezeigt
        ['createAccount'] = 'Bankkonto erstellen',
        ['confirm'] = '~g~Bestätigen',
        ['success_create_account'] = '~g~Bankkonto erfolgreich erstellt für ~b~$',
        ['success_change_iban'] = '~g~Kontonummer erfolgreich geändert für ~b~$',
        ['money'] = 'Bargeld: ',
        ['bank'] = 'Bankkonto: ',
        ['iban'] = 'Kontonummer: ',
        ['deposit'] = '~g~Einzahlen',
        ['withdraw'] = '~r~Auszahlen',
        ['transfer'] = '~p~Überweisen',
        ['amount'] = 'Geldbetrag:',
        ['atm'] = 'Bankautomat',
        ['buy_bankcard'] = 'Bankkarte kaufen',

        ['open_bank'] = 'Drücke ~g~E~s~ um ~b~%s~s~ zu betreten',
        ['open_bank_textui'] = 'Drücke E um %s zu betreten',
        ['open_atm'] = 'Drücke ~g~E~s~ um den Bankautomat zu benutzen',
        ['open_atm_textui'] = 'Drücke E um den Bankautomat zu benutzen',
        ['no_bankcard'] = 'Du hast keine Bankkarte dabei! Besorge dir eine bei einer Bankfiliale.',

        ['cash'] = 'Bargeld',
        ['wallet'] = 'Bankkonto',

        ['not_enough_money'] = '~r~Du hast nicht genug Geld dabei!',
        ['not_enough_bank'] = '~r~Du hast nicht genug Geld auf dem Konto!',
        ['success_deposit'] = 'Du hast ~g~$%s~s~ eingezahlt.',
        ['success_withdraw'] = 'Du hast ~g~$%s~s~ ausgezahlt.',

        ['change_iban'] = 'Kontonummer ändern',
        ['nativeHeader'] = 'Kontonummer:',
        ['nativeDesc'] = '~b~Kontonummer eingeben',
        ['noNumber'] = '~r~Bitte gebe eine gültige Nummer an!',
        ['numberExist'] = 'Diese Kontonummer existiert bereits!',
        ['numbernotExist'] = 'Diese Kontonummer existiert nicht!',
        ['not_correct_insert'] = 'Bitte gebe alle Daten korrekt an!',

        ['delete_iban'] = 'Zweitkonto löschen',
        ['delete_iban_payout'] = 'Geld auszahlen?',
        ['delete_iban_payout_desc'] = '~r~Muss aktiviert werden wenn eine Auszahlung erwünscht ist',
        ['delete_iban_payout_bank'] = 'Auf das Hauptkonto auszahlen?',
        ['delete_iban_payout_bank_desc'] = '~b~Aktivieren falls Auszahlung auf Konto gewünscht',

        ['main_account'] = 'Hauptkonto',
        ['second_account'] = 'Zweitkonto',
        ['society_account'] = 'Firmenkonto',

        ['only_int_allowed'] = 'Es sind nur ganze Zahlen erlaubt!',
        ['max_length_reached_number'] = 'Es sind nur maximal %s Zahlen erlaubt!',
        ['max_length_reached_string'] = 'Es sind nur maximal %s Zeichen erlaubt!',
        ['without_prefix'] = 'IBAN ohne Prefix angeben!',

        -- Transfer
        ['transfer_reason'] = 'Grund:',
        ['selfTransfer'] = 'Du kannst nicht an dich selbst überweisen',
        ['success_transfer'] = 'Du hast erfolgreich $~g~%s~s~ an ~b~%s~s~ überwiesen.',
        ['get_transfer'] = 'Dir wurden $~g~%s~s~ von ~b~%s~s~ überwiesen.',

        -- Setting
        ['settings'] = 'Einstellungen',
        ['settings_desc'] = 'Verwalte deine Accounts',
        ['pin'] = 'PIN: ',
        ['set_pin'] = 'PIN ändern',
        ['current_pin'] = 'Aktuelle PIN: %s',
        ['get_pin'] = 'Gebe deine PIN ein',
        ['wrong_pin'] = 'Deine PIN ist ungültig!',
        ['pin_payment'] = 'Bar bezahlen?',
        ['pin_payment_desc'] = '~b~Wenn aktiviert dann wird mit Bargeld bezahlt',
        ['no_account_found'] = 'Du hast noch kein Konto. Erstelle dir ein Konto bei der Bank.',
        ['success_change_pin'] = 'Du hast deine PIN erfolgreich zu ~g~%s~s~ geändert.',
        ['no_pin_found'] = 'Du hast noch keine PIN. Erstelle dir eine PIN bei der Bank.',

        -- Investment
        ['investment'] = 'Investment',
        ['invest_cash'] = 'Betrag: ',
        ['invest_desc'] = 'Bekomme oder verliere zwischen ~y~%s%s~s~ und ~y~%s%s~s~ alle ~y~3h~s~ vom inventierten Betrag.',
        ['invest_not_enough'] = 'Es ist nicht genug Geld auf dem Investmentkonto.',
        ['investment_add'] = 'Du hast ~y~$%s~s~ vom Invenstment erhalten.',
        ['investment_remove'] = 'Du hast ~y~$%s~s~ vom Invenstment verloren.',

        -- Transactions
        ['transactions'] = 'Transaktionen',
        ['transaction_deposit'] = 'Einzahlungen',
        ['transaction_withdraw'] = 'Auszahlungen',
        ['transaction_transfer'] = 'Überweisungen',
        ['transaction_other'] = 'Sonstiges',
        ['transaction_to'] = 'An: ',
        ['transaction_from'] = 'Von: ',

        -- NUMPAD UI
        ['EnterCode'] = 'Gebe deinen Pin ein',
        ['Incorrect'] = 'Falsche Eingabe',

        -- Billing
        ['billing'] = 'Rechnungen',
        ['billing_desc'] = '~y~%s ~b~offene Rechnungen',
        ['billing_reason'] = '~b~Grund: ',
        ['player_paid_invoice'] = 'Du hast die Rechnung von $%s bezahlt.',
        ['target_paid_invoice'] = 'Jemand hat die Rechnung von $%s bezahlt.',
        ['target_not_enough_money'] = 'Jemand kann die Rechnung von $%s nicht bezahlen.',
        ['player_not_online'] = 'Die Person kann aktuell keine Zahlungen entgegen nehmen.',

        -- ATM Robbery
        ['open_atm_robbery'] = 'Drücke ~g~E~s~ um den Bankautomat zu benutzen.\nDrücke ~g~G~s~ um den Bankautomat auszurauben.',
        ['open_atm_textui_robbery'] = 'Drücke E um den Bankautomat zu benutzen.\nDrücke G um den Bankautomat auszurauben.',
        ['stop_atm_robbery'] = 'Drücke ~g~G~s~ um den ATM Raub abzubrechen.',
        ['stop_atm_textui_robbery'] = 'Drücke X um den ATM Raub abzubrechen.',
        ['job_blacklist'] = 'Dir ist es nicht erlaubt einen ATM auszurauben.',
        ['was_robbed'] = 'Der ATM wurde breits kürzlich ausgeraubt.',
        ['needed_cops'] = 'Es sind nicht genügend Polizisten im Dienst!',
        ['missing_item'] = 'Du hast kein(e) %s!',
        ['robbery_title'] = 'Stiller Alarm',
        ['robbery_subtitle'] = 'ATM Security',
        ['jobnotify_start'] = '~r~Stiller Alarm ~s~an einem Geldautomaten in ~y~%s~s~ ausgelöst.',
        ['jobnotify_stop'] = 'Der ATM Raub wurde ~r~abgebrochen!',
        ['jobnotify_success'] = 'Der ATM Raub wurde ~g~abgeschlossen!',
        ['atm_cracked'] = 'Du hast den ATM aufgebrochen',
        ['cartridge_bursts'] = 'Eine Tintenpatrone ist geplatzt. Dadurch sind $%s unbrauchbar!',
    },
    ['en'] = {
        ['dollar'] = '~g~$~s~', -- Shows everywhere
        ['createAccount'] = 'Create a Bankaccount',
        ['confirm'] = '~g~Confirm',
        ['success_create_account'] = '~g~Successfully created a Bankaccount for ~b~$',
        ['success_change_iban'] = '~g~Successfully changed the Accountnumber for ~b~$',
        ['money'] = 'Cash: ',
        ['bank'] = 'Bankaccount: ',
        ['iban'] = 'Accountnumber: ',
        ['deposit'] = '~g~Deposit',
        ['withdraw'] = '~r~Withdraw',
        ['transfer'] = '~p~Transfer',
        ['amount'] = 'Amount:',
        ['atm'] = 'ATM',
        ['buy_bankcard'] = 'Buy a Bankcard',

        ['open_bank'] = 'Press ~g~E~s~ to open ~b~%s',
        ['open_bank_textui'] = 'Press E to open %s',
        ['open_atm'] = 'Press ~g~E~s~ to use the ATM',
        ['open_atm_textui'] = 'Press E to use the ATM',
        ['no_bankcard'] = "You don't have a Bankcard with you! Please buy one at the Bank.",

        ['cash'] = 'Cash',
        ['wallet'] = 'Bankaccount',

        ['not_enough_money'] = "~r~You don't have enough money with you!",
        ['not_enough_bank'] = "~r~You don't have enough money on your Bankaccount!",
        ['success_deposit'] = 'You have deposited ~g~$%s~s~.',
        ['success_withdraw'] = 'You have withdrawed ~g~$%s~s~.',

        ['change_iban'] = 'Change Accountnumber',
        ['nativeHeader'] = 'Accountnumber:',
        ['nativeDesc'] = '~b~Enter Accountnumber',
        ['noNumber'] = '~r~Please enter a valid number!',
        ['numberExist'] = 'This Accountnumber does exist already!',
        ['numbernotExist'] = "This Accountnumber doesn't exist!",
        ['not_correct_insert'] = 'Bitte gebe alle Daten korrekt an!',

        ['delete_iban'] = 'Delete Secondaccount',
        ['delete_iban_payout'] = 'Payout Money?',
        ['delete_iban_payout_desc'] = '~r~Must be activated if a payout is desired',
        ['delete_iban_payout_bank'] = 'Payout to Bankaccount?',
        ['delete_iban_payout_bank_desc'] = '~b~Activate if payment to Bankaccount is desired',

        ['main_account'] = 'Mainaccount',
        ['second_account'] = 'Secondaccount',
        ['society_account'] = 'Societyaccount',

        ['only_int_allowed'] = 'Only integers are allowed!',
        ['max_length_reached_number'] = 'Only %s numbers max!',
        ['max_length_reached_string'] = 'Only %s characters max!',
        ['without_prefix'] = 'Insert IBAN without prefix!',

        -- Transfer
        ['transfer_reason'] = 'Reason:',
        ['selfTransfer'] = "You can't transfer to yourself",
        ['success_transfer'] = 'You successfully tranfered $~g~%s~s~ to ~b~%s~s~.',
        ['get_transfer'] = 'You get $~g~%s~s~ from ~b~%s~s~ as a transfer.',

        -- Settings
        ['settings'] = 'Settings',
        ['settings_desc'] = 'Manage your accounts',
        ['pin'] = 'PIN: ',
        ['set_pin'] = 'Change PIN',
        ['current_pin'] = 'Current PIN: %s',
        ['get_pin'] = 'Insert your PIN',
        ['wrong_pin'] = 'Your PIN is invalid!',
        ['pin_payment'] = 'Pay with Cash?',
        ['pin_payment_desc'] = '~b~If activated you pay with cash.',
        ['no_account_found'] = "You don't have an account yet. Create an account at the bank.",
        ['success_change_pin'] = 'You changed your PIN successfully to ~g~%s~s~',
        ['no_pin_found'] = "You don't have a PIN yet. Create a PIN at the bank.",

        -- Investment
        ['investment'] = 'Investment',
        ['invest_cash'] = 'Amount: ',
        ['invest_desc'] = 'Get or lose between ~y~%s~s~ and ~y~%s~s~ every ~y~3h~s~ of invested Amount.',
        ['invest_not_enough'] = 'Not enough money at the Investmentaccount.',
        ['investment_add'] = 'You have get ~y~$%s~s~ from Invenstment.',
        ['investment_remove'] = 'You have lost ~y~$%s~s~ from Invenstment.',

        -- Transactions
        ['transactions'] = 'Transactions',
        ['transaction_deposit'] = 'Deposits',
        ['transaction_withdraw'] = 'Withdraws',
        ['transaction_transfer'] = 'Transfers',
        ['transaction_other'] = 'Others',
        ['transaction_to'] = 'To: ',
        ['transaction_from'] = 'From: ',

        -- NUMPAD UI
        ['EnterCode'] = 'Insert your PIN',
        ['Incorrect'] = 'Incorrect Insert',

        -- Billing
        ['billing'] = 'Bills',
        ['billing_desc'] = '~y~%s ~b~open bills',
        ['billing_reason'] = '~b~Reason: ',
        ['player_paid_invoice'] = 'You have paid the bill from $%s.',
        ['target_paid_invoice'] = 'Someone has paid the bill for $%s.',
        ['target_not_enough_money'] = 'Someone can\'t pay the bill for $%s.',
        ['player_not_online'] = 'The person is currently unable to accept payments.',

        -- ATM Robbery
        ['open_atm_robbery'] = 'Press ~g~E~s~ to use the ATM.\nPress ~g~G~s~ to Rob the ATM.',
        ['open_atm_textui_robbery'] = 'Press E to use the ATM.\nPress G to Rob the ATM.',
        ['stop_atm_robbery'] = 'Press ~g~G~s~ to cancel the ATM Robbery.',
        ['stop_atm_textui_robbery'] = 'Press X to cancel the ATM Robbery.',
        ['job_blacklist'] = 'You are not allowed to rob an ATM.',
        ['was_robbed'] = 'The ATM was robbed recently.',
        ['needed_cops'] = 'There are not enough police officers on duty!',
        ['missing_item'] = 'You do not have a(n) %s!',
        ['robbery_title'] = 'Silent alarm',
        ['robbery_subtitle'] = 'ATM Security',
        ['jobnotify_start'] = '~r~Silent alarm~s~ triggered at an ATM in ~y~%s~s~.',
        ['jobnotify_stop'] = 'The ATM robbery was ~r~cancelled!',
        ['jobnotify_success'] = 'The ATM robbery was ~g~completed!',
        ['atm_cracked'] = 'You have broken open the ATM',
        ['cartridge_bursts'] = 'An ink cartridge has burst. This makes $%s unusable!',
    },
}