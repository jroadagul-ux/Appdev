// lib/screens/customer/package_details_screen.dart
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../config/app_theme.dart';

import '../../widgets/core/glass_card.dart';

class PackageDetailsScreen extends StatelessWidget {
  final String packageName;

  const PackageDetailsScreen({
    super.key,
    required this.packageName,
  });

  // Package details data
  static final Map<String, Map<String, dynamic>> packageDetails = {
    'standard': {
      'name': 'Standard Package',
      'price': '₱1,500',
      'duration': 'Day Tour',
      'image': 'assets/images/package/package-1.jpg',
      'features': ['Pool Access', '2 Meals', '1 Cottage'],
      'description': 'Perfect for small groups and families looking for a refreshing day out.',
      'highlights': [
        'Access to swimming pool with jacuzzi',
        '2 meals (lunch & snacks)',
        '1 cottage accommodation for the day',
        'Free WiFi',
        'Use of all basic amenities',
      ],
    },
    'premium': {
      'name': 'Premium Package',
      'price': '₱2,500',
      'duration': 'Day Tour',
      'image': 'assets/images/package/package-2.jpg',
      'features': ['Pool Access', '3 Meals', '1 Private Cottage', 'Welcome Drink'],
      'description': 'Upgrade your experience with premium amenities and enhanced hospitality.',
      'highlights': [
        'Full pool access with priority reserved area',
        '3 meals (breakfast, lunch, dinner)',
        '1 private cottage with air conditioning',
        'Welcome beverage upon arrival',
        'Free WiFi and premium towels',
        'Access to entertainment facilities',
      ],
    },
    'executive': {
      'name': 'Executive Package',
      'price': '₱3,500',
      'duration': 'Day Tour',
      'image': 'assets/images/package/package-3.jpg',
      'features': ['Pool Access', 'Buffet Lunch', 'Private Kubo', 'Free Towels', 'Fruit Platter'],
      'description': 'Experience luxury and comfort with our executive offerings.',
      'highlights': [
        'Exclusive pool area access',
        'Buffet lunch with Filipino and international cuisine',
        'Private kubo (hut) for your group',
        'Premium towels and amenities',
        'Fresh fruit platter',
        'Priority customer service',
        'Access to premium recreational facilities',
      ],
    },
    'overnight': {
      'name': 'Overnight Package',
      'price': '₱5,000',
      'duration': 'Overnight',
      'image': 'assets/images/package/package-4.jpg',
      'features': ['Pool Access', 'Dinner & Breakfast', 'Aircon Room', 'Free Breakfast'],
      'description': 'Perfect for extended relaxation and comfort throughout the night.',
      'highlights': [
        'Full 24-hour access to facilities',
        'Dinner on arrival',
        'Complimentary breakfast',
        'Air-conditioned room',
        'Premium bedding and amenities',
        'Late checkout option available',
        'Evening entertainment activities',
      ],
    },
    'family': {
      'name': 'Family Package',
      'price': '₱7,500',
      'duration': '2 Days / 1 Night',
      'image': 'assets/images/package/package-5.jpg',
      'features': ['Pool Access', '3 Meals', 'Family Room', 'Free Kids Swim', 'Game Room Access'],
      'description': 'Create unforgettable memories with your loved ones in a family-friendly environment.',
      'highlights': [
        'Extended access for 2 days and 1 night',
        '3 meals per person (lunch day 1, dinner, breakfast day 2)',
        'Spacious family room accommodation',
        'Free swimming lessons for kids',
        'Unlimited game room access',
        'Kids activities and supervision',
        'Family-friendly entertainment programs',
      ],
    },
    'deluxe-plus': {
      'name': 'Deluxe Plus Package',
      'price': '₱10,000',
      'duration': '2 Days / 1 Night',
      'image': 'assets/images/package/package-5plus.jpg',
      'features': ['All Premium Features', 'VIP Lounge', 'Spa Treatment', 'Private Jacuzzi', 'Champagne'],
      'description': 'The ultimate luxury experience with all premium services and exclusive amenities.',
      'highlights': [
        '2 days / 1 night at deluxe suite',
        'All premium features included',
        'VIP lounge access with complimentary beverages',
        '1-hour spa treatment per person',
        'Private jacuzzi access',
        'Champagne welcome service',
        'Gourmet dining experience',
        'Personal concierge service',
        'Late checkout (2 PM)',
        'Priority reservation for future visits',
      ],
      'isFeatured': true,
    },
  };

  @override
  Widget build(BuildContext context) {
    final packageKey = packageName.toLowerCase();
    final details = packageDetails[packageKey] ?? packageDetails['standard']!;
    final isFeatured = details['isFeatured'] == true;

    return Scaffold(
      backgroundColor: const Color(0xFF003158),
      body: CustomScrollView(
        slivers: [
          // Sticky App Bar with Image
          SliverAppBar(
            expandedHeight: 300,
            pinned: true,
            backgroundColor: const Color(0xFF003158),
            flexibleSpace: FlexibleSpaceBar(
              title: Text(
                details['name'] as String,
                style: GoogleFonts.poppins(
                  fontWeight: FontWeight.w700,
                  fontSize: 16,
                  color: Colors.white,
                ),
              ),
              background: Stack(
                fit: StackFit.expand,
                children: [
                  Image.asset(
                    details['image'] as String,
                    fit: BoxFit.cover,
                    filterQuality: FilterQuality.high,
                    errorBuilder: (context, error, stackTrace) {
                      return Container(
                        color: AppColors.primary.withOpacity(0.3),
                        child: const Center(
                          child: Icon(Icons.image_not_supported_outlined,
                              size: 64, color: Colors.white54),
                        ),
                      );
                    },
                  ),
                  Container(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [Colors.black.withOpacity(0.5), Colors.transparent],
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            leading: IconButton(
              icon: const Icon(Icons.arrow_back, color: Colors.white),
              onPressed: () => Navigator.pop(context),
            ),
          ),
          
          // Content
          SliverPadding(
            padding: const EdgeInsets.all(16),
            sliver: SliverList(
              delegate: SliverChildListDelegate([
                // Price and Duration Card
                GlassCard(
                  padding: const EdgeInsets.all(16),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('Price',
                              style: GoogleFonts.poppins(
                                  fontSize: 12,
                                  color: Colors.white70)),
                          Text(details['price'] as String,
                              style: GoogleFonts.poppins(
                                  fontSize: 28,
                                  fontWeight: FontWeight.w800,
                                  color: AppColors.primary)),
                        ],
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 16, vertical: 8),
                        decoration: BoxDecoration(
                          color: AppColors.primary,
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Text(details['duration'] as String,
                            style: GoogleFonts.poppins(
                                fontSize: 13,
                                fontWeight: FontWeight.w600,
                                color: Colors.white)),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 20),

                // Description Section
                Text('About This Package',
                    style: GoogleFonts.poppins(
                        fontSize: 18, fontWeight: FontWeight.w700, color: Colors.white)),
                const SizedBox(height: 10),
                Text(details['description'] as String,
                    style: GoogleFonts.poppins(
                        fontSize: 14,
                        height: 1.6,
                        color: Colors.white70)),
                const SizedBox(height: 24),

                // Features Section
                Text('What\'s Included',
                    style: GoogleFonts.poppins(
                        fontSize: 18, fontWeight: FontWeight.w700, color: Colors.white)),
                const SizedBox(height: 14),
                GlassCard(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    children: (details['features'] as List<String>)
                        .map(
                          (feature) => Padding(
                            padding: const EdgeInsets.only(bottom: 12),
                            child: Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Container(
                                  margin: const EdgeInsets.only(top: 6, right: 12),
                                  width: 6,
                                  height: 6,
                                  decoration: const BoxDecoration(
                                    color: AppColors.primary,
                                    shape: BoxShape.circle,
                                  ),
                                ),
                                Expanded(
                                  child: Text(feature,
                                      style: GoogleFonts.poppins(
                                          fontSize: 14,
                                          color: Colors.white70)),
                                ),
                              ],
                            ),
                          ),
                        )
                        .toList(),
                  ),
                ),
                const SizedBox(height: 24),

                // Highlights Section
                Text('Highlights',
                    style: GoogleFonts.poppins(
                        fontSize: 18, fontWeight: FontWeight.w700, color: Colors.white)),
                const SizedBox(height: 14),
                GlassCard(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    children: (details['highlights'] as List<String>)
                        .map(
                          (highlight) => Padding(
                            padding: const EdgeInsets.only(bottom: 14),
                            child: Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Padding(
                                  padding: EdgeInsets.only(right: 12, top: 2),
                                  child: Icon(Icons.check_circle,
                                      size: 20,
                                      color: AppColors.primary),
                                ),
                                Expanded(
                                  child: Text(highlight,
                                      style: GoogleFonts.poppins(
                                          fontSize: 13,
                                          height: 1.5,
                                          color: Colors.white70)),
                                ),
                              ],
                            ),
                          ),
                        )
                        .toList(),
                  ),
                ),
                const SizedBox(height: 30),

                // Book Now Button
                SizedBox(
                  width: double.infinity,
                  height: 52,
                  child: ElevatedButton(
                    onPressed: () {
                      Navigator.pushNamed(context, '/booking',
                          arguments: {'packageName': packageName});
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primary,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14),
                      ),
                    ),
                    child: Text('Book This Package',
                        style: GoogleFonts.poppins(
                            fontSize: 16, fontWeight: FontWeight.w600)),
                  ),
                ),
                const SizedBox(height: 12),

                // Contact Support Button
                SizedBox(
                  width: double.infinity,
                  height: 52,
                  child: OutlinedButton(
                    onPressed: () {
                      Navigator.pushNamed(context, '/contact-us');
                    },
                    style: OutlinedButton.styleFrom(
                      side: const BorderSide(color: AppColors.primary, width: 1.5),
                      foregroundColor: AppColors.primary,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14),
                      ),
                    ),
                    child: Text('Need Help?',
                        style: GoogleFonts.poppins(
                            fontSize: 16, fontWeight: FontWeight.w600)),
                  ),
                ),
                const SizedBox(height: 24),
              ]),
            ),
          ),
        ],
      ),
    );
  }
}