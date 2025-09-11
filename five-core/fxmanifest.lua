fx_version 'cerulean'
game 'gta5'
name 'five-core'
author 'FiveCore'
version '1.0.0'

shared_scripts {
  'shared/config.lua',
  'shared/util.lua'
}

server_scripts {
  'server/rate_limit.lua',
  'server/locks.lua',
  'server/nonces.lua',
  'server/audit.lua',
  'server/perms.lua',
  'server/entities.lua',
  'server/security.lua',
  'server/players.lua',
  'server/economy.lua',
  'server/inventory.lua',
  'server/weapons.lua',
  'server/main.lua',
  'server/mongo.js'.
  'server/mongo_setup.js'      -- js runtime del core para Mongo
}

client_scripts {
  'client/main.lua',
  'client/anti_npc.lua',
  'client/inventory.lua',
  'client/weapons.lua'
}


