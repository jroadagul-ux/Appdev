// lib/screens/integration_guide.md
# Widget Integration Guide

## Quick Integration Examples

### 1. Display Bookings List
```dart
import 'package:flutter/material.dart';
import '../services/api_service.dart';
import '../widgets/common_widgets.dart';

class BookingsScreen extends StatefulWidget {
  const BookingsScreen({super.key});

  @override
  State<BookingsScreen> createState() => _BookingsScreenState();
}

class _BookingsScreenState extends State<BookingsScreen> {
  late Future<List<BookingModel>> bookingsFuture;

  @override
  void initState() {
    super.initState();
    bookingsFuture = ApiService.instance.getBookings();
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<List<BookingModel>>(
      future: bookingsFuture,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const LoadingWidget(message: 'Loading bookings...');
        }
        
        if (snapshot.hasError) {
          return EmptyState(
            message: 'Error loading bookings',
            actionLabel: 'Retry',
            onAction: () => setState(() {
              bookingsFuture = ApiService.instance.getBookings();
            }),
          );
        }

        final bookings = snapshot.data ?? [];
        
        if (bookings.isEmpty) {
          return const EmptyState(message: 'No bookings found');
        }

        return ListView.builder(
          itemCount: bookings.length,
          itemBuilder: (context, index) {
            return BookingCard(
              booking: bookings[index],
              onTap: () => _navigateToBookingDetail(bookings[index]),
              onEdit: () => _editBooking(bookings[index]),
              onDelete: () => _deleteBooking(bookings[index]),
            );
          },
        );
      },
    );
  }

  void _navigateToBookingDetail(BookingModel booking) {
    // Navigation code
  }

  void _editBooking(BookingModel booking) {
    // Edit booking logic
  }

  void _deleteBooking(BookingModel booking) {
    // Delete booking logic
  }
}
```

### 2. Display Rooms with Search/Filter
```dart
class RoomsScreen extends StatefulWidget {
  const RoomsScreen({super.key});

  @override
  State<RoomsScreen> createState() => _RoomsScreenState();
}

class _RoomsScreenState extends State<RoomsScreen> {
  late Future<List<RoomModel>> roomsFuture;
  List<RoomModel> filteredRooms = [];
  String selectedStatus = 'All';

  @override
  void initState() {
    super.initState();
    roomsFuture = ApiService.instance.getRooms();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // Status filter
        Padding(
          padding: const EdgeInsets.all(16),
          child: SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: ['All', 'Available', 'Booked', 'Maintenance']
                  .map((status) => Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 8),
                    child: FilterChip(
                      label: Text(status),
                      selected: selectedStatus == status,
                      onSelected: (selected) {
                        setState(() => selectedStatus = status);
                      },
                    ),
                  ))
                  .toList(),
            ),
          ),
        ),
        // Rooms list
        Expanded(
          child: FutureBuilder<List<RoomModel>>(
            future: roomsFuture,
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const LoadingWidget(message: 'Loading rooms...');
              }

              final rooms = snapshot.data ?? [];
              final filtered = selectedStatus == 'All'
                  ? rooms
                  : rooms.where((r) => r.status == selectedStatus).toList();

              if (filtered.isEmpty) {
                return EmptyState(
                  message: 'No rooms available',
                  actionLabel: 'Clear Filters',
                  onAction: () => setState(() => selectedStatus = 'All'),
                );
              }

              return ListView.builder(
                itemCount: filtered.length,
                itemBuilder: (context, index) {
                  return RoomCard(
                    room: filtered[index],
                    onTap: () => _viewRoomDetail(filtered[index]),
                    onBook: () => _bookRoom(filtered[index]),
                  );
                },
              );
            },
          ),
        ),
      ],
    );
  }

  void _viewRoomDetail(RoomModel room) {}
  void _bookRoom(RoomModel room) {}
}
```

### 3. Display Staff with Role Filter
```dart
class StaffManagementScreen extends StatefulWidget {
  const StaffManagementScreen({super.key});

  @override
  State<StaffManagementScreen> createState() => _StaffManagementScreenState();
}

class _StaffManagementScreenState extends State<StaffManagementScreen> {
  late Future<List<StaffModel>> staffFuture;

  @override
  void initState() {
    super.initState();
    staffFuture = ApiService.instance.getStaff();
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<List<StaffModel>>(
      future: staffFuture,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const LoadingWidget(message: 'Loading staff...');
        }

        final staff = snapshot.data ?? [];

        // Group by position
        final grouped = <String, List<StaffModel>>{};
        for (var member in staff) {
          grouped.putIfAbsent(member.position, () => []).add(member);
        }

        return ListView.builder(
          itemCount: grouped.length,
          itemBuilder: (context, index) {
            final position = grouped.keys.elementAt(index);
            final members = grouped[position]!;

            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Section header
                Padding(
                  padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
                  child: SectionHeader(
                    title: position,
                    actionLabel: 'Add',
                    onAction: () => _addStaff(position),
                  ),
                ),
                // Staff cards
                ...members.map((member) => StaffCard(
                  staff: member,
                  onTap: () => _viewStaffDetail(member),
                  onEdit: () => _editStaff(member),
                  onDelete: () => _deleteStaff(member),
                )),
              ],
            );
          },
        );
      },
    );
  }

  void _addStaff(String position) {}
  void _viewStaffDetail(StaffModel staff) {}
  void _editStaff(StaffModel staff) {}
  void _deleteStaff(StaffModel staff) {}
}
```

### 4. Display Inventory with Low Stock Alerts
```dart
class InventoryScreen extends StatefulWidget {
  const InventoryScreen({super.key});

  @override
  State<InventoryScreen> createState() => _InventoryScreenState();
}

class _InventoryScreenState extends State<InventoryScreen> {
  late Future<List<InventoryModel>> inventoryFuture;
  bool showLowStockOnly = false;

  @override
  void initState() {
    super.initState();
    inventoryFuture = ApiService.instance.getInventory();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // Filter toggle
        Padding(
          padding: const EdgeInsets.all(16),
          child: SwitchListTile(
            title: const Text('Show Low Stock Only'),
            value: showLowStockOnly,
            onChanged: (value) => setState(() => showLowStockOnly = value),
          ),
        ),
        // Inventory list
        Expanded(
          child: FutureBuilder<List<InventoryModel>>(
            future: inventoryFuture,
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const LoadingWidget(message: 'Loading inventory...');
              }

              var items = snapshot.data ?? [];
              if (showLowStockOnly) {
                items = items.where((i) => i.isLowStock).toList();
              }

              if (items.isEmpty) {
                return EmptyState(
                  message: showLowStockOnly
                      ? 'No low stock items'
                      : 'No inventory items',
                );
              }

              return ListView.builder(
                itemCount: items.length,
                itemBuilder: (context, index) {
                  return InventoryCard(
                    inventory: items[index],
                    onTap: () => _viewItemDetail(items[index]),
                    onRestock: () => _restockItem(items[index]),
                  );
                },
              );
            },
          ),
        ),
      ],
    );
  }

  void _viewItemDetail(InventoryModel item) {}
  void _restockItem(InventoryModel item) {}
}
```

### 5. Gallery Showcase
```dart
class GalleryScreen extends StatelessWidget {
  const GalleryScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final galleryImages = [
      ('assets/images/gallery/pool.jpg', 'Olympic Pool', 'Refresh yourself in our crystal clear pool'),
      ('assets/images/gallery/garden.jpg', 'Lush Gardens', 'Beautiful landscape perfect for relaxation'),
      ('assets/images/gallery/karaoke.jpg', 'Karaoke Lounge', 'Sing your heart out in our entertainment venue'),
      ('assets/images/gallery/events.jpg', 'Event Space', 'Perfect venue for your special events'),
      ('assets/images/gallery/cottage.jpg', 'Private Cottage', 'Cozy accommodation with natural views'),
    ];

    return ListView.builder(
      itemCount: galleryImages.length,
      itemBuilder: (context, index) {
        final (image, title, description) = galleryImages[index];
        return GalleryItem(
          imagePath: image,
          title: title,
          description: description,
          onTap: () => _viewFullImage(context, image),
        );
      },
    );
  }

  void _viewFullImage(BuildContext context, String imagePath) {
    showDialog(
      context: context,
      builder: (_) => Dialog(
        child: Image.asset(imagePath, fit: BoxFit.contain),
      ),
    );
  }
}
```

## Features Summary

| Widget | Database Model | Key Features |
|--------|---|---|
| **BookingCard** | BookingModel | Package images, Payment tracking, Edit/Delete |
| **RoomCard** | RoomModel | Room images, Capacity display, Book button |
| **StaffCard** | StaffModel | Position-based icons, Color coding, Status |
| **InventoryCard** | InventoryModel | Low stock alerts, Restock button, Quantity |
| **GalleryItem** | N/A | Image showcase, Gradient overlay, Title/Description |

## Asset Mapping

Your images are automatically mapped:
- **Bookings**: Package 1-5+ → corresponding package images
- **Rooms**: Superior/Family/Cottage → matching room images
- **Gallery**: Pool, Garden, Karaoke, Events → gallery images
- **Hero**: Welcome screen background options

## Next Steps

1. Update your API service to fetch real data
2. Integrate widgets into existing screens
3. Test with actual database records
4. Customize colors/styling in app_theme.dart
