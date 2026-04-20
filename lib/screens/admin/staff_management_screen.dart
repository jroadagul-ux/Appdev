// lib/screens/admin/staff_management_screen.dart
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../config/app_theme.dart';
import '../../models/models.dart';
import '../../services/api_service.dart';
import '../../widgets/common_widgets.dart';
import '../../widgets/core/glass_card.dart';

class StaffManagementScreen extends StatefulWidget {
  const StaffManagementScreen({super.key});
  @override
  State<StaffManagementScreen> createState() => _StaffManagementScreenState();
}

class _StaffManagementScreenState extends State<StaffManagementScreen> {
  List<StaffModel> _staff = [];
  bool _loading = true;
  String _searchQuery = '';

  @override
  void initState() {
    super.initState();
    _fetchStaff();
  }

  Future<void> _fetchStaff() async {
    setState(() => _loading = true);
    try {
      final result = await ApiService.get('/api/admin/staff');
      if (result is Map && result['staff'] is List) {
        setState(() {
          _staff = (result['staff'] as List).map((s) => StaffModel.fromJson(s)).toList();
          _loading = false;
        });
      } else if (result is List) {
        setState(() {
          _staff = result.map((s) => StaffModel.fromJson(s)).toList();
          _loading = false;
        });
      } else {
        setState(() => _loading = false);
      }
    } catch (e) {
      print('Error fetching staff: $e');
      setState(() => _loading = false);
    }
  }

  List<StaffModel> get _filtered => _staff
      .where((s) =>
          s.name.toLowerCase().contains(_searchQuery.toLowerCase()) ||
          s.email.toLowerCase().contains(_searchQuery.toLowerCase()) ||
          s.position.toLowerCase().contains(_searchQuery.toLowerCase()))
      .toList();

  void _showStaffDialog({StaffModel? staff}) {
    final nameCtrl = TextEditingController(text: staff?.name ?? '');
    final emailCtrl = TextEditingController(text: staff?.email ?? '');
    final passwordCtrl = TextEditingController();
    String role = staff?.role ?? 'staff';
    String position = staff?.position ?? 'Housekeeper';
    String status = staff?.status ?? 'Active';
    final formKey = GlobalKey<FormState>();

    final positions = ['Receptionist', 'Housekeeper', 'Manager', 'Maintenance', 'Chef', 'Other'];

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => StatefulBuilder(
        builder: (ctx, setModal) => Dialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
          backgroundColor: const Color(0xFF003158),
          child: Container(
            padding: const EdgeInsets.all(24),
            child: Form(
              key: formKey,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          color: AppColors.primary.withOpacity(0.2),
                          borderRadius: BorderRadius.circular(14),
                        ),
                        child: Icon(
                          staff == null ? Icons.person_add : Icons.edit,
                          color: AppColors.primary,
                          size: 28,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          staff == null ? 'Add Staff' : 'Edit Staff',
                          style: GoogleFonts.poppins(
                            fontSize: 20,
                            fontWeight: FontWeight.w700,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),
                  
                  // Name Field
                  _buildDialogTextField(
                    nameCtrl,
                    'Full Name',
                    Icons.person,
                    validator: (value) => value?.isEmpty == true ? 'Name is required' : null,
                  ),
                  const SizedBox(height: 16),
                  
                  // Email Field
                  _buildDialogTextField(
                    emailCtrl,
                    'Email',
                    Icons.email,
                    validator: (value) {
                      if (value?.isEmpty == true) return 'Email is required';
                      if (!value!.contains('@')) return 'Enter a valid email';
                      return null;
                    },
                  ),
                  const SizedBox(height: 16),
                  
                  // Password Field (only for new staff)
                  if (staff == null)
                    _buildDialogTextField(
                      passwordCtrl,
                      'Password',
                      Icons.lock,
                      obscureText: true,
                      validator: (value) => value?.isEmpty == true ? 'Password is required' : null,
                    ),
                  if (staff == null) const SizedBox(height: 16),
                  
                  // Role Dropdown
                  _buildDialogDropdown(
                    initialValue: role,
                    label: 'Role',
                    items: ['staff', 'admin'],
                    onChanged: (v) => setModal(() => role = v!),
                  ),
                  const SizedBox(height: 16),
                  
                  // Position Dropdown
                  _buildDialogDropdown(
                    initialValue: position,
                    label: 'Position',
                    items: positions,
                    onChanged: (v) => setModal(() => position = v!),
                  ),
                  const SizedBox(height: 16),
                  
                  // Status Dropdown
                  _buildDialogDropdown(
                    initialValue: status,
                    label: 'Status',
                    items: ['Active', 'Disabled'],
                    onChanged: (v) => setModal(() => status = v!),
                  ),
                  
                  const SizedBox(height: 24),
                  
                  Row(
                    children: [
                      Expanded(
                        child: OutlinedButton(
                          onPressed: () => Navigator.pop(ctx),
                          style: OutlinedButton.styleFrom(
                            side: BorderSide(color: Colors.white.withOpacity(0.3)),
                            padding: const EdgeInsets.symmetric(vertical: 14),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                          ),
                          child: Text(
                            'Cancel',
                            style: GoogleFonts.poppins(color: Colors.white70, fontSize: 15),
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: ElevatedButton(
                          onPressed: () async {
                            if (formKey.currentState!.validate()) {
                              Navigator.pop(ctx);
                              
                              showDialog(
                                context: context,
                                barrierDismissible: false,
                                builder: (_) => const Center(child: CircularProgressIndicator()),
                              );
                              
                              final body = {
                                'name': nameCtrl.text.trim(),
                                'email': emailCtrl.text.trim(),
                                'role': role,
                                'position': position,
                                'status': status,
                                if (staff == null && passwordCtrl.text.isNotEmpty)
                                  'password': passwordCtrl.text,
                              };
                              
                              try {
                                if (staff == null) {
                                  await ApiService.post('/api/admin/staff', body);
                                  if (mounted) {
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      const SnackBar(content: Text('Staff added successfully')),
                                    );
                                  }
                                } else {
                                  await ApiService.put('/api/admin/staff/${staff.id}', body);
                                  if (mounted) {
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      const SnackBar(content: Text('Staff updated successfully')),
                                    );
                                  }
                                }
                                if (mounted) Navigator.pop(context);
                                _fetchStaff();
                              } catch (e) {
                                if (mounted) Navigator.pop(context);
                                if (mounted) {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(content: Text('Error: $e')),
                                  );
                                }
                              }
                            }
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.primary,
                            padding: const EdgeInsets.symmetric(vertical: 14),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                          ),
                          child: Text(
                            staff == null ? 'Add Staff' : 'Save Changes',
                            style: GoogleFonts.poppins(fontWeight: FontWeight.w600, fontSize: 15),
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildDialogTextField(
    TextEditingController controller,
    String label,
    IconData icon, {
    bool obscureText = false,
    String? Function(String?)? validator,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.grey.shade50,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: Colors.grey.shade300),
      ),
      child: TextFormField(
        controller: controller,
        obscureText: obscureText,
        style: GoogleFonts.poppins(
          color: Colors.grey.shade800,
          fontSize: 14,
        ),
        validator: validator,
        decoration: InputDecoration(
          labelText: label,
          labelStyle: GoogleFonts.poppins(
            color: Colors.grey.shade600,
            fontSize: 13,
          ),
          prefixIcon: Icon(icon, color: AppColors.primary, size: 20),
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        ),
      ),
    );
  }

  Widget _buildDialogDropdown({
    required String initialValue,
    required String label,
    required List<String> items,
    required ValueChanged<String?> onChanged,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.grey.shade50,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: Colors.grey.shade300),
      ),
      child: DropdownButtonFormField<String>(
        initialValue: initialValue,
        dropdownColor: const Color(0xFF003158),
        style: GoogleFonts.poppins(
          color: Colors.grey.shade800,
          fontSize: 14,
        ),
        decoration: InputDecoration(
          labelText: label,
          labelStyle: GoogleFonts.poppins(
            color: Colors.grey.shade600,
            fontSize: 13,
          ),
          prefixIcon: const Icon(Icons.flag, color: AppColors.primary, size: 20),
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        ),
        items: items.map((item) {
          Color itemColor = Colors.white;
          if (item == 'Admin') itemColor = AppColors.primary;
          if (item == 'Disabled') itemColor = AppColors.error;
          if (item == 'Active') itemColor = AppColors.success;
          
          return DropdownMenuItem(
            value: item,
            child: Text(
              item,
              style: GoogleFonts.poppins(
                color: item == 'Disabled' ? AppColors.error : 
                       item == 'Active' ? AppColors.success : Colors.white,
                fontWeight: FontWeight.w500,
              ),
            ),
          );
        }).toList(),
        onChanged: onChanged,
      ),
    );
  }

  Future<void> _toggleStatus(StaffModel staff) async {
    final newStatus = staff.status == 'Active' ? 'Disabled' : 'Active';
    
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => const Center(child: CircularProgressIndicator()),
    );
    
    try {
      await ApiService.patch('/api/admin/staff/${staff.id}/status', {'status': newStatus});
      if (mounted) Navigator.pop(context);
      _fetchStaff();
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Staff ${newStatus.toLowerCase()} successfully')),
        );
      }
    } catch (e) {
      if (mounted) Navigator.pop(context);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error updating status: $e')),
        );
      }
    }
  }

  Future<void> _deleteStaff(StaffModel staff) async {
    final confirmed = await showConfirmDialog(
      context,
      title: 'Delete Staff',
      message: 'Delete "${staff.name}"? This action cannot be undone.',
      confirmLabel: 'Delete',
    );
    if (confirmed == true) {
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (_) => const Center(child: CircularProgressIndicator()),
      );
      
      try {
        await ApiService.delete('/api/admin/staff/${staff.id}');
        if (mounted) Navigator.pop(context);
        _fetchStaff();
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Staff deleted successfully')),
          );
        }
      } catch (e) {
        if (mounted) Navigator.pop(context);
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Error deleting staff: $e')),
          );
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final activeCount = _staff.where((s) => s.status == 'Active').length;
    final disabledCount = _staff.where((s) => s.status == 'Disabled').length;
    final adminCount = _staff.where((s) => s.role == 'admin').length;

    return Scaffold(
      backgroundColor: const Color(0xFF003158),
      body: RefreshIndicator(
        onRefresh: _fetchStaff,
        child: CustomScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          slivers: [
            // Sticky Header with Back Button
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
                          // Back Button
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
                                  "Staff Management",
                                  style: GoogleFonts.poppins(
                                    fontSize: 20,
                                    fontWeight: FontWeight.w700,
                                    color: Colors.white,
                                  ),
                                ),
                                const SizedBox(height: 2),
                                Text(
                                  "${_staff.length} total staff members",
                                  style: GoogleFonts.poppins(
                                    fontSize: 13,
                                    color: Colors.white70,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          
                          // Add Button
                          GestureDetector(
                            onTap: () => _showStaffDialog(),
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
                                Icons.person_add,
                                color: Colors.white70,
                                size: 24,
                              ),
                            ),
                          ),
                          const SizedBox(width: 8),
                          
                          // Refresh Button
                          GestureDetector(
                            onTap: _fetchStaff,
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
            
            // Stats and Search
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  children: [
                    // Stats Row
                    Row(
                      children: [
                        Expanded(
                          child: SizedBox(
                            height: 95,
                            child: StatCard(
                              title: 'Active',
                              value: '$activeCount',
                              icon: Icons.check_circle,
                              color: Colors.greenAccent,
                            ),
                          ),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: SizedBox(
                            height: 95,
                            child: StatCard(
                              title: 'Disabled',
                              value: '$disabledCount',
                              icon: Icons.block,
                              color: Colors.redAccent,
                            ),
                          ),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: SizedBox(
                            height: 95,
                            child: StatCard(
                              title: 'Admins',
                              value: '$adminCount',
                              icon: Icons.admin_panel_settings,
                              color: AppColors.primary,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    
                    // Search Bar
                    Container(
                      decoration: BoxDecoration(
                        color: Colors.grey.shade100,
                        borderRadius: BorderRadius.circular(14),
                        border: Border.all(color: Colors.grey.shade300),
                      ),
                      child: TextField(
                        style: GoogleFonts.poppins(
                          color: Colors.grey.shade800,
                          fontSize: 14,
                        ),
                        decoration: InputDecoration(
                          hintText: 'Search staff by name, email, or position...',
                          hintStyle: GoogleFonts.poppins(
                            color: Colors.grey.shade500,
                            fontSize: 13,
                          ),
                          prefixIcon: Icon(Icons.search, color: Colors.grey.shade600, size: 20),
                          border: InputBorder.none,
                          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                        ),
                        onChanged: (v) => setState(() => _searchQuery = v),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            
            // Staff List
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: _loading
                    ? const LoadingWidget(message: 'Loading staff...')
                    : _filtered.isEmpty
                        ? const EmptyState(
                            message: 'No staff members found',
                            icon: Icons.people_outline,
                          )
                        : ListView.separated(
                            shrinkWrap: true,
                            physics: const NeverScrollableScrollPhysics(),
                            itemCount: _filtered.length,
                            separatorBuilder: (_, __) => const SizedBox(height: 12),
                            itemBuilder: (_, i) {
                              final s = _filtered[i];
                              return GlassCard(
                                padding: const EdgeInsets.all(16),
                                child: Row(
                                  children: [
                                    // Avatar
                                    Container(
                                      width: 56,
                                      height: 56,
                                      decoration: BoxDecoration(
                                        color: AppColors.primary.withOpacity(0.15),
                                        shape: BoxShape.circle,
                                      ),
                                      child: Center(
                                        child: Text(
                                          s.name[0].toUpperCase(),
                                          style: GoogleFonts.poppins(
                                            fontSize: 24,
                                            fontWeight: FontWeight.w700,
                                            color: AppColors.primary,
                                          ),
                                        ),
                                      ),
                                    ),
                                    const SizedBox(width: 14),
                                    
                                    // Staff Info
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          Row(
                                            children: [
                                              Expanded(
                                                child: Text(
                                                  s.name,
                                                  style: GoogleFonts.poppins(
                                                    fontWeight: FontWeight.w700,
                                                    fontSize: 16,
                                                    color: Colors.white,
                                                  ),
                                                ),
                                              ),
                                              StatusBadge(s.status),
                                            ],
                                          ),
                                          const SizedBox(height: 4),
                                          Text(
                                            s.email,
                                            style: GoogleFonts.poppins(
                                              fontSize: 12,
                                              color: Colors.white70,
                                            ),
                                          ),
                                          const SizedBox(height: 6),
                                          Row(
                                            children: [
                                              Container(
                                                padding: const EdgeInsets.symmetric(
                                                  horizontal: 10,
                                                  vertical: 4,
                                                ),
                                                decoration: BoxDecoration(
                                                  color: AppColors.info.withOpacity(0.15),
                                                  borderRadius: BorderRadius.circular(8),
                                                ),
                                                child: Text(
                                                  s.position,
                                                  style: GoogleFonts.poppins(
                                                    fontSize: 11,
                                                    color: AppColors.info,
                                                    fontWeight: FontWeight.w600,
                                                  ),
                                                ),
                                              ),
                                              const SizedBox(width: 8),
                                              Text(
                                                'ID: ${s.staffId}',
                                                style: GoogleFonts.poppins(
                                                  fontSize: 11,
                                                  color: Colors.white38,
                                                ),
                                              ),
                                            ],
                                          ),
                                        ],
                                      ),
                                    ),
                                    
                                    // Action Menu
                                    PopupMenuButton(
                                      iconColor: Colors.white70,
                                      itemBuilder: (_) => [
                                        const PopupMenuItem(
                                          value: 'edit',
                                          child: Row(
                                            children: [
                                              Icon(Icons.edit, size: 18, color: AppColors.info),
                                              SizedBox(width: 8),
                                              Text('Edit'),
                                            ],
                                          ),
                                        ),
                                        PopupMenuItem(
                                          value: 'toggle',
                                          child: Row(
                                            children: [
                                              Icon(
                                                s.status == 'Active' 
                                                    ? Icons.block 
                                                    : Icons.check_circle,
                                                size: 18,
                                                color: s.status == 'Active' 
                                                    ? AppColors.error 
                                                    : AppColors.success,
                                              ),
                                              const SizedBox(width: 8),
                                              Text(
                                                s.status == 'Active' ? 'Disable' : 'Enable',
                                                style: TextStyle(
                                                  color: s.status == 'Active' 
                                                      ? AppColors.error 
                                                      : AppColors.success,
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                        const PopupMenuItem(
                                          value: 'delete',
                                          child: Row(
                                            children: [
                                              Icon(Icons.delete, size: 18, color: AppColors.error),
                                              SizedBox(width: 8),
                                              Text('Delete', style: TextStyle(color: AppColors.error)),
                                            ],
                                          ),
                                        ),
                                      ],
                                      onSelected: (v) {
                                        if (v == 'edit') _showStaffDialog(staff: s);
                                        if (v == 'toggle') _toggleStatus(s);
                                        if (v == 'delete') _deleteStaff(s);
                                      },
                                    ),
                                  ],
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