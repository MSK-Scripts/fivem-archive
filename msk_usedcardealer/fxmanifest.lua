fx_version 'adamant'
games { 'gta5' }

author 'Musiker15 - MSK Scripts'
name 'msk_usedcardealer'
description 'Used Car Dealership'
version '1.0'

lua54 'yes'

shared_scripts {
    '@msk_core/import.lua',
    '@ox_lib/init.lua',
    'translation.lua',
    'config.lua'
}

client_scripts {
    'client.lua'
}

server_scripts {
    '@oxmysql/lib/MySQL.lua',
    'server.lua'
}

dependencies {
    'oxmysql',
    'ox_lib',
    'msk_core'
}