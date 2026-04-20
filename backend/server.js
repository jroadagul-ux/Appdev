const express = require('express');
const cors = require('cors');
const { MongoClient, ObjectId } = require('mongodb');
const bcrypt = require('bcryptjs');
const jwt = require('jsonwebtoken');
require('dotenv').config();

const app = express();

// Middleware
app.use(cors());
app.use(express.json());

// MongoDB Connection
const MONGO_URI = 'mongodb+srv://poolUser:poolUser123@poolcluster.brghuqk.mongodb.net/bluesense?appName=PoolCluster';
let db;
let usersCollection, bookingsCollection, roomsCollection, staffCollection, inventoryCollection;

// In-memory session storage for bookings (when DB is unavailable)
let sessionBookings = [];

const connectDB = async () => {
  try {
    const client = new MongoClient(MONGO_URI, { maxPoolSize: 10 });
    await client.connect();
    db = client.db('bluesense');
    
    // Initialize collections
    usersCollection = db.collection('users');
    bookingsCollection = db.collection('bookings');
    roomsCollection = db.collection('rooms');
    staffCollection = db.collection('staff');
    inventoryCollection = db.collection('inventory');
    
    console.log('✅ Connected to MongoDB Atlas');
    return true;
  } catch (error) {
    console.log('❌ MongoDB Connection Error:', error.message);
    console.log('💾 Running with mock data only');
    return false;
  }
};

// Helper function for mock responses
const sendMock = (res, endpoint, statusCode = 200) => {
  const mocks = {
    register: { success: true, message: 'User registered successfully', userId: 'user_123', token: 'mock_token' },
    login: { success: true, message: 'Login successful', token: 'mock_token', user: { id: 'user_123', email: 'test@example.com', name: 'Test User', role: 'customer' } },
    bookings: { 
      success: true, 
      bookings: [
        {
          _id: 'booking_1',
          customerName: 'John Doe',
          customerContact: '+1234567890',
          customerEmail: 'john@example.com',
          oasis: 'Oasis Paradise',
          package: 'Family Package',
          bookingDate: new Date().toISOString(),
          session: 'Morning',
          pax: 4,
          downpayment: 2500,
          paymentMethod: 'Credit Card',
          paymentStatus: 'Pending',
          status: 'Pending',
          createdAt: new Date().toISOString(),
        },
        {
          _id: 'booking_2',
          customerName: 'Jane Smith',
          customerContact: '+0987654321',
          customerEmail: 'jane@example.com',
          oasis: 'Tropical Haven',
          package: 'Couple Package',
          bookingDate: new Date().toISOString(),
          session: 'Afternoon',
          pax: 2,
          downpayment: 1500,
          paymentMethod: 'Debit Card',
          paymentStatus: 'Confirmed',
          status: 'Confirmed',
          createdAt: new Date().toISOString(),
        }
      ] 
    },
    rooms: { success: true, rooms: [] },
    stats: { success: true, stats: { totalBookings: 150, totalRevenue: 50000, totalGuests: 300, occupancyRate: 75.5 } },
  };
  res.status(statusCode).json(mocks[endpoint] || { success: true });
};

// ===== AUTH ROUTES =====

// Register
app.post('/api/auth/register', async (req, res) => {
  try {
    const { email, password, name, phone } = req.body;
    
    if (!db) return sendMock(res, 'register', 201);
    
    const existingUser = await usersCollection.findOne({ email });
    if (existingUser) {
      return res.status(400).json({ success: false, message: 'User already exists' });
    }
    
    // Hash password with bcrypt
    const hashedPassword = await bcrypt.hash(password, 10);
    
    const newUser = {
      email,
      password: hashedPassword,
      name: name || 'User',
      phone: phone || '',
      role: 'customer',
      createdAt: new Date(),
    };
    
    const result = await usersCollection.insertOne(newUser);
    res.status(201).json({
      success: true,
      message: 'User registered successfully',
      userId: result.insertedId.toString(),
      token: 'mock_token_' + Date.now(),
    });
  } catch (error) {
    console.error('Register error:', error);
    res.status(500).json({ success: false, message: 'Registration failed', error: error.message });
  }
});

// Login
app.post('/api/auth/login', async (req, res) => {
  try {
    const { email, password } = req.body;
    
    if (!db) return sendMock(res, 'login', 200);
    
    const user = await usersCollection.findOne({ email });
    if (!user) {
      return res.status(401).json({ success: false, message: 'Invalid email or password' });
    }
    
    // Compare password with bcrypt hash
    const passwordMatch = await bcrypt.compare(password, user.password);
    if (!passwordMatch) {
      return res.status(401).json({ success: false, message: 'Invalid email or password' });
    }
    
    res.json({
      success: true,
      message: 'Login successful',
      token: 'mock_token_' + Date.now(),
      user: {
        id: user._id.toString(),
        email: user.email,
        name: user.name,
        role: user.role,
      },
    });
  } catch (error) {
    console.error('Login error:', error);
    res.status(500).json({ success: false, message: 'Login failed', error: error.message });
  }
});

// Forgot Password
app.post('/api/auth/forgot-password', async (req, res) => {
  try {
    res.json({ success: true, message: 'Password reset link sent to email' });
  } catch (error) {
    res.status(500).json({ success: false, message: 'Error sending reset link' });
  }
});

// Get Profile
app.get('/api/auth/profile', async (req, res) => {
  try {
    res.json({
      success: true,
      user: {
        id: 'user_123',
        email: 'user@example.com',
        name: 'Test User',
        phone: '+1234567890',
        role: 'customer',
      },
    });
  } catch (error) {
    res.status(500).json({ success: false, message: 'Error fetching profile' });
  }
});

// ===== BOOKING ROUTES =====

// Get all bookings
app.get('/api/bookings', async (req, res) => {
  try {
    if (!db) {
      // Return session bookings when DB is unavailable
      return res.json({
        success: true,
        bookings: sessionBookings.map(b => ({
          id: b._id,
          _id: b._id,
          customerName: b.customerName,
          customerContact: b.customerContact,
          customerEmail: b.customerEmail,
          oasis: b.oasis,
          package: b.package,
          bookingDate: b.bookingDate,
          session: b.session,
          pax: b.pax,
          downpayment: b.downpayment,
          paymentMethod: b.paymentMethod,
          paymentStatus: b.paymentStatus,
          status: b.status,
          createdAt: b.createdAt,
        })),
      });
    }
    
    const bookings = await bookingsCollection.find({}).toArray();
    res.json({
      success: true,
      bookings: bookings.map(b => ({
        id: b._id.toString(),
        customerName: b.customerName,
        customerContact: b.customerContact,
        customerEmail: b.customerEmail,
        oasis: b.oasis,
        package: b.package,
        bookingDate: b.bookingDate,
        pax: b.pax,
        downpayment: b.downpayment,
        paymentMethod: b.paymentMethod,
        paymentStatus: b.paymentStatus,
        status: b.status,
        createdAt: b.createdAt,
      })),
    });
  } catch (error) {
    console.error('Get bookings error:', error);
    res.status(500).json({ success: false, message: 'Error fetching bookings' });
  }
});

// Create booking
app.post('/api/bookings', async (req, res) => {
  try {
    console.log('\n📥 Booking request received:', JSON.stringify(req.body, null, 2));
    
    const { userId, customerName, customerContact, customerEmail, oasis, package: packageName, bookingDate, session, pax, downpayment, paymentMethod, addons } = req.body;
    
    // Validate required fields
    if (!customerName || !customerContact || !oasis || !packageName || !bookingDate) {
      console.log('❌ Validation failed - Missing fields:', { customerName, customerContact, oasis, packageName, bookingDate });
      return res.status(400).json({
        success: false,
        message: 'Missing required fields: customerName, customerContact, oasis, package, bookingDate',
      });
    }
    
    console.log('✅ Validation passed');
    console.log('Database connected:', !!db);
    
    if (!db) {
      // Store in session memory when DB is unavailable
      const bookingId = 'booking_' + Date.now().toString();
      const bookingRecord = {
        _id: bookingId,
        userId: userId || null,
        customerName: customerName.trim(),
        customerContact: customerContact.trim(),
        customerEmail: customerEmail?.trim() || null,
        oasis,
        package: packageName,
        bookingDate: new Date(bookingDate).toISOString(),
        session,
        pax: parseInt(pax) || 1,
        downpayment: parseFloat(downpayment) || 0,
        paymentMethod,
        addons: addons || [],
        status: 'Pending',
        paymentStatus: 'Pending',
        createdAt: new Date().toISOString(),
      };
      sessionBookings.push(bookingRecord);
      console.log('📝 Booking saved to session memory:', bookingRecord);
      
      return res.status(201).json({
        success: true,
        message: 'Booking created successfully',
        _id: bookingId,
        booking: bookingRecord,
      });
    }
    
    const bookingRecord = {
      userId: userId || null,
      customerName: customerName.trim(),
      customerContact: customerContact.trim(),
      customerEmail: customerEmail?.trim() || null,
      oasis,
      package: packageName,
      bookingDate: new Date(bookingDate),
      session,
      pax: parseInt(pax) || 1,
      downpayment: parseFloat(downpayment) || 0,
      paymentMethod,
      addons: addons || [],
      status: 'Pending',
      paymentStatus: 'Pending',
      createdAt: new Date(),
    };
    
    console.log('💾 Saving to database:', bookingRecord);
    const result = await bookingsCollection.insertOne(bookingRecord);
    console.log('✅ Booking saved to MongoDB with ID:', result.insertedId.toString());
    
    res.status(201).json({
      success: true,
      message: 'Booking created successfully',
      _id: result.insertedId.toString(),
      booking: { ...bookingRecord, _id: result.insertedId.toString() },
    });
  } catch (error) {
    console.error('❌ Create booking error:', error);
    console.error('Error stack:', error.stack);
    res.status(500).json({ success: false, message: 'Error creating booking: ' + error.message });
  }
});

// Get booking by ID
app.get('/api/bookings/:id', async (req, res) => {
  try {
    if (!db) return res.json({ success: true, booking: {} });
    
    const booking = await bookingsCollection.findOne({ _id: new ObjectId(req.params.id) });
    if (!booking) {
      return res.status(404).json({ success: false, message: 'Booking not found' });
    }
    
    res.json({
      success: true,
      booking: {
        id: booking._id.toString(),
        roomId: booking.roomId,
        userId: booking.userId,
        checkInDate: booking.checkInDate,
        checkOutDate: booking.checkOutDate,
        status: booking.status,
        totalPrice: booking.totalPrice,
      },
    });
  } catch (error) {
    res.status(500).json({ success: false, message: 'Error fetching booking' });
  }
});

// Update booking status
app.put('/api/bookings/:id/status', async (req, res) => {
  try {
    if (!db) return res.json({ success: true, message: 'Booking status updated' });
    
    await bookingsCollection.updateOne(
      { _id: new ObjectId(req.params.id) },
      { $set: { status: req.body.status } }
    );
    
    res.json({ success: true, message: 'Booking status updated' });
  } catch (error) {
    res.status(500).json({ success: false, message: 'Error updating booking' });
  }
});

// Process payment
app.post('/api/bookings/:id/payment', async (req, res) => {
  try {
    if (!db) return res.json({ success: true, message: 'Payment processed', transactionId: 'txn_' + Date.now() });
    
    await bookingsCollection.updateOne(
      { _id: new ObjectId(req.params.id) },
      { $set: { status: 'confirmed' } }
    );
    
    res.json({
      success: true,
      message: 'Payment processed successfully',
      transactionId: 'txn_' + Date.now(),
    });
  } catch (error) {
    res.status(500).json({ success: false, message: 'Error processing payment' });
  }
});

// ===== ADMIN ROUTES =====

// Admin Dashboard Stats
app.get('/api/admin/dashboard/stats', async (req, res) => {
  try {
    if (!db) return sendMock(res, 'stats', 200);
    
    const totalBookings = await bookingsCollection.countDocuments();
    const totalUsers = await usersCollection.countDocuments();
    const totalStaff = await db.collection('staffs').countDocuments();
    const totalInventory = await db.collection('inventories').countDocuments();
    
    res.json({
      success: true,
      totalReservations: totalBookings,
      availableRooms: 5,
      maintainanceRooms: 0,
      activeStaff: totalStaff,
      monthlyRevenue: 50000,
      lowStockItems: 0,
    });
  } catch (error) {
    console.error('Dashboard stats error:', error);
    res.status(500).json({ success: false, message: 'Error fetching dashboard stats' });
  }
});

// Admin Dashboard Daily Chart
app.get('/api/admin/dashboard/daily-chart', async (req, res) => {
  try {
    res.json({
      success: true,
      data: [
        { date: '2024-01-01', bookings: 10, revenue: 5000 },
        { date: '2024-01-02', bookings: 12, revenue: 6000 },
      ],
    });
  } catch (error) {
    res.status(500).json({ success: false, message: 'Error fetching daily chart' });
  }
});

// Admin Dashboard Monthly Chart
app.get('/api/admin/dashboard/monthly-chart', async (req, res) => {
  try {
    res.json({
      success: true,
      data: [
        { month: 'January', bookings: 100, revenue: 50000 },
        { month: 'February', bookings: 120, revenue: 60000 },
      ],
    });
  } catch (error) {
    res.status(500).json({ success: false, message: 'Error fetching monthly chart' });
  }
});

// Get all rooms
app.get('/api/admin/rooms', async (req, res) => {
  try {
    if (!db) return sendMock(res, 'rooms', 200);
    
    const rooms = await roomsCollection.find({}).toArray();
    res.json({
      success: true,
      rooms: rooms.map(r => ({
        id: r._id.toString(),
        name: r.name,
        capacity: r.capacity,
        pricePerNight: r.pricePerNight,
        status: r.status,
      })),
    });
  } catch (error) {
    res.status(500).json({ success: false, message: 'Error fetching rooms' });
  }
});

// Create room
app.post('/api/admin/rooms', async (req, res) => {
  try {
    if (!db) return res.status(201).json({ success: true, message: 'Room created' });
    
    const result = await roomsCollection.insertOne(req.body);
    res.status(201).json({ success: true, message: 'Room created successfully', roomId: result.insertedId.toString() });
  } catch (error) {
    res.status(500).json({ success: false, message: 'Error creating room' });
  }
});

// Get room by ID
app.get('/api/admin/rooms/:id', async (req, res) => {
  try {
    if (!db) return res.json({ success: true, room: {} });
    
    const room = await roomsCollection.findOne({ _id: new ObjectId(req.params.id) });
    res.json({ success: true, room });
  } catch (error) {
    res.status(500).json({ success: false, message: 'Error fetching room' });
  }
});

// Get all staff
app.get('/api/admin/staff', async (req, res) => {
  try {
    if (!db) return res.json({ success: true, staff: [] });
    
    const staffCollection = db.collection('staffs');
    const staff = await staffCollection.find({}).toArray();
    res.json({
      success: true,
      staff: staff.map(s => ({
        id: s._id.toString(),
        staffId: s.staffId,
        name: s.name,
        email: s.email,
        position: s.position,
        role: s.role,
        status: s.status,
        phone: s.phone,
      })),
    });
  } catch (error) {
    console.error('Get staff error:', error);
    res.status(500).json({ success: false, message: 'Error fetching staff' });
  }
});

// Create staff
app.post('/api/admin/staff', async (req, res) => {
  try {
    if (!db) return res.status(201).json({ success: true, message: 'Staff created' });
    
    const result = await staffCollection.insertOne(req.body);
    res.status(201).json({ success: true, message: 'Staff member added', staffId: result.insertedId.toString() });
  } catch (error) {
    res.status(500).json({ success: false, message: 'Error creating staff' });
  }
});

// Get staff by ID
app.get('/api/admin/staff/:id', async (req, res) => {
  try {
    if (!db) return res.json({ success: true, staff: {} });
    
    const staff = await staffCollection.findOne({ _id: new ObjectId(req.params.id) });
    res.json({ success: true, staff });
  } catch (error) {
    res.status(500).json({ success: false, message: 'Error fetching staff' });
  }
});

// Get inventory
app.get('/api/admin/inventory', async (req, res) => {
  try {
    if (!db) return res.json({ success: true, inventory: [] });
    
    const inventoryCollection = db.collection('inventories');
    const inventory = await inventoryCollection.find({}).toArray();
    res.json({
      success: true,
      inventory: inventory.map(item => ({
        id: item._id.toString(),
        itemId: item.itemId,
        item: item.item,
        quantity: item.quantity,
        unit: item.unit,
        lowStockAlert: item.lowStockAlert,
        createdAt: item.createdAt,
      })),
    });
  } catch (error) {
    console.error('Get inventory error:', error);
    res.status(500).json({ success: false, message: 'Error fetching inventory' });
  }
});

// Create inventory item
app.post('/api/admin/inventory', async (req, res) => {
  try {
    if (!db) return res.status(201).json({ success: true, message: 'Inventory created' });
    
    const result = await inventoryCollection.insertOne(req.body);
    res.status(201).json({ success: true, message: 'Inventory item created', itemId: result.insertedId.toString() });
  } catch (error) {
    res.status(500).json({ success: false, message: 'Error creating inventory item' });
  }
});

// Get inventory by ID
app.get('/api/admin/inventory/:id', async (req, res) => {
  try {
    if (!db) return res.json({ success: true, inventory: {} });
    
    const item = await inventoryCollection.findOne({ _id: new ObjectId(req.params.id) });
    res.json({ success: true, inventory: item });
  } catch (error) {
    res.status(500).json({ success: false, message: 'Error fetching inventory item' });
  }
});

// Use inventory
app.post('/api/admin/inventory/:id/use', async (req, res) => {
  try {
    if (!db) return res.json({ success: true, message: 'Inventory updated' });
    
    res.json({ success: true, message: 'Inventory updated' });
  } catch (error) {
    res.status(500).json({ success: false, message: 'Error updating inventory' });
  }
});

// Get admin bookings
app.get('/api/admin/bookings', async (req, res) => {
  try {
    if (!db) {
      // Return session bookings merged with mock data when DB is unavailable
      const mockBookings = [
        {
          _id: 'booking_1',
          customerName: 'John Doe',
          customerContact: '+1234567890',
          customerEmail: 'john@example.com',
          oasis: 'Oasis Paradise',
          package: 'Family Package',
          bookingDate: new Date().toISOString(),
          session: 'Morning',
          pax: 4,
          downpayment: 2500,
          paymentMethod: 'Credit Card',
          paymentStatus: 'Pending',
          status: 'Pending',
          createdAt: new Date().toISOString(),
        },
        {
          _id: 'booking_2',
          customerName: 'Jane Smith',
          customerContact: '+0987654321',
          customerEmail: 'jane@example.com',
          oasis: 'Tropical Haven',
          package: 'Couple Package',
          bookingDate: new Date().toISOString(),
          session: 'Afternoon',
          pax: 2,
          downpayment: 1500,
          paymentMethod: 'Debit Card',
          paymentStatus: 'Confirmed',
          status: 'Confirmed',
          createdAt: new Date().toISOString(),
        }
      ];
      
      // Combine mock data with session bookings
      const allBookings = [...mockBookings, ...sessionBookings];
      return res.json({ success: true, bookings: allBookings });
    }
    
    const bookings = await bookingsCollection.find({}).toArray();
    res.json({ success: true, bookings });
  } catch (error) {
    res.status(500).json({ success: false, message: 'Error fetching bookings' });
  }
});

// Get sales by period
app.get('/api/admin/sales/:period', async (req, res) => {
  try {
    if (!db) {
      return res.json({ 
        success: true, 
        sales: [
          { date: '2024-01-01', amount: 5000, count: 10 },
          { date: '2024-01-02', amount: 6000, count: 12 },
          { date: '2024-01-03', amount: 5500, count: 11 },
        ], 
        total: 16500,
        totalSales: 16500
      });
    }

    const { period } = req.params;
    const now = new Date();
    let startDate = new Date();
    
    // Calculate date range based on period
    switch(period) {
      case 'daily':
        startDate.setDate(now.getDate() - 7);
        break;
      case 'weekly':
        startDate.setDate(now.getDate() - 30);
        break;
      case 'monthly':
        startDate.setMonth(now.getMonth() - 12);
        break;
      default:
        startDate.setDate(now.getDate() - 7);
    }

    const bookings = await bookingsCollection.find({
      bookingDate: { $gte: startDate.toISOString() }
    }).toArray();

    const sales = bookings.map(b => ({
      date: new Date(b.bookingDate).toISOString().split('T')[0],
      customerName: b.customerName,
      amount: b.downpayment || 0,
      package: b.package,
      oasis: b.oasis,
      status: b.paymentStatus
    }));

    const total = sales.reduce((sum, s) => sum + (s.amount || 0), 0);

    res.json({ 
      success: true, 
      sales, 
      total,
      totalSales: total,
      data: sales
    });
  } catch (error) {
    console.error('Sales fetch error:', error);
    res.status(500).json({ success: false, message: 'Error fetching sales' });
  }
});

// Get sales (default)
app.get('/api/admin/sales', async (req, res) => {
  try {
    res.json({ success: true, sales: [{ date: '2024-01-01', amount: 5000, count: 10 }] });
  } catch (error) {
    res.status(500).json({ success: false, message: 'Error fetching sales' });
  }
});

// Get reservations
app.get('/api/admin/reservations', async (req, res) => {
  try {
    if (!db) return res.json({ success: true, reservations: [] });
    
    const reservations = await bookingsCollection.find({}).toArray();
    res.json({ success: true, reservations });
  } catch (error) {
    res.status(500).json({ success: false, message: 'Error fetching reservations' });
  }
});

// ===== REPORTS ENDPOINTS =====

// Reservation Report
app.get('/api/admin/reports/reservation', async (req, res) => {
  try {
    const { startDate, endDate } = req.query;
    let query = {};
    
    if (startDate || endDate) {
      query.bookingDate = {};
      if (startDate) query.bookingDate.$gte = new Date(startDate).toISOString();
      if (endDate) {
        const end = new Date(endDate);
        end.setDate(end.getDate() + 1);
        query.bookingDate.$lt = end.toISOString();
      }
    }
    
    if (!db) {
      return res.json({ 
        success: true, 
        reservations: [],
        total: 0
      });
    }

    const reservations = await bookingsCollection.find(query).toArray();
    res.json({ 
      success: true, 
      reservations,
      total: reservations.length
    });
  } catch (error) {
    console.error('Report error:', error);
    res.status(500).json({ success: false, message: 'Error generating report' });
  }
});

// Sales Report
app.get('/api/admin/reports/sales', async (req, res) => {
  try {
    const { startDate, endDate } = req.query;
    let query = {};
    
    if (startDate || endDate) {
      query.bookingDate = {};
      if (startDate) query.bookingDate.$gte = new Date(startDate).toISOString();
      if (endDate) {
        const end = new Date(endDate);
        end.setDate(end.getDate() + 1);
        query.bookingDate.$lt = end.toISOString();
      }
    }
    
    if (!db) {
      return res.json({ 
        success: true, 
        sales: [],
        totalSales: 0
      });
    }

    const bookings = await bookingsCollection.find(query).toArray();
    const sales = bookings.map(b => ({
      _id: b._id,
      date: b.bookingDate,
      customerName: b.customerName,
      oasis: b.oasis,
      package: b.package,
      amount: b.downpayment || 0,
      paymentStatus: b.paymentStatus
    }));
    
    const totalSales = sales.reduce((sum, s) => sum + (s.amount || 0), 0);
    
    res.json({ 
      success: true, 
      sales,
      totalSales,
      total: totalSales
    });
  } catch (error) {
    console.error('Report error:', error);
    res.status(500).json({ success: false, message: 'Error generating report' });
  }
});

// Inventory Usage Report
app.get('/api/admin/reports/inventory-usage', async (req, res) => {
  try {
    const { startDate, endDate } = req.query;
    
    if (!db) {
      return res.json({ 
        success: true, 
        items: [],
        total: 0
      });
    }

    const items = await db.collection('inventories').find({}).toArray();
    res.json({ 
      success: true, 
      items,
      total: items.length
    });
  } catch (error) {
    res.status(500).json({ success: false, message: 'Error generating report' });
  }
});

// Staff Activity Report
app.get('/api/admin/reports/staff-activity', async (req, res) => {
  try {
    if (!db) {
      return res.json({ 
        success: true, 
        staff: [],
        total: 0
      });
    }

    const staff = await staffCollection.find({}).toArray();
    res.json({ 
      success: true, 
      staff,
      total: staff.length
    });
  } catch (error) {
    res.status(500).json({ success: false, message: 'Error generating report' });
  }
});

// ===== STAFF ROUTES =====

// Staff Dashboard
app.get('/api/staff/dashboard', async (req, res) => {
  try {
    res.json({ success: true, dashboard: { pendingTasks: 5, completedTasks: 20 } });
  } catch (error) {
    res.status(500).json({ success: false, message: 'Error fetching dashboard' });
  }
});

// Staff Dashboard Stats
app.get('/api/staff/dashboard/stats', async (req, res) => {
  try {
    res.json({ success: true, stats: { tasksCompleted: 20, inspectionsCompleted: 5 } });
  } catch (error) {
    res.status(500).json({ success: false, message: 'Error fetching stats' });
  }
});

// Get staff tasks
app.get('/api/staff/tasks', async (req, res) => {
  try {
    if (!db) return res.json({ success: true, tasks: [] });
    
    const tasksCollection = db.collection('taskassignments');
    const tasks = await tasksCollection.find({}).toArray();
    res.json({
      success: true,
      tasks: tasks.map(t => ({
        id: t._id.toString(),
        title: t.title,
        description: t.description,
        status: t.status || 'pending',
        dueTime: t.dueTime || '10:00 AM',
        assignedTo: t.assignedTo,
      })),
    });
  } catch (error) {
    console.error('Get tasks error:', error);
    res.status(500).json({ success: false, message: 'Error fetching tasks' });
  }
});

// Get task by ID
app.get('/api/staff/tasks/:id', async (req, res) => {
  try {
    res.json({ success: true, task: { id: req.params.id, title: 'Task', status: 'pending' } });
  } catch (error) {
    res.status(500).json({ success: false, message: 'Error fetching task' });
  }
});

// Get inspections
app.get('/api/staff/inspections', async (req, res) => {
  try {
    res.json({ success: true, inspections: [] });
  } catch (error) {
    res.status(500).json({ success: false, message: 'Error fetching inspections' });
  }
});

// ===== TEST ENDPOINTS =====

// Test database connection
app.get('/api/test/db-status', async (req, res) => {
  try {
    if (!db) {
      return res.json({ 
        success: false, 
        status: 'DISCONNECTED',
        message: 'Database is not connected',
        sessionBookingsCount: sessionBookings.length,
      });
    }
    
    const adminDb = db.admin();
    const status = await adminDb.ping();
    
    const totalBookings = await bookingsCollection.countDocuments();
    
    res.json({
      success: true,
      status: 'CONNECTED',
      message: 'Connected to MongoDB Atlas',
      totalBookingsInDB: totalBookings,
      sessionBookingsCount: sessionBookings.length,
      ping: status,
    });
  } catch (error) {
    res.status(500).json({
      success: false,
      status: 'ERROR',
      message: error.message,
    });
  }
});

// Test create booking
app.post('/api/test/create-booking', async (req, res) => {
  try {
    const testBooking = {
      customerName: 'Test Customer',
      customerContact: '+1234567890',
      customerEmail: 'test@example.com',
      oasis: 'Test Oasis',
      package: 'Test Package',
      bookingDate: new Date().toISOString(),
      session: 'Day',
      pax: 2,
      downpayment: 1000,
      paymentMethod: 'Cash',
      addons: [],
      status: 'Pending',
      paymentStatus: 'Pending',
      createdAt: new Date(),
    };
    
    console.log('\n🧪 TEST: Creating booking...');
    console.log('Database connected:', !!db);
    
    if (!db) {
      console.log('⚠️ Database not connected, using session storage');
      const bookingId = 'test_booking_' + Date.now().toString();
      testBooking._id = bookingId;
      sessionBookings.push(testBooking);
      return res.json({
        success: true,
        message: 'Test booking saved to session (DB not connected)',
        bookingId,
        booking: testBooking,
      });
    }
    
    const result = await bookingsCollection.insertOne(testBooking);
    console.log('✅ TEST: Booking saved with ID:', result.insertedId.toString());
    
    // Verify the booking was inserted
    const verifyBooking = await bookingsCollection.findOne({ _id: result.insertedId });
    console.log('✅ TEST: Verified booking from DB:', !!verifyBooking);
    
    res.json({
      success: true,
      message: 'Test booking created successfully',
      bookingId: result.insertedId.toString(),
      booking: { ...testBooking, _id: result.insertedId.toString() },
      verified: !!verifyBooking,
    });
  } catch (error) {
    console.error('❌ TEST: Create booking error:', error);
    res.status(500).json({
      success: false,
      message: 'Test booking failed: ' + error.message,
    });
  }
});

// Get all bookings count
app.get('/api/test/bookings-count', async (req, res) => {
  try {
    if (!db) {
      return res.json({
        success: true,
        dbBookings: 0,
        sessionBookings: sessionBookings.length,
        total: sessionBookings.length,
      });
    }
    
    const count = await bookingsCollection.countDocuments();
    res.json({
      success: true,
      dbBookings: count,
      sessionBookings: sessionBookings.length,
      total: count + sessionBookings.length,
    });
  } catch (error) {
    res.status(500).json({
      success: false,
      message: error.message,
    });
  }
});

// 404 handler
app.use((req, res) => {
  res.status(404).json({ error: 'Not Found' });
});

// Start server
const PORT = process.env.PORT || 8080;

connectDB().then(() => {
  app.listen(PORT, () => {
    console.log(`🚀 Backend server running on http://localhost:${PORT}`);
  });
});
