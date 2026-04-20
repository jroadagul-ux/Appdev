const { MongoClient } = require('mongodb');
const bcrypt = require('bcryptjs');

const MONGO_URI = 'mongodb+srv://poolUser:poolUser123@poolcluster.brghuqk.mongodb.net/bluesense?appName=PoolCluster';

async function verifyUser() {
  const client = new MongoClient(MONGO_URI);
  
  try {
    await client.connect();
    console.log('✅ Connected to MongoDB Atlas');
    
    const db = client.db('bluesense');
    const usersCollection = db.collection('users');
    
    // Find the admin user
    const admin = await usersCollection.findOne({ email: 'admin@bluesense.com' });
    
    if (admin) {
      console.log('\n✅ Admin user found in database:');
      console.log('━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━');
      console.log('Email:', admin.email);
      console.log('Password Hash:', admin.password);
      console.log('Name:', admin.name);
      console.log('Role:', admin.role);
      console.log('ID:', admin._id.toString());
      console.log('━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━');
      
      // Test login with bcrypt
      const passwordMatch = await bcrypt.compare('admin123', admin.password);
      
      if (passwordMatch) {
        console.log('\n✅ ✅ ✅ Login credentials are CORRECT! ✅ ✅ ✅');
        console.log('The user can successfully login with:');
        console.log('  📧 Email: admin@bluesense.com');
        console.log('  🔐 Password: admin123');
        console.log('\n✅ Password hashing is working properly!');
      } else {
        console.log('\n❌ Login failed - password does not match');
      }
    } else {
      console.log('❌ Admin user not found in database');
      
      // List all users
      const allUsers = await usersCollection.find({}).toArray();
      console.log('\nAll users in database:', allUsers.length);
      allUsers.forEach(u => console.log('  - ', u.email));
    }
    
  } catch (error) {
    console.error('❌ Error:', error.message);
  } finally {
    await client.close();
  }
}

verifyUser();
