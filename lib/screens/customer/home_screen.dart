// lib/screens/customer/home_screen.dart
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../../config/app_theme.dart';
import '../../services/auth_provider.dart';
import '../../widgets/core/glass_card.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _selectedTab = 0;

  final List<Widget> _tabs = const [
    _HomeTab(),
    SizedBox.shrink(),
    SizedBox.shrink(),
    _ProfileTab(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF003158),
      body: _tabs[_selectedTab],
      bottomNavigationBar: NavigationBar(
        backgroundColor: const Color(0xFF003158),
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        selectedIndex: _selectedTab,
        onDestinationSelected: (i) {
          if (i == 1) {
            Navigator.pushNamed(context, '/booking');
            return;
          }
          if (i == 2) {
            Navigator.pushNamed(context, '/my-bookings');
            return;
          }
          setState(() => _selectedTab = i);
        },
        destinations: const [
          NavigationDestination(icon: Icon(Icons.home_outlined, color: Colors.white70), selectedIcon: Icon(Icons.home, color: AppColors.primary), label: 'Home'),
          NavigationDestination(icon: Icon(Icons.calendar_month_outlined, color: Colors.white70), selectedIcon: Icon(Icons.calendar_month, color: AppColors.primary), label: 'Book'),
          NavigationDestination(icon: Icon(Icons.receipt_long_outlined, color: Colors.white70), selectedIcon: Icon(Icons.receipt_long, color: AppColors.primary), label: 'My Bookings'),
          NavigationDestination(icon: Icon(Icons.person_outlined, color: Colors.white70), selectedIcon: Icon(Icons.person, color: AppColors.primary), label: 'Profile'),
        ],
      ),
    );
  }
}

class _HomeTab extends StatelessWidget {
  const _HomeTab();

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>();

    return CustomScrollView(
      slivers: [
        SliverAppBar(
          expandedHeight: 220,
          pinned: true,
          backgroundColor: const Color(0xFF003158),
          flexibleSpace: FlexibleSpaceBar(
            title: Text('BlueSense Resort',
                style: GoogleFonts.poppins(
                    fontWeight: FontWeight.w700, fontSize: 16, color: Colors.white)),
            background: Stack(
              fit: StackFit.expand,
              children: [
                Image.asset(
                  'assets/images/hero/welcome.jpg',
                  fit: BoxFit.cover,
                  filterQuality: FilterQuality.high,
                  errorBuilder: (context, error, stackTrace) {
                    return Container(
                      decoration: const BoxDecoration(
                        gradient: LinearGradient(
                          colors: [Color(0xFF003158), Color(0xFF001a2e)],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                      ),
                    );
                  },
                ),
                Container(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [Colors.black.withOpacity(0.4), Colors.transparent],
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                    ),
                  ),
                ),
              ],
            ),
          ),
          actions: [
            IconButton(
              icon: const Icon(Icons.logout, color: Colors.white),
              onPressed: () async {
                await context.read<AuthProvider>().logout();
                if (context.mounted) Navigator.pushReplacementNamed(context, '/login');
              },
            ),
          ],
        ),
        SliverPadding(
          padding: const EdgeInsets.all(16),
          sliver: SliverList(
            delegate: SliverChildListDelegate([
              // Welcome Card
              if (auth.user != null)
                GlassCard(
                  padding: const EdgeInsets.all(16),
                  child: Row(
                    children: [
                      CircleAvatar(
                        radius: 28,
                        backgroundColor: AppColors.primary,
                        child: Text(
                          auth.user!.name.isNotEmpty ? auth.user!.name[0].toUpperCase() : 'U',
                          style: const TextStyle(color: Color(0xFF003158), fontWeight: FontWeight.bold, fontSize: 18),
                        ),
                      ),
                      const SizedBox(width: 14),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('Welcome back!',
                                style: GoogleFonts.poppins(
                                    fontSize: 12, color: Colors.white70)),
                            Text(auth.user!.name,
                                style: GoogleFonts.poppins(
                                    fontSize: 18, fontWeight: FontWeight.w700,
                                    color: Colors.white)),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              const SizedBox(height: 20),

              // Quick actions
              Text('Quick Actions',
                  style: GoogleFonts.poppins(
                      fontSize: 16, fontWeight: FontWeight.w700, color: Colors.white)),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    child: _QuickActionCard(
                      icon: Icons.calendar_month,
                      label: 'Book Now',
                      color: AppColors.primary,
                      onTap: () => Navigator.pushNamed(context, '/booking'),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _QuickActionCard(
                      icon: Icons.receipt_long,
                      label: 'My Bookings',
                      color: AppColors.primary,
                      onTap: () => Navigator.pushNamed(context, '/my-bookings'),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _QuickActionCard(
                      icon: Icons.sensors,
                      label: 'Pool Status',
                      color: AppColors.primary,
                      onTap: () => Navigator.pushNamed(context, '/pool-monitoring'),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 24),

              // Our Pools
              Text('Our Pools',
                  style: GoogleFonts.poppins(
                      fontSize: 16, fontWeight: FontWeight.w700, color: Colors.white)),
              const SizedBox(height: 12),
              _PoolCard(
                name: 'Oasis 1',
                imagePath: 'assets/images/hero/oasis1.jpg',
                description:
                    'A tropical paradise with swimming pool, jacuzzi, and private cottages. Perfect for groups and family getaways.',
                icon: Icons.waves,
                color: AppColors.primary,
                onTap: () => Navigator.pushNamed(context, '/oasis-1'),
              ),
              const SizedBox(height: 12),
              _PoolCard(
                name: 'Oasis 2',
                imagePath: 'assets/images/hero/oasis2.jpg',
                description:
                    'Exclusive private pool experience with covered function hall. Ideal for special events and large groups.',
                icon: Icons.pool,
                color: AppColors.primary,
                onTap: () => Navigator.pushNamed(context, '/oasis-2'),
              ),
              const SizedBox(height: 24),

              // Special Packages Section
              Text('Special Packages',
                  style: GoogleFonts.poppins(
                      fontSize: 18, fontWeight: FontWeight.w700, color: Colors.white)),
              const SizedBox(height: 8),
              Text('Exclusive offers for your perfect getaway',
                  style: GoogleFonts.poppins(
                      fontSize: 12, color: Colors.white70)),
              const SizedBox(height: 12),
              
              // Package Cards
              _PackageCard(
                name: 'Standard Package',
                price: '₱1,500',
                duration: 'Day Tour',
                features: const ['Pool Access', '2 Meals', '1 Cottage'],
                imagePath: 'assets/images/package/package-1.jpg',
                color: AppColors.primary,
                onTap: () => Navigator.pushNamed(context, '/package/standard'),
              ),
              const SizedBox(height: 12),
              
              _PackageCard(
                name: 'Premium Package',
                price: '₱2,500',
                duration: 'Day Tour',
                features: const ['Pool Access', '3 Meals', '1 Private Cottage', 'Welcome Drink'],
                imagePath: 'assets/images/package/package-2.jpg',
                color: AppColors.primary,
                onTap: () => Navigator.pushNamed(context, '/package/premium'),
              ),
              const SizedBox(height: 12),
              
              _PackageCard(
                name: 'Executive Package',
                price: '₱3,500',
                duration: 'Day Tour',
                features: const ['Pool Access', 'Buffet Lunch', 'Private Kubo', 'Free Towels', 'Fruit Platter'],
                imagePath: 'assets/images/package/package-3.jpg',
                color: AppColors.primary,
                onTap: () => Navigator.pushNamed(context, '/package/executive'),
              ),
              const SizedBox(height: 12),
              
              _PackageCard(
                name: 'Overnight Package',
                price: '₱5,000',
                duration: 'Overnight',
                features: const ['Pool Access', 'Dinner & Breakfast', 'Aircon Room', 'Free Breakfast'],
                imagePath: 'assets/images/package/package-4.jpg',
                color: AppColors.primary,
                onTap: () => Navigator.pushNamed(context, '/package/overnight'),
              ),
              const SizedBox(height: 12),
              
              _PackageCard(
                name: 'Family Package',
                price: '₱7,500',
                duration: '2 Days / 1 Night',
                features: const ['Pool Access', '3 Meals', 'Family Room', 'Free Kids Swim', 'Game Room Access'],
                imagePath: 'assets/images/package/package-5.jpg',
                color: AppColors.primary,
                onTap: () => Navigator.pushNamed(context, '/package/family'),
              ),
              const SizedBox(height: 12),
              
              _PackageCard(
                name: 'Deluxe Plus Package',
                price: '₱10,000',
                duration: '2 Days / 1 Night',
                features: const ['All Premium Features', 'VIP Lounge', 'Spa Treatment', 'Private Jacuzzi', 'Champagne'],
                imagePath: 'assets/images/package/package-5plus.jpg',
                color: AppColors.primary,
                isFeatured: true,
                onTap: () => Navigator.pushNamed(context, '/package/deluxe-plus'),
              ),
              const SizedBox(height: 24),

              // Amenities
              Text('Amenities',
                  style: GoogleFonts.poppins(
                      fontSize: 16, fontWeight: FontWeight.w700, color: Colors.white)),
              const SizedBox(height: 12),
              const Wrap(
                spacing: 10,
                runSpacing: 10,
                children: [
                  _AmenityChip(label: 'Swimming Pool', icon: Icons.pool),
                  _AmenityChip(label: 'Jacuzzi', icon: Icons.spa),
                  _AmenityChip(label: 'Free WiFi', icon: Icons.wifi),
                  _AmenityChip(label: 'BBQ Grill', icon: Icons.outdoor_grill),
                  _AmenityChip(label: 'Karaoke', icon: Icons.mic),
                  _AmenityChip(label: 'AC Rooms', icon: Icons.ac_unit),
                  _AmenityChip(label: 'Smart TV', icon: Icons.tv),
                  _AmenityChip(label: 'Parking', icon: Icons.local_parking),
                ],
              ),
              const SizedBox(height: 24),

              // Contact Card
              GestureDetector(
                onTap: () => Navigator.pushNamed(context, '/contact-us'),
                child: GlassCard(
                  padding: const EdgeInsets.all(16),
                  child: Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.15),
                          borderRadius: BorderRadius.circular(14),
                        ),
                        child: const Icon(Icons.headset_mic, color: AppColors.primary, size: 28),
                      ),
                      const SizedBox(width: 14),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('Need help?',
                                style: GoogleFonts.poppins(
                                    color: Colors.white, fontWeight: FontWeight.w700, fontSize: 16)),
                            Text('Contact us for inquiries about reservations.',
                                style: GoogleFonts.poppins(
                                    color: Colors.white70, fontSize: 13)),
                          ],
                        ),
                      ),
                      const Icon(Icons.arrow_forward_ios, color: Colors.white54, size: 16),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 16),
              
              // More links
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton.icon(
                      icon: const Icon(Icons.info_outlined, size: 18),
                      label: const Text('About Us'),
                      style: OutlinedButton.styleFrom(
                        side: const BorderSide(color: AppColors.primary),
                        foregroundColor: AppColors.primary,
                      ),
                      onPressed: () => Navigator.pushNamed(context, '/about-us'),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: OutlinedButton.icon(
                      icon: const Icon(Icons.photo_library_outlined, size: 18),
                      label: const Text('Gallery'),
                      style: OutlinedButton.styleFrom(
                        side: const BorderSide(color: AppColors.primary),
                        foregroundColor: AppColors.primary,
                      ),
                      onPressed: () => Navigator.pushNamed(context, '/gallery'),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 24),
            ]),
          ),
        ),
      ],
    );
  }
}

class _PackageCard extends StatelessWidget {
  final String name;
  final String price;
  final String duration;
  final List<String> features;
  final String? imagePath;
  final Color color;
  final VoidCallback onTap;
  final bool isFeatured;

  const _PackageCard({
    required this.name,
    required this.price,
    required this.duration,
    required this.features,
    this.imagePath,
    required this.color,
    required this.onTap,
    this.isFeatured = false,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
                color: Colors.black.withOpacity(0.15),
                blurRadius: 12,
                offset: const Offset(0, 4))
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Stack(
              children: [
                ClipRRect(
                  borderRadius: const BorderRadius.only(
                    topLeft: Radius.circular(16),
                    topRight: Radius.circular(16),
                  ),
                  child: Image.asset(
                    imagePath ?? 'assets/images/package/package-1.jpg',
                    height: 160,
                    width: double.infinity,
                    fit: BoxFit.cover,
                    filterQuality: FilterQuality.high,
                    errorBuilder: (context, error, stackTrace) {
                      return Container(
                        height: 160,
                        color: const Color(0xFF003158),
                        child: const Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(Icons.image_not_supported_outlined, color: AppColors.primary, size: 48),
                              SizedBox(height: 8),
                              Text('Image Not Found',
                                  style: TextStyle(color: Colors.white54, fontSize: 12)),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
                ),
                if (isFeatured)
                  Positioned(
                    top: 12,
                    right: 12,
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(
                          colors: [Color(0xFFFF6B6B), Color(0xFFFF4757)],
                        ),
                        borderRadius: BorderRadius.circular(20),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.2),
                            blurRadius: 4,
                          ),
                        ],
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(Icons.star, color: Colors.white, size: 14),
                          const SizedBox(width: 4),
                          Text('BEST SELLER',
                              style: GoogleFonts.poppins(
                                  color: Colors.white,
                                  fontSize: 10,
                                  fontWeight: FontWeight.w700)),
                        ],
                      ),
                    ),
                  ),
                Positioned(
                  bottom: 12,
                  left: 12,
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: Colors.black.withOpacity(0.7),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(Icons.access_time, color: Colors.white, size: 12),
                        const SizedBox(width: 4),
                        Text(duration,
                            style: GoogleFonts.poppins(
                                color: Colors.white,
                                fontSize: 11,
                                fontWeight: FontWeight.w500)),
                      ],
                    ),
                  ),
                ),
              ],
            ),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.08),
                borderRadius: const BorderRadius.only(
                  bottomLeft: Radius.circular(16),
                  bottomRight: Radius.circular(16),
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Text(name,
                            style: GoogleFonts.poppins(
                                fontWeight: FontWeight.w700,
                                fontSize: 16,
                                color: Colors.white)),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                        decoration: BoxDecoration(
                          color: AppColors.primary.withOpacity(0.2),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Text(price,
                            style: GoogleFonts.poppins(
                                fontWeight: FontWeight.w700,
                                fontSize: 16,
                                color: AppColors.primary)),
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),
                  Wrap(
                    spacing: 8,
                    runSpacing: 6,
                    children: features.map((feature) {
                      return Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.08),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Icon(Icons.check_circle_outline,
                                size: 10, color: AppColors.primary),
                            const SizedBox(width: 4),
                            Text(feature,
                                style: GoogleFonts.poppins(
                                    fontSize: 10, color: Colors.white70)),
                          ],
                        ),
                      );
                    }).toList(),
                  ),
                  const SizedBox(height: 12),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primary,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 10),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                      onPressed: onTap,
                      child: const Text('View Details', style: TextStyle(fontWeight: FontWeight.w600)),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _QuickActionCard extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;
  final VoidCallback onTap;

  const _QuickActionCard({
    required this.icon,
    required this.label,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 20),
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.08),
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: Colors.white.withOpacity(0.15)),
        ),
        child: Column(
          children: [
            Icon(icon, color: color, size: 32),
            const SizedBox(height: 8),
            Text(label,
                style: GoogleFonts.poppins(
                    color: color, fontWeight: FontWeight.w700, fontSize: 13)),
          ],
        ),
      ),
    );
  }
}

class _PoolCard extends StatelessWidget {
  final String name;
  final String? imagePath;
  final String description;
  final IconData icon;
  final Color color;
  final VoidCallback onTap;

  const _PoolCard({
    required this.name,
    this.imagePath,
    required this.description,
    required this.icon,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
                color: Colors.black.withOpacity(0.12),
                blurRadius: 10,
                offset: const Offset(0, 4))
          ],
        ),
        child: Column(
          children: [
            if (imagePath != null)
              ClipRRect(
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(16),
                  topRight: Radius.circular(16),
                ),
                child: Image.asset(
                  imagePath!,
                  height: 180,
                  width: double.infinity,
                  fit: BoxFit.cover,
                  filterQuality: FilterQuality.high,
                  errorBuilder: (context, error, stackTrace) {
                    return Container(
                      height: 180,
                      color: const Color(0xFF003158),
                      child: Center(
                        child: Icon(icon, color: AppColors.primary, size: 56),
                      ),
                    );
                  },
                ),
              ),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.08),
                borderRadius: imagePath != null
                    ? const BorderRadius.only(
                        bottomLeft: Radius.circular(16),
                        bottomRight: Radius.circular(16),
                      )
                    : BorderRadius.circular(16),
              ),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Icon(icon, color: color, size: 28),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(name,
                            style: GoogleFonts.poppins(
                                fontWeight: FontWeight.w700,
                                fontSize: 15,
                                color: Colors.white)),
                        const SizedBox(height: 4),
                        Text(description,
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                            style: GoogleFonts.poppins(
                                color: Colors.white70, fontSize: 12)),
                      ],
                    ),
                  ),
                  const Icon(Icons.arrow_forward_ios,
                      color: Colors.white54, size: 14),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _AmenityChip extends StatelessWidget {
  final String label;
  final IconData icon;
  const _AmenityChip({required this.label, required this.icon});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.08),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.white.withOpacity(0.15)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: AppColors.primary),
          const SizedBox(width: 6),
          Text(label,
              style: GoogleFonts.poppins(
                  fontSize: 12,
                  color: Colors.white70,
                  fontWeight: FontWeight.w500)),
        ],
      ),
    );
  }
}

class _ProfileTab extends StatelessWidget {
  const _ProfileTab();

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>();
    final user = auth.user;

    return Scaffold(
      backgroundColor: const Color(0xFF003158),
      appBar: AppBar(
        title: const Text('Profile', style: TextStyle(color: Colors.white)),
        backgroundColor: const Color(0xFF003158),
        elevation: 0,
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Center(
            child: Column(
              children: [
                Container(
                  padding: const EdgeInsets.all(4),
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(color: AppColors.primary, width: 2),
                  ),
                  child: CircleAvatar(
                    radius: 45,
                    backgroundColor: AppColors.primary,
                    child: Text(
                      user?.name.isNotEmpty == true ? user!.name[0].toUpperCase() : 'U',
                      style: const TextStyle(color: Color(0xFF003158), fontSize: 36, fontWeight: FontWeight.bold),
                    ),
                  ),
                ),
                const SizedBox(height: 12),
                Text(user?.name ?? '',
                    style: GoogleFonts.poppins(
                        fontSize: 22, fontWeight: FontWeight.w700, color: Colors.white)),
                Text(user?.email ?? '',
                    style: GoogleFonts.poppins(
                        color: Colors.white70, fontSize: 14)),
              ],
            ),
          ),
          const SizedBox(height: 24),
          _ProfileItem(icon: Icons.person_outlined, label: 'Full Name', value: user?.name ?? ''),
          const SizedBox(height: 10),
          _ProfileItem(icon: Icons.email_outlined, label: 'Email', value: user?.email ?? ''),
          const SizedBox(height: 10),
          _ProfileItem(icon: Icons.phone_outlined, label: 'Phone', value: user?.phone ?? 'Not set'),
          const SizedBox(height: 10),
          _ProfileItem(icon: Icons.badge_outlined, label: 'Role', value: user?.role ?? ''),
          const SizedBox(height: 24),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14),
                ),
              ),
              icon: const Icon(Icons.logout),
              label: const Text('Logout', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
              onPressed: () async {
                await auth.logout();
                if (context.mounted) Navigator.pushReplacementNamed(context, '/login');
              },
            ),
          ),
        ],
      ),
    );
  }
}

class _ProfileItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  const _ProfileItem({required this.icon, required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.08),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: Colors.white.withOpacity(0.15)),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.1),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, color: AppColors.primary, size: 22),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(label,
                    style: GoogleFonts.poppins(
                        fontSize: 11, color: Colors.white54)),
                Text(value.isNotEmpty ? value : 'Not set',
                    style: GoogleFonts.poppins(
                        fontSize: 15, fontWeight: FontWeight.w600, color: Colors.white)),
              ],
            ),
          ),
        ],
      ),
    );
  }
}