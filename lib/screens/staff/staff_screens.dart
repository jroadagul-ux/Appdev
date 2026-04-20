// lib/screens/staff/staff_screens.dart
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../../config/app_theme.dart';
import '../../models/models.dart';
import '../../services/api_service.dart';
import '../../services/auth_provider.dart';
import '../../widgets/common_widgets.dart';

// ============================================
// STAFF DASHBOARD
// ============================================
class StaffDashboardScreen extends StatefulWidget {
  const StaffDashboardScreen({super.key});
  @override
  State<StaffDashboardScreen> createState() => _StaffDashboardScreenState();
}

class _StaffDashboardScreenState extends State<StaffDashboardScreen> {
  Map<String, dynamic>? _stats;
  List<Map<String, dynamic>> _recentTasks = [];
  bool _loading = true;
  int _unreadNotifications = 0;

  @override
  void initState() {
    super.initState();
    _fetchAll();
  }

  Future<void> _fetchAll() async {
    setState(() => _loading = true);
    try {
      final results = await Future.wait([
        ApiService.get('/api/staff/dashboard/stats'),
        ApiService.get('/api/staff/dashboard/tasks?limit=5'),
        ApiService.get('/api/staff/dashboard/notifications/unread-count'),
      ]);
      setState(() {
        _stats = results[0] is Map ? (results[0] as Map).cast<String, dynamic>() : {};
        final taskData = results[1];
        if (taskData is Map && taskData['tasks'] is List) {
          _recentTasks = (taskData['tasks'] as List).cast<Map<String, dynamic>>();
        } else if (taskData is List) {
          _recentTasks = taskData.cast<Map<String, dynamic>>();
        }
        final unread = results[2];
        _unreadNotifications = unread is int ? unread : (unread is Map ? (unread['unreadCount'] ?? 0) : 0);
        _loading = false;
      });
    } catch (_) {
      setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final user = context.watch<AuthProvider>().user;
    return Scaffold(
      appBar: AppBar(
        title: Text('Staff Dashboard', style: GoogleFonts.poppins(fontWeight: FontWeight.w700)),
        backgroundColor: AppColors.staffSidebarBg,
        actions: [
          IconButton(icon: const Icon(Icons.refresh), onPressed: _fetchAll),
          Stack(
            children: [
              IconButton(
                icon: const Icon(Icons.notifications_outlined),
                onPressed: () => Navigator.push(context,
                    MaterialPageRoute(builder: (_) => const StaffNotificationsScreen()))
                    .then((_) => _fetchAll()),
              ),
              if (_unreadNotifications > 0)
                Positioned(
                  right: 6, top: 6,
                  child: Container(
                    padding: const EdgeInsets.all(3),
                    decoration: const BoxDecoration(color: AppColors.error, shape: BoxShape.circle),
                    child: Text('$_unreadNotifications',
                        style: const TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold)),
                  ),
                ),
            ],
          ),
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () async {
              await context.read<AuthProvider>().logout();
              if (context.mounted) Navigator.pushReplacementNamed(context, '/login');
            },
          ),
        ],
      ),
      body: _loading
          ? const LoadingWidget()
          : RefreshIndicator(
              onRefresh: _fetchAll,
              child: ListView(
                padding: const EdgeInsets.all(16),
                children: [
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(colors: [AppColors.staffSidebarBg, AppColors.staffSidebarActive]),
                      borderRadius: BorderRadius.circular(14),
                    ),
                    child: Row(
                      children: [
                        CircleAvatar(
                          backgroundColor: Colors.white.withOpacity(0.2),
                          child: Text(user?.name.isNotEmpty == true ? user!.name[0].toUpperCase() : 'S',
                              style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text('Welcome, ${user?.name ?? 'Staff'}!',
                                  style: GoogleFonts.poppins(color: Colors.white, fontWeight: FontWeight.w700, fontSize: 16)),
                              Text(user?.email ?? '',
                                  style: GoogleFonts.poppins(color: Colors.white70, fontSize: 12)),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 20),
                  GridView.count(
                    crossAxisCount: 2, crossAxisSpacing: 12, mainAxisSpacing: 12,
                    shrinkWrap: true, physics: const NeverScrollableScrollPhysics(), childAspectRatio: 1.6,
                    children: [
                      StatCard(title: 'Pending Tasks', value: '${_stats?['pendingTasks'] ?? 0}',
                          icon: Icons.pending_outlined, color: AppColors.warning,
                          onTap: () => Navigator.pushNamed(context, '/staff/tasks')),
                      StatCard(title: 'In Progress', value: '${_stats?['inProgressTasks'] ?? 0}',
                          icon: Icons.timelapse, color: AppColors.info,
                          onTap: () => Navigator.pushNamed(context, '/staff/tasks')),
                      StatCard(title: 'Completed', value: '${_stats?['completedTasks'] ?? 0}',
                          icon: Icons.check_circle_outlined, color: AppColors.success),
                      StatCard(title: 'Assigned Rooms', value: '${_stats?['assignedRooms'] ?? 0}',
                          icon: Icons.hotel_outlined, color: AppColors.primary,
                          onTap: () => Navigator.pushNamed(context, '/staff/inspections')),
                    ],
                  ),
                  const SizedBox(height: 20),
                  Text('Quick Navigation', style: GoogleFonts.poppins(fontSize: 16, fontWeight: FontWeight.w700)),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Expanded(child: _NavCard(icon: Icons.task_alt, label: 'My Tasks', color: AppColors.primary,
                          onTap: () => Navigator.pushNamed(context, '/staff/tasks'))),
                      const SizedBox(width: 12),
                      Expanded(child: _NavCard(icon: Icons.manage_search, label: 'Inspections', color: AppColors.info,
                          onTap: () => Navigator.pushNamed(context, '/staff/inspections'))),
                    ],
                  ),
                  if (_recentTasks.isNotEmpty) ...[
                    const SizedBox(height: 20),
                    SectionHeader(title: 'Recent Tasks', actionLabel: 'View All',
                        onAction: () => Navigator.pushNamed(context, '/staff/tasks')),
                    const SizedBox(height: 10),
                    ..._recentTasks.map((t) {
                      final task = TaskModel.fromJson(t);
                      return Container(
                        margin: const EdgeInsets.only(bottom: 10),
                        padding: const EdgeInsets.all(14),
                        decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(12),
                            boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 6, offset: const Offset(0, 2))]),
                        child: Row(
                          children: [
                            PriorityBadge(task.priority),
                            const SizedBox(width: 10),
                            Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                              Text(task.title, style: GoogleFonts.poppins(fontWeight: FontWeight.w600, fontSize: 13)),
                              Text(task.taskType, style: GoogleFonts.poppins(fontSize: 11, color: AppColors.textSecondary)),
                            ])),
                            StatusBadge(task.status),
                          ],
                        ),
                      );
                    }),
                  ],
                ],
              ),
            ),
    );
  }
}

class _NavCard extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;
  final VoidCallback onTap;
  const _NavCard({required this.icon, required this.label, required this.color, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 20),
        decoration: BoxDecoration(
          color: color.withOpacity(0.08), borderRadius: BorderRadius.circular(14),
          border: Border.all(color: color.withOpacity(0.25)),
        ),
        child: Column(children: [
          Icon(icon, color: color, size: 36),
          const SizedBox(height: 8),
          Text(label, style: GoogleFonts.poppins(color: color, fontWeight: FontWeight.w700, fontSize: 14)),
        ]),
      ),
    );
  }
}

// ============================================
// NOTIFICATIONS SCREEN
// ============================================
class StaffNotificationsScreen extends StatefulWidget {
  const StaffNotificationsScreen({super.key});
  @override
  State<StaffNotificationsScreen> createState() => _StaffNotificationsScreenState();
}

class _StaffNotificationsScreenState extends State<StaffNotificationsScreen> {
  List<Map<String, dynamic>> _notifications = [];
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _fetch();
  }

  Future<void> _fetch() async {
    setState(() => _loading = true);
    try {
      final result = await ApiService.get('/api/staff/dashboard/notifications?limit=50');
      final list = result is Map ? result['notifications'] : result;
      setState(() {
        _notifications = list is List ? list.cast<Map<String, dynamic>>() : [];
        _loading = false;
      });
    } catch (_) {
      setState(() => _loading = false);
    }
  }

  Future<void> _markAllRead() async {
    await ApiService.put('/api/staff/dashboard/notifications/mark-all-read', {});
    _fetch();
  }

  Future<void> _markRead(String id) async {
    await ApiService.put('/api/staff/dashboard/notifications/$id/read', {});
    _fetch();
  }

  Future<void> _delete(String id) async {
    await ApiService.delete('/api/staff/dashboard/notifications/$id');
    _fetch();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Notifications', style: GoogleFonts.poppins(fontWeight: FontWeight.w700)),
        backgroundColor: AppColors.staffSidebarBg,
        actions: [
          TextButton(
            onPressed: _markAllRead,
            child: Text('Mark All Read', style: GoogleFonts.poppins(color: Colors.white, fontSize: 12, fontWeight: FontWeight.w600)),
          ),
        ],
      ),
      body: _loading
          ? const LoadingWidget()
          : _notifications.isEmpty
              ? const EmptyState(message: 'No notifications', icon: Icons.notifications_none_outlined)
              : RefreshIndicator(
                  onRefresh: _fetch,
                  child: ListView.separated(
                    padding: const EdgeInsets.all(14),
                    itemCount: _notifications.length,
                    separatorBuilder: (_, __) => const SizedBox(height: 8),
                    itemBuilder: (_, i) {
                      final n = _notifications[i];
                      final isRead = n['isRead'] == true;
                      return Dismissible(
                        key: Key(n['_id'] ?? '$i'),
                        direction: DismissDirection.endToStart,
                        background: Container(
                          alignment: Alignment.centerRight, padding: const EdgeInsets.only(right: 16),
                          decoration: BoxDecoration(color: AppColors.error, borderRadius: BorderRadius.circular(12)),
                          child: const Icon(Icons.delete, color: Colors.white),
                        ),
                        onDismissed: (_) => _delete(n['_id'] ?? ''),
                        child: GestureDetector(
                          onTap: isRead ? null : () => _markRead(n['_id'] ?? ''),
                          child: Container(
                            padding: const EdgeInsets.all(14),
                            decoration: BoxDecoration(
                              color: isRead ? Colors.white : AppColors.primary.withOpacity(0.06),
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(color: isRead ? AppColors.border : AppColors.primary.withOpacity(0.3)),
                            ),
                            child: Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Container(
                                  padding: const EdgeInsets.all(8),
                                  decoration: BoxDecoration(
                                    color: AppColors.primary.withOpacity(0.1), shape: BoxShape.circle),
                                  child: Icon(Icons.notifications,
                                      color: isRead ? AppColors.textSecondary : AppColors.primary, size: 18),
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(n['message'] ?? '',
                                          style: GoogleFonts.poppins(fontSize: 13,
                                              fontWeight: isRead ? FontWeight.w400 : FontWeight.w600,
                                              color: isRead ? AppColors.textSecondary : AppColors.textPrimary)),
                                      if (n['createdAt'] != null)
                                        Text(formatDateTime(DateTime.parse(n['createdAt'])),
                                            style: GoogleFonts.poppins(fontSize: 11, color: AppColors.textSecondary)),
                                    ],
                                  ),
                                ),
                                if (!isRead)
                                  Container(width: 8, height: 8,
                                      decoration: const BoxDecoration(color: AppColors.primary, shape: BoxShape.circle)),
                              ],
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                ),
    );
  }
}

// ============================================
// STAFF TASKS SCREEN
// ============================================
class StaffTasksScreen extends StatefulWidget {
  const StaffTasksScreen({super.key});
  @override
  State<StaffTasksScreen> createState() => _StaffTasksScreenState();
}

class _StaffTasksScreenState extends State<StaffTasksScreen> {
  List<TaskModel> _tasks = [];
  bool _loading = true;
  String _filter = '';

  @override
  void initState() {
    super.initState();
    _fetchTasks();
  }

  Future<void> _fetchTasks([String status = '']) async {
    setState(() => _loading = true);
    try {
      final query = status.isNotEmpty ? '?status=${Uri.encodeComponent(status)}' : '';
      final result = await ApiService.get('/api/staff/dashboard/tasks$query');
      List raw = result is List ? result : (result is Map && result['tasks'] is List ? result['tasks'] : []);
      setState(() {
        _tasks = raw.map((t) => TaskModel.fromJson(t)).toList();
        _loading = false;
      });
    } catch (_) {
      setState(() => _loading = false);
    }
  }

  Future<void> _updateStatus(TaskModel task, String newStatus, String notes) async {
    await ApiService.put('/api/staff/dashboard/tasks/${task.id}/status',
        {'status': newStatus, 'notes': notes});
    _fetchTasks(_filter);
  }

  void _showDetail(TaskModel task) {
    final notesCtrl = TextEditingController(text: task.notes);
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (_) => Padding(
        padding: EdgeInsets.fromLTRB(20, 20, 20, MediaQuery.of(context).viewInsets.bottom + 20),
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(child: Container(width: 40, height: 4,
                  decoration: BoxDecoration(color: AppColors.border, borderRadius: BorderRadius.circular(2)))),
              const SizedBox(height: 16),
              Row(children: [
                Expanded(child: Text(task.title,
                    style: GoogleFonts.poppins(fontSize: 18, fontWeight: FontWeight.w700))),
                PriorityBadge(task.priority),
              ]),
              if (task.description != null) ...[
                const SizedBox(height: 8),
                Text(task.description!, style: GoogleFonts.poppins(color: AppColors.textSecondary)),
              ],
              const SizedBox(height: 12),
              _Row(Icons.category_outlined, 'Type', task.taskType),
              _Row(Icons.calendar_today_outlined, 'Due', formatDate(task.dueDate)),
              if (task.roomName != null) _Row(Icons.hotel_outlined, 'Room', task.roomName!),
              _Row(Icons.timer_outlined, 'Est. Hours', '${task.estimatedHours}h'),
              const SizedBox(height: 12),
              TextFormField(controller: notesCtrl, maxLines: 2,
                  decoration: const InputDecoration(labelText: 'Notes / Completion Remarks')),
              const SizedBox(height: 14),
              Text('Update Status', style: GoogleFonts.poppins(fontWeight: FontWeight.w700)),
              const SizedBox(height: 8),
              Wrap(
                spacing: 8, runSpacing: 8,
                children: ['Pending', 'In Progress', 'Completed', 'Cancelled'].map((s) {
                  final isCurrent = task.status == s;
                  return GestureDetector(
                    onTap: isCurrent ? null : () {
                      Navigator.pop(context);
                      _updateStatus(task, s, notesCtrl.text);
                    },
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                      decoration: BoxDecoration(
                        color: isCurrent ? AppColors.primary : Colors.transparent,
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(color: isCurrent ? AppColors.primary : AppColors.border),
                      ),
                      child: Text(s, style: GoogleFonts.poppins(
                          color: isCurrent ? Colors.white : AppColors.textSecondary,
                          fontWeight: FontWeight.w600, fontSize: 13)),
                    ),
                  );
                }).toList(),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('My Tasks', style: GoogleFonts.poppins(fontWeight: FontWeight.w700)),
        backgroundColor: AppColors.staffSidebarBg,
        actions: [IconButton(icon: const Icon(Icons.refresh), onPressed: () => _fetchTasks(_filter))],
      ),
      body: Column(
        children: [
          Container(
            color: Colors.white,
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: {'': 'All', 'Pending': 'Pending', 'In Progress': 'In Progress',
                    'Completed': 'Completed', 'Cancelled': 'Cancelled'}.entries.map((e) {
                  final sel = e.key == _filter;
                  return Padding(
                    padding: const EdgeInsets.only(right: 8),
                    child: GestureDetector(
                      onTap: () { setState(() => _filter = e.key); _fetchTasks(e.key); },
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 7),
                        decoration: BoxDecoration(
                          color: sel ? AppColors.primary : Colors.transparent,
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(color: sel ? AppColors.primary : AppColors.border),
                        ),
                        child: Text(e.value, style: GoogleFonts.poppins(
                            color: sel ? Colors.white : AppColors.textSecondary,
                            fontWeight: FontWeight.w600, fontSize: 12)),
                      ),
                    ),
                  );
                }).toList(),
              ),
            ),
          ),
          Expanded(
            child: _loading
                ? const LoadingWidget()
                : _tasks.isEmpty
                    ? const EmptyState(message: 'No tasks found', icon: Icons.task_outlined)
                    : RefreshIndicator(
                        onRefresh: _fetchTasks,
                        child: ListView.separated(
                          padding: const EdgeInsets.all(14),
                          itemCount: _tasks.length,
                          separatorBuilder: (_, __) => const SizedBox(height: 10),
                          itemBuilder: (_, i) {
                            final task = _tasks[i];
                            final isOverdue = task.dueDate.isBefore(DateTime.now()) &&
                                task.status != 'Completed' && task.status != 'Cancelled';
                            return GestureDetector(
                              onTap: () => _showDetail(task),
                              child: Container(
                                padding: const EdgeInsets.all(14),
                                decoration: BoxDecoration(
                                  color: Colors.white, borderRadius: BorderRadius.circular(14),
                                  border: isOverdue ? Border.all(color: AppColors.error.withOpacity(0.4)) : null,
                                  boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 6, offset: const Offset(0, 2))],
                                ),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Row(children: [
                                      PriorityBadge(task.priority),
                                      const SizedBox(width: 8),
                                      Expanded(child: Text(task.title,
                                          style: GoogleFonts.poppins(fontWeight: FontWeight.w700, fontSize: 14))),
                                      StatusBadge(task.status),
                                    ]),
                                    const SizedBox(height: 4),
                                    Row(children: [
                                      const Icon(Icons.category_outlined, size: 13, color: AppColors.textSecondary),
                                      const SizedBox(width: 4),
                                      Text(task.taskType, style: GoogleFonts.poppins(fontSize: 12, color: AppColors.textSecondary)),
                                      if (task.roomName != null) ...[
                                        const SizedBox(width: 10),
                                        const Icon(Icons.hotel_outlined, size: 13, color: AppColors.textSecondary),
                                        const SizedBox(width: 4),
                                        Text(task.roomName!, style: GoogleFonts.poppins(fontSize: 12, color: AppColors.textSecondary)),
                                      ],
                                    ]),
                                    Row(children: [
                                      Icon(Icons.calendar_today_outlined, size: 13,
                                          color: isOverdue ? AppColors.error : AppColors.textSecondary),
                                      const SizedBox(width: 4),
                                      Text(
                                        'Due: ${formatDate(task.dueDate)}${isOverdue ? ' ⚠ Overdue' : ''}',
                                        style: GoogleFonts.poppins(fontSize: 12,
                                            color: isOverdue ? AppColors.error : AppColors.textSecondary,
                                            fontWeight: isOverdue ? FontWeight.w700 : FontWeight.w400),
                                      ),
                                    ]),
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
    );
  }
}

// ============================================
// STAFF INSPECTIONS SCREEN
// ============================================
class StaffInspectionsScreen extends StatefulWidget {
  const StaffInspectionsScreen({super.key});
  @override
  State<StaffInspectionsScreen> createState() => _StaffInspectionsScreenState();
}

class _StaffInspectionsScreenState extends State<StaffInspectionsScreen> {
  List<Map<String, dynamic>> _inspections = [];
  List<Map<String, dynamic>> _assignedRooms = [];
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _fetchAll();
  }

  Future<void> _fetchAll() async {
    setState(() => _loading = true);
    try {
      final results = await Future.wait([
        ApiService.get('/api/staff/dashboard/inspections'),
        ApiService.get('/api/staff/dashboard/assigned-rooms'),
      ]);
      setState(() {
        final inspData = results[0];
        if (inspData is Map && inspData['inspections'] is List) {
          _inspections = (inspData['inspections'] as List).cast<Map<String, dynamic>>();
        } else if (inspData is List) {
          _inspections = inspData.cast<Map<String, dynamic>>();
        }
        final roomData = results[1];
        if (roomData is Map && roomData['rooms'] is List) {
          _assignedRooms = (roomData['rooms'] as List).cast<Map<String, dynamic>>();
        } else if (roomData is List) {
          _assignedRooms = roomData.cast<Map<String, dynamic>>();
        }
        _loading = false;
      });
    } catch (_) {
      setState(() => _loading = false);
    }
  }

  void _showCreateForm() {
    String? selectedRoomId;
    String cleanliness = 'Good';
    String furniture = 'Good';
    String electricity = 'Working';
    String plumbing = 'Working';
    bool damagesFound = false;
    bool maintenanceRequired = false;
    final damageCtrl = TextEditingController();
    final maintenanceCtrl = TextEditingController();
    final itemsCtrl = TextEditingController();
    final notesCtrl = TextEditingController();
    int rating = 5;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (_) => StatefulBuilder(
        builder: (ctx, setModal) => Padding(
          padding: EdgeInsets.fromLTRB(20, 20, 20, MediaQuery.of(context).viewInsets.bottom + 20),
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Center(child: Container(width: 40, height: 4,
                    decoration: BoxDecoration(color: AppColors.border, borderRadius: BorderRadius.circular(2)))),
                const SizedBox(height: 16),
                Text('New Inspection Report', style: GoogleFonts.poppins(fontSize: 18, fontWeight: FontWeight.w700)),
                const SizedBox(height: 16),
                DropdownButtonFormField<String>(
                  initialValue: selectedRoomId,
                  decoration: const InputDecoration(labelText: 'Select Room *'),
                  items: _assignedRooms.map((r) => DropdownMenuItem(
                      value: r['_id']?.toString(), child: Text(r['name'] ?? ''))).toList(),
                  onChanged: (v) => setModal(() => selectedRoomId = v),
                ),
                const SizedBox(height: 12),
                _buildDropdown('Cleanliness', cleanliness, ['Poor', 'Fair', 'Good', 'Excellent'],
                    (v) => setModal(() => cleanliness = v!)),
                _buildDropdown('Furniture Condition', furniture, ['Poor', 'Fair', 'Good', 'Excellent'],
                    (v) => setModal(() => furniture = v!)),
                _buildDropdown('Electricity Status', electricity, ['Not Working', 'Partial', 'Working', 'Excellent'],
                    (v) => setModal(() => electricity = v!)),
                _buildDropdown('Plumbing Status', plumbing, ['Not Working', 'Partial', 'Working', 'Excellent'],
                    (v) => setModal(() => plumbing = v!)),
                SwitchListTile(
                  contentPadding: EdgeInsets.zero,
                  title: Text('Damages Found', style: GoogleFonts.poppins(fontWeight: FontWeight.w600)),
                  value: damagesFound, activeThumbColor: AppColors.error,
                  onChanged: (v) => setModal(() => damagesFound = v),
                ),
                if (damagesFound) ...[
                  TextFormField(controller: damageCtrl, maxLines: 2,
                      decoration: const InputDecoration(labelText: 'Damage Description')),
                  const SizedBox(height: 10),
                ],
                SwitchListTile(
                  contentPadding: EdgeInsets.zero,
                  title: Text('Maintenance Required', style: GoogleFonts.poppins(fontWeight: FontWeight.w600)),
                  value: maintenanceRequired, activeThumbColor: AppColors.warning,
                  onChanged: (v) => setModal(() => maintenanceRequired = v),
                ),
                if (maintenanceRequired) ...[
                  TextFormField(controller: maintenanceCtrl, maxLines: 2,
                      decoration: const InputDecoration(labelText: 'Maintenance Notes')),
                  const SizedBox(height: 10),
                ],
                TextFormField(
                  controller: itemsCtrl,
                  decoration: const InputDecoration(
                      labelText: 'Items Needed (comma-separated)',
                      hintText: 'e.g. towels, soap, light bulb'),
                ),
                const SizedBox(height: 12),
                TextFormField(controller: notesCtrl, maxLines: 2,
                    decoration: const InputDecoration(labelText: 'Additional Notes')),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Text('Rating: ', style: GoogleFonts.poppins(fontWeight: FontWeight.w600)),
                    ...List.generate(5, (i) => GestureDetector(
                      onTap: () => setModal(() => rating = i + 1),
                      child: Icon(i < rating ? Icons.star : Icons.star_border,
                          color: AppColors.accentGold, size: 28),
                    )),
                  ],
                ),
                const SizedBox(height: 20),
                SizedBox(
                  width: double.infinity, height: 50,
                  child: ElevatedButton(
                    onPressed: () async {
                      if (selectedRoomId == null) {
                        ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text('Please select a room')));
                        return;
                      }
                      Navigator.pop(context);
                      await ApiService.post('/api/staff/dashboard/inspections', {
                        'roomId': selectedRoomId,
                        'cleanliness': cleanliness,
                        'furnitureCondition': furniture,
                        'electricityStatus': electricity,
                        'plumbingStatus': plumbing,
                        'damagesFound': damagesFound,
                        'damageDescription': damageCtrl.text,
                        'maintenanceRequired': maintenanceRequired,
                        'maintenanceNotes': maintenanceCtrl.text,
                        'itemsNeeded': itemsCtrl.text
                            .split(',').map((s) => s.trim()).where((s) => s.isNotEmpty).toList(),
                        'notes': notesCtrl.text,
                        'rating': rating,
                      });
                      _fetchAll();
                    },
                    child: Text('Submit Inspection',
                        style: GoogleFonts.poppins(fontWeight: FontWeight.w700, fontSize: 16)),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildDropdown(String label, String value, List<String> items, ValueChanged<String?> onChanged) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: DropdownButtonFormField<String>(
        initialValue: value,
        decoration: InputDecoration(labelText: label),
        items: items.map((i) => DropdownMenuItem(value: i, child: Text(i))).toList(),
        onChanged: onChanged,
      ),
    );
  }

  void _showDetail(Map<String, dynamic> insp) {
    final room = insp['room'] is Map ? insp['room'] : null;
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (_) => Padding(
        padding: const EdgeInsets.all(20),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(child: Container(width: 40, height: 4,
                  decoration: BoxDecoration(color: AppColors.border, borderRadius: BorderRadius.circular(2)))),
              const SizedBox(height: 16),
              Row(children: [
                Expanded(child: Text('Inspection Report',
                    style: GoogleFonts.poppins(fontSize: 18, fontWeight: FontWeight.w700))),
                StatusBadge(insp['status'] ?? 'Submitted'),
              ]),
              const SizedBox(height: 14),
              if (room != null) _Row(Icons.hotel_outlined, 'Room', room['name'] ?? ''),
              if (insp['inspectionDate'] != null)
                _Row(Icons.calendar_today, 'Date', formatDate(DateTime.parse(insp['inspectionDate']))),
              _Row(Icons.cleaning_services_outlined, 'Cleanliness', insp['cleanliness'] ?? '-'),
              _Row(Icons.chair_outlined, 'Furniture', insp['furnitureCondition'] ?? '-'),
              _Row(Icons.electrical_services_outlined, 'Electricity', insp['electricityStatus'] ?? '-'),
              _Row(Icons.plumbing_outlined, 'Plumbing', insp['plumbingStatus'] ?? '-'),
              if (insp['damagesFound'] == true) ...[
                const SizedBox(height: 8),
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: AppColors.error.withOpacity(0.08), borderRadius: BorderRadius.circular(10),
                    border: Border.all(color: AppColors.error.withOpacity(0.3)),
                  ),
                  child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                    Text('⚠ Damages Found', style: GoogleFonts.poppins(color: AppColors.error, fontWeight: FontWeight.w700)),
                    if (insp['damageDescription']?.isNotEmpty == true)
                      Text(insp['damageDescription'], style: GoogleFonts.poppins(fontSize: 13, color: AppColors.error)),
                  ]),
                ),
              ],
              if (insp['maintenanceRequired'] == true) ...[
                const SizedBox(height: 8),
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(color: AppColors.warning.withOpacity(0.08), borderRadius: BorderRadius.circular(10)),
                  child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                    Text('🔧 Maintenance Required', style: GoogleFonts.poppins(color: AppColors.warning, fontWeight: FontWeight.w700)),
                    if (insp['maintenanceNotes']?.isNotEmpty == true)
                      Text(insp['maintenanceNotes'], style: GoogleFonts.poppins(fontSize: 13)),
                  ]),
                ),
              ],
              if ((insp['itemsNeeded'] as List?)?.isNotEmpty == true) ...[
                const SizedBox(height: 8),
                Text('Items Needed:', style: GoogleFonts.poppins(fontWeight: FontWeight.w600)),
                ...(insp['itemsNeeded'] as List).map((item) => Padding(
                    padding: const EdgeInsets.only(left: 8, top: 2),
                    child: Row(children: [
                      const Icon(Icons.circle, size: 6, color: AppColors.textSecondary),
                      const SizedBox(width: 6),
                      Text('$item', style: GoogleFonts.poppins(fontSize: 13)),
                    ]))),
              ],
              if (insp['notes']?.isNotEmpty == true) ...[
                const SizedBox(height: 8),
                _Row(Icons.notes_outlined, 'Notes', insp['notes']),
              ],
              if (insp['rating'] != null) ...[
                const SizedBox(height: 8),
                Row(children: [
                  Text('Rating: ', style: GoogleFonts.poppins(fontWeight: FontWeight.w600)),
                  ...List.generate(5, (i) => Icon(i < (insp['rating'] ?? 0) ? Icons.star : Icons.star_border,
                      color: AppColors.accentGold, size: 22)),
                ]),
              ],
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Inspections', style: GoogleFonts.poppins(fontWeight: FontWeight.w700)),
        backgroundColor: AppColors.staffSidebarBg,
        actions: [IconButton(icon: const Icon(Icons.refresh), onPressed: _fetchAll)],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _showCreateForm,
        icon: const Icon(Icons.add_task),
        label: const Text('New Report'),
        backgroundColor: AppColors.staffSidebarActive,
      ),
      body: _loading
          ? const LoadingWidget()
          : _inspections.isEmpty
              ? EmptyState(
                  message: 'No inspections yet.\nTap + to submit your first report.',
                  icon: Icons.manage_search_outlined,
                  onAction: _showCreateForm, actionLabel: 'Create Report')
              : RefreshIndicator(
                  onRefresh: _fetchAll,
                  child: ListView.separated(
                    padding: const EdgeInsets.fromLTRB(14, 14, 14, 80),
                    itemCount: _inspections.length,
                    separatorBuilder: (_, __) => const SizedBox(height: 10),
                    itemBuilder: (_, i) {
                      final insp = _inspections[i];
                      final room = insp['room'] is Map ? insp['room'] : null;
                      final hasDamage = insp['damagesFound'] == true;
                      final needsMaint = insp['maintenanceRequired'] == true;
                      return GestureDetector(
                        onTap: () => _showDetail(insp),
                        child: Container(
                          padding: const EdgeInsets.all(14),
                          decoration: BoxDecoration(
                            color: Colors.white, borderRadius: BorderRadius.circular(14),
                            border: hasDamage ? Border.all(color: AppColors.error.withOpacity(0.4)) : null,
                            boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 6, offset: const Offset(0, 2))],
                          ),
                          child: Row(
                            children: [
                              Container(
                                padding: const EdgeInsets.all(10),
                                decoration: BoxDecoration(
                                  color: (hasDamage ? AppColors.error : AppColors.info).withOpacity(0.1),
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                child: Icon(Icons.manage_search,
                                    color: hasDamage ? AppColors.error : AppColors.info, size: 22),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Row(children: [
                                      Expanded(child: Text(room?['name'] ?? 'Room',
                                          style: GoogleFonts.poppins(fontWeight: FontWeight.w700, fontSize: 14))),
                                      StatusBadge(insp['status'] ?? 'Submitted'),
                                    ]),
                                    if (insp['inspectionDate'] != null)
                                      Text(formatDate(DateTime.parse(insp['inspectionDate'])),
                                          style: GoogleFonts.poppins(fontSize: 12, color: AppColors.textSecondary)),
                                    Row(children: [
                                      if (hasDamage) ...[
                                        const Icon(Icons.warning_amber, size: 13, color: AppColors.error),
                                        const SizedBox(width: 4),
                                        Text('Damage', style: GoogleFonts.poppins(fontSize: 11, color: AppColors.error, fontWeight: FontWeight.w600)),
                                        const SizedBox(width: 10),
                                      ],
                                      if (needsMaint) ...[
                                        const Icon(Icons.build_outlined, size: 13, color: AppColors.warning),
                                        const SizedBox(width: 4),
                                        Text('Maintenance', style: GoogleFonts.poppins(fontSize: 11, color: AppColors.warning, fontWeight: FontWeight.w600)),
                                      ],
                                    ]),
                                    if (insp['rating'] != null)
                                      Row(children: List.generate(5, (i) => Icon(
                                        i < (insp['rating'] ?? 0) ? Icons.star : Icons.star_border,
                                        color: AppColors.accentGold, size: 14,
                                      ))),
                                  ],
                                ),
                              ),
                              const Icon(Icons.arrow_forward_ios, size: 14, color: AppColors.textSecondary),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
                ),
    );
  }
}

class _Row extends StatelessWidget {
  final IconData icon;
  final String label, value;
  const _Row(this.icon, this.label, this.value);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(children: [
        Icon(icon, size: 16, color: AppColors.textSecondary),
        const SizedBox(width: 8),
        Text('$label: ', style: GoogleFonts.poppins(color: AppColors.textSecondary, fontSize: 13)),
        Expanded(child: Text(value, style: GoogleFonts.poppins(fontWeight: FontWeight.w600, fontSize: 13))),
      ]),
    );
  }
}
