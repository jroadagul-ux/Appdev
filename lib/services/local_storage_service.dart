import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

class LocalStorageService {
  static const String _bookingsKey = 'user_bookings';
  static const String _roomsKey = 'admin_rooms';  // new

  // Save a list of bookings
  static Future<void> saveBookings(List<Map<String, dynamic>> bookings) async {
    final prefs = await SharedPreferences.getInstance();
    final jsonString = jsonEncode(bookings);
    await prefs.setString(_bookingsKey, jsonString);
  }

  // Load bookings from storage
  static Future<List<Map<String, dynamic>>> loadBookings() async {
    final prefs = await SharedPreferences.getInstance();
    final jsonString = prefs.getString(_bookingsKey);
    if (jsonString == null) return [];
    final List<dynamic> decoded = jsonDecode(jsonString);
    return decoded.map((e) => Map<String, dynamic>.from(e)).toList();
  }

  // Add a new booking
  static Future<void> addBooking(Map<String, dynamic> newBooking) async {
    try {
      final bookings = await loadBookings();
      // Add a unique ID (using timestamp)
      newBooking['_id'] = DateTime.now().millisecondsSinceEpoch.toString();
      newBooking['status'] = newBooking['status'] ?? 'Pending';
      newBooking['paymentStatus'] = newBooking['paymentStatus'] ?? 'Pending';
      newBooking['createdAt'] = newBooking['createdAt'] ?? DateTime.now().toIso8601String();
      
      // Ensure userId is present
      if (newBooking['userId'] == null) {
        newBooking['userId'] = 'guest_${DateTime.now().millisecondsSinceEpoch}';
      }
      
      bookings.add(newBooking);
      await saveBookings(bookings);
      print('Booking saved with userId: ${newBooking['userId']}');
    } catch (e) {
      print('Error saving booking: $e');
      rethrow;
    }
  }
  static Future<List<Map<String, dynamic>>> loadRooms() async {
    final prefs = await SharedPreferences.getInstance();
    final String? jsonString = prefs.getString(_roomsKey);
    if (jsonString == null) return [];
    return List<Map<String, dynamic>>.from(jsonDecode(jsonString));
  }

  static Future<void> saveRooms(List<Map<String, dynamic>> rooms) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_roomsKey, jsonEncode(rooms));
  }

  static Future<void> addRoom(Map<String, dynamic> room) async {
    final rooms = await loadRooms();
    room['id'] = DateTime.now().millisecondsSinceEpoch.toString(); // unique id
    rooms.add(room);
    await saveRooms(rooms);
  }

  static Future<void> updateRoom(String id, Map<String, dynamic> updatedRoom) async {
    final rooms = await loadRooms();
    final index = rooms.indexWhere((r) => r['id'] == id);
    if (index != -1) {
      updatedRoom['id'] = id; // keep the same id
      rooms[index] = updatedRoom;
      await saveRooms(rooms);
    }
  }

  static Future<void> deleteRoom(String id) async {
    final rooms = await loadRooms();
    rooms.removeWhere((r) => r['id'] == id);
    await saveRooms(rooms);
  }
}
