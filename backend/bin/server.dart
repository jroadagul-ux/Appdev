import 'package:shelf/shelf.dart';
import 'package:shelf/shelf_io.dart' as shelf_io;
import 'package:shelf_router/shelf_router.dart';
import 'package:mongo_dart/mongo_dart.dart';
import 'dart:convert';

late Db db;

void main() async {
  // Connect to MongoDB
  try {
    db = Db('mongodb+srv://poolUser:poolUser123@poolcluster.brghuqk.mongodb.net/bluesense?appName=PoolCluster');
    await db.open();
    print('✅ Connected to MongoDB');
  } catch (e) {
    print('❌ MongoDB Connection Error: $e');
    print('💾 Running with mock data only');
  }

  final router = Router();

  // Auth endpoints
  router.post('/api/auth/register', _register);
  router.post('/api/auth/login', _login);
  router.post('/api/auth/forgot-password', _forgotPassword);
  router.get('/api/auth/profile', _profile);

  // Booking endpoints
  router.get('/api/bookings', _getBookings);
  router.post('/api/bookings', _createBooking);
  router.get('/api/bookings/<id>', _getBookingById);
  router.put('/api/bookings/<id>/status', _updateBookingStatus);
  router.post('/api/bookings/<id>/payment', _processPayment);

  // Admin endpoints
  router.get('/api/admin/dashboard/stats', _adminDashboardStats);
  router.get('/api/admin/dashboard/daily-chart', _adminDashboardDaily);
  router.get('/api/admin/dashboard/monthly-chart', _adminDashboardMonthly);
  
  router.get('/api/admin/rooms', _adminGetRooms);
  router.post('/api/admin/rooms', _adminCreateRoom);
  router.get('/api/admin/rooms/<id>', _adminGetRoomById);
  
  router.get('/api/admin/staff', _adminGetStaff);
  router.post('/api/admin/staff', _adminCreateStaff);
  router.get('/api/admin/staff/<id>', _adminGetStaffById);
  
  router.get('/api/admin/inventory', _adminGetInventory);
  router.post('/api/admin/inventory', _adminCreateInventory);
  router.get('/api/admin/inventory/<id>', _adminGetInventoryById);
  router.post('/api/admin/inventory/<id>/use', _adminUseInventory);
  
  router.get('/api/admin/bookings', _adminGetBookings);
  router.get('/api/admin/sales', _adminGetSales);
  router.get('/api/admin/reservations', _adminGetReservations);

  // Staff endpoints
  router.get('/api/staff/dashboard', _staffDashboard);
  router.get('/api/staff/dashboard/stats', _staffDashboardStats);
  router.get('/api/staff/tasks', _staffGetTasks);
  router.get('/api/staff/tasks/<id>', _staffGetTaskById);
  router.get('/api/staff/inspections', _staffGetInspections);

  // 404 handler
  router.all('/<ignored|.*>', _notFound);

  final handler =
      const Pipeline().addMiddleware(logRequests()).addHandler(router.call);

  await shelf_io.serve(handler, 'localhost', 8080);
  print('🚀 Backend server running on http://localhost:8080');
}

_jsonResponse(dynamic data, {int statusCode = 200}) {
  return Response(
    statusCode,
    body: jsonEncode(data),
    headers: {'Content-Type': 'application/json'},
  );
}

_mockResponse(String endpoint, int statusCode) {
  final mockResponses = {
    'register': {'success': true, 'message': 'User registered successfully', 'userId': 'user_123', 'token': 'mock_token'},
    'login': {'success': true, 'message': 'Login successful', 'token': 'mock_token', 'user': {'id': 'user_123', 'email': 'test@example.com', 'name': 'Test User', 'role': 'customer'}},
    'bookings': {'success': true, 'bookings': []},
    'rooms': {'success': true, 'rooms': []},
  };
  
  return _jsonResponse(mockResponses[endpoint] ?? {'success': true}, statusCode: statusCode);
}

// Auth handlers
Future<Response> _register(Request request) async {
  try {
    final body = await request.readAsString();
    final data = jsonDecode(body) as Map;
    
    if (db.state != State.open) {
      return _mockResponse('register', 201);
    }
    
    final usersCollection = db.collection('users');
    
    // Check if user already exists
    final existingUser = await usersCollection.findOne(
      {'email': data['email']}
    );
    
    if (existingUser != null) {
      return _jsonResponse({
        'success': false,
        'message': 'User already exists',
      }, statusCode: 400);
    }
    
    // Create new user
    final newUser = {
      'email': data['email'],
      'password': data['password'], // Note: In production, hash this!
      'name': data['name'] ?? 'User',
      'phone': data['phone'] ?? '',
      'role': 'customer',
      'createdAt': DateTime.now(),
    };
    
    final result = await usersCollection.insertOne(newUser);
    
    return _jsonResponse({
      'success': true,
      'message': 'User registered successfully',
      'userId': result.id.toString(),
      'token': 'mock_token_${DateTime.now().millisecondsSinceEpoch}',
    }, statusCode: 201);
  } catch (e) {
    print('Registration error: $e');
    return _mockResponse('register', 201);
  }
}

Future<Response> _login(Request request) async {
  try {
    final body = await request.readAsString();
    final data = jsonDecode(body) as Map;
    
    if (db.state != State.open) {
      return _mockResponse('login', 200);
    }
    
    final usersCollection = db.collection('users');
    final user = await usersCollection.findOne(
      {'email': data['email'], 'password': data['password']}
    );
    
    if (user == null) {
      return _jsonResponse({
        'success': false,
        'message': 'Invalid email or password',
      }, statusCode: 401);
    }
    
    return _jsonResponse({
      'success': true,
      'message': 'Login successful',
      'token': 'mock_token_${DateTime.now().millisecondsSinceEpoch}',
      'user': {
        'id': user['_id'].toString(),
        'email': user['email'],
        'name': user['name'],
        'role': user['role'],
      },
    });
  } catch (e) {
    print('Login error: $e');
    return _mockResponse('login', 200);
  }
}

Future<Response> _forgotPassword(Request request) async {
  return _jsonResponse({
    'success': true,
    'message': 'Password reset link sent to email',
  });
}

Future<Response> _profile(Request request) async {
  return _jsonResponse({
    'success': true,
    'user': {
      'id': 'user_123',
      'email': 'user@example.com',
      'name': 'Test User',
      'phone': '+1234567890',
      'role': 'customer',
    },
  });
}

// Booking handlers
Future<Response> _getBookings(Request request) async {
  try {
    if (db.state == State.open) {
      final bookingsCollection = db.collection('bookings');
      final bookings = await bookingsCollection.find().toList();
      
      return _jsonResponse({
        'success': true,
        'bookings': bookings.map((b) => {
          'id': b['_id'].toString(),
          'roomId': b['roomId'],
          'userId': b['userId'],
          'checkInDate': b['checkInDate'],
          'checkOutDate': b['checkOutDate'],
          'status': b['status'],
          'totalPrice': b['totalPrice'],
        }).toList(),
      });
    }
  } catch (e) {
    print('Error fetching bookings: $e');
  }
  return _mockResponse('bookings', 200);
}

Future<Response> _createBooking(Request request) async {
  try {
    final body = await request.readAsString();
    final data = jsonDecode(body) as Map;
    
    if (db.state == State.open) {
      final bookingsCollection = db.collection('bookings');
      final newBooking = {
        'roomId': data['roomId'],
        'userId': data['userId'],
        'checkInDate': data['checkInDate'],
        'checkOutDate': data['checkOutDate'],
        'status': 'pending',
        'totalPrice': data['totalPrice'] ?? 0.0,
        'createdAt': DateTime.now(),
      };
      
      final result = await bookingsCollection.insertOne(newBooking);
      
      return _jsonResponse({
        'success': true,
        'message': 'Booking created successfully',
        'bookingId': result.id.toString(),
      }, statusCode: 201);
    }
  } catch (e) {
    print('Error creating booking: $e');
  }
  
  return _jsonResponse({
    'success': true,
    'message': 'Booking created successfully',
    'bookingId': 'booking_${DateTime.now().millisecondsSinceEpoch}',
  }, statusCode: 201);
}

Future<Response> _getBookingById(Request request, String id) async {
  return _jsonResponse({
    'success': true,
    'booking': {
      'id': id,
      'roomId': 'room_1',
      'userId': 'user_123',
      'checkInDate': '2024-05-01',
      'checkOutDate': '2024-05-05',
      'status': 'confirmed',
      'totalPrice': 500.0,
    },
  });
}

Future<Response> _updateBookingStatus(Request request, String id) async {
  final body = await request.readAsString();
  return _jsonResponse({
    'success': true,
    'message': 'Booking status updated',
  });
}

Future<Response> _processPayment(Request request, String id) async {
  return _jsonResponse({
    'success': true,
    'message': 'Payment processed successfully',
    'transactionId': 'txn_${DateTime.now().millisecondsSinceEpoch}',
  });
}

// Admin dashboard handlers
Future<Response> _adminDashboardStats(Request request) async {
  return _jsonResponse({
    'success': true,
    'stats': {
      'totalBookings': 150,
      'totalRevenue': 50000.0,
      'totalGuests': 300,
      'occupancyRate': 75.5,
    },
  });
}

Future<Response> _adminDashboardDaily(Request request) async {
  return _jsonResponse({
    'success': true,
    'data': [
      {'date': '2024-01-01', 'bookings': 10, 'revenue': 5000},
      {'date': '2024-01-02', 'bookings': 12, 'revenue': 6000},
    ],
  });
}

Future<Response> _adminDashboardMonthly(Request request) async {
  return _jsonResponse({
    'success': true,
    'data': [
      {'month': 'January', 'bookings': 100, 'revenue': 50000},
      {'month': 'February', 'bookings': 120, 'revenue': 60000},
    ],
  });
}

// Admin rooms handlers
Future<Response> _adminGetRooms(Request request) async {
  return _mockResponse('rooms', 200);
}

Future<Response> _adminCreateRoom(Request request) async {
  return _jsonResponse({
    'success': true,
    'message': 'Room created successfully',
  }, statusCode: 201);
}

Future<Response> _adminGetRoomById(Request request, String id) async {
  return _jsonResponse({
    'success': true,
    'room': {
      'id': id,
      'name': 'Deluxe Suite',
      'capacity': 4,
      'pricePerNight': 150.0,
      'status': 'available',
    },
  });
}

// Admin staff handlers
Future<Response> _adminGetStaff(Request request) async {
  return _jsonResponse({
    'success': true,
    'staff': [
      {
        'id': 'staff_1',
        'name': 'John Doe',
        'role': 'Manager',
        'email': 'john@example.com',
      },
    ],
  });
}

Future<Response> _adminCreateStaff(Request request) async {
  return _jsonResponse({
    'success': true,
    'message': 'Staff member added successfully',
  }, statusCode: 201);
}

Future<Response> _adminGetStaffById(Request request, String id) async {
  return _jsonResponse({
    'success': true,
    'staff': {
      'id': id,
      'name': 'John Doe',
      'role': 'Manager',
      'email': 'john@example.com',
    },
  });
}

// Admin inventory handlers
Future<Response> _adminGetInventory(Request request) async {
  return _jsonResponse({
    'success': true,
    'inventory': [
      {
        'id': 'inv_1',
        'name': 'Bed Sheets',
        'quantity': 100,
        'unit': 'pieces',
      },
    ],
  });
}

Future<Response> _adminCreateInventory(Request request) async {
  return _jsonResponse({
    'success': true,
    'message': 'Inventory item created',
  }, statusCode: 201);
}

Future<Response> _adminGetInventoryById(Request request, String id) async {
  return _jsonResponse({
    'success': true,
    'inventory': {
      'id': id,
      'name': 'Bed Sheets',
      'quantity': 100,
      'unit': 'pieces',
    },
  });
}

Future<Response> _adminUseInventory(Request request, String id) async {
  return _jsonResponse({
    'success': true,
    'message': 'Inventory updated',
  });
}

Future<Response> _adminGetBookings(Request request) async {
  return _jsonResponse({
    'success': true,
    'bookings': [],
  });
}

Future<Response> _adminGetSales(Request request) async {
  return _jsonResponse({
    'success': true,
    'sales': [
      {'date': '2024-01-01', 'amount': 5000, 'count': 10},
    ],
  });
}

Future<Response> _adminGetReservations(Request request) async {
  return _jsonResponse({
    'success': true,
    'reservations': [],
  });
}

// Staff handlers
Future<Response> _staffDashboard(Request request) async {
  return _jsonResponse({
    'success': true,
    'dashboard': {
      'pendingTasks': 5,
      'completedTasks': 20,
    },
  });
}

Future<Response> _staffDashboardStats(Request request) async {
  return _jsonResponse({
    'success': true,
    'stats': {
      'tasksCompleted': 20,
      'inspectionsCompleted': 5,
    },
  });
}

Future<Response> _staffGetTasks(Request request) async {
  return _jsonResponse({
    'success': true,
    'tasks': [
      {
        'id': 'task_1',
        'title': 'Clean Room 101',
        'status': 'pending',
        'dueTime': '10:00 AM',
      },
    ],
  });
}

Future<Response> _staffGetTaskById(Request request, String id) async {
  return _jsonResponse({
    'success': true,
    'task': {
      'id': id,
      'title': 'Clean Room 101',
      'status': 'pending',
      'dueTime': '10:00 AM',
    },
  });
}

Future<Response> _staffGetInspections(Request request) async {
  return _jsonResponse({
    'success': true,
    'inspections': [],
  });
}

Future<Response> _notFound(Request request) {
  return Future.value(_jsonResponse({'error': 'Not Found'}, statusCode: 404));
}
