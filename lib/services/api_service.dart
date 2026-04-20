// lib/services/api_service.dart
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import '../config/api_config.dart';

class ApiService {
  static Future<String?> _getToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('token');
  }

  static Future<Map<String, String>> _headers({bool auth = false}) async {
    final headers = {'Content-Type': 'application/json'};
    if (auth) {
      final token = await _getToken();
      if (token != null) headers['Authorization'] = 'Bearer $token';
    }
    return headers;
  }

  static Future<dynamic> get(String path, {bool auth = true}) async {
    final url = Uri.parse('${ApiConfig.baseUrl}$path');
    final headers = await _headers(auth: auth);
    final response = await http.get(url, headers: headers)
        .timeout(const Duration(seconds: 15));
    return _handleResponse(response);
  }

  static Future<dynamic> post(String path, Map<String, dynamic> body,
      {bool auth = false}) async {
    final url = Uri.parse('${ApiConfig.baseUrl}$path');
    final headers = await _headers(auth: auth);
    final response = await http
        .post(url, headers: headers, body: json.encode(body))
        .timeout(const Duration(seconds: 15));
    return _handleResponse(response);
  }

  static Future<dynamic> put(String path, Map<String, dynamic> body,
      {bool auth = true}) async {
    final url = Uri.parse('${ApiConfig.baseUrl}$path');
    final headers = await _headers(auth: auth);
    final response = await http
        .put(url, headers: headers, body: json.encode(body))
        .timeout(const Duration(seconds: 15));
    return _handleResponse(response);
  }

  static Future<dynamic> patch(String path, Map<String, dynamic> body,
      {bool auth = true}) async {
    final url = Uri.parse('${ApiConfig.baseUrl}$path');
    final headers = await _headers(auth: auth);
    final response = await http
        .patch(url, headers: headers, body: json.encode(body))
        .timeout(const Duration(seconds: 15));
    return _handleResponse(response);
  }

  static Future<dynamic> delete(String path, {bool auth = true}) async {
    final url = Uri.parse('${ApiConfig.baseUrl}$path');
    final headers = await _headers(auth: auth);
    final response = await http
        .delete(url, headers: headers)
        .timeout(const Duration(seconds: 15));
    return _handleResponse(response);
  }

  static dynamic _handleResponse(http.Response response) {
    final body = json.decode(response.body);
    return body;
  }

  // Booking methods
  static Future<List<dynamic>> fetchBookings() async {
    try {
      final response = await get('/bookings', auth: true);
      if (response['success'] == true && response['bookings'] != null) {
        return response['bookings'] as List<dynamic>;
      }
      return [];
    } catch (e) {
      print('Error fetching bookings: $e');
      return [];
    }
  }

  static Future<dynamic> createBooking(Map<String, dynamic> bookingData) async {
    return await post('/bookings', bookingData, auth: true);
  }
}
