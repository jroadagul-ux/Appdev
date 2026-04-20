// lib/screens/admin/admin_dashboard_screen.dart
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:fl_chart/fl_chart.dart';
import '../../config/app_theme.dart';
import '../../models/models.dart';
import '../../services/api_service.dart';
import '../../services/auth_provider.dart';
import '../../widgets/common_widgets.dart';
import '../../widgets/core/glass_card.dart';

class AdminDashboardScreen extends StatefulWidget {
  const AdminDashboardScreen({super.key});
  @override
  State<AdminDashboardScreen> createState() => _AdminDashboardScreenState();
}

class _AdminDashboardScreenState extends State<AdminDashboardScreen> {
  DashboardStats? _stats;
  List<Map<String, dynamic>> _dailyData = [];
  List<Map<String, dynamic>> _monthlyData = [];
  SensorReading? _sensorReading;
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _fetchAll();
  }

  Future<void> _fetchAll() async {
    setState(() => _loading = true);
    try {
      debugPrint('Fetching dashboard stats...');
      final statsResult =
          await ApiService.get('/api/admin/dashboard/stats', auth: true);
      debugPrint('Stats result: $statsResult');

      final dailyResult =
          await ApiService.get('/api/admin/dashboard/daily-chart', auth: true);
      debugPrint('Daily chart result type: ${dailyResult.runtimeType}');

      final monthlyResult = await ApiService.get(
          '/api/admin/dashboard/monthly-chart',
          auth: true);
      debugPrint('Monthly chart result type: ${monthlyResult.runtimeType}');

      setState(() {
        // Parse stats - handle both direct object and wrapped response
        if (statsResult is Map) {
          if (statsResult['data'] is Map) {
            _stats = DashboardStats.fromJson(
                statsResult['data'] as Map<String, dynamic>);
          } else if (statsResult['stats'] is Map) {
            _stats = DashboardStats.fromJson(
                statsResult['stats'] as Map<String, dynamic>);
          } else {
            _stats =
                DashboardStats.fromJson(statsResult as Map<String, dynamic>);
          }
        }

        // Parse daily chart data
        _dailyData = [];
        if (dailyResult is Map && dailyResult['data'] is List) {
          _dailyData =
              (dailyResult['data'] as List).cast<Map<String, dynamic>>();
        } else if (dailyResult is List) {
          _dailyData = dailyResult.cast<Map<String, dynamic>>();
        }

        // Parse monthly chart data
        _monthlyData = [];
        if (monthlyResult is Map && monthlyResult['data'] is List) {
          _monthlyData =
              (monthlyResult['data'] as List).cast<Map<String, dynamic>>();
        } else if (monthlyResult is List) {
          _monthlyData = monthlyResult.cast<Map<String, dynamic>>();
        }

        _loading = false;
        debugPrint('Dashboard loaded: ${_stats?.toString()}');
      });
    } catch (e, stack) {
      debugPrint('Error fetching dashboard data: $e');
      debugPrint('Stack: $stack');
      setState(() => _loading = false);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to load dashboard: $e')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color.fromARGB(255, 0, 49, 88),
      body: _loading
          ? const LoadingWidget(message: 'Loading dashboard...')
          : RefreshIndicator(
              onRefresh: _fetchAll,
              child: CustomScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
                slivers: [
                  // =========================================
                  // STICKY HEADER - Using existing DashboardHeader
                  // =========================================
                  SliverPersistentHeader(
                    pinned: true,
                    delegate: _StickyHeaderDelegate(
                      minHeight: 90,
                      maxHeight: 90,
                      child: DashboardHeader(
                        title: "Welcome back, Admin!",
                        subtitle: context.watch<AuthProvider>().user?.email ?? '',
                        actions: [
                          IconButton(
                            icon: const Icon(Icons.refresh, color: Colors.white70),
                            onPressed: _fetchAll,
                          ),
                          IconButton(
                            icon: const Icon(Icons.logout, color: Colors.white70),
                            onPressed: () async {
                              await context.read<AuthProvider>().logout();
                              if (context.mounted) {
                                Navigator.pushReplacementNamed(context, '/login');
                              }
                            },
                          ),
                        ],
                      ),
                    ),
                  ),

                  // =========================================
                  // BODY CONTENT
                  // =========================================
                  SliverToBoxAdapter(
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Pool Monitoring
                          if (_sensorReading != null) ...[
                            Text(
                              'Pool Monitoring',
                              style: GoogleFonts.poppins(
                                fontSize: 16,
                                fontWeight: FontWeight.w700,
                                color: Colors.white70,
                              ),
                            ),
                            const SizedBox(height: 12),
                            Row(
                              children: [
                                Expanded(
                                  child: _SensorCard(
                                    label: 'Temperature',
                                    value: _sensorReading!.temperature != null
                                        ? '${_sensorReading!.temperature!.toStringAsFixed(1)}°C'
                                        : '--',
                                    icon: Icons.thermostat,
                                    color: Colors.orangeAccent,
                                  ),
                                ),
                                const SizedBox(width: 10),
                                Expanded(
                                  child: _SensorCard(
                                    label: 'Turbidity',
                                    value: _sensorReading!.turbidity != null
                                        ? '${_sensorReading!.turbidity!.toStringAsFixed(1)} NTU'
                                        : '--',
                                    icon: Icons.water,
                                    color: Colors.lightBlueAccent,
                                  ),
                                ),
                                const SizedBox(width: 10),
                                Expanded(
                                  child: _SensorCard(
                                    label: 'pH Level',
                                    value: _sensorReading!.ph != null
                                        ? _sensorReading!.ph!.toStringAsFixed(1)
                                        : '--',
                                    icon: Icons.science,
                                    color: Colors.greenAccent,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 20),
                          ],

                          // =========================
                          // OVERVIEW TEXT
                          // =========================
                          Text(
                            'Overview',
                            style: GoogleFonts.poppins(
                              fontSize: 16,
                              fontWeight: FontWeight.w700,
                              color: Colors.white,
                            ),
                          ),
                          const SizedBox(height: 12),

                          if (_stats != null)
                            GridView.count(
                              crossAxisCount: 2,
                              crossAxisSpacing: 12,
                              mainAxisSpacing: 12,
                              shrinkWrap: true,
                              physics: const NeverScrollableScrollPhysics(),
                              childAspectRatio: 1.6,
                              children: [
                                StatCard(
                                  title: 'Total Reservations',
                                  value: '${_stats!.totalReservations}',
                                  icon: Icons.book_online,
                                  color: Colors.tealAccent,
                                  onTap: () => Navigator.pushNamed(
                                      context, '/admin/bookings'),
                                ),
                                StatCard(
                                  title: 'Available Rooms',
                                  value: '${_stats!.availableRooms}',
                                  icon: Icons.hotel,
                                  color: Colors.greenAccent,
                                  onTap: () => Navigator.pushNamed(
                                      context, '/admin/rooms'),
                                ),
                                StatCard(
                                  title: 'Maintenance Rooms',
                                  value: '${_stats!.maintainanceRooms}',
                                  icon: Icons.build_outlined,
                                  color: Colors.orangeAccent,
                                  onTap: () => Navigator.pushNamed(
                                      context, '/admin/rooms'),
                                ),
                                StatCard(
                                  title: 'Active Staff',
                                  value: '${_stats!.activeStaff}',
                                  icon: Icons.people,
                                  color: Colors.cyanAccent,
                                  onTap: () => Navigator.pushNamed(
                                      context, '/admin/staff'),
                                ),
                                StatCard(
                                  title: 'Monthly Revenue',
                                  value: formatPeso(_stats!.monthlyRevenue),
                                  icon: Icons.attach_money,
                                  color: Colors.amberAccent,
                                  onTap: () => Navigator.pushNamed(
                                      context, '/admin/sales'),
                                ),
                                StatCard(
                                  title: 'Low Stock Items',
                                  value: '${_stats!.lowStockItems}',
                                  icon: Icons.warning_amber,
                                  color: Colors.redAccent,
                                  onTap: () => Navigator.pushNamed(
                                      context, '/admin/inventory'),
                                ),
                              ],
                            ),

                          const SizedBox(height: 24),

                          // Sales Charts
                          Text('Sales Analytics',
                              style: GoogleFonts.poppins(
                                fontSize: 16,
                                fontWeight: FontWeight.w700,
                                color: Colors.white,
                              )),
                          const SizedBox(height: 12),

                          if (_dailyData.isNotEmpty)
                            GlassCard(
                              padding: const EdgeInsets.all(16),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'Daily Sales (Last 7 Days)',
                                    style: GoogleFonts.poppins(
                                      fontWeight: FontWeight.w700,
                                      fontSize: 14,
                                      color: Colors.white,
                                    ),
                                  ),
                                  const SizedBox(height: 12),
                                  SizedBox(
                                    height: 200,
                                    child: BarChart(
                                      BarChartData(
                                        barGroups:
                                            _dailyData.asMap().entries.map((e) {
                                          final val =
                                              (e.value['total'] ?? 0).toDouble();
                                          return BarChartGroupData(
                                            x: e.key,
                                            barRods: [
                                              BarChartRodData(
                                                toY: val,
                                                width: 20,
                                                borderRadius:
                                                    BorderRadius.circular(6),
                                                color: Colors.blueAccent,
                                              ),
                                            ],
                                          );
                                        }).toList(),
                                        gridData: const FlGridData(show: false),
                                        borderData: FlBorderData(show: false),
                                        titlesData: FlTitlesData(
                                          topTitles: const AxisTitles(
                                              sideTitles:
                                                  SideTitles(showTitles: false)),
                                          rightTitles: const AxisTitles(
                                              sideTitles:
                                                  SideTitles(showTitles: false)),
                                          leftTitles: const AxisTitles(
                                              sideTitles:
                                                  SideTitles(showTitles: false)),
                                          bottomTitles: AxisTitles(
                                            sideTitles: SideTitles(
                                              showTitles: true,
                                              reservedSize: 30,
                                              getTitlesWidget: (value, _) {
                                                final idx = value.toInt();
                                                if (idx < _dailyData.length) {
                                                  String day = _dailyData[idx]['_id'] ?? '';
                                                  // Shorten day names
                                                  if (day.length > 3) {
                                                    day = day.substring(0, 3);
                                                  }
                                                  return Padding(
                                                    padding: const EdgeInsets.only(top: 8),
                                                    child: Text(
                                                      day,
                                                      style: GoogleFonts.poppins(
                                                        fontSize: 10,
                                                        color: Colors.white70,
                                                      ),
                                                    ),
                                                  );
                                                }
                                                return const SizedBox();
                                              },
                                            ),
                                          ),
                                        ),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),

                          const SizedBox(height: 16),

                          if (_monthlyData.isNotEmpty)
                            GlassCard(
                              padding: const EdgeInsets.all(16),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'Monthly Sales',
                                    style: GoogleFonts.poppins(
                                      fontWeight: FontWeight.w700,
                                      fontSize: 14,
                                      color: Colors.white,
                                    ),
                                  ),
                                  const SizedBox(height: 12),
                                  SizedBox(
                                    height: 200,
                                    child: LineChart(
                                      LineChartData(
                                        gridData: const FlGridData(show: false),
                                        borderData: FlBorderData(show: false),
                                        titlesData: const FlTitlesData(
                                          topTitles: AxisTitles(
                                              sideTitles:
                                                  SideTitles(showTitles: false)),
                                          rightTitles: AxisTitles(
                                              sideTitles:
                                                  SideTitles(showTitles: false)),
                                          leftTitles: AxisTitles(
                                              sideTitles:
                                                  SideTitles(showTitles: false)),
                                        ),
                                        lineBarsData: [
                                          LineChartBarData(
                                            isCurved: true,
                                            color: Colors.orangeAccent,
                                            barWidth: 3,
                                            dotData: const FlDotData(show: true),
                                            belowBarData: BarAreaData(
                                              show: true,
                                              color: Colors.orangeAccent
                                                  .withOpacity(0.2),
                                            ),
                                            spots: _monthlyData
                                                .asMap()
                                                .entries
                                                .map((e) {
                                              final val = (e.value['total'] ?? 0)
                                                  .toDouble();
                                              return FlSpot(
                                                  e.key.toDouble(), val);
                                            }).toList(),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),

                          const SizedBox(height: 24),

                          // Quick Navigation
                          Text('Quick Actions',
                              style: GoogleFonts.poppins(
                                fontSize: 16,
                                fontWeight: FontWeight.w700,
                                color: Colors.white,
                              )),
                          const SizedBox(height: 12),
                          GridView.count(
                            crossAxisCount: 3,
                            crossAxisSpacing: 12,
                            mainAxisSpacing: 12,
                            shrinkWrap: true,
                            physics: const NeverScrollableScrollPhysics(),
                            children: [
                              _QuickNav(
                                  Icons.hotel,
                                  'Rooms',
                                  AppColors.primary,
                                  () => Navigator.pushNamed(
                                      context, '/admin/rooms')),
                              _QuickNav(
                                  Icons.people,
                                  'Staff',
                                  AppColors.info,
                                  () => Navigator.pushNamed(
                                      context, '/admin/staff')),
                              _QuickNav(
                                  Icons.inventory_2,
                                  'Inventory',
                                  AppColors.success,
                                  () => Navigator.pushNamed(
                                      context, '/admin/inventory')),
                              _QuickNav(
                                  Icons.book_online,
                                  'Bookings',
                                  AppColors.warning,
                                  () => Navigator.pushNamed(
                                      context, '/admin/bookings')),
                              _QuickNav(
                                  Icons.point_of_sale,
                                  'Sales',
                                  AppColors.accentGold,
                                  () => Navigator.pushNamed(
                                      context, '/admin/sales')),
                              _QuickNav(
                                  Icons.assessment,
                                  'Reports',
                                  AppColors.error,
                                  () => Navigator.pushNamed(
                                      context, '/admin/reports')),
                              _QuickNav(
                                  Icons.sensors,
                                  'Pool Monitor',
                                  AppColors.primary,
                                  () => Navigator.pushNamed(
                                      context, '/admin/pool-monitoring')),
                            ],
                          ),
                          const SizedBox(height: 24),
                        ],
                      ),
                    ),
                  )
                ],
              ),
            ),
    );
  }
}

// ============================================
// STICKY HEADER DELEGATE
// ============================================
class _StickyHeaderDelegate extends SliverPersistentHeaderDelegate {
  final double minHeight;
  final double maxHeight;
  final Widget child;

  _StickyHeaderDelegate({
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
  bool shouldRebuild(covariant _StickyHeaderDelegate oldDelegate) {
    return oldDelegate.minHeight != minHeight ||
        oldDelegate.maxHeight != maxHeight ||
        oldDelegate.child != child;
  }
}

// ============================================
// SENSOR CARD - Using GlassCard
// ============================================
class _SensorCard extends StatelessWidget {
  final String label, value;
  final IconData icon;
  final Color color;

  const _SensorCard({
    required this.label,
    required this.value,
    required this.icon,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return GlassCard(
      padding: const EdgeInsets.all(12),
      child: Column(
        children: [
          Icon(icon, color: color, size: 24),
          const SizedBox(height: 8),
          Text(
            value,
            style: GoogleFonts.poppins(
              fontWeight: FontWeight.w800,
              fontSize: 18,
              color: color,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            label,
            textAlign: TextAlign.center,
            style: GoogleFonts.poppins(
              fontSize: 11,
              color: Colors.white70,
            ),
          ),
        ],
      ),
    );
  }
}

// ============================================
// QUICK NAV - Using GlassCard
// ============================================
class _QuickNav extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;
  final VoidCallback onTap;

  const _QuickNav(this.icon, this.label, this.color, this.onTap);

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: GlassCard(
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: color.withOpacity(0.18),
                boxShadow: [
                  BoxShadow(
                    color: color.withOpacity(0.25),
                    blurRadius: 12,
                    spreadRadius: 1,
                  ),
                ],
              ),
              child: Icon(
                icon,
                color: color.withOpacity(0.95),
                size: 26,
              ),
            ),
            const SizedBox(height: 10),
            Text(
              label,
              textAlign: TextAlign.center,
              style: GoogleFonts.poppins(
                fontSize: 12,
                fontWeight: FontWeight.w500,
                color: Colors.white70,
                letterSpacing: 0.2,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      ),
    );
  }
}