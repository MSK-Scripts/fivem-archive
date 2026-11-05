fx_version 'cerulean'
games { 'gta5' }

author 'Musiker15 - MSK Scripts'
name 'msk_radio'
description 'Radio System'
version '1.0.2'

lua54 'yes'

escrow_ignore {
	'config.lua',
	'translation.lua',

    'client/client.lua',
    -- 'client/client_functions.lua',
    'server/server.lua',
    -- 'server/server_functions.lua',
}

shared_script {
    '@es_extended/imports.lua',
    '@msk_core/import.lua',
    'config.lua',
    'translation.lua'
}

client_scripts {
	'client/**/*.*',
}

server_scripts {
	'server/**/*.*',
}

ui_page 'html/index.html'

files {
	"html/**/*.*"
}

dependencies {
	'es_extended',
    'msk_core'
}