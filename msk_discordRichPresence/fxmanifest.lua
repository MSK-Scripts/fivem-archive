fx_version 'adamant'
games { 'gta5' }

author 'Musiker15 - MSK Scripts'
name 'msk_discordRichPresence'
description 'Displays some Information about your Server'
version '1.0'

shared_scripts {
    '@msk_core/import.lua',
    'config.lua'
}

client_scripts {
    'client.lua'
}

server_scripts {
    'server.lua'
}

dependencies {
	'msk_core'
}