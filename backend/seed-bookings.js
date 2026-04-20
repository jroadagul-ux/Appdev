const { MongoClient } = require('mongodb');

const MONGO_URI = 'mongodb+srv://poolUser:poolUser123@poolcluster.brghuqk.mongodb.net/bluesense?appName=PoolCluster';

async function seedBookings() {
  const client = new MongoClient(MONGO_URI);
  
  try {
    await client.connect();
    const db = client.db('bluesense');
    const bookingsCol = db.collection('bookings');
    
    // Check if bookings already exist
    const count = await bookingsCol.countDocuments();
    if (count > 0) {
      console.log('❌ Bookings already exist. Skipping...');
      await client.close();
      return;
    }
    
    // Create sample bookings
    const sampleBookings = [
      {
        customerName: 'John Doe',
        customerContact: '+1234567890',
        customerEmail: 'john@example.com',
        oasis: 'Villa 1',
        package: 'Premium',
        bookingDate: new Date('2024-05-01'),
        pax: 4,
        downpayment: 5000,
        paymentMethod: 'Credit Card',
        paymentStatus: 'Completed',
        status: 'Confirmed',
        createdAt: new Date(),
      },
      {
        customerName: 'Jane Smith',
        customerContact: '+0987654321',
        customerEmail: 'jane@example.com',
        oasis: 'Villa 2',
        package: 'Standard',
        bookingDate: new Date('2024-05-15'),
        pax: 2,
        downpayment: 3000,
        paymentMethod: 'Bank Transfer',
        paymentStatus: 'Pending',
        status: 'Pending',
        createdAt: new Date(),
      },
      {
        customerName: 'Michael Brown',
        customerContact: '+1122334455',
        customerEmail: 'michael@example.com',
        oasis: 'Villa 3',
        package: 'Deluxe',
        bookingDate: new Date('2024-06-01'),
        pax: 6,
        downpayment: 8000,
        paymentMethod: 'Cash',
        paymentStatus: 'Completed',
        status: 'Confirmed',
        createdAt: new Date(),
      },
      {
        customerName: 'Sarah Johnson',
        customerContact: '+5566778899',
        customerEmail: 'sarah@example.com',
        oasis: 'Villa 1',
        package: 'Standard',
        bookingDate: new Date('2024-06-10'),
        pax: 3,
        downpayment: 2500,
        paymentMethod: 'Credit Card',
        paymentStatus: 'Completed',
        status: 'Confirmed',
        createdAt: new Date(),
      },
    ];
    
    const result = await bookingsCol.insertMany(sampleBookings);
    console.log('✅ Sample bookings created successfully!');
    console.log(`📊 Inserted ${result.insertedIds.length} bookings`);
    console.log('IDs:', Object.values(result.insertedIds).map(id => id.toString()));
    
  } catch (error) {
    console.error('❌ Error:', error.message);
  } finally {
    await client.close();
  }
}

seedBookings();
