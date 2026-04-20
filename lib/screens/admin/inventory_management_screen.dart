// lib/screens/admin/inventory_management_screen.dart
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../config/app_theme.dart';
import '../../models/models.dart';
import '../../services/api_service.dart';
import '../../widgets/common_widgets.dart';
import '../../widgets/core/glass_card.dart';

class InventoryManagementScreen extends StatefulWidget {
  const InventoryManagementScreen({super.key});
  @override
  State<InventoryManagementScreen> createState() => _InventoryManagementScreenState();
}

class _InventoryManagementScreenState extends State<InventoryManagementScreen> {
  List<InventoryModel> _items = [];
  bool _loading = true;
  bool _showLowStockOnly = false;

  @override
  void initState() {
    super.initState();
    _fetchInventory();
  }

  Future<void> _fetchInventory() async {
    setState(() => _loading = true);
    try {
      final result = await ApiService.get('/api/admin/inventory');
      if (result is Map && result['inventory'] is List) {
        setState(() {
          _items = (result['inventory'] as List).map((i) => InventoryModel.fromJson(i)).toList();
          _loading = false;
        });
      } else if (result is List) {
        setState(() {
          _items = result.map((i) => InventoryModel.fromJson(i)).toList();
          _loading = false;
        });
      } else {
        setState(() => _loading = false);
      }
    } catch (e) {
      print('Error fetching inventory: $e');
      setState(() => _loading = false);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to load inventory: $e')),
        );
      }
    }
  }

  List<InventoryModel> get _filtered =>
      _showLowStockOnly ? _items.where((i) => i.isLowStock).toList() : _items;

  void _showAddEditDialog({InventoryModel? item}) {
    final itemCtrl = TextEditingController(text: item?.item ?? '');
    final qtyCtrl = TextEditingController(text: item?.quantity.toString() ?? '');
    final unitCtrl = TextEditingController(text: item?.unit ?? '');
    final alertCtrl = TextEditingController(text: item?.lowStockAlert.toString() ?? '5');
    final formKey = GlobalKey<FormState>();

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => Dialog(
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
                        item == null ? Icons.add_box : Icons.edit_note,
                        color: AppColors.primary,
                        size: 28,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        item == null ? 'Add Inventory Item' : 'Edit Item',
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
                
                // Item Name Field
                _buildDialogTextField(
                  itemCtrl, 
                  'Item Name', 
                  Icons.inventory,
                  validator: (value) => value?.isEmpty == true ? 'Item name is required' : null,
                ),
                const SizedBox(height: 16),
                
                // Quantity Field
                _buildDialogTextField(
                  qtyCtrl, 
                  'Quantity', 
                  Icons.numbers, 
                  isNumber: true,
                  validator: (value) {
                    if (value?.isEmpty == true) return 'Quantity is required';
                    if (int.tryParse(value!) == null) return 'Enter a valid number';
                    return null;
                  },
                ),
                const SizedBox(height: 16),
                
                // Unit Field
                _buildDialogTextField(
                  unitCtrl, 
                  'Unit (e.g. Liters, Boxes, Pieces)', 
                  Icons.square_foot,
                  validator: (value) => value?.isEmpty == true ? 'Unit is required' : null,
                ),
                const SizedBox(height: 16),
                
                // Alert Threshold Field
                _buildDialogTextField(
                  alertCtrl, 
                  'Low Stock Alert Threshold', 
                  Icons.warning_amber, 
                  isNumber: true,
                  validator: (value) {
                    if (value?.isEmpty == true) return 'Alert threshold is required';
                    if (int.tryParse(value!) == null) return 'Enter a valid number';
                    return null;
                  },
                ),
                const SizedBox(height: 24),
                
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton(
                        onPressed: () => Navigator.pop(context),
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
                            Navigator.pop(context);
                            
                            // Show loading indicator
                            showDialog(
                              context: context,
                              barrierDismissible: false,
                              builder: (_) => const Center(child: CircularProgressIndicator()),
                            );
                            
                            final body = {
                              'item': itemCtrl.text.trim(),
                              'quantity': int.tryParse(qtyCtrl.text) ?? 0,
                              'unit': unitCtrl.text.trim(),
                              'lowStockAlert': int.tryParse(alertCtrl.text) ?? 5,
                            };
                            
                            try {
                              if (item == null) {
                                await ApiService.post('/api/admin/inventory', body);
                                if (mounted) {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    const SnackBar(content: Text('Item added successfully')),
                                  );
                                }
                              } else {
                                await ApiService.put('/api/admin/inventory/${item.id}', body);
                                if (mounted) {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    const SnackBar(content: Text('Item updated successfully')),
                                  );
                                }
                              }
                              Navigator.pop(context); // Close loading
                              _fetchInventory();
                            } catch (e) {
                              Navigator.pop(context); // Close loading
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
                          item == null ? 'Add Item' : 'Save Changes',
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
    );
  }

  Widget _buildDialogTextField(
    TextEditingController controller, 
    String label, 
    IconData icon, {
    bool isNumber = false,
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
        keyboardType: isNumber ? TextInputType.number : TextInputType.text,
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

  void _showUseDialog(InventoryModel item) {
    final qtyCtrl = TextEditingController(text: '1');
    final formKey = GlobalKey<FormState>();
    final currentStock = item.quantity;
    
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => Dialog(
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
                        color: AppColors.warning.withOpacity(0.2),
                        borderRadius: BorderRadius.circular(14),
                      ),
                      child: const Icon(
                        Icons.production_quantity_limits,
                        color: AppColors.warning,
                        size: 28,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        'Log Usage',
                        style: GoogleFonts.poppins(
                          fontSize: 20,
                          fontWeight: FontWeight.w700,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                
                // Item Info Card
                GlassCard(
                  padding: const EdgeInsets.all(12),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        item.item,
                        style: GoogleFonts.poppins(
                          fontSize: 16,
                          fontWeight: FontWeight.w700,
                          color: Colors.white,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          const Icon(Icons.inventory, size: 16, color: Colors.white54),
                          const SizedBox(width: 4),
                          Text(
                            'Current Stock: ',
                            style: GoogleFonts.poppins(
                              fontSize: 13,
                              color: Colors.white70,
                            ),
                          ),
                          Text(
                            '$currentStock ${item.unit ?? ''}',
                            style: GoogleFonts.poppins(
                              fontSize: 15,
                              fontWeight: FontWeight.w700,
                              color: currentStock < item.lowStockAlert ? AppColors.error : AppColors.success,
                            ),
                          ),
                        ],
                      ),
                      if (currentStock < item.lowStockAlert)
                        Padding(
                          padding: const EdgeInsets.only(top: 4),
                          child: Text(
                            '⚠️ Low stock alert! Please restock soon.',
                            style: GoogleFonts.poppins(
                              fontSize: 11,
                              color: AppColors.error,
                            ),
                          ),
                        ),
                    ],
                  ),
                ),
                
                const SizedBox(height: 20),
                
                // Quantity Used Field
                _buildDialogTextField(
                  qtyCtrl, 
                  'Quantity Used', 
                  Icons.production_quantity_limits, 
                  isNumber: true,
                  validator: (value) {
                    if (value?.isEmpty == true) return 'Quantity is required';
                    final qty = int.tryParse(value!);
                    if (qty == null) return 'Enter a valid number';
                    if (qty <= 0) return 'Quantity must be greater than 0';
                    if (qty > currentStock) return 'Not enough stock. Available: $currentStock';
                    return null;
                  },
                ),
                
                const SizedBox(height: 20),
                
                // Preview after usage
                ValueListenableBuilder(
                  valueListenable: qtyCtrl,
                  builder: (context, _, __) {
                    final enteredQty = int.tryParse(qtyCtrl.text) ?? 0;
                    final remainingStock = currentStock - enteredQty;
                    return Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.grey.shade50,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            'Remaining Stock:',
                            style: GoogleFonts.poppins(
                              fontSize: 13,
                              color: Colors.grey.shade700,
                            ),
                          ),
                          Text(
                            '$remainingStock ${item.unit ?? ''}',
                            style: GoogleFonts.poppins(
                              fontSize: 16,
                              fontWeight: FontWeight.w700,
                              color: remainingStock < item.lowStockAlert ? AppColors.error : AppColors.success,
                            ),
                          ),
                        ],
                      ),
                    );
                  },
                ),
                
                const SizedBox(height: 24),
                
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton(
                        onPressed: () => Navigator.pop(context),
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
                            Navigator.pop(context);
                            
                            // Show loading indicator
                            showDialog(
                              context: context,
                              barrierDismissible: false,
                              builder: (_) => const Center(child: CircularProgressIndicator()),
                            );
                            
                            try {
                              await ApiService.post('/api/admin/inventory/${item.id}/use',
                                  {'quantityUsed': int.tryParse(qtyCtrl.text) ?? 1});
                              
                              if (mounted) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                    content: Text('Used ${qtyCtrl.text} ${item.unit} from ${item.item}'),
                                    backgroundColor: AppColors.success,
                                  ),
                                );
                              }
                              Navigator.pop(context); // Close loading
                              _fetchInventory();
                            } catch (e) {
                              Navigator.pop(context); // Close loading
                              if (mounted) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(content: Text('Error: $e')),
                                );
                              }
                            }
                          }
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.warning,
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                        ),
                        child: Text(
                          'Confirm Usage',
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
    );
  }

  Future<void> _deleteItem(InventoryModel item) async {
    final confirmed = await showConfirmDialog(
      context,
      title: 'Delete Item',
      message: 'Are you sure you want to delete "${item.item}"? This action cannot be undone.',
      confirmLabel: 'Delete',
    );
    if (confirmed == true) {
      // Show loading
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (_) => const Center(child: CircularProgressIndicator()),
      );
      
      try {
        await ApiService.delete('/api/admin/inventory/${item.id}');
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Item deleted successfully')),
          );
        }
        Navigator.pop(context); // Close loading
        _fetchInventory();
      } catch (e) {
        Navigator.pop(context); // Close loading
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Error deleting item: $e')),
          );
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final lowStockCount = _items.where((i) => i.isLowStock).length;

    return Scaffold(
      backgroundColor: const Color(0xFF003158),
      body: RefreshIndicator(
        onRefresh: _fetchInventory,
        child: CustomScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          slivers: [
            // Sticky Header with Back Button
            SliverPersistentHeader(
              pinned: true,
              delegate: StickyHeaderDelegate(
                minHeight: 90,
                maxHeight: 90,
                child: Container(
                  color: const Color(0xFF003158),
                  child: SafeArea(
                    bottom: false,
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                      height: 90,
                      child: Row(
                        children: [
                          // Back Button
                          Container(
                            decoration: BoxDecoration(
                              color: Colors.white.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(
                                color: Colors.white.withOpacity(0.15),
                              ),
                            ),
                            child: IconButton(
                              icon: const Icon(Icons.arrow_back, color: Colors.white70),
                              onPressed: () => Navigator.pop(context),
                            ),
                          ),
                          const SizedBox(width: 12),
                          
                          // Icon
                          Container(
                            padding: const EdgeInsets.all(10),
                            decoration: BoxDecoration(
                              color: Colors.white.withOpacity(0.10),
                              borderRadius: BorderRadius.circular(14),
                              border: Border.all(
                                color: Colors.white.withOpacity(0.15),
                              ),
                            ),
                            child: const Icon(
                              Icons.inventory_2,
                              color: Colors.tealAccent,
                              size: 24,
                            ),
                          ),
                          const SizedBox(width: 12),
                          
                          // Text
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Text(
                                  "Inventory Management",
                                  style: GoogleFonts.poppins(
                                    fontSize: 18,
                                    fontWeight: FontWeight.w700,
                                    color: Colors.white,
                                  ),
                                  overflow: TextOverflow.ellipsis,
                                ),
                                const SizedBox(height: 2),
                                Text(
                                  "Track and manage stock",
                                  style: GoogleFonts.poppins(
                                    fontSize: 13,
                                    color: Colors.white70,
                                  ),
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ],
                            ),
                          ),
                          
                          // Add Button
                          Container(
                            decoration: BoxDecoration(
                              color: Colors.white.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(
                                color: Colors.white.withOpacity(0.15),
                              ),
                            ),
                            child: IconButton(
                              icon: const Icon(Icons.add, color: Colors.white70),
                              onPressed: () => _showAddEditDialog(),
                            ),
                          ),
                          const SizedBox(width: 8),
                          
                          // Refresh Button
                          Container(
                            decoration: BoxDecoration(
                              color: Colors.white.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(
                                color: Colors.white.withOpacity(0.15),
                              ),
                            ),
                            child: IconButton(
                              icon: const Icon(Icons.refresh, color: Colors.white70),
                              onPressed: _fetchInventory,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ),
            
            // Stats and Filters
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  children: [
                    // Stats Row
                    Row(
                      children: [
                        Expanded(
                          child: StatCard(
                            title: 'Total Items',
                            value: '${_items.length}',
                            icon: Icons.inventory,
                            color: Colors.tealAccent,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: StatCard(
                            title: 'Low Stock Items',
                            value: '$lowStockCount',
                            icon: Icons.warning_amber,
                            color: lowStockCount > 0 ? Colors.redAccent : Colors.greenAccent,
                            onTap: () {
                              if (lowStockCount > 0) {
                                setState(() => _showLowStockOnly = true);
                              }
                            },
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    
                    // Filter Row
                    GlassCard(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                      child: Row(
                        children: [
                          const Icon(Icons.filter_list, color: Colors.white54, size: 20),
                          const SizedBox(width: 8),
                          Text(
                            'Show low stock only',
                            style: GoogleFonts.poppins(
                              fontSize: 13,
                              color: Colors.white70,
                            ),
                          ),
                          const Spacer(),
                          Switch(
                            value: _showLowStockOnly,
                            onChanged: (v) => setState(() => _showLowStockOnly = v),
                            activeThumbColor: AppColors.error,
                            activeTrackColor: AppColors.error.withOpacity(0.5),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
            
            // Inventory List
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: _loading
                    ? const LoadingWidget(message: 'Loading inventory...')
                    : _filtered.isEmpty
                        ? EmptyState(
                            message: _showLowStockOnly
                                ? 'No low stock items! 🎉'
                                : 'No inventory items found.\nTap + to add items.',
                            icon: Icons.inventory_2_outlined,
                          )
                        : ListView.separated(
                            shrinkWrap: true,
                            physics: const NeverScrollableScrollPhysics(),
                            itemCount: _filtered.length,
                            separatorBuilder: (_, __) => const SizedBox(height: 12),
                            itemBuilder: (_, i) {
                              final item = _filtered[i];
                              return GlassCard(
                                padding: const EdgeInsets.all(16),
                                child: Row(
                                  children: [
                                    // Icon Container
                                    Container(
                                      padding: const EdgeInsets.all(12),
                                      decoration: BoxDecoration(
                                        color: (item.isLowStock ? AppColors.error : AppColors.success).withOpacity(0.15),
                                        borderRadius: BorderRadius.circular(14),
                                      ),
                                      child: Icon(
                                        item.isLowStock ? Icons.warning_amber : Icons.inventory_2,
                                        color: item.isLowStock ? AppColors.error : AppColors.success,
                                        size: 28,
                                      ),
                                    ),
                                    const SizedBox(width: 14),
                                    
                                    // Item Info
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          Row(
                                            children: [
                                              Expanded(
                                                child: Text(
                                                  item.item,
                                                  style: GoogleFonts.poppins(
                                                    fontWeight: FontWeight.w700,
                                                    fontSize: 16,
                                                    color: Colors.white,
                                                  ),
                                                ),
                                              ),
                                              if (item.isLowStock)
                                                Container(
                                                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                                                  decoration: BoxDecoration(
                                                    color: AppColors.error.withOpacity(0.15),
                                                    borderRadius: BorderRadius.circular(12),
                                                  ),
                                                  child: Text(
                                                    'Low Stock',
                                                    style: GoogleFonts.poppins(
                                                      fontSize: 10,
                                                      color: AppColors.error,
                                                      fontWeight: FontWeight.w600,
                                                    ),
                                                  ),
                                                ),
                                            ],
                                          ),
                                          const SizedBox(height: 6),
                                          Row(
                                            children: [
                                              Text(
                                                'Quantity: ',
                                                style: GoogleFonts.poppins(
                                                  fontSize: 13,
                                                  color: Colors.white70,
                                                ),
                                              ),
                                              Text(
                                                '${item.quantity} ${item.unit ?? ''}',
                                                style: GoogleFonts.poppins(
                                                  fontWeight: FontWeight.w700,
                                                  fontSize: 15,
                                                  color: item.isLowStock ? AppColors.error : AppColors.accentGold,
                                                ),
                                              ),
                                            ],
                                          ),
                                          const SizedBox(height: 4),
                                          Row(
                                            children: [
                                              const Icon(Icons.notifications_outlined, size: 12, color: Colors.white54),
                                              const SizedBox(width: 4),
                                              Text(
                                                'Alert at: ${item.lowStockAlert} ${item.unit ?? ''}',
                                                style: GoogleFonts.poppins(
                                                  fontSize: 11,
                                                  color: Colors.white54,
                                                ),
                                              ),
                                            ],
                                          ),
                                          const SizedBox(height: 4),
                                          Text(
                                            'ID: ${item.itemId}',
                                            style: GoogleFonts.poppins(
                                              fontSize: 10,
                                              color: Colors.white38,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                    
                                    // Action Menu
                                    PopupMenuButton(
                                      iconColor: Colors.white70,
                                      itemBuilder: (_) => [
                                        const PopupMenuItem(
                                          value: 'use',
                                          child: Row(
                                            children: [
                                              Icon(Icons.production_quantity_limits, size: 18, color: AppColors.warning),
                                              SizedBox(width: 8),
                                              Text('Log Usage'),
                                            ],
                                          ),
                                        ),
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
                                        if (v == 'use') _showUseDialog(item);
                                        if (v == 'edit') _showAddEditDialog(item: item);
                                        if (v == 'delete') _deleteItem(item);
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

// Add StickyHeaderDelegate if not in common_widgets
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