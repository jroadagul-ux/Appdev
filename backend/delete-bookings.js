const { MongoClient } = require('mongodb');

const MONGO_URI = 'mongodb+srv://poolUser:poolUser123@poolcluster.brghuqk.mongodb.net/bluesense?appName=PoolCluster';

async function deleteBookings() {
  const client = new MongoClient(MONGO_URI);
  
  try {
    await client.connect();
    const db = client.db('bluesense');
    const bookingsCol = db.collection('bookings');
    
    const result = await bookingsCol.deleteMany({});
    console.log(`✅ Deleted ${result.deletedCount} bookings`);
    
  } catch (error) {
    console.error('❌ Error:', error.message);
  } finally {
    await client.close();
  }
}

deleteBookings();
