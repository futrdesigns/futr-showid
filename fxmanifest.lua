fx_version 'cerulean'
game 'gta5'

author 'futrdesigns'
description 'Simple Player ID Display System for QB Core'
version '1.0.0'

lua54 'yes'

client_scripts {
    'config.lua',
    'client.lua'
}

server_script 'server.lua'

dependencies {
    'qb-core',
    'qb-target'
}
