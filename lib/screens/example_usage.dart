// lib/screens/example_usage.dart
// Example usage of redesigned widgets

import 'package:flutter/material.dart';
import '../widgets/common_widgets.dart';
import '../models/models.dart';
import 'package:google_fonts/google_fonts.dart';

class WidgetShowcaseScreen extends StatelessWidget {
  const WidgetShowcaseScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 5,
      child: Scaffold(
        appBar: AppBar(
          title: Text(
            'Widget Showcase',
            style: GoogleFonts.poppins(fontWeight: FontWeight.w700),
          ),
          bottom: const TabBar(
            tabs: [
              Tab(text: 'Bookings'),
              Tab(text: 'Rooms'),
              Tab(text: 'Staff'),
              Tab(text: 'Inventory'),
              Tab(text: 'Gallery'),
            ],
          ),
        ),
        body: TabBarView(
          children: [
            _buildBookingTab(),
            _buildRoomTab(),
            _buildStaffTab(),
            _buildInventoryTab(),
            _buildGalleryTab(),
          ],
        ),
      ),
    );
  }

  Widget _buildBookingTab() {
    // Example booking data
    final bookings = [
      BookingModel(
        id: '1',
        customerName: 'John Doe',
        customerContact: '09123456789',
        customerEmail: 'john@example.com',
        oasis: 'Oasis 1',
        package: 'Package 3',
        bookingDate: DateTime.now().add(const Duration(days: 5)),
        pax: 4,
        downpayment: 5000,
        paymentMethod: 'GCash',
        paymentStatus: 'Paid',
        status: 'Confirmed',
      ),
      BookingModel(
        id: '2',
        customerName: 'Jane Smith',
        customerContact: '09987654321',
        customerEmail: 'jane@example.com',
        oasis: 'Oasis 2',
        package: 'Package 5+',
        bookingDate: DateTime.now().add(const Duration(days: 10)),
        pax: 8,
        downpayment: 10000,
        paymentMethod: 'Bank Transfer',
        paymentStatus: 'Pending',
        status: 'Pending',
      ),
    ];

    return ListView.builder(
      itemCount: bookings.length,
      itemBuilder: (context, index) {
        return BookingCard(
          booking: bookings[index],
          onTap: () => ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Booking: ${bookings[index].customerName}')),
          ),
          onEdit: () => ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Edit pressed')),
          ),
          onDelete: () => ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Delete pressed')),
          ),
        );
      },
    );
  }

  Widget _buildRoomTab() {
    // Example room data
    final rooms = [
      const RoomModel(
        id: '1',
        name: 'Superior Room',
        capacity: 2,
        price: 2500,
        description: 'Comfortable room with queen bed',
        status: 'Available',
      ),
      const RoomModel(
        id: '2',
        name: 'Family Room',
        capacity: 4,
        price: 4500,
        description: 'Spacious room perfect for families',
        status: 'Booked',
      ),
      const RoomModel(
        id: '3',
        name: 'Cottage',
        capacity: 6,
        price: 7000,
        description: 'Private cottage with garden view',
        status: 'Available',
      ),
    ];

    return ListView.builder(
      itemCount: rooms.length,
      itemBuilder: (context, index) {
        return RoomCard(
          room: rooms[index],
          onTap: () => ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Room: ${rooms[index].name}')),
          ),
          onBook: () => ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Book room pressed')),
          ),
        );
      },
    );
  }

  Widget _buildStaffTab() {
    // Example staff data
    final staffMembers = [
      const StaffModel(
        id: '1',
        staffId: 'S001',
        name: 'Maria Santos',
        email: 'maria@resort.com',
        role: 'staff',
        position: 'Manager',
        status: 'Active',
      ),
      const StaffModel(
        id: '2',
        staffId: 'S002',
        name: 'Ana Lopez',
        email: 'ana@resort.com',
        role: 'staff',
        position: 'Housekeeper',
        status: 'Active',
      ),
      const StaffModel(
        id: '3',
        staffId: 'S003',
        name: 'Carlos Reyes',
        email: 'carlos@resort.com',
        role: 'staff',
        position: 'Security',
        status: 'Active',
      ),
      const StaffModel(
        id: '4',
        staffId: 'S004',
        name: 'Juan Cruz',
        email: 'juan@resort.com',
        role: 'staff',
        position: 'Maintenance',
        status: 'On Leave',
      ),
    ];

    return ListView.builder(
      itemCount: staffMembers.length,
      itemBuilder: (context, index) {
        return StaffCard(
          staff: staffMembers[index],
          onTap: () => ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Staff: ${staffMembers[index].name}')),
          ),
          onEdit: () => ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Edit staff')),
          ),
          onDelete: () => ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Delete staff')),
          ),
        );
      },
    );
  }

  Widget _buildInventoryTab() {
    // Example inventory data
    final items = [
      const InventoryModel(
        id: '1',
        itemId: 'INV001',
        item: 'Bed Sheets',
        quantity: 3,
        unit: 'sets',
        lowStockAlert: 5,
      ),
      const InventoryModel(
        id: '2',
        itemId: 'INV002',
        item: 'Towels',
        quantity: 25,
        unit: 'pcs',
        lowStockAlert: 10,
      ),
      const InventoryModel(
        id: '3',
        itemId: 'INV003',
        item: 'Toiletries',
        quantity: 8,
        unit: 'boxes',
        lowStockAlert: 5,
      ),
    ];

    return ListView.builder(
      itemCount: items.length,
      itemBuilder: (context, index) {
        return InventoryCard(
          inventory: items[index],
          onTap: () => ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Item: ${items[index].item}')),
          ),
          onRestock: () => ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Restocking...')),
          ),
        );
      },
    );
  }

  Widget _buildGalleryTab() {
    // Gallery items using available images
    final galleryItems = [
      {
        'image': 'assets/images/gallery/pool.jpg',
        'title': 'Olympic Pool',
        'description': 'Crystal clear swimming pool',
      },
      {
        'image': 'assets/images/gallery/garden.jpg',
        'title': 'Lush Gardens',
        'description': 'Beautiful landscaped gardens',
      },
      {
        'image': 'assets/images/gallery/karaoke.jpg',
        'title': 'Karaoke Lounge',
        'description': 'Entertainment venue',
      },
      {
        'image': 'assets/images/gallery/events.jpg',
        'title': 'Event Space',
        'description': 'Perfect for celebrations',
      },
      {
        'image': 'assets/images/hero/resort-main.jpg',
        'title': 'Main Resort',
        'description': 'Welcome to our resort',
      },
    ];

    return ListView.builder(
      itemCount: galleryItems.length,
      itemBuilder: (context, index) {
        final item = galleryItems[index];
        return GalleryItem(
          imagePath: item['image'] as String,
          title: item['title'] as String,
          description: item['description'] as String,
          onTap: () => ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(item['title'] as String)),
          ),
        );
      },
    );
  }
}
