fx_version 'cerulean'
game 'gta5'

author 'FiveCore'
description 'Trabajo de taxista con niveles, clientes VIP y paparazzis'
version '1.0.0'

shared_scripts {
  'config.lua'
}

client_scripts {
  'client/main.lua'
}

server_scripts {
  'server/main.lua'
}

ui_page 'html/taxi.html'

files {
  'html/taxi.html',
  'html/taxi.css',
  'html/taxi.js'
}
