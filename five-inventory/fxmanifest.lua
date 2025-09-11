fx_version 'cerulean'
game 'gta5'
name 'Five-Inventory'
author 'FiveCore'
version '1.0.0'

ui_page 'html/inventory.html'

files {
    'html/inventory.html',
    'html/inventory.css',
    'html/inventory.js'
}

client_scripts {
    'client/inventory.lua'
}

server_scripts {
    'server/inventory.lua'
}
