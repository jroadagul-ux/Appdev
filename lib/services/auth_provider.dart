// lib/services/auth_provider.dart
import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/models.dart';
import 'api_service.dart';

class AuthProvider extends ChangeNotifier {
  UserModel? _user;
  String? _token;
  bool _isLoading = false;

  UserModel? get user => _user;
  String? get token => _token;
  bool get isLoading => _isLoading;
  bool get isLoggedIn => _token != null && _user != null;
  bool get isAdmin => _user?.role == 'admin';
  bool get isStaff => _user?.role == 'staff';
  bool get isCustomer => _user?.role == 'customer';

  AuthProvider() {
    _loadFromStorage();
  }

  Future<void> _loadFromStorage() async {
    final prefs = await SharedPreferences.getInstance();
    _token = prefs.getString('token');
    final userJson = prefs.getString('user');
    if (userJson != null) {
      _user = UserModel.fromJson(json.decode(userJson));
    }
    notifyListeners();
  }

  Future<Map<String, dynamic>> login(String email, String password) async {
    _isLoading = true;
    notifyListeners();

    try {
      final result = await ApiService.post('/api/auth/login', {
        'email': email,
        'password': password,
      });

      if (result['token'] != null) {
        _token = result['token'];
        // Backend returns user or staff object
        final userData = result['user'] ?? result['staff'];
        if (userData != null) {
          _user = UserModel.fromJson(userData);
        }
        await _saveToStorage();
        _isLoading = false;
        notifyListeners();
        return {'success': true};
      } else {
        _isLoading = false;
        notifyListeners();
        return {
          'success': false,
          'message': result['message'] ?? 'Login failed'
        };
      }
    } catch (e) {
      _isLoading = false;
      notifyListeners();
      return {'success': false, 'message': 'Network error: $e'};
    }
  }

  Future<Map<String, dynamic>> register(Map<String, dynamic> userData) async {
    _isLoading = true;
    notifyListeners();

    try {
      final result = await ApiService.post('/api/auth/register', userData);
      _isLoading = false;
      notifyListeners();

      if (result['token'] != null || result['message']?.contains('success') == true) {
        return {'success': true, 'message': result['message'] ?? 'Registration successful'};
      } else {
        return {
          'success': false,
          'message': result['message'] ?? 'Registration failed'
        };
      }
    } catch (e) {
      _isLoading = false;
      notifyListeners();
      return {'success': false, 'message': 'Network error: $e'};
    }
  }

  Future<Map<String, dynamic>> forgotPassword(String email) async {
    try {
      final result = await ApiService.post('/api/auth/forgot-password', {
        'email': email,
      });
      if (result['message'] != null) {
        return {'success': true, 'message': result['message']};
      }
      return {'success': false, 'message': result['message'] ?? 'Failed'};
    } catch (e) {
      return {'success': false, 'message': 'Network error: $e'};
    }
  }

  Future<void> logout() async {
    _user = null;
    _token = null;
    notifyListeners();
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('token');
    await prefs.remove('user');
    notifyListeners();
  }

  Future<void> updateUser(UserModel updatedUser) async {
    _user = updatedUser;
    await _saveToStorage();
    notifyListeners();
  }

  Future<void> _saveToStorage() async {
    final prefs = await SharedPreferences.getInstance();
    if (_token != null) await prefs.setString('token', _token!);
    if (_user != null) {
      await prefs.setString('user', json.encode(_user!.toJson()));
    }
  }
}

