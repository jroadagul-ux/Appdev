const { MongoClient } = require('mongodb');

const MONGO_URI = 'mongodb+srv://poolUser:poolUser123@poolcluster.brghuqk.mongodb.net/bluesense?appName=PoolCluster';

async function setupAdminUser() {
  const client = new MongoClient(MONGO_URI);
  
  try {
    await client.connect();
    console.log('✅ Connected to MongoDB Atlas');
    
    const db = client.db('bluesense');
    const usersCollection = db.collection('users');
    
    // Check if admin already exists
    const existingAdmin = await usersCollection.findOne({ email: 'admin@bluesense.com' });
    
    if (existingAdmin) {
      console.log('⚠️  Admin user already exists');
      await client.close();
      return;
    }
    
    // Create admin user
    const result = await usersCollection.insertOne({
      email: 'admin@bluesense.com',
      password: 'admin123', // TODO: Hash in production
      name: 'Admin User',
      phone: '+1234567890',
      role: 'admin',
      createdAt: new Date(),
    });
    
    console.log('✅ Admin user created successfully');
    console.log('📧 Email: admin@bluesense.com');
    console.log('🔐 Password: admin123');
    console.log('👤 Role: admin');
    console.log('ID:', result.insertedId.toString());
    
  } catch (error) {
    console.error('❌ Error:', error.message);
  } finally {
    await client.close();
  }
}

setupAdminUser();
