// lib/screens/admin/sales_screen.dart
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:intl/intl.dart';
import '../../config/app_theme.dart';
import '../../services/api_service.dart';
import '../../widgets/common_widgets.dart';
import '../../widgets/core/glass_card.dart';

class SalesScreen extends StatefulWidget {
  const SalesScreen({super.key});
  @override
  State<SalesScreen> createState() => _SalesScreenState();
}

class _SalesScreenState extends State<SalesScreen> {
  List<Map<String, dynamic>> _sales = [];
  double _totalSales = 0;
  bool _loading = true;
  String _period = 'daily';

  @override
  void initState() {
    super.initState();
    _fetchSales();
  }

  Future<void> _fetchSales() async {
    setState(() => _loading = true);
    try {
      debugPrint('Fetching sales for period: $_period');
      final result = await ApiService.get('/api/admin/sales/$_period', auth: true);
      
      final sales = result is Map
          ? (result['sales'] as List? ?? result['data'] as List? ?? []).cast<Map<String, dynamic>>()
          : result is List
              ? result.cast<Map<String, dynamic>>()
              : <Map<String, dynamic>>[];
      
      double total = result is Map
          ? (result['total'] ?? result['totalSales'] ?? result['sum'] ?? 0).toDouble()
          : sales.fold(0.0, (sum, s) => sum + ((s['amount'] ?? s['total'] ?? 0) as num).toDouble());
      
      setState(() {
        _sales = sales;
        _totalSales = total;
        _loading = false;
      });
    } catch (e) {
      debugPrint('Error fetching sales: $e');
      setState(() => _loading = false);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to load sales: $e')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final avgSale = _sales.isNotEmpty ? _totalSales / _sales.length : 0.0;

    return Scaffold(
      backgroundColor: const Color(0xFF003158),
      body: RefreshIndicator(
        onRefresh: _fetchSales,
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
                                  "Sales Tracking",
                                  style: GoogleFonts.poppins(
                                    fontSize: 20,
                                    fontWeight: FontWeight.w700,
                                    color: Colors.white,
                                  ),
                                ),
                                const SizedBox(height: 2),
                                Text(
                                  "${_sales.length} transactions",
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
                            onTap: _fetchSales,
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
            
            // Period Selector
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: GlassCard(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  child: Row(
                    children: [
                      const Icon(Icons.calendar_today, color: Colors.white54, size: 18),
                      const SizedBox(width: 8),
                      Text(
                        'Period: ',
                        style: GoogleFonts.poppins(
                          fontWeight: FontWeight.w600,
                          fontSize: 14,
                          color: Colors.white70,
                        ),
                      ),
                      const SizedBox(width: 8),
                      ...['daily', 'weekly', 'monthly'].map((p) {
                        final sel = p == _period;
                        return Padding(
                          padding: const EdgeInsets.only(right: 8),
                          child: GestureDetector(
                            onTap: () {
                              setState(() => _period = p);
                              _fetchSales();
                            },
                            child: Container(
                              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 7),
                              decoration: BoxDecoration(
                                color: sel ? AppColors.primary : Colors.white.withOpacity(0.1),
                                borderRadius: BorderRadius.circular(20),
                                border: Border.all(
                                  color: sel ? AppColors.primary : Colors.white.withOpacity(0.2),
                                ),
                              ),
                              child: Text(
                                p[0].toUpperCase() + p.substring(1),
                                style: GoogleFonts.poppins(
                                  color: sel ? Colors.white : Colors.white70,
                                  fontWeight: FontWeight.w600,
                                  fontSize: 12,
                                ),
                              ),
                            ),
                          ),
                        );
                      }),
                    ],
                  ),
                ),
              ),
            ),

            // Stats and Content
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: _loading
                    ? const LoadingWidget(message: 'Loading sales data...')
                    : Column(
                        children: [
                          // Total Sales and Transactions Row
                          Row(
                            children: [
                              Expanded(
                                child: SizedBox(
                                  height: 100,
                                  child: StatCard(
                                    title: 'Total Sales',
                                    value: formatPeso(_totalSales),
                                    icon: Icons.attach_money,
                                    color: AppColors.accentGold,
                                  ),
                                ),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: SizedBox(
                                  height: 100,
                                  child: StatCard(
                                    title: 'Transactions',
                                    value: '${_sales.length}',
                                    icon: Icons.receipt_long,
                                    color: AppColors.primary,
                                  ),
                                ),
                              ),
                            ],
                          ),
                          
                          // Average Sale Card - Fixed (No overflow)
                          const SizedBox(height: 12),
                          GlassCard(
                            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                            child: Row(
                              children: [
                                Container(
                                  padding: const EdgeInsets.all(12),
                                  decoration: BoxDecoration(
                                    color: AppColors.success.withOpacity(0.15),
                                    borderRadius: BorderRadius.circular(14),
                                  ),
                                  child: const Icon(
                                    Icons.trending_up, 
                                    color: AppColors.success, 
                                    size: 26,
                                  ),
                                ),
                                const SizedBox(width: 16),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        'Average Sale',
                                        style: GoogleFonts.poppins(
                                          fontSize: 13,
                                          color: Colors.white70,
                                        ),
                                      ),
                                      const SizedBox(height: 4),
                                      Text(
                                        formatPeso(avgSale),
                                        style: GoogleFonts.poppins(
                                          fontWeight: FontWeight.w800,
                                          fontSize: 22,
                                          color: AppColors.success,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),
                          
                          const SizedBox(height: 24),

                          // Sales Chart
                          if (_sales.isNotEmpty) ...[
                            Text(
                              'Sales Chart',
                              style: GoogleFonts.poppins(
                                fontSize: 16,
                                fontWeight: FontWeight.w700,
                                color: Colors.white,
                              ),
                            ),
                            const SizedBox(height: 12),
                            GlassCard(
                              padding: const EdgeInsets.all(16),
                              child: SizedBox(
                                height: 200,
                                child: BarChart(
                                  BarChartData(
                                    barGroups: _sales.take(10).toList().asMap().entries.map((e) {
                                      return BarChartGroupData(
                                        x: e.key,
                                        barRods: [
                                          BarChartRodData(
                                            toY: (e.value['amount'] ?? 0).toDouble(),
                                            color: AppColors.accentGold,
                                            width: 20,
                                            borderRadius: BorderRadius.circular(6),
                                          ),
                                        ],
                                      );
                                    }).toList(),
                                    titlesData: FlTitlesData(
                                      leftTitles: const AxisTitles(
                                        sideTitles: SideTitles(showTitles: false),
                                      ),
                                      topTitles: const AxisTitles(
                                        sideTitles: SideTitles(showTitles: false),
                                      ),
                                      rightTitles: const AxisTitles(
                                        sideTitles: SideTitles(showTitles: false),
                                      ),
                                      bottomTitles: AxisTitles(
                                        sideTitles: SideTitles(
                                          showTitles: true,
                                          reservedSize: 30,
                                          getTitlesWidget: (value, _) {
                                            final idx = value.toInt();
                                            if (idx < _sales.length && _sales[idx]['date'] != null) {
                                              final dateStr = _sales[idx]['date'].toString();
                                              final date = DateTime.tryParse(dateStr);
                                              if (date != null) {
                                                return Padding(
                                                  padding: const EdgeInsets.only(top: 8),
                                                  child: Text(
                                                    DateFormat('MM/dd').format(date),
                                                    style: GoogleFonts.poppins(
                                                      fontSize: 10,
                                                      color: Colors.white54,
                                                    ),
                                                  ),
                                                );
                                              }
                                            }
                                            return const SizedBox();
                                          },
                                        ),
                                      ),
                                    ),
                                    borderData: FlBorderData(show: false),
                                    gridData: const FlGridData(show: false),
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(height: 24),
                          ],

                          // Sales Details Table
                          Text(
                            'Sales Details',
                            style: GoogleFonts.poppins(
                              fontSize: 16,
                              fontWeight: FontWeight.w700,
                              color: Colors.white,
                            ),
                          ),
                          const SizedBox(height: 12),
                          
                          if (_sales.isEmpty)
                            const EmptyState(
                              message: 'No sales data for this period',
                              icon: Icons.point_of_sale_outlined,
                            )
                          else
                            GlassCard(
                              padding: EdgeInsets.zero,
                              child: Column(
                                children: [
                                  // Header
                                  Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                                    decoration: BoxDecoration(
                                      color: AppColors.primary.withOpacity(0.15),
                                      borderRadius: const BorderRadius.vertical(top: Radius.circular(18)),
                                    ),
                                    child: Row(
                                      children: [
                                        Expanded(
                                          flex: 2,
                                          child: Text(
                                            'Guest Name',
                                            style: GoogleFonts.poppins(
                                              fontWeight: FontWeight.w700,
                                              fontSize: 12,
                                              color: Colors.white70,
                                            ),
                                          ),
                                        ),
                                        Expanded(
                                          flex: 1,
                                          child: Text(
                                            'Amount',
                                            style: GoogleFonts.poppins(
                                              fontWeight: FontWeight.w700,
                                              fontSize: 12,
                                              color: Colors.white70,
                                            ),
                                            textAlign: TextAlign.right,
                                          ),
                                        ),
                                        Expanded(
                                          flex: 1,
                                          child: Text(
                                            'Method',
                                            style: GoogleFonts.poppins(
                                              fontWeight: FontWeight.w700,
                                              fontSize: 12,
                                              color: Colors.white70,
                                            ),
                                            textAlign: TextAlign.right,
                                          ),
                                        ),
                                        Expanded(
                                          flex: 1,
                                          child: Text(
                                            'Date',
                                            style: GoogleFonts.poppins(
                                              fontWeight: FontWeight.w700,
                                              fontSize: 12,
                                              color: Colors.white70,
                                            ),
                                            textAlign: TextAlign.right,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  
                                  // Rows
                                  ..._sales.map((sale) {
                                    final guestName = sale['reservation']?['guestName'] ??
                                        sale['customerName'] ?? 'N/A';
                                    final amount = (sale['amount'] ?? 0).toDouble();
                                    final paymentMethod = sale['paymentMethod'] ?? '--';
                                    final dateStr = sale['date'] ?? sale['createdAt'];
                                    final date = dateStr != null ? DateTime.tryParse(dateStr.toString()) : null;
                                    
                                    return Container(
                                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                                      decoration: BoxDecoration(
                                        border: Border(
                                          top: BorderSide(
                                            color: Colors.white.withOpacity(0.08),
                                          ),
                                        ),
                                      ),
                                      child: Row(
                                        children: [
                                          Expanded(
                                            flex: 2,
                                            child: Column(
                                              crossAxisAlignment: CrossAxisAlignment.start,
                                              children: [
                                                Text(
                                                  guestName,
                                                  style: GoogleFonts.poppins(
                                                    fontWeight: FontWeight.w600,
                                                    fontSize: 13,
                                                    color: Colors.white,
                                                  ),
                                                  overflow: TextOverflow.ellipsis,
                                                ),
                                                if (sale['_id'] != null)
                                                  Text(
                                                    '#${sale['_id'].toString().substring(0, 8)}...',
                                                    style: GoogleFonts.poppins(
                                                      fontSize: 10,
                                                      color: Colors.white38,
                                                    ),
                                                  ),
                                              ],
                                            ),
                                          ),
                                          Expanded(
                                            flex: 1,
                                            child: Text(
                                              formatPeso(amount),
                                              style: GoogleFonts.poppins(
                                                fontWeight: FontWeight.w700,
                                                fontSize: 13,
                                                color: AppColors.accentGold,
                                              ),
                                              textAlign: TextAlign.right,
                                            ),
                                          ),
                                          Expanded(
                                            flex: 1,
                                            child: Text(
                                              paymentMethod,
                                              style: GoogleFonts.poppins(
                                                fontSize: 12,
                                                color: Colors.white70,
                                              ),
                                              textAlign: TextAlign.right,
                                            ),
                                          ),
                                          Expanded(
                                            flex: 1,
                                            child: Text(
                                              date != null 
                                                  ? DateFormat('MM/dd/yy').format(date) 
                                                  : '--',
                                              style: GoogleFonts.poppins(
                                                fontSize: 11,
                                                color: Colors.white54,
                                              ),
                                              textAlign: TextAlign.right,
                                            ),
                                          ),
                                        ],
                                      ),
                                    );
                                  }),
                                ],
                              ),
                            ),
                          const SizedBox(height: 20),
                        ],
                      ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// Reports Screen
class ReportsScreen extends StatefulWidget {
  const ReportsScreen({super.key});
  @override
  State<ReportsScreen> createState() => _ReportsScreenState();
}

class _ReportsScreenState extends State<ReportsScreen> {
  String _reportType = 'reservation';
  DateTime? _startDate;
  DateTime? _endDate;
  dynamic _reportData;
  bool _loading = false;

  final _reportTypes = {
    'reservation': 'Reservation Report',
    'sales': 'Sales Report',
    'inventory': 'Inventory Usage Report',
    'staff': 'Staff Activity Report',
  };

  Future<void> _generateReport() async {
    setState(() { _loading = true; _reportData = null; });
    try {
      String path;
      final params = <String>[];
      if (_startDate != null) params.add('startDate=${_startDate!.toIso8601String().split('T')[0]}');
      if (_endDate != null) params.add('endDate=${_endDate!.toIso8601String().split('T')[0]}');
      final query = params.isNotEmpty ? '?${params.join('&')}' : '';

      switch (_reportType) {
        case 'reservation':
          path = '/api/admin/reports/reservation$query';
          break;
        case 'sales':
          path = '/api/admin/reports/sales$query';
          break;
        case 'inventory':
          path = '/api/admin/reports/inventory-usage$query';
          break;
        case 'staff':
          path = '/api/admin/reports/staff-activity';
          break;
        default:
          path = '/api/admin/reports/reservation$query';
      }

      final result = await ApiService.get(path, auth: true);
      
      setState(() { 
        _reportData = result; 
        _loading = false;
      });
    } catch (e) {
      setState(() => _loading = false);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to generate report: $e')),
        );
      }
    }
  }

  Future<void> _pickDate(bool isStart) async {
    final picked = await showDatePicker(
      context: context,
      initialDate: isStart ? (_startDate ?? DateTime.now()) : (_endDate ?? DateTime.now()),
      firstDate: DateTime(2020),
      lastDate: DateTime.now(),
    );
    if (picked != null) {
      setState(() {
        if (isStart) {
          _startDate = picked;
        } else {
          _endDate = picked;
        }
      });
    }
  }

  List<dynamic> get _tableRows {
    if (_reportData == null) return [];
    if (_reportData is List) return _reportData;
    if (_reportData is Map) {
      if (_reportData['reservations'] is List) return _reportData['reservations'];
      if (_reportData['sales'] is List) return _reportData['sales'];
      if (_reportData['items'] is List) return _reportData['items'];
      if (_reportData['staff'] is List) return _reportData['staff'];
    }
    return [];
  }

  double get _totalSales {
    if (_reportData is Map) {
      return (_reportData['totalSales'] ?? _reportData['total'] ?? 0).toDouble();
    }
    return 0;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF003158),
      body: CustomScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        slivers: [
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
                              Text(
                                "Reports",
                                style: GoogleFonts.poppins(
                                  fontSize: 20,
                                  fontWeight: FontWeight.w700,
                                  color: Colors.white,
                                ),
                              ),
                              const SizedBox(height: 2),
                              Text(
                                "Generate analytics reports",
                                style: GoogleFonts.poppins(
                                  fontSize: 13,
                                  color: Colors.white70,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
          
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  GlassCard(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Report Type',
                          style: GoogleFonts.poppins(
                            fontWeight: FontWeight.w600,
                            fontSize: 14,
                            color: Colors.white70,
                          ),
                        ),
                        const SizedBox(height: 12),
                        SingleChildScrollView(
                          scrollDirection: Axis.horizontal,
                          child: Row(
                            children: _reportTypes.entries.map((e) {
                              final sel = e.key == _reportType;
                              return Padding(
                                padding: const EdgeInsets.only(right: 8),
                                child: GestureDetector(
                                  onTap: () => setState(() => _reportType = e.key),
                                  child: Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                                    decoration: BoxDecoration(
                                      color: sel ? AppColors.primary : Colors.white.withOpacity(0.1),
                                      borderRadius: BorderRadius.circular(25),
                                      border: Border.all(
                                        color: sel ? AppColors.primary : Colors.white.withOpacity(0.2),
                                      ),
                                    ),
                                    child: Text(
                                      e.value,
                                      style: GoogleFonts.poppins(
                                        color: sel ? Colors.white : Colors.white70,
                                        fontWeight: FontWeight.w600,
                                        fontSize: 13,
                                      ),
                                    ),
                                  ),
                                ),
                              );
                            }).toList(),
                          ),
                        ),
                        
                        if (_reportType != 'staff') ...[
                          const SizedBox(height: 16),
                          Row(
                            children: [
                              Expanded(
                                child: GestureDetector(
                                  onTap: () => _pickDate(true),
                                  child: Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                                    decoration: BoxDecoration(
                                      color: Colors.grey.shade50,
                                      borderRadius: BorderRadius.circular(12),
                                      border: Border.all(color: Colors.grey.shade300),
                                    ),
                                    child: Row(
                                      children: [
                                        const Icon(Icons.calendar_today, size: 16, color: AppColors.primary),
                                        const SizedBox(width: 8),
                                        Text(
                                          _startDate != null
                                              ? DateFormat('MMM d, yyyy').format(_startDate!)
                                              : 'Start Date',
                                          style: GoogleFonts.poppins(
                                            fontSize: 12,
                                            color: _startDate != null ? Colors.grey.shade800 : Colors.grey.shade500,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ),
                              const Padding(
                                padding: EdgeInsets.symmetric(horizontal: 8),
                                child: Text('to', style: TextStyle(color: Colors.white54)),
                              ),
                              Expanded(
                                child: GestureDetector(
                                  onTap: () => _pickDate(false),
                                  child: Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                                    decoration: BoxDecoration(
                                      color: Colors.grey.shade50,
                                      borderRadius: BorderRadius.circular(12),
                                      border: Border.all(color: Colors.grey.shade300),
                                    ),
                                    child: Row(
                                      children: [
                                        const Icon(Icons.calendar_today, size: 16, color: AppColors.primary),
                                        const SizedBox(width: 8),
                                        Text(
                                          _endDate != null
                                              ? DateFormat('MMM d, yyyy').format(_endDate!)
                                              : 'End Date',
                                          style: GoogleFonts.poppins(
                                            fontSize: 12,
                                            color: _endDate != null ? Colors.grey.shade800 : Colors.grey.shade500,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ],
                        
                        const SizedBox(height: 16),
                        SizedBox(
                          width: double.infinity,
                          height: 48,
                          child: ElevatedButton.icon(
                            onPressed: _loading ? null : _generateReport,
                            icon: const Icon(Icons.bar_chart, size: 18, color: Colors.white),
                            label: Text(
                              'Generate Report',
                              style: GoogleFonts.poppins(fontWeight: FontWeight.w600),
                            ),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AppColors.primary,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  
                  const SizedBox(height: 16),
                  
                  if (_loading)
                    const LoadingWidget(message: 'Generating report...')
                  else if (_reportData == null)
                    Center(
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(Icons.assessment_outlined, size: 64, color: Colors.white.withOpacity(0.3)),
                          const SizedBox(height: 12),
                          Text(
                            'Select a report type and tap Generate',
                            style: GoogleFonts.poppins(color: Colors.white54),
                          ),
                        ],
                      ),
                    )
                  else
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        if (_reportType == 'sales' && _totalSales > 0)
                          GlassCard(
                            padding: const EdgeInsets.all(16),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Total Revenue',
                                  style: GoogleFonts.poppins(
                                    color: Colors.white70,
                                    fontSize: 13,
                                  ),
                                ),
                                Text(
                                  formatPeso(_totalSales),
                                  style: GoogleFonts.poppins(
                                    color: AppColors.accentGold,
                                    fontWeight: FontWeight.w800,
                                    fontSize: 28,
                                  ),
                                ),
                                Text(
                                  '${_tableRows.length} transactions',
                                  style: GoogleFonts.poppins(
                                    color: Colors.white54,
                                    fontSize: 12,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        
                        const SizedBox(height: 16),
                        
                        Text(
                          '${_reportTypes[_reportType]} Results',
                          style: GoogleFonts.poppins(
                            fontSize: 16,
                            fontWeight: FontWeight.w700,
                            color: Colors.white,
                          ),
                        ),
                        const SizedBox(height: 12),
                        
                        if (_tableRows.isEmpty)
                          const EmptyState(
                            message: 'No data for selected period',
                            icon: Icons.inbox_outlined,
                          )
                        else
                          GlassCard(
                            padding: const EdgeInsets.all(12),
                            child: SingleChildScrollView(
                              scrollDirection: Axis.horizontal,
                              child: DataTable(
                                headingRowColor: WidgetStateProperty.all(
                                  AppColors.primary.withOpacity(0.15),
                                ),
                                dataRowColor: WidgetStateProperty.all(Colors.transparent),
                                dividerThickness: 0,
                                columnSpacing: 20,
                                columns: _buildColumns(),
                                rows: _buildRows(),
                              ),
                            ),
                          ),
                      ],
                    ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  List<DataColumn> _buildColumns() {
    final style = GoogleFonts.poppins(
      fontWeight: FontWeight.w700,
      fontSize: 12,
      color: Colors.white70,
    );
    
    switch (_reportType) {
      case 'reservation':
        return ['Guest', 'Email', 'Oasis', 'Package', 'Date', 'Status']
            .map((c) => DataColumn(label: Text(c, style: style)))
            .toList();
      case 'sales':
        return ['Guest', 'Amount', 'Method', 'Date']
            .map((c) => DataColumn(label: Text(c, style: style)))
            .toList();
      case 'inventory':
        return ['Item', 'Total Used', 'Current Stock', 'Unit']
            .map((c) => DataColumn(label: Text(c, style: style)))
            .toList();
      case 'staff':
        return ['Name', 'Role', 'Position', 'Status', 'Activity']
            .map((c) => DataColumn(label: Text(c, style: style)))
            .toList();
      default:
        return [DataColumn(label: Text('Data', style: style))];
    }
  }

  List<DataRow> _buildRows() {
    return _tableRows.map<DataRow>((row) {
      List<DataCell> cells;
      switch (_reportType) {
        case 'reservation':
          cells = [
            DataCell(Text(row['customerName'] ?? row['guestName'] ?? '--',
                style: GoogleFonts.poppins(fontSize: 13, color: Colors.white))),
            DataCell(Text(row['customerEmail'] ?? row['guestEmail'] ?? '--',
                style: GoogleFonts.poppins(fontSize: 12, color: Colors.white70))),
            DataCell(Text(row['oasis'] ?? '--',
                style: GoogleFonts.poppins(fontSize: 13, color: Colors.white))),
            DataCell(Text(row['package'] ?? '--',
                style: GoogleFonts.poppins(fontSize: 13, color: Colors.white))),
            DataCell(Text(row['bookingDate'] != null
                ? DateFormat('MM/dd/yy').format(DateTime.parse(row['bookingDate']))
                : '--',
                style: GoogleFonts.poppins(fontSize: 12, color: Colors.white70))),
            DataCell(Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
              decoration: BoxDecoration(
                color: _getStatusColor(row['status']).withOpacity(0.15),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(row['status'] ?? '--',
                  style: GoogleFonts.poppins(
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                    color: _getStatusColor(row['status']),
                  )),
            )),
          ];
          break;
        case 'sales':
          final amount = (row['amount'] ?? 0).toDouble();
          final date = row['date'] != null ? DateTime.tryParse(row['date']) : null;
          cells = [
            DataCell(Text(row['reservation']?['guestName'] ?? row['customerName'] ?? 'N/A',
                style: GoogleFonts.poppins(fontSize: 13, color: Colors.white))),
            DataCell(Text(formatPeso(amount),
                style: GoogleFonts.poppins(
                  fontWeight: FontWeight.w700,
                  fontSize: 13,
                  color: AppColors.accentGold,
                ))),
            DataCell(Text(row['paymentMethod'] ?? '--',
                style: GoogleFonts.poppins(fontSize: 12, color: Colors.white70))),
            DataCell(Text(date != null ? DateFormat('MM/dd/yy').format(date) : '--',
                style: GoogleFonts.poppins(fontSize: 12, color: Colors.white70))),
          ];
          break;
        case 'inventory':
          cells = [
            DataCell(Text(row['item'] ?? '--',
                style: GoogleFonts.poppins(fontSize: 13, color: Colors.white))),
            DataCell(Text('${row['totalUsed'] ?? 0}',
                style: GoogleFonts.poppins(fontSize: 13, color: Colors.white))),
            DataCell(Text('${row['currentStock'] ?? row['quantity'] ?? 0}',
                style: GoogleFonts.poppins(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: (row['currentStock'] ?? 0) < (row['lowStockAlert'] ?? 5) 
                      ? AppColors.error 
                      : AppColors.success,
                ))),
            DataCell(Text(row['unit'] ?? '--',
                style: GoogleFonts.poppins(fontSize: 12, color: Colors.white70))),
          ];
          break;
        case 'staff':
          cells = [
            DataCell(Text(row['name'] ?? '--',
                style: GoogleFonts.poppins(fontSize: 13, color: Colors.white))),
            DataCell(Text(row['role'] ?? '--',
                style: GoogleFonts.poppins(fontSize: 12, color: Colors.white70))),
            DataCell(Text(row['position'] ?? '--',
                style: GoogleFonts.poppins(fontSize: 12, color: Colors.white70))),
            DataCell(Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
              decoration: BoxDecoration(
                color: _getStatusColor(row['status']).withOpacity(0.15),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(row['status'] ?? '--',
                  style: GoogleFonts.poppins(
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                    color: _getStatusColor(row['status']),
                  )),
            )),
            DataCell(Text('${row['activityCount'] ?? 0}',
                style: GoogleFonts.poppins(fontSize: 13, color: Colors.white))),
          ];
          break;
        default:
          cells = [DataCell(Text('$row', style: GoogleFonts.poppins(color: Colors.white)))];
      }
      return DataRow(cells: cells);
    }).toList();
  }
  
  Color _getStatusColor(String? status) {
    switch (status?.toLowerCase()) {
      case 'confirmed': return AppColors.success;
      case 'pending': return AppColors.warning;
      case 'cancelled': return AppColors.error;
      case 'active': return AppColors.success;
      default: return Colors.white54;
    }
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