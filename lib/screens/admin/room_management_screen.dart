// lib/screens/admin/room_management_screen.dart
import 'package:flutter/material.dart';

import '../../config/app_theme.dart';
import '../../models/models.dart';
import '../../widgets/common_widgets.dart';
import '../../widgets/core/glass_card.dart';
import '../../services/local_storage_service.dart';

class RoomManagementScreen extends StatefulWidget {
  const RoomManagementScreen({super.key});
  @override
  State<RoomManagementScreen> createState() => _RoomManagementScreenState();
}

class _RoomManagementScreenState extends State<RoomManagementScreen> {
  List<RoomModel> _rooms = [];
  bool _loading = true;
  String _filter = 'All';
  final List<String> _statusFilters = ['All', 'Available', 'Booked', 'Maintenance'];

  @override
  void initState() {
    super.initState();
    _fetchRooms();
  }

  Future<void> _fetchRooms() async {
    setState(() => _loading = true);
    try {
      final List<Map<String, dynamic>> roomMaps = await LocalStorageService.loadRooms();
      setState(() {
        _rooms = roomMaps.map((map) => RoomModel.fromJson(map)).toList();
        _loading = false;
      });
    } catch (_) {
      setState(() => _loading = false);
    }
  }

  List<RoomModel> get _filtered =>
      _filter == 'All' ? _rooms : _rooms.where((r) => r.status == _filter).toList();

  void _showRoomDialog({RoomModel? room}) {
    final nameCtrl = TextEditingController(text: room?.name ?? '');
    final capacityCtrl = TextEditingController(text: room?.capacity.toString() ?? '');
    final priceCtrl = TextEditingController(text: room?.price.toString() ?? '');
    final descCtrl = TextEditingController(text: room?.description ?? '');
    String status = room?.status ?? 'Available';
    final formKey = GlobalKey<FormState>();

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => StatefulBuilder(
        builder: (innerCtx, setModalState) => Dialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
          backgroundColor: AppColors.dashboardBg,
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
                          room == null ? Icons.add_business : Icons.edit,
                          color: AppColors.primary,
                          size: 28,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          room == null ? 'Add Room' : 'Edit Room',
                          style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w700, color: Colors.white),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),
                  _buildDialogTextField(nameCtrl, 'Room Name', Icons.hotel,
                      validator: (v) => v?.isEmpty == true ? 'Room name is required' : null),
                  const SizedBox(height: 16),
                  _buildDialogTextField(capacityCtrl, 'Capacity (Pax)', Icons.group, isNumber: true,
                      validator: (v) {
                        if (v?.isEmpty == true) return 'Capacity is required';
                        if (int.tryParse(v!) == null) return 'Enter a valid number';
                        return null;
                      }),
                  const SizedBox(height: 16),
                  _buildDialogTextField(priceCtrl, 'Price per Night (₱)', Icons.attach_money, isNumber: true,
                      validator: (v) {
                        if (v?.isEmpty == true) return 'Price is required';
                        if (double.tryParse(v!) == null) return 'Enter a valid price';
                        return null;
                      }),
                  const SizedBox(height: 16),
                  _buildDialogTextField(descCtrl, 'Description', Icons.description, maxLines: 2),
                  const SizedBox(height: 16),
                  Container(
                    decoration: BoxDecoration(
                      color: Colors.grey.shade50,
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(color: Colors.grey.shade300),
                    ),
                    child: DropdownButtonFormField<String>(
                      initialValue: status,
                      dropdownColor: AppColors.dashboardBg,
                      style: const TextStyle(color: Colors.grey, fontSize: 14),
                      decoration: const InputDecoration(
                        labelText: 'Status',
                        labelStyle: TextStyle(color: Colors.grey, fontSize: 13),
                        prefixIcon: Icon(Icons.flag, color: AppColors.primary, size: 20),
                        border: InputBorder.none,
                        contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                      ),
                      items: ['Available', 'Booked', 'Maintenance']
                          .map((s) => DropdownMenuItem(
                                value: s,
                                child: Text(
                                  s,
                                  style: TextStyle(
                                    color: s == 'Available'
                                        ? AppColors.success
                                        : s == 'Booked'
                                            ? AppColors.warning
                                            : AppColors.error,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ))
                          .toList(),
                      onChanged: (v) => setModalState(() => status = v!),
                    ),
                  ),
                  const SizedBox(height: 24),
                  Row(
                    children: [
                      Expanded(
                        child: OutlinedButton(
                          onPressed: () => Navigator.pop(innerCtx),
                          style: OutlinedButton.styleFrom(
                            side: BorderSide(color: Colors.white.withOpacity(0.3)),
                            padding: const EdgeInsets.symmetric(vertical: 14),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                          ),
                          child: const Text('Cancel', style: TextStyle(color: Colors.white70, fontSize: 15)),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: ElevatedButton(
                          onPressed: () async {
                            if (formKey.currentState!.validate()) {
                              Navigator.pop(innerCtx);
                              final newRoomData = {
                                'name': nameCtrl.text.trim(),
                                'capacity': int.tryParse(capacityCtrl.text) ?? 0,
                                'price': double.tryParse(priceCtrl.text) ?? 0,
                                'description': descCtrl.text.trim(),
                                'status': status,
                              };
                              if (room == null) {
                                await LocalStorageService.addRoom(newRoomData);
                              } else {
                                await LocalStorageService.updateRoom(room.id, newRoomData);
                              }
                              _fetchRooms();
                            }
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.primary,
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(vertical: 14),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                          ),
                          child: Text(room == null ? 'Add Room' : 'Save Changes',
                              style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 15)),
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
    bool isNumber = false,
    int maxLines = 1,
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
        maxLines: maxLines,
        style: const TextStyle(color: Colors.grey, fontSize: 14),
        validator: validator,
        decoration: InputDecoration(
          labelText: label,
          labelStyle: const TextStyle(color: Colors.grey, fontSize: 13),
          prefixIcon: Icon(icon, color: AppColors.primary, size: 20),
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        ),
      ),
    );
  }

  Future<void> _deleteRoom(RoomModel room) async {
    final confirmed = await showConfirmDialog(
      context,
      title: 'Delete Room',
      message: 'Delete "${room.name}"? This action cannot be undone.',
      confirmLabel: 'Delete',
    );
    if (confirmed == true) {
      await LocalStorageService.deleteRoom(room.id);
      _fetchRooms();
    }
  }

  @override
  Widget build(BuildContext context) {
    final availableCount = _rooms.where((r) => r.status == 'Available').length;
    final bookedCount = _rooms.where((r) => r.status == 'Booked').length;
    final maintenanceCount = _rooms.where((r) => r.status == 'Maintenance').length;

    return Scaffold(
      backgroundColor: AppColors.dashboardBg,
      body: RefreshIndicator(
        onRefresh: _fetchRooms,
        child: CustomScrollView(
          slivers: [
            // Sticky Header (same as before – you can reuse your existing header)
            SliverPersistentHeader(
              pinned: true,
              delegate: StickyHeaderDelegate(
                minHeight: 80,
                maxHeight: 80,
                child: Container(
                  color: AppColors.dashboardBg,
                  child: SafeArea(
                    bottom: false,
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      height: 80,
                      child: Row(
                        children: [
                          GestureDetector(
                            onTap: () => Navigator.pop(context),
                            child: Container(
                              padding: const EdgeInsets.all(10),
                              decoration: BoxDecoration(
                                color: Colors.white.withOpacity(0.1),
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(color: Colors.white.withOpacity(0.15)),
                              ),
                              child: const Icon(Icons.arrow_back, color: Colors.white70, size: 24),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                const Text('Room Management',
                                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.w700, color: Colors.white)),
                                Text('${_rooms.length} total rooms',
                                    style: const TextStyle(fontSize: 13, color: Colors.white70)),
                              ],
                            ),
                          ),
                          GestureDetector(
                            onTap: () => _showRoomDialog(),
                            child: Container(
                              padding: const EdgeInsets.all(10),
                              decoration: BoxDecoration(
                                color: Colors.white.withOpacity(0.1),
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(color: Colors.white.withOpacity(0.15)),
                              ),
                              child: const Icon(Icons.add, color: Colors.white70, size: 24),
                            ),
                          ),
                          const SizedBox(width: 8),
                          GestureDetector(
                            onTap: _fetchRooms,
                            child: Container(
                              padding: const EdgeInsets.all(10),
                              decoration: BoxDecoration(
                                color: Colors.white.withOpacity(0.1),
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(color: Colors.white.withOpacity(0.15)),
                              ),
                              child: const Icon(Icons.refresh, color: Colors.white70, size: 24),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ),
            // Stats and filters
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: SizedBox(
                            height: 95,
                            child: GestureDetector(
                              onTap: () => setState(() => _filter = 'Available'),
                              child: StatCard(
                                title: 'Available',
                                value: '$availableCount',
                                icon: Icons.check_circle,
                                color: Colors.greenAccent,
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: SizedBox(
                            height: 95,
                            child: GestureDetector(
                              onTap: () => setState(() => _filter = 'Booked'),
                              child: StatCard(
                                title: 'Booked',
                                value: '$bookedCount',
                                icon: Icons.book_online,
                                color: Colors.orangeAccent,
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: SizedBox(
                            height: 95,
                            child: GestureDetector(
                              onTap: () => setState(() => _filter = 'Maintenance'),
                              child: StatCard(
                                title: 'Maint',
                                value: '$maintenanceCount',
                                icon: Icons.build,
                                color: Colors.redAccent,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      child: Row(
                        children: _statusFilters.map((f) {
                          final sel = f == _filter;
                          return Padding(
                            padding: const EdgeInsets.only(right: 8),
                            child: GestureDetector(
                              onTap: () => setState(() => _filter = f),
                              child: Container(
                                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                                decoration: BoxDecoration(
                                  color: sel ? AppColors.primary : Colors.white.withOpacity(0.1),
                                  borderRadius: BorderRadius.circular(25),
                                  border: Border.all(color: sel ? AppColors.primary : Colors.white.withOpacity(0.2)),
                                ),
                                child: Text(f,
                                    style: TextStyle(
                                        color: sel ? Colors.white : Colors.white70,
                                        fontWeight: FontWeight.w600,
                                        fontSize: 13)),
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
            // Rooms list
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: _loading
                    ? const LoadingWidget()
                    : _filtered.isEmpty
                        ? const EmptyState(message: 'No rooms found', icon: Icons.hotel_outlined)
                        : ListView.separated(
                            shrinkWrap: true,
                            physics: const NeverScrollableScrollPhysics(),
                            itemCount: _filtered.length,
                            separatorBuilder: (_, __) => const SizedBox(height: 12),
                            itemBuilder: (_, i) {
                              final room = _filtered[i];
                              return GlassCard(
                                padding: const EdgeInsets.all(16),
                                child: Row(
                                  children: [
                                    Container(
                                      padding: const EdgeInsets.all(12),
                                      decoration: BoxDecoration(
                                        color: AppColors.primary.withOpacity(0.15),
                                        borderRadius: BorderRadius.circular(14),
                                      ),
                                      child: const Icon(Icons.hotel, color: AppColors.primary, size: 28),
                                    ),
                                    const SizedBox(width: 14),
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          Row(
                                            children: [
                                              Expanded(
                                                child: Text(room.name,
                                                    style: const TextStyle(
                                                        fontWeight: FontWeight.w700, fontSize: 16, color: Colors.white)),
                                              ),
                                              StatusBadge(room.status),
                                            ],
                                          ),
                                          const SizedBox(height: 6),
                                          Row(
                                            children: [
                                              const Icon(Icons.group, size: 14, color: Colors.white54),
                                              const SizedBox(width: 4),
                                              Text('${room.capacity} pax',
                                                  style: const TextStyle(fontSize: 12, color: Colors.white70)),
                                              const SizedBox(width: 16),
                                              const Icon(Icons.attach_money, size: 14, color: Colors.white54),
                                              const SizedBox(width: 4),
                                              Text(formatPeso(room.price),
                                                  style: const TextStyle(
                                                      fontSize: 13,
                                                      fontWeight: FontWeight.w600,
                                                      color: AppColors.accentGold)),
                                            ],
                                          ),
                                          if (room.description != null && room.description!.isNotEmpty)
                                            Padding(
                                              padding: const EdgeInsets.only(top: 4),
                                              child: Row(
                                                children: [
                                                  const Icon(Icons.description, size: 12, color: Colors.white38),
                                                  const SizedBox(width: 4),
                                                  Expanded(
                                                    child: Text(room.description!,
                                                        maxLines: 1,
                                                        overflow: TextOverflow.ellipsis,
                                                        style: const TextStyle(fontSize: 11, color: Colors.white38)),
                                                  ),
                                                ],
                                              ),
                                            ),
                                        ],
                                      ),
                                    ),
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
                                        if (v == 'edit') _showRoomDialog(room: room);
                                        if (v == 'delete') _deleteRoom(room);
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