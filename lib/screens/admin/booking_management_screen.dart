// lib/screens/admin/booking_management_screen.dart
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import '../../config/app_theme.dart';
import '../../models/models.dart';
import '../../services/api_service.dart';
import '../../services/local_storage_service.dart';
import '../../widgets/common_widgets.dart';
import '../../widgets/core/glass_card.dart';

class BookingManagementScreen extends StatefulWidget {
  const BookingManagementScreen({super.key});
  @override
  State<BookingManagementScreen> createState() => _BookingManagementScreenState();
}

class _BookingManagementScreenState extends State<BookingManagementScreen> {
  List<BookingModel> _bookings = [];
  bool _loading = true;
  String _statusFilter = 'All';
  String _search = '';

  final _statuses = ['All', 'Pending', 'Confirmed', 'Completed', 'Cancelled'];

  @override
  void initState() {
    super.initState();
    _fetchBookings();
  }

  Future<void> _fetchBookings() async {
    setState(() => _loading = true);
    try {
      List<BookingModel> fetchedBookings = [];
      
      // First, try to load from local storage
      try {
        final allBookingsData = await LocalStorageService.loadBookings();
        debugPrint('Loaded ${allBookingsData.length} bookings from local storage');
        
        fetchedBookings = allBookingsData
            .map((b) => BookingModel.fromJson(b))
            .toList();
      } catch (e) {
        debugPrint('Error loading from local storage: $e');
      }
      
      // Then, try to load from API/database
      try {
        final result = await ApiService.get('/api/admin/bookings', auth: true);
        
        List<BookingModel> dbBookings = [];
        if (result is List) {
          dbBookings = result.map((b) => BookingModel.fromJson(b as Map<String, dynamic>)).toList();
        } else if (result is Map) {
          if (result['bookings'] is List) {
            dbBookings = (result['bookings'] as List)
                .map((b) => BookingModel.fromJson(b as Map<String, dynamic>))
                .toList();
          } else if (result['data'] is List) {
            dbBookings = (result['data'] as List)
                .map((b) => BookingModel.fromJson(b as Map<String, dynamic>))
                .toList();
          }
        }
        
        // Merge with local storage (prefer local storage for latest updates)
        if (dbBookings.isNotEmpty) {
          debugPrint('Loaded ${dbBookings.length} bookings from database');
          // Add database bookings that aren't in local storage
          for (var dbBooking in dbBookings) {
            if (!fetchedBookings.any((b) => b.id == dbBooking.id)) {
              fetchedBookings.add(dbBooking);
            }
          }
        }
      } catch (e) {
        debugPrint('Could not load from database: $e');
      }
      
      setState(() {
        _bookings = fetchedBookings;
        _loading = false;
      });
      
      debugPrint('Total bookings to display: ${fetchedBookings.length}');
    } catch (e) {
      debugPrint('Error fetching bookings: $e');
      setState(() => _loading = false);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to load bookings: $e')),
        );
      }
    }
  }

  List<BookingModel> get _filtered => _bookings.where((b) {
        final matchStatus = _statusFilter == 'All' || b.status == _statusFilter;
        final matchSearch = _search.isEmpty ||
            b.customerName.toLowerCase().contains(_search.toLowerCase()) ||
            b.oasis.toLowerCase().contains(_search.toLowerCase());
        return matchStatus && matchSearch;
      }).toList();

  Future<void> _updateStatus(BookingModel booking, String newStatus) async {
    try {
      // Update in local storage
      final allBookings = await LocalStorageService.loadBookings();
      final index = allBookings.indexWhere((b) => b['_id'] == booking.id);
      
      if (index != -1) {
        allBookings[index]['status'] = newStatus;
        await LocalStorageService.saveBookings(allBookings);
        debugPrint('Updated booking status to $newStatus in local storage');
      }
      
      // Also try to update in database (fire and forget)
      try {
        await ApiService.patch('/api/admin/bookings/${booking.id}/status', {'status': newStatus});
      } catch (e) {
        debugPrint('Could not sync with database: $e');
      }
      
      // Refresh the list
      _fetchBookings();
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Booking status updated to $newStatus'),
            backgroundColor: AppColors.success,
          ),
        );
      }
    } catch (e) {
      debugPrint('Error updating status: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error updating status: $e')),
        );
      }
    }
  }

  Future<void> _updatePayment(BookingModel booking, String newPaymentStatus) async {
    try {
      // Update in local storage
      final allBookings = await LocalStorageService.loadBookings();
      final index = allBookings.indexWhere((b) => b['_id'] == booking.id);
      
      if (index != -1) {
        allBookings[index]['paymentStatus'] = newPaymentStatus;
        await LocalStorageService.saveBookings(allBookings);
        debugPrint('Updated booking payment status to $newPaymentStatus in local storage');
      }
      
      // Also try to update in database (fire and forget)
      try {
        await ApiService.patch('/api/admin/bookings/${booking.id}/payment',
            {'paymentStatus': newPaymentStatus});
      } catch (e) {
        debugPrint('Could not sync with database: $e');
      }
      
      // Refresh the list
      _fetchBookings();
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Payment status updated to $newPaymentStatus'),
            backgroundColor: AppColors.success,
          ),
        );
      }
    } catch (e) {
      debugPrint('Error updating payment status: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error updating payment: $e')),
        );
      }
    }
  }

  void _showBookingDetails(BookingModel b) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (_) => DraggableScrollableSheet(
        initialChildSize: 0.85,
        minChildSize: 0.5,
        maxChildSize: 0.95,
        expand: false,
        builder: (_, ctrl) => Container(
          decoration: const BoxDecoration(
            color: Color(0xFF003158),
            borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
          ),
          child: Column(
            children: [
              Container(
                margin: const EdgeInsets.only(top: 12, bottom: 8),
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.3),
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              Expanded(
                child: ListView(
                  controller: ctrl,
                  padding: const EdgeInsets.all(20),
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Booking Details',
                          style: GoogleFonts.poppins(
                            fontSize: 20,
                            fontWeight: FontWeight.w700,
                            color: Colors.white,
                          ),
                        ),
                        StatusBadge(b.status),
                      ],
                    ),
                    const SizedBox(height: 20),
                    
                    GlassCard(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Customer Information',
                            style: GoogleFonts.poppins(
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                              color: Colors.white70,
                            ),
                          ),
                          const SizedBox(height: 12),
                          _DetailRow('Name', b.customerName),
                          _DetailRow('Contact', b.customerContact),
                          if (b.customerEmail != null) _DetailRow('Email', b.customerEmail!),
                        ],
                      ),
                    ),
                    const SizedBox(height: 12),
                    
                    GlassCard(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Booking Information',
                            style: GoogleFonts.poppins(
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                              color: Colors.white70,
                            ),
                          ),
                          const SizedBox(height: 12),
                          _DetailRow('Oasis', b.oasis),
                          _DetailRow('Package', b.package),
                          _DetailRow('Date', DateFormat('MMMM d, yyyy (EEEE)').format(b.bookingDate)),
                          _DetailRow('Guests', '${b.pax} Pax'),
                        ],
                      ),
                    ),
                    const SizedBox(height: 12),
                    
                    GlassCard(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Payment Information',
                            style: GoogleFonts.poppins(
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                              color: Colors.white70,
                            ),
                          ),
                          const SizedBox(height: 12),
                          _DetailRow('Downpayment', formatPeso(b.downpayment)),
                          _DetailRow('Payment Method', b.paymentMethod),
                          _DetailRow('Payment Status', b.paymentStatus),
                          if (b.createdAt != null)
                            _DetailRow('Booked on', formatDateTime(b.createdAt!)),
                        ],
                      ),
                    ),
                    
                    const SizedBox(height: 20),
                    
                    Text(
                      'Update Status',
                      style: GoogleFonts.poppins(
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(height: 12),
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: ['Pending', 'Confirmed', 'Completed', 'Cancelled'].map((s) {
                        final isCurrent = b.status == s;
                        return GestureDetector(
                          onTap: isCurrent ? null : () {
                            Navigator.pop(context);
                            _updateStatus(b, s);
                          },
                          child: Container(
                            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                            decoration: BoxDecoration(
                              color: isCurrent ? AppColors.primary : Colors.white.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(25),
                              border: Border.all(
                                color: isCurrent ? AppColors.primary : Colors.white.withOpacity(0.2),
                              ),
                            ),
                            child: Text(
                              s,
                              style: GoogleFonts.poppins(
                                color: isCurrent ? Colors.white : Colors.white70,
                                fontWeight: FontWeight.w600,
                                fontSize: 13,
                              ),
                            ),
                          ),
                        );
                      }).toList(),
                    ),
                    
                    const SizedBox(height: 16),
                    
                    Text(
                      'Update Payment',
                      style: GoogleFonts.poppins(
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(height: 12),
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: ['Pending', 'Partial', 'Paid'].map((s) {
                        final isCurrent = b.paymentStatus == s;
                        return GestureDetector(
                          onTap: isCurrent ? null : () {
                            Navigator.pop(context);
                            _updatePayment(b, s);
                          },
                          child: Container(
                            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                            decoration: BoxDecoration(
                              color: isCurrent ? AppColors.success : Colors.white.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(25),
                              border: Border.all(
                                color: isCurrent ? AppColors.success : Colors.white.withOpacity(0.2),
                              ),
                            ),
                            child: Text(
                              s,
                              style: GoogleFonts.poppins(
                                color: isCurrent ? Colors.white : Colors.white70,
                                fontWeight: FontWeight.w600,
                                fontSize: 13,
                              ),
                            ),
                          ),
                        );
                      }).toList(),
                    ),
                    
                    const SizedBox(height: 30),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final pendingCount = _bookings.where((b) => b.status == 'Pending').length;
    final confirmedCount = _bookings.where((b) => b.status == 'Confirmed').length;
    
    return Scaffold(
      backgroundColor: const Color(0xFF003158),
      body: RefreshIndicator(
        onRefresh: _fetchBookings,
        child: CustomScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          slivers: [
            // Simple Sticky Header - Just Back Button and Title
            SliverPersistentHeader(
              pinned: true,
              delegate: StickyHeaderDelegate(
                minHeight: 80,
                maxHeight: 80,
                child: Container(
                  color: const Color(0xFF003158),
                  child: SafeArea(
                    bottom: false,
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      height: 80,
                      child: Row(
                        children: [
                          // Back Button only
                          GestureDetector(
                            onTap: () => Navigator.pop(context),
                            child: Container(
                              padding: const EdgeInsets.all(10),
                              decoration: BoxDecoration(
                                color: Colors.white.withOpacity(0.1),
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(
                                  color: Colors.white.withOpacity(0.15),
                                ),
                              ),
                              child: const Icon(
                                Icons.arrow_back,
                                color: Colors.white70,
                                size: 24,
                              ),
                            ),
                          ),
                          const SizedBox(width: 12),
                          
                          // Title
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Text(
                                  "Booking Management",
                                  style: GoogleFonts.poppins(
                                    fontSize: 20,
                                    fontWeight: FontWeight.w700,
                                    color: Colors.white,
                                  ),
                                  overflow: TextOverflow.ellipsis,
                                ),
                                const SizedBox(height: 2),
                                Text(
                                  "${_filtered.length} total bookings",
                                  style: GoogleFonts.poppins(
                                    fontSize: 13,
                                    color: Colors.white70,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          
                          // Refresh Button
                          GestureDetector(
                            onTap: _fetchBookings,
                            child: Container(
                              padding: const EdgeInsets.all(10),
                              decoration: BoxDecoration(
                                color: Colors.white.withOpacity(0.1),
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(
                                  color: Colors.white.withOpacity(0.15),
                                ),
                              ),
                              child: const Icon(
                                Icons.refresh,
                                color: Colors.white70,
                                size: 24,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ),
            
            // Search and Filters
            SliverToBoxAdapter(
              child: Container(
                padding: const EdgeInsets.all(16),
                child: Column(
                  children: [
                    // Stats Row
                    Row(
                      children: [
                        Expanded(
                          child: StatCard(
                            title: 'Total Bookings',
                            value: '${_filtered.length}',
                            icon: Icons.book_online,
                            color: Colors.tealAccent,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: StatCard(
                            title: 'Pending',
                            value: '$pendingCount',
                            icon: Icons.pending_actions,
                            color: Colors.orangeAccent,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: StatCard(
                            title: 'Confirmed',
                            value: '$confirmedCount',
                            icon: Icons.check_circle,
                            color: Colors.greenAccent,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    
                    // Search Bar - FIXED COLORS
                    Container(
                      decoration: BoxDecoration(
                        color: Colors.grey.shade100,  // Light background
                        borderRadius: BorderRadius.circular(14),
                        border: Border.all(color: Colors.grey.shade300),
                      ),
                      child: TextField(
                        style: GoogleFonts.poppins(
                          color: Colors.grey.shade800,  // Dark text
                          fontSize: 14,
                        ),
                        decoration: InputDecoration(
                          hintText: 'Search by name or oasis...',
                          hintStyle: GoogleFonts.poppins(
                            color: Colors.grey.shade500,  // Gray hint text
                            fontSize: 13,
                          ),
                          prefixIcon: Icon(Icons.search, color: Colors.grey.shade600, size: 20),
                          border: InputBorder.none,
                          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                        ),
                        onChanged: (v) => setState(() => _search = v),
                      ),
                    ),
                    
                    const SizedBox(height: 12),
                    
                    // Status Filters
                    SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      child: Row(
                        children: _statuses.map((s) {
                          final sel = s == _statusFilter;
                          return Padding(
                            padding: const EdgeInsets.only(right: 8),
                            child: GestureDetector(
                              onTap: () => setState(() => _statusFilter = s),
                              child: Container(
                                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                                decoration: BoxDecoration(
                                  color: sel ? AppColors.primary : Colors.white.withOpacity(0.1),
                                  borderRadius: BorderRadius.circular(25),
                                  border: Border.all(
                                    color: sel ? AppColors.primary : Colors.white.withOpacity(0.2),
                                  ),
                                ),
                                child: Text(
                                  s,
                                  style: GoogleFonts.poppins(
                                    color: sel ? Colors.white : Colors.white70,
                                    fontWeight: FontWeight.w600,
                                    fontSize: 12,
                                  ),
                                ),
                              ),
                            ),
                          );
                        }).toList(),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            
            // Bookings List
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: _loading
                    ? const LoadingWidget(message: 'Loading bookings...')
                    : _filtered.isEmpty
                        ? const EmptyState(
                            message: 'No bookings found',
                            icon: Icons.book_online_outlined,
                          )
                        : ListView.separated(
                            shrinkWrap: true,
                            physics: const NeverScrollableScrollPhysics(),
                            itemCount: _filtered.length,
                            separatorBuilder: (_, __) => const SizedBox(height: 12),
                            itemBuilder: (_, i) {
                              final b = _filtered[i];
                              return GestureDetector(
                                onTap: () => _showBookingDetails(b),
                                child: GlassCard(
                                  padding: const EdgeInsets.all(16),
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Row(
                                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                        children: [
                                          Expanded(
                                            child: Text(
                                              b.customerName,
                                              style: GoogleFonts.poppins(
                                                fontWeight: FontWeight.w700,
                                                fontSize: 16,
                                                color: Colors.white,
                                              ),
                                            ),
                                          ),
                                          StatusBadge(b.status),
                                        ],
                                      ),
                                      const SizedBox(height: 8),
                                      Row(
                                        children: [
                                          const Icon(Icons.pool, size: 14, color: Colors.white54),
                                          const SizedBox(width: 4),
                                          Text(
                                            '${b.oasis} · ${b.package}',
                                            style: GoogleFonts.poppins(
                                              fontSize: 12,
                                              color: Colors.white70,
                                            ),
                                          ),
                                        ],
                                      ),
                                      const SizedBox(height: 4),
                                      Row(
                                        children: [
                                          const Icon(Icons.calendar_today, size: 14, color: Colors.white54),
                                          const SizedBox(width: 4),
                                          Text(
                                            DateFormat('MMM d, yyyy').format(b.bookingDate),
                                            style: GoogleFonts.poppins(
                                              fontSize: 12,
                                              color: Colors.white70,
                                            ),
                                          ),
                                          const Spacer(),
                                          StatusBadge(b.paymentStatus),
                                        ],
                                      ),
                                      const SizedBox(height: 8),
                                      Divider(
                                        color: Colors.white.withOpacity(0.1),
                                        height: 1,
                                      ),
                                      const SizedBox(height: 8),
                                      Row(
                                        children: [
                                          const Icon(Icons.payments_outlined, size: 14, color: Colors.white54),
                                          const SizedBox(width: 4),
                                          Text(
                                            formatPeso(b.downpayment),
                                            style: GoogleFonts.poppins(
                                              fontSize: 13,
                                              fontWeight: FontWeight.w600,
                                              color: AppColors.accentGold,
                                            ),
                                          ),
                                          Text(
                                            ' via ${b.paymentMethod}',
                                            style: GoogleFonts.poppins(
                                              fontSize: 12,
                                              color: Colors.white70,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ],
                                  ),
                                ),
                              );
                            },
                          ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _DetailRow extends StatelessWidget {
  final String label;
  final String value;
  
  const _DetailRow(this.label, this.value);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 110,
            child: Text(
              label,
              style: GoogleFonts.poppins(
                color: Colors.white70,
                fontSize: 13,
              ),
            ),
          ),
          Text(
            ':',
            style: GoogleFonts.poppins(color: Colors.white70, fontSize: 13),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              value,
              style: GoogleFonts.poppins(
                fontWeight: FontWeight.w600,
                fontSize: 13,
                color: Colors.white,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// StickyHeaderDelegate
class StickyHeaderDelegate extends SliverPersistentHeaderDelegate {
  final double minHeight;
  final double maxHeight;
  final Widget child;

  StickyHeaderDelegate({
    required this.minHeight,
    required this.maxHeight,
    required this.child,
  });

  @override
  double get minExtent => minHeight;
  
  @override
  double get maxExtent => maxHeight;

  @override
  Widget build(BuildContext context, double shrinkOffset, bool overlapsContent) {
    return SizedBox(
      height: maxHeight,
      child: child,
    );
  }

  @override
  bool shouldRebuild(covariant StickyHeaderDelegate oldDelegate) {
    return oldDelegate.minHeight != minHeight ||
        oldDelegate.maxHeight != maxHeight ||
        oldDelegate.child != child;
  }
}