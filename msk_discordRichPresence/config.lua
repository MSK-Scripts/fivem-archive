Config = {}

Config.AppId = '105595432' -- Make an application @ https://discordapp.com/developers/applications/ ID can be found there.
Config.Asset = 'msk_scripts' -- Go to https://discordapp.com/developers/applications/APPID/rich-presence/assets
Config.ServerSlots = 64 -- Set the Slots of your Server
Config.ServerName = 'MSK Scripts'

Config.Buttons = {
    ['0'] = {
        name = 'Discord',
        link = 'https://discord.gg/5hHSBRHvJE'
    },
    ['1'] = {
        name = 'Connect',
        link = 'fivem://connect/musiker15.de:30120'
    }
}

Config.Refresh = 10 -- in seconds // How often should it be refreshed