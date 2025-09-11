fx_version 'cerulean'
game 'gta5'

author 'FiveCore'
description 'Centro de trabajos moderno para QBCore'
version '1.0.0'

shared_script 'config.lua'

client_scripts {
  'client/main.lua',
  'client/nui.lua'
}

server_script 'server/main.lua'

ui_page 'html/index.html'

files {
  'html/index.html',
  'html/style.css',
  'html/script.js'
}
