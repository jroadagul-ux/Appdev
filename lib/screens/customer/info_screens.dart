// lib/screens/customer/info_screens.dart
// About Us, Oasis 1, Oasis 2, Gallery, Contact Us
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../config/app_theme.dart';
import '../../config/package_data.dart';
import '../../widgets/core/glass_card.dart';

// ============================================
// ABOUT US
// ============================================
class AboutUsScreen extends StatelessWidget {
  const AboutUsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF003158),
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            expandedHeight: 180,
            pinned: true,
            backgroundColor: const Color(0xFF003158),
            flexibleSpace: FlexibleSpaceBar(
              title: Text("About Catherine's Oasis",
                  style: GoogleFonts.poppins(fontWeight: FontWeight.w700, fontSize: 14, color: Colors.white)),
              background: Container(
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    colors: [Color(0xFF003158), Color(0xFF001a2e)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                ),
                child: const Center(
                  child: Icon(Icons.info_outline, color: AppColors.primary, size: 60),
                ),
              ),
            ),
            leading: IconButton(
              icon: const Icon(Icons.arrow_back, color: Colors.white),
              onPressed: () => Navigator.pop(context),
            ),
          ),
          SliverPadding(
            padding: const EdgeInsets.all(16),
            sliver: SliverList(
              delegate: SliverChildListDelegate([
                const _InfoSection(
                  title: 'Our Story',
                  content: "Catherine's Oasis was founded with a simple mission: to provide a serene escape from the hustle and bustle of everyday life. What started as a vision has blossomed into one of the most sought-after resort destinations, known for its exceptional service, stunning facilities, and warm hospitality.\n\nOver the years, we have hosted thousands of happy guests from around the world, creating unforgettable memories and lasting impressions.",
                ),
                const _InfoSection(
                  title: 'Our Mission',
                  content: "We are committed to creating unforgettable experiences for every guest. Whether you're seeking relaxation, adventure, or celebrating a special milestone, our team is dedicated to exceeding your expectations and making your stay truly memorable.\n\nOur mission extends beyond providing accommodation; we strive to be your trusted partner in creating moments that matter.",
                ),
                const _InfoSection(
                  title: 'Why Choose Us',
                  content: null,
                  bullets: [
                    'Premium private pool facilities',
                    'Professional and friendly staff',
                    'Modern amenities and smart technology',
                    'Affordable packages for all group sizes',
                    'Scenic and peaceful environment',
                    'Easy online booking system',
                  ],
                ),
                const _InfoSection(
                  title: 'Our Values',
                  content: null,
                  bullets: [
                    'Excellence in service',
                    'Guest satisfaction first',
                    'Clean and safe environment',
                    'Transparency and fairness',
                    'Continuous improvement',
                  ],
                ),
                const SizedBox(height: 20),
                SizedBox(
                  width: double.infinity,
                  height: 50,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primary,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                    ),
                    onPressed: () => Navigator.pushNamed(context, '/booking'),
                    child: const Text(
                      'Book Now',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
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

// ============================================
// OASIS 1
// ============================================
class Oasis1Screen extends StatelessWidget {
  const Oasis1Screen({super.key});

  @override
  Widget build(BuildContext context) {
    return _OasisScreen(
      name: 'Oasis 1',
      subtitle: 'Perfect for intimate gatherings and family outings',
      description: "Oasis 1 is our cozy and intimate retreat designed for smaller groups seeking a peaceful escape. With carefully curated amenities, lush green surroundings, and personalized service, we ensure every moment of your stay is truly memorable.\n\nIdeal for family reunions, intimate celebrations, romantic getaways, and small corporate gatherings.",
      features: const [
        'Swimming pool with bubble jacuzzi and fountain',
        'Cottage (Gazebo) and kubo cottage near parking area',
        'Free WiFi',
        'Portable griller',
        'Optional karaoke & stove',
        'AC rooms available (Superior & Family)',
        'Smart TV with Netflix',
        'All outside amenities',
      ],
      packages: oasisPackages['Oasis 1'] ?? {},
    );
  }
}

// ============================================
// OASIS 2
// ============================================
class Oasis2Screen extends StatelessWidget {
  const Oasis2Screen({super.key});

  @override
  Widget build(BuildContext context) {
    return _OasisScreen(
      name: 'Oasis 2',
      subtitle: 'Spacious grounds ideal for larger events and celebrations',
      description: "Oasis 2 is our premium exclusive pool experience designed for larger groups and special events. Featuring a private pool and covered function hall, it's the perfect venue for unforgettable celebrations.\n\nPerfect for large family gatherings, birthday parties, corporate events, and group celebrations.",
      features: const [
        'Exclusive private pool access',
        'Covered function hall',
        'BBQ grill area',
        'Free WiFi',
        'Outdoor lounge area',
        'Optional AC rooms',
        'All outside amenities',
      ],
      packages: oasisPackages['Oasis 2'] ?? {},
    );
  }
}

class _OasisScreen extends StatelessWidget {
  final String name;
  final String subtitle;
  final String description;
  final List<String> features;
  final Map<String, OasisPackage> packages;

  const _OasisScreen({
    required this.name,
    required this.subtitle,
    required this.description,
    required this.features,
    required this.packages,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF003158),
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            expandedHeight: 200,
            pinned: true,
            backgroundColor: const Color(0xFF003158),
            flexibleSpace: FlexibleSpaceBar(
              title: Text(name, style: GoogleFonts.poppins(fontWeight: FontWeight.w700, color: Colors.white)),
              background: Container(
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    colors: [Color(0xFF003158), Color(0xFF001a2e)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                ),
                child: const Center(child: Icon(Icons.pool, color: AppColors.primary, size: 64)),
              ),
            ),
            leading: IconButton(
              icon: const Icon(Icons.arrow_back, color: Colors.white),
              onPressed: () => Navigator.pop(context),
            ),
          ),
          SliverPadding(
            padding: const EdgeInsets.all(16),
            sliver: SliverList(
              delegate: SliverChildListDelegate([
                Text(subtitle,
                    style: GoogleFonts.poppins(fontSize: 15, color: Colors.white70)),
                const SizedBox(height: 14),
                Text(description,
                    style: GoogleFonts.poppins(fontSize: 14, height: 1.6, color: Colors.white70)),
                const SizedBox(height: 20),

                Text('Inclusions',
                    style: GoogleFonts.poppins(fontSize: 16, fontWeight: FontWeight.w700, color: Colors.white)),
                const SizedBox(height: 10),
                ...features.map((f) => Padding(
                  padding: const EdgeInsets.only(bottom: 8),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Icon(Icons.check_circle, color: AppColors.primary, size: 16),
                      const SizedBox(width: 8),
                      Expanded(child: Text(f, style: GoogleFonts.poppins(fontSize: 13, color: Colors.white70))),
                    ],
                  ),
                )),
                const SizedBox(height: 20),

                Text('Packages',
                    style: GoogleFonts.poppins(fontSize: 16, fontWeight: FontWeight.w700, color: Colors.white)),
                const SizedBox(height: 10),
                ...packages.entries.map((entry) {
                  final pkg = entry.value;
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 12),
                    child: GlassCard(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(pkg.name,
                              style: GoogleFonts.poppins(fontWeight: FontWeight.w700, fontSize: 16, color: Colors.white)),
                          Text(pkg.description,
                              style: GoogleFonts.poppins(fontSize: 13, color: Colors.white70)),
                          const SizedBox(height: 8),
                          const Divider(height: 1, color: Colors.white24),
                          const SizedBox(height: 8),
                          Text('Pricing',
                              style: GoogleFonts.poppins(fontWeight: FontWeight.w600, fontSize: 13, color: Colors.white70)),
                          const SizedBox(height: 6),
                          ...pkg.pricing.entries.where((p) => p.value != null).map((pricingEntry) => Padding(
                            padding: const EdgeInsets.only(bottom: 4),
                            child: Row(
                              children: [
                                SizedBox(
                                  width: 60,
                                  child: Text(pricingEntry.key,
                                      style: GoogleFonts.poppins(
                                          fontSize: 12, color: Colors.white54)),
                                ),
                                Text(
                                  '₱${_fmt(pricingEntry.value!.weekday)} (weekday)  ·  ₱${_fmt(pricingEntry.value!.weekend)} (weekend)',
                                  style: GoogleFonts.poppins(
                                      fontSize: 12, fontWeight: FontWeight.w600, color: AppColors.primary),
                                ),
                              ],
                            ),
                          )),
                          if (pkg.addons.isNotEmpty) ...[
                            const SizedBox(height: 8),
                            Text('Add-ons: ${pkg.addons.join(', ')}',
                                style: GoogleFonts.poppins(fontSize: 12, color: Colors.white54)),
                          ],
                        ],
                      ),
                    ),
                  );
                }),
                const SizedBox(height: 16),
                SizedBox(
                  width: double.infinity,
                  height: 50,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primary,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                    ),
                    onPressed: () => Navigator.pushNamed(context, '/booking'),
                    child: Text(
                      'Book $name',
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
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

  String _fmt(int? v) {
    if (v == null) return 'N/A';
    return v.toString().replaceAllMapped(
        RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (m) => '${m[1]},');
  }
}

// ============================================
// GALLERY
// ============================================
class GalleryScreen extends StatelessWidget {
  const GalleryScreen({super.key});

  final List<Map<String, dynamic>> _galleryItems = const [
    {'icon': Icons.pool, 'title': 'Swimming Pool', 'desc': 'Crystal clear waters'},
    {'icon': Icons.spa, 'title': 'Jacuzzi Area', 'desc': 'Relax and unwind'},
    {'icon': Icons.cottage, 'title': 'Cottages', 'desc': 'Comfortable resting area'},
    {'icon': Icons.outdoor_grill, 'title': 'BBQ Area', 'desc': 'Perfect for grilling'},
    {'icon': Icons.hotel, 'title': 'AC Rooms', 'desc': 'Cool and comfortable'},
    {'icon': Icons.tv, 'title': 'Entertainment', 'desc': 'Netflix & more'},
    {'icon': Icons.wifi, 'title': 'Free WiFi', 'desc': 'Stay connected'},
    {'icon': Icons.local_parking, 'title': 'Parking Area', 'desc': 'Secure parking space'},
    {'icon': Icons.nightlight_round, 'title': 'Night Events', 'desc': 'Beautiful night ambiance'},
    {'icon': Icons.celebration, 'title': 'Events', 'desc': 'Special celebrations'},
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF003158),
      appBar: AppBar(
        title: Text("Gallery", style: GoogleFonts.poppins(fontWeight: FontWeight.w700, color: Colors.white)),
        backgroundColor: const Color(0xFF003158),
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            color: AppColors.primary.withOpacity(0.1),
            child: Text(
              "Explore Catherine's Oasis through our gallery. Experience the beauty of our resort facilities.",
              style: GoogleFonts.poppins(fontSize: 13, color: Colors.white70),
              textAlign: TextAlign.center,
            ),
          ),
          Expanded(
            child: GridView.builder(
              padding: const EdgeInsets.all(12),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                crossAxisSpacing: 12,
                mainAxisSpacing: 12,
                childAspectRatio: 1.1,
              ),
              itemCount: _galleryItems.length,
              itemBuilder: (_, i) {
                final item = _galleryItems[i];
                return Container(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        AppColors.primary.withOpacity(0.2 + (i % 3) * 0.1),
                        const Color(0xFF003158).withOpacity(0.8),
                      ],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: Colors.white.withOpacity(0.15)),
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(item['icon'] as IconData, color: AppColors.primary, size: 44),
                      const SizedBox(height: 10),
                      Text(item['title'] as String,
                          style: GoogleFonts.poppins(
                              color: Colors.white, fontWeight: FontWeight.w700, fontSize: 14)),
                      Text(item['desc'] as String,
                          style: GoogleFonts.poppins(color: Colors.white70, fontSize: 11)),
                    ],
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

// ============================================
// CONTACT US
// ============================================
class ContactUsScreen extends StatefulWidget {
  const ContactUsScreen({super.key});
  @override
  State<ContactUsScreen> createState() => _ContactUsScreenState();
}

class _ContactUsScreenState extends State<ContactUsScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameCtrl = TextEditingController();
  final _emailCtrl = TextEditingController();
  final _phoneCtrl = TextEditingController();
  final _subjectCtrl = TextEditingController();
  final _messageCtrl = TextEditingController();

  @override
  void dispose() {
    _nameCtrl.dispose();
    _emailCtrl.dispose();
    _phoneCtrl.dispose();
    _subjectCtrl.dispose();
    _messageCtrl.dispose();
    super.dispose();
  }

  void _submit() {
    if (!_formKey.currentState!.validate()) return;
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        backgroundColor: const Color(0xFF003158),
        child: Container(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: AppColors.success.withOpacity(0.15),
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.check_circle, color: AppColors.success, size: 56),
              ),
              const SizedBox(height: 20),
              Text("Message Sent!",
                  style: GoogleFonts.poppins(fontSize: 20, fontWeight: FontWeight.w700, color: Colors.white)),
              const SizedBox(height: 8),
              Text("Thank you for your message! We will get back to you soon.",
                  textAlign: TextAlign.center,
                  style: GoogleFonts.poppins(color: Colors.white70)),
              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                  ),
                  onPressed: () {
                    Navigator.pop(context);
                    _nameCtrl.clear();
                    _emailCtrl.clear();
                    _phoneCtrl.clear();
                    _subjectCtrl.clear();
                    _messageCtrl.clear();
                  },
                  child: const Text(
                    'Done',
                    style: TextStyle(
                      fontWeight: FontWeight.w600,
                      fontSize: 16,
                    ),
                  ),
                ),
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
      backgroundColor: const Color(0xFF003158),
      appBar: AppBar(
        title: Text("Contact Us", style: GoogleFonts.poppins(fontWeight: FontWeight.w700, color: Colors.white)),
        backgroundColor: const Color(0xFF003158),
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          const Row(
            children: [
              Expanded(child: _ContactCard(Icons.location_on, 'Location', 'Philippines')),
              SizedBox(width: 10),
              Expanded(child: _ContactCard(Icons.phone, 'Phone', '+63 XXX XXX XXXX')),
            ],
          ),
          const SizedBox(height: 10),
          const Row(
            children: [
              Expanded(child: _ContactCard(Icons.email, 'Email', 'info@cathysoasis.com')),
              SizedBox(width: 10),
              Expanded(child: _ContactCard(Icons.access_time, 'Hours', '6AM - 10PM')),
            ],
          ),
          const SizedBox(height: 24),
          Text("Send us a Message",
              style: GoogleFonts.poppins(fontSize: 16, fontWeight: FontWeight.w700, color: Colors.white)),
          const SizedBox(height: 14),
          Form(
            key: _formKey,
            child: Column(
              children: [
                _buildTextField(_nameCtrl, 'Full Name *', Icons.person_outline, validator: (v) => v?.isEmpty == true ? 'Required' : null),
                const SizedBox(height: 14),
                _buildTextField(_emailCtrl, 'Email Address *', Icons.email_outlined, keyboardType: TextInputType.emailAddress,
                  validator: (v) {
                    if (v?.isEmpty == true) return 'Required';
                    if (!v!.contains('@')) return 'Invalid email';
                    return null;
                  },
                ),
                const SizedBox(height: 14),
                _buildTextField(_phoneCtrl, 'Phone Number', Icons.phone_outlined, keyboardType: TextInputType.phone),
                const SizedBox(height: 14),
                _buildTextField(_subjectCtrl, 'Subject *', Icons.subject, validator: (v) => v?.isEmpty == true ? 'Required' : null),
                const SizedBox(height: 14),
                _buildTextField(_messageCtrl, 'Message *', Icons.message_outlined, maxLines: 4, validator: (v) => v?.isEmpty == true ? 'Required' : null),
                const SizedBox(height: 20),
                SizedBox(
                  width: double.infinity,
                  height: 52,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primary,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                    ),
                    onPressed: _submit,
                    child: const Text(
                      'Send Message',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),
        ],
      ),
    );
  }

  Widget _buildTextField(TextEditingController controller, String label, IconData icon,
      {TextInputType keyboardType = TextInputType.text, int maxLines = 1, String? Function(String?)? validator}) {
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
            maxLines: maxLines,
            style: GoogleFonts.poppins(color: Colors.grey.shade800, fontSize: 15),
            validator: validator,
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

class _ContactCard extends StatelessWidget {
  final IconData icon;
  final String label, value;
  const _ContactCard(this.icon, this.label, this.value);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.08),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: Colors.white.withOpacity(0.15)),
      ),
      child: Column(
        children: [
          Icon(icon, color: AppColors.primary, size: 28),
          const SizedBox(height: 6),
          Text(label, style: GoogleFonts.poppins(fontSize: 11, color: Colors.white54)),
          Text(value,
              style: GoogleFonts.poppins(fontSize: 12, fontWeight: FontWeight.w700, color: Colors.white),
              textAlign: TextAlign.center),
        ],
      ),
    );
  }
}

// ============================================
// HELPER - INFO SECTION
// ============================================
class _InfoSection extends StatelessWidget {
  final String title;
  final String? content;
  final List<String>? bullets;

  const _InfoSection({required this.title, this.content, this.bullets});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: GlassCard(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(children: [
              Container(
                width: 4,
                height: 20,
                decoration: BoxDecoration(
                  color: AppColors.primary,
                  borderRadius: BorderRadius.circular(2)
                ),
              ),
              const SizedBox(width: 10),
              Text(
                title,
                style: GoogleFonts.poppins(
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                  color: Colors.white
                ),
              ),
            ]),
            const SizedBox(height: 12),
            if (content != null)
              Text(
                content!,
                style: GoogleFonts.poppins(
                  fontSize: 14,
                  height: 1.6,
                  color: Colors.white70
                ),
              ),
            if (bullets != null)
              ...bullets!.map((b) => Padding(
                padding: const EdgeInsets.only(bottom: 6),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Icon(Icons.check_circle, color: AppColors.primary, size: 16),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        b,
                        style: GoogleFonts.poppins(
                          fontSize: 13,
                          color: Colors.white70
                        ),
                      ),
                    ),
                  ],
                ),
              )),
          ],
        ),
      ),
    );
  }
}