fx_version 'adamant'
games { 'gta5' }

author 'Musiker15 - MSK Scripts'
name 'msk_blackmoney'
description 'MSK Blackmoney Miniheist'
version '1.0'

lua54 'yes'

shared_script {
    '@msk_core/import.lua',
    '@ox_lib/init.lua',
    'config.lua'
}

client_scripts {
    'client.lua'
}

server_scripts {
    'server.lua'
}

dependencies {
    'es_extended',
    'msk_core'
}