Config = {}
----------------------------------------------------------------
Config.VersionChecker = true
----------------------------------------------------------------
Config.testCommand = {
    enable = true, -- Set false to deactivate the Test Command
    command = 'testWebhook',
    data = {
        webhook = "https://discordapp.com/api/webhooks/101088",
        botColor = "6205745", -- https://www.mathsisfun.com/hexadecimal-decimal-colors.html
        botName = "MSK Scripts",
        botAvatar = "https://i.imgur.com/PizJGsh.png",
        title = "MSK Scripts - Webhook Script",
        description = "Test Beschreibung",
        fields = {
            {name = "Title", value = 'Description', inline = true},
            {name = "Title", value = 'Description', inline = true},
        },
        footer = {
            text = "© MSK Scripts", 
            link = "https://i.imgur.com/PizJGsh.png"
        },
        time = "%d/%m/%Y %H:%M:%S" -- format: "day/month/year hour:minute:second"
    }
}
----------------------------------------------------------------
-- Read the Readme.md to understand how to use the EXPORT

-- exports['msk_webhook']:sendDiscordLog(webhook, botColor, botName, botAvatar, title, description, fields, footer, time)