// lib/config/package_data.dart
// Mirrors frontend/src/config/packageData.js

class PackageInclusion {
  final String text;
  const PackageInclusion(this.text);
}

class PackagePricing {
  final int? weekday;
  final int? weekend;
  const PackagePricing({this.weekday, this.weekend});
}

class OasisPackage {
  final String name;
  final String description;
  final int capacity;
  final List<String> inclusions;
  final Map<String, PackagePricing?> pricing;
  final List<String> addons;

  const OasisPackage({
    required this.name,
    required this.description,
    required this.capacity,
    required this.inclusions,
    required this.pricing,
    required this.addons,
  });
}

final Map<String, Map<String, OasisPackage>> oasisPackages = {
  'Oasis 1': {
    'Package 1': const OasisPackage(
      name: 'Package 1',
      description: 'Cottage Only',
      capacity: 20,
      inclusions: [
        'Swimming pool with bubble jacuzzi and fountain',
        'Cottage (Gazebo) and kubo cottage near parking area',
        'Free WiFi',
        'Portable griller',
        'All outside amenities',
      ],
      pricing: {
        'Day': PackagePricing(weekday: 5999, weekend: 6400),
        'Night': PackagePricing(weekday: 6400, weekend: 6800),
        '22hrs': null,
      },
      addons: ['Karaoke (₱700)', 'Stove 10hrs (₱200)', 'Stove 22hrs (₱400)'],
    ),
    'Package 2': const OasisPackage(
      name: 'Package 2',
      description: '1 AC Room (Superior - 2-4 pax)',
      capacity: 4,
      inclusions: [
        'Swimming pool with bubble jacuzzi and fountain',
        'Cottage (Gazebo) and kubo cottage near parking area',
        'Air Conditioned Superior room (2-4 sleeping capacity)',
        'Smart TV with Netflix',
        'Free WiFi',
        'Portable griller',
        'Cooler',
        'All outside amenities',
      ],
      pricing: {
        'Day': PackagePricing(weekday: 9000, weekend: 9500),
        'Night': PackagePricing(weekday: 10000, weekend: 10500),
        '22hrs': PackagePricing(weekday: 15000, weekend: 16000),
      },
      addons: ['Karaoke (₱700)', 'Stove 10hrs (₱200)', 'Stove 22hrs (₱400)'],
    ),
    'Package 3': const OasisPackage(
      name: 'Package 3',
      description: '1 AC Room (Family - 8-12 pax)',
      capacity: 12,
      inclusions: [
        'Swimming pool with bubble jacuzzi and fountain',
        'Cottage (Gazebo) and kubo cottage near parking area',
        'Air Conditioned Family room (8-12 sleeping capacity)',
        'Smart TV with Netflix',
        'Fridge',
        'Free WiFi',
        'Portable griller',
        'Cooler',
        'All outside amenities',
      ],
      pricing: {
        'Day': PackagePricing(weekday: 9500, weekend: 10000),
        'Night': PackagePricing(weekday: 10500, weekend: 11000),
        '22hrs': PackagePricing(weekday: 16000, weekend: 17000),
      },
      addons: ['Karaoke (₱700)', 'Stove 10hrs (₱200)', 'Stove 22hrs (₱400)'],
    ),
    'Package 4': const OasisPackage(
      name: 'Package 4',
      description: '2 AC Rooms (Family + Superior - 12-15 pax)',
      capacity: 15,
      inclusions: [
        'Swimming pool with bubble jacuzzi and fountain',
        'Cottage (Gazebo) and kubo cottage near parking area',
        'Air Conditioned Family room & Superior room (12-15 sleeping capacity)',
        'Smart TV with Netflix',
        'Fridge',
        'Free WiFi',
        'Portable griller',
        'Cooler',
        'All outside amenities',
      ],
      pricing: {
        'Day': PackagePricing(weekday: 13000, weekend: 14000),
        'Night': PackagePricing(weekday: 14000, weekend: 15000),
        '22hrs': PackagePricing(weekday: 20000, weekend: 22000),
      },
      addons: ['Karaoke (₱700)', 'Stove 10hrs (₱200)', 'Stove 22hrs (₱400)'],
    ),
  },
  'Oasis 2': {
    'Package 1': const OasisPackage(
      name: 'Package 1',
      description: 'Private Pool (Exclusive)',
      capacity: 30,
      inclusions: [
        'Exclusive private pool access',
        'Covered function hall',
        'BBQ grill area',
        'Free WiFi',
        'Outdoor lounge area',
        'All outside amenities',
      ],
      pricing: {
        'Day': PackagePricing(weekday: 7999, weekend: 8500),
        'Night': PackagePricing(weekday: 8500, weekend: 9000),
        '22hrs': PackagePricing(weekday: 14000, weekend: 15000),
      },
      addons: ['Karaoke (₱700)', 'Stove 10hrs (₱200)', 'Stove 22hrs (₱400)'],
    ),
    'Package 2': const OasisPackage(
      name: 'Package 2',
      description: '1 AC Room + Private Pool',
      capacity: 15,
      inclusions: [
        'Exclusive private pool access',
        'Air Conditioned room (4-6 sleeping capacity)',
        'Smart TV with Netflix',
        'Covered function hall',
        'Free WiFi',
        'Portable griller',
        'Cooler',
        'All outside amenities',
      ],
      pricing: {
        'Day': PackagePricing(weekday: 11000, weekend: 12000),
        'Night': PackagePricing(weekday: 12000, weekend: 13000),
        '22hrs': PackagePricing(weekday: 18000, weekend: 20000),
      },
      addons: ['Karaoke (₱700)', 'Stove 10hrs (₱200)', 'Stove 22hrs (₱400)'],
    ),
  },
};
