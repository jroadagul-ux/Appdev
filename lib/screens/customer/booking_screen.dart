// lib/screens/customer/booking_screen.dart
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../../config/app_theme.dart';
import '../../config/package_data.dart';
import '../../services/api_service.dart';
import '../../services/auth_provider.dart';
import '../../services/local_storage_service.dart';
import '../../widgets/core/glass_card.dart';

class BookingScreen extends StatefulWidget {
  const BookingScreen({super.key});
  @override
  State<BookingScreen> createState() => _BookingScreenState();
}

class _BookingScreenState extends State<BookingScreen> {
  int _step = 0;
  final _formKey = GlobalKey<FormState>();
  bool _loading = false;

  // Step 1 - Date & Oasis
  String _selectedOasis = 'Oasis 1';
  DateTime? _selectedDate;
  String _selectedSession = 'Day';

  // Step 2 - Package
  String? _selectedPackage;
  List<String> _selectedAddons = [];

  // Step 3 - Guest Info
  final _nameCtrl = TextEditingController();
  final _contactCtrl = TextEditingController();
  final _emailCtrl = TextEditingController();
  final _paxCtrl = TextEditingController(text: '1');

  // Step 4 - Payment
  String _paymentMethod = 'GCash';
  double _downpayment = 0;

  final List<String> _sessions = ['Day', 'Night', '22hrs'];
  final List<String> _paymentMethods = ['GCash', 'Maya', 'GoTyme', 'SeaBank', 'Cash'];

  @override
  void dispose() {
    _nameCtrl.dispose();
    _contactCtrl.dispose();
    _emailCtrl.dispose();
    _paxCtrl.dispose();
    super.dispose();
  }

  Map<String, OasisPackage> get _currentPackages =>
      oasisPackages[_selectedOasis] ?? {};

  OasisPackage? get _currentPkg =>
      _selectedPackage != null ? _currentPackages[_selectedPackage] : null;

  double get _computedPrice {
    final pkg = _currentPkg;
    if (pkg == null) return 0;
    final pricing = pkg.pricing[_selectedSession];
    if (pricing == null) return 0;
    final isWeekend = _selectedDate != null &&
        (_selectedDate!.weekday == DateTime.saturday ||
            _selectedDate!.weekday == DateTime.sunday);
    return (isWeekend ? pricing.weekend : pricing.weekday)?.toDouble() ?? 0;
  }

  void _nextStep() {
    if (_step == 0 && _selectedDate == null) {
      _showSnack('Please select a date');
      return;
    }
    if (_step == 1 && _selectedPackage == null) {
      _showSnack('Please select a package');
      return;
    }
    if (_step == 2 && !_formKey.currentState!.validate()) return;
    if (_step < 3) setState(() => _step++);
  }

  void _showSnack(String msg) {
    ScaffoldMessenger.of(context)
        .showSnackBar(SnackBar(content: Text(msg), backgroundColor: AppColors.error));
  }

  Future<void> _submitBooking() async {
    setState(() => _loading = true);
    try {
      final auth = context.read<AuthProvider>();
      
      final bookingData = {
        'userId': auth.user?.id,
        'customerName': _nameCtrl.text.trim(),
        'customerContact': _contactCtrl.text.trim(),
        'customerEmail': _emailCtrl.text.trim(),
        'oasis': _selectedOasis,
        'package': _selectedPackage,
        'bookingDate': _selectedDate!.toIso8601String(),
        'session': _selectedSession,
        'pax': int.tryParse(_paxCtrl.text) ?? 1,
        'downpayment': _downpayment,
        'paymentMethod': _paymentMethod,
        'addons': _selectedAddons,
      };

      final result = await ApiService.post('/api/bookings', bookingData, auth: false);

      if (!mounted) return;
      setState(() => _loading = false);

      // Check if booking was successfully created
      if (result != null && (result['_id'] != null || result['booking'] != null || result['success'] == true)) {
        try {
          // Save booking to local storage so it appears in My Bookings immediately
          await LocalStorageService.addBooking(bookingData);
        } catch (e) {
          print('Error saving to local storage: $e');
        }
        
        // Show success notification with correct green color
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text(
                'Booking successfully created!',
                style: TextStyle(color: Colors.white, fontWeight: FontWeight.w600),
              ),
              backgroundColor: Color(0xFF4CAF50), // Green success color
              duration: Duration(seconds: 2),
              behavior: SnackBarBehavior.floating,
              margin: EdgeInsets.all(16),
            ),
          );
        }
        
        // Navigate to receipt page
        if (mounted) {
          await Future.delayed(const Duration(milliseconds: 800));
          if (mounted) {
            Navigator.pushReplacementNamed(
              context,
              '/booking-receipt',
              arguments: {
                ...bookingData,
                'bookingId': result['_id'] ?? result['booking']?['_id'] ?? 'pending',
              },
            );
          }
        }
      } else {
        final errorMsg = result?['message'] ?? 'Booking failed. Please try again.';
        _showSnack(errorMsg);
      }
    } catch (e) {
      if (mounted) {
        setState(() => _loading = false);
      }
      _showSnack('Network error: ${e.toString()}');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF003158),
      appBar: AppBar(
        title: Text('Book a Reservation',
            style: GoogleFonts.poppins(fontWeight: FontWeight.w700, color: Colors.white)),
        backgroundColor: const Color(0xFF003158),
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () {
            if (_step > 0) {
              setState(() => _step--);
            } else {
              Navigator.pop(context);
            }
          },
        ),
      ),
      body: Column(
        children: [
          _StepIndicator(currentStep: _step),
          Expanded(
            child: Form(
              key: _formKey,
              child: _buildStep(),
            ),
          ),
          _BottomBar(
            step: _step,
            loading: _loading,
            onNext: _step < 3 ? _nextStep : _submitBooking,
          ),
        ],
      ),
    );
  }

  Widget _buildStep() {
    switch (_step) {
      case 0:
        return _DateStep(
          selectedOasis: _selectedOasis,
          selectedDate: _selectedDate,
          selectedSession: _selectedSession,
          sessions: _sessions,
          onOasisChanged: (v) => setState(() {
            _selectedOasis = v;
            _selectedPackage = null;
          }),
          onDateChanged: (d) => setState(() => _selectedDate = d),
          onSessionChanged: (s) => setState(() => _selectedSession = s),
        );
      case 1:
        return _PackageStep(
          oasis: _selectedOasis,
          packages: _currentPackages,
          selectedPackage: _selectedPackage,
          selectedSession: _selectedSession,
          selectedDate: _selectedDate,
          selectedAddons: _selectedAddons,
          onPackageChanged: (p) => setState(() {
            _selectedPackage = p;
            _selectedAddons = [];
            final pkg = _currentPackages[p];
            final pricing = pkg?.pricing[_selectedSession];
            if (pricing != null) {
              final isWeekend = _selectedDate != null &&
                  (_selectedDate!.weekday == DateTime.saturday ||
                      _selectedDate!.weekday == DateTime.sunday);
              final price = (isWeekend ? pricing.weekend : pricing.weekday)?.toDouble() ?? 0;
              _downpayment = price * 0.3;
            }
          }),
          onAddonsChanged: (a) => setState(() => _selectedAddons = a),
        );
      case 2:
        return _GuestInfoStep(
          nameCtrl: _nameCtrl,
          contactCtrl: _contactCtrl,
          emailCtrl: _emailCtrl,
          paxCtrl: _paxCtrl,
        );
      case 3:
        return _ReviewStep(
          oasis: _selectedOasis,
          package: _selectedPackage ?? '',
          session: _selectedSession,
          date: _selectedDate,
          name: _nameCtrl.text,
          contact: _contactCtrl.text,
          pax: _paxCtrl.text,
          totalPrice: _computedPrice,
          downpayment: _downpayment,
          paymentMethod: _paymentMethod,
          paymentMethods: _paymentMethods,
          addons: _selectedAddons,
          onDownpaymentChanged: (v) => setState(() => _downpayment = v),
          onPaymentMethodChanged: (v) => setState(() => _paymentMethod = v),
        );
      default:
        return const SizedBox.shrink();
    }
  }
}

// ============================================
// STEP INDICATOR
// ============================================
class _StepIndicator extends StatelessWidget {
  final int currentStep;
  const _StepIndicator({required this.currentStep});

  @override
  Widget build(BuildContext context) {
    final steps = ['Date', 'Package', 'Guest Info', 'Review'];
    return Container(
      color: const Color(0xFF003158),
      padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 16),
      child: Row(
        children: List.generate(steps.length, (i) {
          final isActive = i == currentStep;
          final isDone = i < currentStep;
          return Expanded(
            child: Row(
              children: [
                Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      width: 30,
                      height: 30,
                      decoration: BoxDecoration(
                        color: isDone
                            ? AppColors.success
                            : isActive
                                ? AppColors.primary
                                : Colors.white.withOpacity(0.2),
                        shape: BoxShape.circle,
                      ),
                      child: Center(
                        child: isDone
                            ? const Icon(Icons.check, color: Colors.white, size: 16)
                            : Text('${i + 1}',
                                style: TextStyle(
                                    color: isActive ? Colors.white : Colors.white70,
                                    fontSize: 12,
                                    fontWeight: FontWeight.w700)),
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(steps[i],
                        style: GoogleFonts.poppins(
                            fontSize: 10,
                            color: isActive ? AppColors.primary : Colors.white54,
                            fontWeight: isActive ? FontWeight.w700 : FontWeight.w400)),
                  ],
                ),
                if (i < steps.length - 1)
                  Expanded(
                    child: Container(
                      height: 2,
                      margin: const EdgeInsets.only(bottom: 16),
                      color: isDone ? AppColors.success : Colors.white.withOpacity(0.2),
                    ),
                  ),
              ],
            ),
          );
        }),
      ),
    );
  }
}

// ============================================
// BOTTOM BAR - Button already blue
// ============================================
class _BottomBar extends StatelessWidget {
  final int step;
  final bool loading;
  final VoidCallback onNext;

  const _BottomBar({required this.step, required this.loading, required this.onNext});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF003158),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.2),
            blurRadius: 8,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: SizedBox(
        width: double.infinity,
        height: 52,
        child: ElevatedButton(
          onPressed: loading ? null : onNext,
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColors.primary,
            foregroundColor: Colors.white,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(14),
            ),
          ),
          child: loading
              ? const SizedBox(
                  height: 22,
                  width: 22,
                  child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2.5))
              : Text(
                  step < 3 ? 'Continue' : 'Confirm Booking',
                  style: GoogleFonts.poppins(fontWeight: FontWeight.w700, fontSize: 16, color: Colors.white),
                ),
        ),
      ),
    );
  }
}

// ============================================
// STEP 1 - DATE
// ============================================
class _DateStep extends StatelessWidget {
  final String selectedOasis;
  final DateTime? selectedDate;
  final String selectedSession;
  final List<String> sessions;
  final ValueChanged<String> onOasisChanged;
  final ValueChanged<DateTime> onDateChanged;
  final ValueChanged<String> onSessionChanged;

  const _DateStep({
    required this.selectedOasis,
    required this.selectedDate,
    required this.selectedSession,
    required this.sessions,
    required this.onOasisChanged,
    required this.onDateChanged,
    required this.onSessionChanged,
  });

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Select Oasis & Date',
              style: GoogleFonts.poppins(fontSize: 18, fontWeight: FontWeight.w700, color: Colors.white)),
          const SizedBox(height: 16),

          // Oasis selector
          Text('Choose Oasis', style: GoogleFonts.poppins(fontWeight: FontWeight.w600, color: Colors.white70)),
          const SizedBox(height: 8),
          Row(
            children: ['Oasis 1', 'Oasis 2'].map((o) {
              final selected = o == selectedOasis;
              return Expanded(
                child: GestureDetector(
                  onTap: () => onOasisChanged(o),
                  child: Container(
                    margin: EdgeInsets.only(right: o == 'Oasis 1' ? 8 : 0),
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    decoration: BoxDecoration(
                      color: selected ? AppColors.primary : Colors.white.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(
                          color: selected ? AppColors.primary : Colors.white.withOpacity(0.2)),
                    ),
                    child: Column(
                      children: [
                        Icon(Icons.pool,
                            color: selected ? Colors.white : Colors.white70),
                        const SizedBox(height: 6),
                        Text(o,
                            style: GoogleFonts.poppins(
                                color: selected ? Colors.white : Colors.white70,
                                fontWeight: FontWeight.w700)),
                      ],
                    ),
                  ),
                ),
              );
            }).toList(),
          ),
          const SizedBox(height: 20),

          // Date picker
          Text('Select Date', style: GoogleFonts.poppins(fontWeight: FontWeight.w600, color: Colors.white70)),
          const SizedBox(height: 8),
          GestureDetector(
            onTap: () async {
              final picked = await showDatePicker(
                context: context,
                initialDate: DateTime.now().add(const Duration(days: 1)),
                firstDate: DateTime.now(),
                lastDate: DateTime.now().add(const Duration(days: 365)),
              );
              if (picked != null) onDateChanged(picked);
            },
            child: Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.1),
                borderRadius: BorderRadius.circular(14),
                border: Border.all(
                    color: selectedDate != null ? AppColors.primary : Colors.white.withOpacity(0.2),
                    width: selectedDate != null ? 2 : 1),
              ),
              child: Row(
                children: [
                  Icon(Icons.calendar_today,
                      color: selectedDate != null ? AppColors.primary : Colors.white54),
                  const SizedBox(width: 12),
                  Text(
                    selectedDate != null
                        ? DateFormat('EEEE, MMMM d, yyyy').format(selectedDate!)
                        : 'Tap to select date',
                    style: GoogleFonts.poppins(
                        color: selectedDate != null ? Colors.white : Colors.white54,
                        fontSize: 14),
                  ),
                ],
              ),
            ),
          ),

          if (selectedDate != null) ...[
            const SizedBox(height: 8),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: (selectedDate!.weekday == DateTime.saturday ||
                            selectedDate!.weekday == DateTime.sunday)
                        ? AppColors.warning.withOpacity(0.15)
                        : AppColors.success.withOpacity(0.15),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                (selectedDate!.weekday == DateTime.saturday ||
                        selectedDate!.weekday == DateTime.sunday)
                    ? '📅 Weekend rate applies'
                    : '📅 Weekday rate applies',
                style: GoogleFonts.poppins(
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                    color: (selectedDate!.weekday == DateTime.saturday ||
                            selectedDate!.weekday == DateTime.sunday)
                        ? AppColors.warning
                        : AppColors.success),
              ),
            ),
          ],

          const SizedBox(height: 20),

          // Session
          Text('Session Type', style: GoogleFonts.poppins(fontWeight: FontWeight.w600, color: Colors.white70)),
          const SizedBox(height: 8),
          Row(
            children: sessions.map((s) {
              final selected = s == selectedSession;
              return Expanded(
                child: GestureDetector(
                  onTap: () => onSessionChanged(s),
                  child: Container(
                    margin: const EdgeInsets.only(right: 8),
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    decoration: BoxDecoration(
                      color: selected ? AppColors.primary.withOpacity(0.2) : Colors.white.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                          color: selected ? AppColors.primary : Colors.white.withOpacity(0.2)),
                    ),
                    child: Column(
                      children: [
                        Icon(
                          s == 'Day' ? Icons.wb_sunny : s == 'Night' ? Icons.nightlight : Icons.access_time,
                          color: selected ? AppColors.primary : Colors.white54,
                          size: 20,
                        ),
                        const SizedBox(height: 4),
                        Text(s,
                            style: GoogleFonts.poppins(
                                fontSize: 12,
                                color: selected ? AppColors.primary : Colors.white70,
                                fontWeight: selected ? FontWeight.w700 : FontWeight.w400)),
                      ],
                    ),
                  ),
                ),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }
}

// ============================================
// STEP 2 - PACKAGE
// ============================================
class _PackageStep extends StatelessWidget {
  final String oasis;
  final Map<String, OasisPackage> packages;
  final String? selectedPackage;
  final String selectedSession;
  final DateTime? selectedDate;
  final List<String> selectedAddons;
  final ValueChanged<String> onPackageChanged;
  final ValueChanged<List<String>> onAddonsChanged;

  const _PackageStep({
    required this.oasis,
    required this.packages,
    required this.selectedPackage,
    required this.selectedSession,
    required this.selectedDate,
    required this.selectedAddons,
    required this.onPackageChanged,
    required this.onAddonsChanged,
  });

  bool get _isWeekend =>
      selectedDate != null &&
      (selectedDate!.weekday == DateTime.saturday ||
          selectedDate!.weekday == DateTime.sunday);

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Choose Package',
              style: GoogleFonts.poppins(fontSize: 18, fontWeight: FontWeight.w700, color: Colors.white)),
          Text('$oasis · $selectedSession',
              style: GoogleFonts.poppins(color: Colors.white54, fontSize: 13)),
          const SizedBox(height: 16),
          ...packages.entries.map((e) {
            final pkg = e.value;
            final isSelected = selectedPackage == e.key;
            final pricing = pkg.pricing[selectedSession];
            final price = pricing != null
                ? (_isWeekend ? pricing.weekend : pricing.weekday)
                : null;

            return GestureDetector(
              onTap: () => onPackageChanged(e.key),
              child: Container(
                margin: const EdgeInsets.only(bottom: 12),
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: isSelected ? AppColors.primary.withOpacity(0.1) : Colors.white.withOpacity(0.08),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                      color: isSelected ? AppColors.primary : Colors.white.withOpacity(0.15),
                      width: isSelected ? 2 : 1),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(pkg.name,
                                  style: GoogleFonts.poppins(
                                      fontWeight: FontWeight.w700, fontSize: 15,
                                      color: isSelected ? AppColors.primary : Colors.white)),
                              Text(pkg.description,
                                  style: GoogleFonts.poppins(
                                      color: Colors.white54, fontSize: 12)),
                            ],
                          ),
                        ),
                        if (price != null)
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                            decoration: BoxDecoration(
                              color: AppColors.primary,
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: Text(
                              '₱${NumberFormat('#,##0').format(price)}',
                              style: GoogleFonts.poppins(
                                  color: Colors.white, fontWeight: FontWeight.w700, fontSize: 13),
                            ),
                          )
                        else
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                            decoration: BoxDecoration(
                              color: Colors.white.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: Text('N/A',
                                style: GoogleFonts.poppins(
                                    color: Colors.white54, fontSize: 12)),
                          ),
                      ],
                    ),
                    const SizedBox(height: 10),
                    ...pkg.inclusions.map((inc) => Padding(
                          padding: const EdgeInsets.only(bottom: 4),
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Icon(Icons.check_circle, color: AppColors.success, size: 14),
                              const SizedBox(width: 6),
                              Expanded(
                                  child: Text(inc,
                                      style: GoogleFonts.poppins(fontSize: 12, color: Colors.white70))),
                            ],
                          ),
                        )),
                    if (isSelected && pkg.addons.isNotEmpty) ...[
                      const Divider(height: 20, color: Colors.white24),
                      Text('Add-ons (optional)',
                          style: GoogleFonts.poppins(fontWeight: FontWeight.w600, fontSize: 13, color: Colors.white70)),
                      const SizedBox(height: 8),
                      ...pkg.addons.map((addon) {
                        final isAddonSelected = selectedAddons.contains(addon);
                        return CheckboxListTile(
                          dense: true,
                          value: isAddonSelected,
                          contentPadding: EdgeInsets.zero,
                          title: Text(addon, style: GoogleFonts.poppins(fontSize: 13, color: Colors.white)),
                          onChanged: (v) {
                            final updated = List<String>.from(selectedAddons);
                            if (v == true) {
                              updated.add(addon);
                            } else {
                              updated.remove(addon);
                            }
                            onAddonsChanged(updated);
                          },
                        );
                      }),
                    ],
                  ],
                ),
              ),
            );
          }),
        ],
      ),
    );
  }
}

// ============================================
// STEP 3 - GUEST INFO
// ============================================
class _GuestInfoStep extends StatelessWidget {
  final TextEditingController nameCtrl;
  final TextEditingController contactCtrl;
  final TextEditingController emailCtrl;
  final TextEditingController paxCtrl;

  const _GuestInfoStep({
    required this.nameCtrl,
    required this.contactCtrl,
    required this.emailCtrl,
    required this.paxCtrl,
  });

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Guest Information',
              style: GoogleFonts.poppins(fontSize: 18, fontWeight: FontWeight.w700, color: Colors.white)),
          const SizedBox(height: 20),
          _buildTextField(nameCtrl, 'Full Name *', Icons.person_outline),
          const SizedBox(height: 16),
          _buildTextField(contactCtrl, 'Contact Number *', Icons.phone_outlined, keyboardType: TextInputType.phone),
          const SizedBox(height: 16),
          _buildTextField(emailCtrl, 'Email Address (optional)', Icons.email_outlined, keyboardType: TextInputType.emailAddress),
          const SizedBox(height: 16),
          _buildTextField(paxCtrl, 'Number of Guests *', Icons.group_outlined, keyboardType: TextInputType.number),
        ],
      ),
    );
  }

  Widget _buildTextField(TextEditingController controller, String label, IconData icon,
      {TextInputType keyboardType = TextInputType.text}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: GoogleFonts.poppins(color: Colors.white70, fontSize: 13, fontWeight: FontWeight.w500)),
        const SizedBox(height: 6),
        Container(
          decoration: BoxDecoration(
            color: Colors.grey.shade50,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: Colors.grey.shade300),
          ),
          child: TextFormField(
            controller: controller,
            keyboardType: keyboardType,
            style: GoogleFonts.poppins(color: Colors.grey.shade800, fontSize: 15),
            validator: (v) => (v?.isEmpty ?? true) && label.contains('*') ? 'Required' : null,
            decoration: InputDecoration(
              hintText: 'Enter $label',
              hintStyle: GoogleFonts.poppins(color: Colors.grey.shade400, fontSize: 14),
              prefixIcon: Icon(icon, color: AppColors.primary, size: 22),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(14),
                borderSide: BorderSide.none,
              ),
              contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
            ),
          ),
        ),
      ],
    );
  }
}

// ============================================
// STEP 4 - REVIEW & PAYMENT
// ============================================
class _ReviewStep extends StatelessWidget {
  final String oasis, package, session;
  final DateTime? date;
  final String name, contact, pax;
  final double totalPrice, downpayment;
  final String paymentMethod;
  final List<String> paymentMethods;
  final List<String> addons;
  final ValueChanged<double> onDownpaymentChanged;
  final ValueChanged<String> onPaymentMethodChanged;

  const _ReviewStep({
    required this.oasis,
    required this.package,
    required this.session,
    required this.date,
    required this.name,
    required this.contact,
    required this.pax,
    required this.totalPrice,
    required this.downpayment,
    required this.paymentMethod,
    required this.paymentMethods,
    required this.addons,
    required this.onDownpaymentChanged,
    required this.onPaymentMethodChanged,
  });

  @override
  Widget build(BuildContext context) {
    final fmt = NumberFormat('#,##0');
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Review & Payment',
              style: GoogleFonts.poppins(fontSize: 18, fontWeight: FontWeight.w700, color: Colors.white)),
          const SizedBox(height: 16),

          // Summary card
          GlassCard(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Booking Summary',
                    style: GoogleFonts.poppins(fontWeight: FontWeight.w700, color: AppColors.primary)),
                const SizedBox(height: 12),
                _SummaryRow('Pool', oasis),
                _SummaryRow('Package', package),
                _SummaryRow('Session', session),
                _SummaryRow('Date', date != null ? DateFormat('MMM d, yyyy (EEEE)').format(date!) : '-'),
                _SummaryRow('Guests', pax),
                _SummaryRow('Name', name),
                _SummaryRow('Contact', contact),
                if (addons.isNotEmpty) _SummaryRow('Add-ons', addons.join(', ')),
                const Divider(height: 20, color: Colors.white24),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text('Total Price', style: GoogleFonts.poppins(fontWeight: FontWeight.w700, fontSize: 15, color: Colors.white)),
                    Text('₱${fmt.format(totalPrice)}',
                        style: GoogleFonts.poppins(
                            fontWeight: FontWeight.w800, fontSize: 18, color: AppColors.accentGold)),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),

          // Payment method - Updated chips with blue when selected
          Text('Payment Method', style: GoogleFonts.poppins(fontWeight: FontWeight.w600, color: Colors.white70)),
          const SizedBox(height: 8),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: paymentMethods.map((m) {
              final sel = m == paymentMethod;
              return GestureDetector(
                onTap: () => onPaymentMethodChanged(m),
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                  decoration: BoxDecoration(
                    color: sel ? AppColors.primary : Colors.white.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: sel ? AppColors.primary : Colors.white.withOpacity(0.2)),
                  ),
                  child: Text(m,
                      style: GoogleFonts.poppins(
                          color: sel ? Colors.white : Colors.white70,
                          fontWeight: FontWeight.w600, fontSize: 13)),
                ),
              );
            }).toList(),
          ),
          const SizedBox(height: 20),

          // Downpayment
          Text('Downpayment Amount', style: GoogleFonts.poppins(fontWeight: FontWeight.w600, color: Colors.white70)),
          const SizedBox(height: 4),
          Text('Minimum 30% required (₱${fmt.format(totalPrice * 0.3)})',
              style: GoogleFonts.poppins(color: Colors.white54, fontSize: 12)),
          const SizedBox(height: 8),
          Container(
            decoration: BoxDecoration(
              color: Colors.grey.shade50,
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: Colors.grey.shade300),
            ),
            child: TextFormField(
              initialValue: downpayment > 0 ? downpayment.toStringAsFixed(0) : '',
              keyboardType: TextInputType.number,
              style: GoogleFonts.poppins(color: Colors.grey.shade800, fontSize: 15),
              decoration: InputDecoration(
                labelText: 'Downpayment (₱)',
                labelStyle: GoogleFonts.poppins(color: Colors.grey.shade600, fontSize: 13),
                prefixIcon: const Icon(Icons.payments_outlined, color: AppColors.primary, size: 22),
                border: InputBorder.none,
                contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
              ),
              onChanged: (v) => onDownpaymentChanged(double.tryParse(v) ?? 0),
            ),
          ),
          const SizedBox(height: 16),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: AppColors.info.withOpacity(0.12),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: AppColors.info.withOpacity(0.3)),
            ),
            child: Row(
              children: [
                const Icon(Icons.info_outline, color: AppColors.info, size: 18),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    'Our team will contact you to confirm your booking and payment.',
                    style: GoogleFonts.poppins(fontSize: 12, color: AppColors.info),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _SummaryRow extends StatelessWidget {
  final String label, value;
  const _SummaryRow(this.label, this.value);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 90,
            child: Text(label,
                style: GoogleFonts.poppins(color: Colors.white70, fontSize: 13)),
          ),
          const Text(': ', style: TextStyle(color: Colors.white70)),
          Expanded(
            child: Text(value,
                style: GoogleFonts.poppins(fontWeight: FontWeight.w600, fontSize: 13, color: Colors.white)),
          ),
        ],
      ),
    );
  }
}