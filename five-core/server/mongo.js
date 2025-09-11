// resources/fivecore/server/mongo.js
const { MongoClient } = require('mongodb');

let db;

on('onResourceStart', async (res) => {
  if (GetCurrentResourceName() !== res) return;
  const uri = GetConvar('fivecore_mongo_uri', 'mongodb://localhost:27017');
  const dbName = GetConvar('fivecore_mongo_db', 'fivecore');

  try {
    const client = new MongoClient(uri);
    await client.connect();
    db = client.db(dbName);
    console.log('[FiveCore][Mongo] Conectado a', uri, 'db:', dbName);

    // Índices recomendados
    await db.collection('nonces').createIndex({ license: 1, nonce: 1 }, { unique: true });
    await db.collection('player_snapshots').createIndex({ license: 1, ts: -1 });
    await db.collection('bans').createIndex({ license: 1 });

    emit('fivecore:mongo:ready');
  } catch (e) {
    console.log('[FiveCore][Mongo] Error conectando:', String(e));
  }
});

// API vía eventos internos (mismo recurso)

onNet('fivecore:mongo:insertAudit', async (entry) => {
  try { await db.collection('audit_logs').insertOne(entry); } catch (e) {}
});

onNet('fivecore:mongo:insertNonce', async (doc) => {
  try {
    await db.collection('nonces').updateOne(
      { license: doc.license, nonce: doc.nonce },
      { $setOnInsert: { ts: doc.ts } },
      { upsert: true }
    );
  } catch (e) {}
});

on('fivecore:mongo:isBanned', async (license, cbEvent, cbId) => {
  try {
    const now = Math.floor(Date.now() / 1000);
    const ban = await db.collection('bans').findOne({
      license,
      $or: [{ until: null }, { until: { $gt: now } }]
    });
    emitNet(cbEvent, cbId, !!ban, ban?.reason || null);
  } catch (e) {
    emitNet(cbEvent, cbId, false, null);
  }
});

onNet('fivecore:mongo:insertPlayerSnapshot', async (doc) => {
  try { await db.collection('player_snapshots').insertOne(doc); } catch (e) {}
});

onNet('fivecore:mongo:ban', async (license, reason, untilTs) => {
  try {
    await db.collection('bans').updateOne(
      { license },
      { $set: { reason: reason || 'ban', until: untilTs || null, createdAt: Math.floor(Date.now()/1000) } },
      { upsert: true }
    );
  } catch (e) {}
});
