fx_version 'adamant'

game 'gta5'

ui_page 'web/build/index.html' 

ui_page_preload 'yes'

files {
    'config/shared/*.lua',
    'web/build/*.*',
    'web/build/**/*.*'
}

dependencies {
    '/onesync',
    '/server:2843'
}

server_scripts {
    'token.lua'
}

server_script '_server.lua'
client_script '_client.lua'