const { MongoClient } = require('mongodb');

const MONGO_URI = 'mongodb+srv://poolUser:poolUser123@poolcluster.brghuqk.mongodb.net/bluesense?appName=PoolCluster';

async function checkDatabase() {
  const client = new MongoClient(MONGO_URI);
  
  try {
    await client.connect();
    console.log('✅ Connected to MongoDB Atlas\n');
    
    const db = client.db('bluesense');
    
    // Get all collections
    const collections = await db.listCollections().toArray();
    console.log('📊 Collections found:', collections.length);
    console.log('━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━');
    
    for (const collection of collections) {
      const name = collection.name;
      const col = db.collection(name);
      const count = await col.countDocuments();
      console.log(`\n📋 Collection: ${name}`);
      console.log(`   Count: ${count} documents`);
      
      if (count > 0) {
        const sample = await col.findOne();
        console.log(`   Sample:`, JSON.stringify(sample, null, 2).substring(0, 200) + '...');
      }
    }
    
  } catch (error) {
    console.error('❌ Error:', error.message);
  } finally {
    await client.close();
  }
}

checkDatabase();
