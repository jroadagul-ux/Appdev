// lib/main.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:bluesense/screens/admin/admin_dashboard_screen.dart';
import 'package:bluesense/screens/admin/booking_management_screen.dart';
import 'package:bluesense/screens/admin/inventory_management_screen.dart';
import 'package:bluesense/screens/admin/room_management_screen.dart';
import 'package:bluesense/screens/admin/sales_screen.dart';
import 'package:bluesense/screens/admin/staff_management_screen.dart';
import 'package:bluesense/screens/auth/forgot_password_screen.dart';
import 'package:bluesense/screens/auth/login_screen.dart';
import 'package:bluesense/screens/auth/register_screen.dart';
import 'package:bluesense/screens/auth/reset_password_screen.dart';
import 'package:bluesense/screens/customer/booking_receipt_screen.dart';
import 'package:bluesense/screens/customer/booking_screen.dart';
import 'package:bluesense/screens/customer/home_screen.dart';
import 'package:bluesense/screens/customer/info_screens.dart';
import 'package:bluesense/screens/customer/my_bookings_screen.dart';
import 'package:bluesense/screens/customer/package_details_screen.dart';
import 'package:bluesense/screens/customer/pool_monitoring_screen.dart';
import 'package:bluesense/screens/staff/staff_screens.dart';
import 'package:bluesense/services/auth_provider.dart';
import 'package:bluesense/config/app_theme.dart';

void main() {
  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AuthProvider()),
      ],
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'BlueSense Resort',
      theme: AppTheme.lightTheme, // Make sure lightTheme is defined in AppTheme
      debugShowCheckedModeBanner: false,
      initialRoute: '/login',
      routes: {
        '/login': (ctx) => const LoginScreen(),
        '/register': (ctx) => const RegisterScreen(),
        '/forgot-password': (ctx) => const ForgotPasswordScreen(),
        '/home': (ctx) => const HomeScreen(),
        '/booking': (ctx) => const BookingScreen(),
        '/my-bookings': (ctx) => const MyBookingsScreen(),
        '/booking-receipt': (ctx) {
          final args = ModalRoute.of(ctx)?.settings.arguments as Map<String, dynamic>;
          return BookingReceiptScreen(bookingData: args);
        },
        '/pool-monitoring': (ctx) => const PoolMonitoringScreen(),
        '/about-us': (ctx) => const AboutUsScreen(),
        '/gallery': (ctx) => const GalleryScreen(), // removed const
        '/contact-us': (ctx) => const ContactUsScreen(), // removed const
        '/oasis-1': (ctx) => const Oasis1Screen(),
        '/oasis-2': (ctx) => const Oasis2Screen(),
        '/admin/dashboard': (ctx) => const AdminDashboardScreen(),
        '/admin/bookings': (ctx) => const BookingManagementScreen(),
        '/admin/rooms': (ctx) => const RoomManagementScreen(),
        '/admin/inventory': (ctx) => const InventoryManagementScreen(),
        '/admin/staff': (ctx) => const StaffManagementScreen(),
        '/admin/sales': (ctx) => const SalesScreen(),
        '/admin/reports': (ctx) => const ReportsScreen(),
        '/staff/dashboard': (ctx) => const StaffDashboardScreen(),
        '/staff/tasks': (ctx) => const StaffTasksScreen(),
        '/staff/inspections': (ctx) => const StaffInspectionsScreen(),
        '/staff/notifications': (ctx) => const StaffNotificationsScreen(),
      },
      onGenerateRoute: (settings) {
        if (settings.name == '/reset-password') {
          final token = settings.arguments as String;
          return MaterialPageRoute(
            builder: (_) => ResetPasswordScreen(token: token),
          );
        }
        if (settings.name == '/package-details') {
          final packageName = settings.arguments as String;
          return MaterialPageRoute(
            builder: (_) => PackageDetailsScreen(packageName: packageName),
          );
        }
        return null;
      },
    );
  }
}