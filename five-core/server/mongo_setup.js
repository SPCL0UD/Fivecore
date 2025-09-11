// resources/fivecore/server/mongo_setup.js
const { MongoClient } = require('mongodb');

on('onResourceStart', async (res) => {
  if (GetCurrentResourceName() !== res) return;

  const uri = GetConvar('fivecore_mongo_uri', 'mongodb://localhost:27017');
  const dbName = GetConvar('fivecore_mongo_db', 'fivecore');

  try {
    const client = new MongoClient(uri);
    await client.connect();
    const db = client.db(dbName);

    console.log(`[FiveCore][MongoSetup] Conectado a ${uri}, base: ${dbName}`);

    // 1️⃣ audit_logs
    await db.createCollection('audit_logs', {
      validator: {
        $jsonSchema: {
          bsonType: 'object',
          required: ['ts', 'license', 'category', 'action'],
          properties: {
            ts: { bsonType: 'int' },
            license: { bsonType: 'string' },
            category: { bsonType: 'string' },
            action: { bsonType: 'string' },
            payload: {}
          }
        }
      }
    }).catch(() => {});
    await db.collection('audit_logs').createIndex({ license: 1, ts: -1 });

    // 2️⃣ nonces
    await db.createCollection('nonces', {
      validator: {
        $jsonSchema: {
          bsonType: 'object',
          required: ['license', 'nonce', 'ts'],
          properties: {
            license: { bsonType: 'string' },
            nonce: { bsonType: 'string' },
            ts: { bsonType: 'int' }
          }
        }
      }
    }).catch(() => {});
    await db.collection('nonces').createIndex({ license: 1, nonce: 1 }, { unique: true });
    await db.collection('nonces').createIndex({ ts: 1 }, { expireAfterSeconds: 600 }); // TTL 10 min

    // 3️⃣ bans
    await db.createCollection('bans', {
      validator: {
        $jsonSchema: {
          bsonType: 'object',
          required: ['license', 'reason', 'createdAt'],
          properties: {
            license: { bsonType: 'string' },
            reason: { bsonType: 'string' },
            until: { bsonType: ['int', 'null'] },
            createdAt: { bsonType: 'int' }
          }
        }
      }
    }).catch(() => {});
    await db.collection('bans').createIndex({ license: 1 });

    // 4️⃣ player_snapshots
    await db.createCollection('player_snapshots', {
      validator: {
        $jsonSchema: {
          bsonType: 'object',
          required: ['license', 'ts', 'data'],
          properties: {
            license: { bsonType: 'string' },
            ts: { bsonType: 'int' },
            data: { bsonType: 'object' }
          }
        }
      }
    }).catch(() => {});
    await db.collection('player_snapshots').createIndex({ license: 1, ts: -1 });

    // 5️⃣ config (opcional)
    await db.createCollection('config', {
      validator: {
        $jsonSchema: {
          bsonType: 'object',
          required: ['key', 'value'],
          properties: {
            key: { bsonType: 'string' },
            value: {}
          }
        }
      }
    }).catch(() => {});
    await db.collection('config').createIndex({ key: 1 }, { unique: true });

    console.log('[FiveCore][MongoSetup] Colecciones e índices listos.');
    await client.close();
  } catch (e) {
    console.error('[FiveCore][MongoSetup] Error:', e);
  }
});
