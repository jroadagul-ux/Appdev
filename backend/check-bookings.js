const { MongoClient } = require('mongodb');

const MONGO_URI = 'mongodb+srv://poolUser:poolUser123@poolcluster.brghuqk.mongodb.net/bluesense?appName=PoolCluster';

async function checkBookings() {
  const client = new MongoClient(MONGO_URI);
  
  try {
    await client.connect();
    const db = client.db('bluesense');
    
    // Check all collections that might have booking-like data
    const collections = ['bookings', 'reservations', 'taskassignments'];
    
    for (const collName of collections) {
      const col = db.collection(collName);
      const count = await col.countDocuments();
      console.log(`\n📋 Collection: ${collName}`);
      console.log(`   Count: ${count} documents`);
      
      if (count > 0) {
        const docs = await col.find({}).limit(2).toArray();
        console.log(`   Sample documents:`);
        docs.forEach((doc, i) => {
          console.log(`   [${i}]:`, JSON.stringify(doc, null, 2).substring(0, 300));
        });
      }
    }
    
  } catch (error) {
    console.error('❌ Error:', error.message);
  } finally {
    await client.close();
  }
}

checkBookings();
