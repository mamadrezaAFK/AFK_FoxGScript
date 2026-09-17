fx_version 'cerulean'

game 'gta5'

lua54 'yes'

author 'mamadreza AFK'

description 'AFK FoxG Security System'

version '3.2.0'

repository 'https://github.com/mamadrezaAFK'

shared_scripts {
    'config.lua'
}

client_scripts {
    'client/cl_main.lua'
}

server_scripts {
    '@oxmysql/lib/MySQL.lua',
    '@mysql-async/lib/MySQL.lua',
    'server/sv_main.lua'
}

-- dependencies {
--   'es_extended'
-- }
