// lib/screens/customer/my_bookings_screen.dart
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../../models/models.dart';
import '../../services/auth_provider.dart';
import '../../widgets/common_widgets.dart';
import '../../widgets/core/glass_card.dart';
import '../../services/local_storage_service.dart';

class MyBookingsScreen extends StatefulWidget {
  const MyBookingsScreen({super.key});
  @override
  State<MyBookingsScreen> createState() => _MyBookingsScreenState();
}

class _MyBookingsScreenState extends State<MyBookingsScreen> {
  List<BookingModel> _bookings = [];
  bool _loading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _fetchBookings();
  }

  Future<void> _fetchBookings() async {
    final auth = context.read<AuthProvider>();
    if (auth.user == null) {
      setState(() {
        _loading = false;
        _error = 'Please log in to view your bookings.';
      });
      return;
    }

    setState(() { _loading = true; _error = null; });
    try {
      // Load from local storage
      final allBookings = await LocalStorageService.loadBookings();
      debugPrint('Total bookings in storage: ${allBookings.length}');
      
      final userId = auth.user!.id;
      debugPrint('Current user ID: $userId');
      
      // Filter bookings by userId - also handle cases where userId might be null or missing
      final myBookings = allBookings.where((b) {
        final bookingUserId = b['userId'];
        debugPrint('Checking booking with userId: $bookingUserId against user: $userId');
        return bookingUserId == userId || b['customerEmail'] == auth.user!.email;
      }).toList();
      
      debugPrint('Found ${myBookings.length} bookings for this user');
      
      setState(() {
        _bookings = myBookings.map((b) => BookingModel.fromJson(b)).toList();
        _loading = false;
      });
    } catch (e) {
      debugPrint('Error fetching bookings: $e');
      setState(() { _loading = false; _error = 'Failed to fetch bookings.'; });
    }
  }

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>();

    return Scaffold(
      backgroundColor: const Color(0xFF003158),
      appBar: AppBar(
        title: Text('My Bookings', style: GoogleFonts.poppins(fontWeight: FontWeight.w700, color: Colors.white)),
        backgroundColor: const Color(0xFF003158),
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh, color: Colors.white),
            onPressed: _fetchBookings,
            tooltip: 'Refresh',
          ),
        ],
      ),
      body: _loading
          ? const LoadingWidget(message: 'Loading your bookings...')
          : auth.user == null
              ? Center(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Container(
                        padding: const EdgeInsets.all(20),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.1),
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(Icons.lock_outline, size: 48, color: Colors.tealAccent),
                      ),
                      const SizedBox(height: 20),
                      Text('Please log in',
                          style: GoogleFonts.poppins(
                              fontSize: 20, fontWeight: FontWeight.w700, color: Colors.white)),
                      const SizedBox(height: 8),
                      Text('to view your bookings',
                          style: GoogleFonts.poppins(color: Colors.white70)),
                      const SizedBox(height: 24),
                      ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.tealAccent,
                          foregroundColor: const Color(0xFF003158),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                          padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 12),
                        ),
                        onPressed: () => Navigator.pushReplacementNamed(context, '/login'),
                        child: const Text('Go to Login', style: TextStyle(fontWeight: FontWeight.w600)),
                      ),
                    ],
                  ),
                )
              : _bookings.isEmpty
                  ? EmptyState(
                      message: _error ?? 'No bookings found.',
                      icon: Icons.receipt_long_outlined,
                    )
                  : RefreshIndicator(
                      onRefresh: _fetchBookings,
                      child: ListView.separated(
                        padding: const EdgeInsets.all(16),
                        itemCount: _bookings.length,
                        separatorBuilder: (_, __) => const SizedBox(height: 12),
                        itemBuilder: (_, i) => _BookingCard(booking: _bookings[i]),
                      ),
                    ),
    );
  }
}

class _BookingCard extends StatelessWidget {
  final BookingModel booking;
  const _BookingCard({required this.booking});

  @override
  Widget build(BuildContext context) {
    return GlassCard(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(booking.oasis,
                      style: GoogleFonts.poppins(fontWeight: FontWeight.w700, fontSize: 16, color: Colors.white)),
                  Text(booking.package,
                      style: GoogleFonts.poppins(color: Colors.white70, fontSize: 13)),
                ],
              ),
              StatusBadge(booking.status),
            ],
          ),
          const SizedBox(height: 12),
          const Divider(height: 1, color: Colors.white24),
          const SizedBox(height: 12),
          _InfoRow(Icons.person_outlined, booking.customerName),
          _InfoRow(Icons.calendar_today_outlined,
              DateFormat('MMMM d, yyyy (EEEE)').format(booking.bookingDate)),
          _InfoRow(Icons.group_outlined, '${booking.pax} guest(s)'),
          _InfoRow(Icons.payments_outlined,
              'Downpayment: ${formatPeso(booking.downpayment)} via ${booking.paymentMethod}'),
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('Payment Status:',
                  style: GoogleFonts.poppins(color: Colors.white70, fontSize: 12)),
              StatusBadge(booking.paymentStatus),
            ],
          ),
        ],
      ),
    );
  }
}

class _InfoRow extends StatelessWidget {
  final IconData icon;
  final String text;
  const _InfoRow(this.icon, this.text);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        children: [
          Icon(icon, size: 16, color: Colors.tealAccent),
          const SizedBox(width: 10),
          Expanded(
            child: Text(text,
                style: GoogleFonts.poppins(fontSize: 13, color: Colors.white70)),
          ),
        ],
      ),
    );
  }
}