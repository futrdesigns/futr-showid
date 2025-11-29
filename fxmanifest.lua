fx_version 'cerulean'
game 'gta5'

author 'futrdesigns'
description 'Simple Player ID Display System for QB Core with OX Target'
version '1.1.0'

lua54 'yes'

client_scripts {
    'config.lua',
    'client.lua'
}

server_script 'server.lua'

dependencies {
    'qb-core',
    'ox_target',
    'ox_lib'
}

shared_script '@ox_lib/init.lua'
