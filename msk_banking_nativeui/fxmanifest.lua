fx_version 'cerulean'
games { 'gta5' }

author 'Musiker15 - MSK Scripts'
name 'msk_banking'
description 'MSK Advanced Bankingsystem with NativeUI'
version '3.6.5'

lua54 'yes'

escrow_ignore {
	'config.lua',
	'translation.lua',

	-- 'client/main.lua',
	-- 'client/menu.lua',
	'client/functions.lua',
	'client/investment.lua',

	-- 'server/main.lua',
	-- 'server/database.lua',
	-- 'server/sharedaccounts.lua',
	-- 'server/investment.lua',
	'server/functions.lua',
	'server/discordlog.lua'
}

shared_scripts {
	'@es_extended/imports.lua',
	'@msk_core/import.lua',
	'translation.lua',
	'config.lua'
}

client_scripts {
	'@NativeUI/NativeUI.lua',
	'client/**/*.*'
}

server_scripts {
	'@oxmysql/lib/MySQL.lua',
	'server/**/*.*'
}

dependencies {
	'es_extended',
	'oxmysql',
	'msk_core',
	'NativeUI'
}