# msk_webhook
Send Discord Webhooks

## Export [ONLY serverside]
```lua
exports['msk_webhook']:sendDiscordLog(webhook, botColor, botName, botAvatar, title, description, fields, footer, time)
```

## Description
```lua
webhook = "WEBHOOK_LINK"

botColor = false -- to deactivate it
botName = false -- to deactivate it
botAvatar = false -- to deactivate it
title = false -- to deactivate it
description = false -- to deactivate it
fields = false -- to deactive it
footer = false -- to deactive it
time = false -- to deactive it
```

```lua
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
```