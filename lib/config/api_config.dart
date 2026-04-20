// lib/config/api_config.dart
// ============================================
// API CONFIGURATION - Change IP when network changes
// ============================================

class ApiConfig {
  // ============================================
  // CHANGE THIS IP TO MATCH YOUR BACKEND SERVER
  // ============================================
  static const String baseUrl = 'http://localhost:8080';

  // Auth endpoints
  static const String login = '$baseUrl/api/auth/login';
  static const String register = '$baseUrl/api/auth/register';
  static const String forgotPassword = '$baseUrl/api/auth/forgot-password';
  static const String profile = '$baseUrl/api/auth/profile';

  // Booking endpoints
  static const String bookings = '$baseUrl/api/bookings';
  static String bookingById(String id) => '$baseUrl/api/bookings/$id';
  static String bookingStatus(String id) => '$baseUrl/api/bookings/$id/status';
  static String bookingPayment(String id) => '$baseUrl/api/bookings/$id/payment';

  // Admin endpoints
  static const String adminDashboardStats = '$baseUrl/api/admin/dashboard/stats';
  static const String adminDashboardDaily = '$baseUrl/api/admin/dashboard/daily-chart';
  static const String adminDashboardMonthly = '$baseUrl/api/admin/dashboard/monthly-chart';

  static const String adminRooms = '$baseUrl/api/admin/rooms';
  static String adminRoomById(String id) => '$baseUrl/api/admin/rooms/$id';

  static const String adminStaff = '$baseUrl/api/admin/staff';
  static String adminStaffById(String id) => '$baseUrl/api/admin/staff/$id';

  static const String adminInventory = '$baseUrl/api/admin/inventory';
  static String adminInventoryById(String id) => '$baseUrl/api/admin/inventory/$id';
  static String adminInventoryUse(String id) => '$baseUrl/api/admin/inventory/$id/use';

  static const String adminBookings = '$baseUrl/api/admin/bookings';
  static const String adminSales = '$baseUrl/api/admin/sales';
  static const String adminReservations = '$baseUrl/api/admin/reservations';

  // Staff endpoints
  static const String staffDashboard = '$baseUrl/api/staff/dashboard';
  static const String staffTasks = '$baseUrl/api/staff/tasks';
  static String staffTaskById(String id) => '$baseUrl/api/staff/tasks/$id';
  static const String staffInspections = '$baseUrl/api/staff/inspections';

  // Staff dashboard endpoints (correct path)
  static const String staffDashboardStats = '$baseUrl/api/staff/dashboard/stats';
  static const String staffDashboardTasks = '$baseUrl/api/staff/dashboard/tasks';
  static String staffDashboardTaskById(String id) => '$baseUrl/api/staff/dashboard/tasks/$id';
  static String staffDashboardTaskStatus(String id) => '$baseUrl/api/staff/dashboard/tasks/$id/status';
  static const String staffDashboardInspections = '$baseUrl/api/staff/dashboard/inspections';
  static const String staffDashboardAssignedRooms = '$baseUrl/api/staff/dashboard/assigned-rooms';
  static const String staffDashboardNotifications = '$baseUrl/api/staff/dashboard/notifications';
  static const String staffDashboardUnreadCount = '$baseUrl/api/staff/dashboard/notifications/unread-count';
  static const String staffDashboardMarkAllRead = '$baseUrl/api/staff/dashboard/notifications/mark-all-read';
  static String staffDashboardMarkRead(String id) => '$baseUrl/api/staff/dashboard/notifications/$id/read';
  static String staffDashboardDeleteNotification(String id) => '$baseUrl/api/staff/dashboard/notifications/$id';

  // Customer booking lookup (correct path)
  static String bookingsByCustomerEmail(String email) => '$baseUrl/api/bookings/customer/$email';

  // Sensor/readings
  static const String latestReading = '$baseUrl/api/readings/latest';
  static const String readingHistory = '$baseUrl/api/readings/history';
}
