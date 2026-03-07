fx_version 'cerulean'
games { 'gta5' }

author 'Musiker15 - MSK Scripts'
name 'msk_crafting'
description 'MSK Craftingsystem with NativeUI'
version '2.0.1'

lua54 'yes'

escrow_ignore {
	'config.lua',
	'translation.lua',
	'server_discordlog.lua'
}

shared_scripts {
	'@msk_core/import.lua',
	'config.lua',
	'translation.lua'
}

client_scripts {
	'@NativeUI/NativeUI.lua',
	'client.lua'
}

server_scripts {
	'@oxmysql/lib/MySQL.lua',
	'server.lua',
	'server_discordlog.lua'
}

dependencies {
	'es_extended',
	'oxmysql',
	'msk_core'
}