// lib/screens/admin/admin_layout.dart
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../config/app_theme.dart';

class AdminLayout extends StatefulWidget {
  const AdminLayout({super.key});
  @override
  State<AdminLayout> createState() => _AdminLayoutState();
}

class _AdminLayoutState extends State<AdminLayout> {
  int _selectedIndex = 0;

  final List<_NavItem> _navItems = const [
    _NavItem(Icons.dashboard_outlined, Icons.dashboard, 'Dashboard', '/admin/dashboard'),
    _NavItem(Icons.hotel_outlined, Icons.hotel, 'Rooms', '/admin/rooms'),
    _NavItem(Icons.people_outlined, Icons.people, 'Staff', '/admin/staff'),
    _NavItem(Icons.inventory_2_outlined, Icons.inventory_2, 'Inventory', '/admin/inventory'),
    _NavItem(Icons.book_online_outlined, Icons.book_online, 'Bookings', '/admin/bookings'),
    _NavItem(Icons.point_of_sale_outlined, Icons.point_of_sale, 'Sales', '/admin/sales'),
    _NavItem(Icons.assessment_outlined, Icons.assessment, 'Reports', '/admin/reports'),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Row(
        children: [
          // Sidebar (tablet/desktop)
          if (MediaQuery.of(context).size.width > 700)
            NavigationRail(
              backgroundColor: AppColors.sidebarBg,
              selectedIndex: _selectedIndex,
              onDestinationSelected: (i) {
                setState(() => _selectedIndex = i);
                Navigator.pushReplacementNamed(context, _navItems[i].route);
              },
              labelType: NavigationRailLabelType.all,
              leading: Column(
                children: [
                  const SizedBox(height: 16),
                  const Icon(Icons.pool, color: Colors.white, size: 32),
                  const SizedBox(height: 4),
                  Text('BlueSense',
                      style: GoogleFonts.poppins(
                          color: Colors.white, fontWeight: FontWeight.w700, fontSize: 13)),
                  const SizedBox(height: 16),
                ],
              ),
              destinations: _navItems.map((item) => NavigationRailDestination(
                icon: Icon(item.icon, color: Colors.white60),
                selectedIcon: Icon(item.activeIcon, color: Colors.white),
                label: Text(item.label,
                    style: GoogleFonts.poppins(color: Colors.white, fontSize: 11)),
              )).toList(),
            ),
          // Main content area
          Expanded(
            child: Navigator(
              key: GlobalKey<NavigatorState>(),
              initialRoute: '/admin/dashboard',
              onGenerateRoute: (settings) => MaterialPageRoute(
                builder: (_) => const SizedBox.shrink(),
              ),
            ),
          ),
        ],
      ),
      bottomNavigationBar: MediaQuery.of(context).size.width <= 700
          ? NavigationBar(
              backgroundColor: AppColors.sidebarBg,
              selectedIndex: _selectedIndex,
              indicatorColor: AppColors.sidebarActive,
              onDestinationSelected: (i) {
                setState(() => _selectedIndex = i);
                Navigator.pushNamed(context, _navItems[i].route);
              },
              destinations: _navItems.map((item) => NavigationDestination(
                icon: Icon(item.icon, color: Colors.white60),
                selectedIcon: Icon(item.activeIcon, color: Colors.white),
                label: item.label,
              )).toList(),
            )
          : null,
    );
  }
}

class _NavItem {
  final IconData icon;
  final IconData activeIcon;
  final String label;
  final String route;
  const _NavItem(this.icon, this.activeIcon, this.label, this.route);
}
