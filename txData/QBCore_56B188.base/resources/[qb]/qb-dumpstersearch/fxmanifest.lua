fx_version 'cerulean'
game 'gta5'
lua54 'yes'
author 'Copilot'
description 'Dumpster search interaction for QB-Core'
version '1.0.0'

shared_scripts {
    '@qb-core/shared/locale.lua',
    'locales/en.lua',
    'locales/*.lua',
    'config.lua'
}

dependencies {
    'qb-core',
    'qb-target',
    'qb-inventory',
    'progressbar'
}

client_script 'client.lua'
server_script 'server.lua'
