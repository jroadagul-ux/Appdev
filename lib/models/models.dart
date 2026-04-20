// lib/models/models.dart
// All data models mirroring the MongoDB schemas

// ============================================
// USER MODEL
// ============================================
class UserModel {
  final String id;
  final String name;
  final String email;
  final String role; // admin | staff | customer
  final String? phone;
  final String? address;
  final String? avatar;
  final String? googleAvatar;
  final bool isEmailVerified;

  const UserModel({
    required this.id,
    required this.name,
    required this.email,
    required this.role,
    this.phone,
    this.address,
    this.avatar,
    this.googleAvatar,
    this.isEmailVerified = false,
  });

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      id: json['_id'] ?? json['id'] ?? '',
      name: json['name'] ?? '',
      email: json['email'] ?? '',
      role: json['role'] ?? 'customer',
      phone: json['phone'],
      address: json['address'],
      avatar: json['avatar'],
      googleAvatar: json['googleAvatar'],
      isEmailVerified: json['isEmailVerified'] ?? false,
    );
  }

  Map<String, dynamic> toJson() => {
        '_id': id,
        'name': name,
        'email': email,
        'role': role,
        'phone': phone,
        'address': address,
        'avatar': avatar,
        'googleAvatar': googleAvatar,
        'isEmailVerified': isEmailVerified,
      };

  String get displayAvatar => avatar ?? googleAvatar ?? '';
  bool get isAdmin => role == 'admin';
  bool get isStaff => role == 'staff';
  bool get isCustomer => role == 'customer';
}

// ============================================
// BOOKING MODEL
// ============================================
class BookingModel {
  final String id;
  final String customerName;
  final String customerContact;
  final String? customerEmail;
  final String oasis;
  final String package;
  final DateTime bookingDate;
  final int pax;
  final double downpayment;
  final String paymentMethod;
  final String paymentStatus;
  final String status;
  final DateTime? createdAt;

  const BookingModel({
    required this.id,
    required this.customerName,
    required this.customerContact,
    this.customerEmail,
    required this.oasis,
    required this.package,
    required this.bookingDate,
    required this.pax,
    required this.downpayment,
    required this.paymentMethod,
    this.paymentStatus = 'Pending',
    this.status = 'Pending',
    this.createdAt,
  });

  factory BookingModel.fromJson(Map<String, dynamic> json) {
    return BookingModel(
      id: json['_id'] ?? '',
      customerName: json['customerName'] ?? '',
      customerContact: json['customerContact'] ?? '',
      customerEmail: json['customerEmail'],
      oasis: json['oasis'] ?? '',
      package: json['package'] ?? '',
      bookingDate: json['bookingDate'] != null
          ? DateTime.parse(json['bookingDate'])
          : DateTime.now(),
      pax: json['pax'] ?? 0,
      downpayment: (json['downpayment'] ?? 0).toDouble(),
      paymentMethod: json['paymentMethod'] ?? 'Cash',
      paymentStatus: json['paymentStatus'] ?? 'Pending',
      status: json['status'] ?? 'Pending',
      createdAt: json['createdAt'] != null
          ? DateTime.parse(json['createdAt'])
          : null,
    );
  }
}

// ============================================
// ROOM MODEL
// ============================================
class RoomModel {
  final String id;
  final String name;
  final int capacity;
  final double price;
  final String? description;
  final String status;
  final DateTime? createdAt;

  const RoomModel({
    required this.id,
    required this.name,
    required this.capacity,
    required this.price,
    this.description,
    this.status = 'Available',
    this.createdAt,
  });

  factory RoomModel.fromJson(Map<String, dynamic> json) {
    return RoomModel(
      id: json['_id'] ?? '',
      name: json['name'] ?? '',
      capacity: json['capacity'] ?? 0,
      price: (json['price'] ?? 0).toDouble(),
      description: json['description'],
      status: json['status'] ?? 'Available',
      createdAt:
          json['createdAt'] != null ? DateTime.parse(json['createdAt']) : null,
    );
  }

  Map<String, dynamic> toJson() => {
        'name': name,
        'capacity': capacity,
        'price': price,
        'description': description,
        'status': status,
      };
}

// ============================================
// STAFF MODEL
// ============================================
class StaffModel {
  final String id;
  final String staffId;
  final String name;
  final String email;
  final String role;
  final String position;
  final String status;
  final DateTime? createdAt;

  const StaffModel({
    required this.id,
    required this.staffId,
    required this.name,
    required this.email,
    required this.role,
    required this.position,
    this.status = 'Active',
    this.createdAt,
  });

  factory StaffModel.fromJson(Map<String, dynamic> json) {
    return StaffModel(
      id: json['_id'] ?? '',
      staffId: json['staffId'] ?? '',
      name: json['name'] ?? '',
      email: json['email'] ?? '',
      role: json['role'] ?? 'staff',
      position: json['position'] ?? 'Housekeeper',
      status: json['status'] ?? 'Active',
      createdAt:
          json['createdAt'] != null ? DateTime.parse(json['createdAt']) : null,
    );
  }

  Map<String, dynamic> toJson() => {
        'name': name,
        'email': email,
        'role': role,
        'position': position,
        'status': status,
      };
}

// ============================================
// INVENTORY MODEL
// ============================================
class InventoryModel {
  final String id;
  final String itemId;
  final String item;
  final int quantity;
  final String? unit;
  final int lowStockAlert;
  final DateTime? createdAt;

  const InventoryModel({
    required this.id,
    required this.itemId,
    required this.item,
    required this.quantity,
    this.unit,
    this.lowStockAlert = 5,
    this.createdAt,
  });

  bool get isLowStock => quantity < lowStockAlert;

  factory InventoryModel.fromJson(Map<String, dynamic> json) {
    return InventoryModel(
      id: json['_id'] ?? '',
      itemId: json['itemId'] ?? '',
      item: json['item'] ?? '',
      quantity: json['quantity'] ?? 0,
      unit: json['unit'],
      lowStockAlert: json['lowStockAlert'] ?? 5,
      createdAt:
          json['createdAt'] != null ? DateTime.parse(json['createdAt']) : null,
    );
  }

  Map<String, dynamic> toJson() => {
        'item': item,
        'quantity': quantity,
        'unit': unit,
        'lowStockAlert': lowStockAlert,
      };
}

// ============================================
// TASK MODEL
// ============================================
class TaskModel {
  final String id;
  final String title;
  final String? description;
  final String taskType;
  final String priority;
  final String status;
  final DateTime dueDate;
  final String? roomId;
  final String? roomName;
  final double estimatedHours;
  final double actualHours;
  final String notes;
  final DateTime? createdAt;
  final DateTime? completedAt;

  const TaskModel({
    required this.id,
    required this.title,
    this.description,
    required this.taskType,
    this.priority = 'Medium',
    this.status = 'Pending',
    required this.dueDate,
    this.roomId,
    this.roomName,
    this.estimatedHours = 1,
    this.actualHours = 0,
    this.notes = '',
    this.createdAt,
    this.completedAt,
  });

  factory TaskModel.fromJson(Map<String, dynamic> json) {
    final room = json['roomId'];
    return TaskModel(
      id: json['_id'] ?? '',
      title: json['title'] ?? '',
      description: json['description'],
      taskType: json['taskType'] ?? 'Other',
      priority: json['priority'] ?? 'Medium',
      status: json['status'] ?? 'Pending',
      dueDate: json['dueDate'] != null
          ? DateTime.parse(json['dueDate'])
          : DateTime.now(),
      roomId: room is Map ? room['_id'] : room?.toString(),
      roomName: room is Map ? room['name'] : null,
      estimatedHours: (json['estimatedHours'] ?? 1).toDouble(),
      actualHours: (json['actualHours'] ?? 0).toDouble(),
      notes: json['notes'] ?? '',
      createdAt:
          json['createdAt'] != null ? DateTime.parse(json['createdAt']) : null,
      completedAt: json['completedAt'] != null
          ? DateTime.parse(json['completedAt'])
          : null,
    );
  }
}

// ============================================
// INSPECTION MODEL
// ============================================
class InspectionModel {
  final String id;
  final String roomId;
  final String? roomName;
  final String inspectorId;
  final String? inspectorName;
  final String status;
  final String? notes;
  final List<String> issues;
  final DateTime? inspectionDate;

  const InspectionModel({
    required this.id,
    required this.roomId,
    this.roomName,
    required this.inspectorId,
    this.inspectorName,
    this.status = 'Pending',
    this.notes,
    this.issues = const [],
    this.inspectionDate,
  });

  factory InspectionModel.fromJson(Map<String, dynamic> json) {
    final room = json['roomId'];
    final inspector = json['inspectorId'];
    return InspectionModel(
      id: json['_id'] ?? '',
      roomId: room is Map ? room['_id'] : room?.toString() ?? '',
      roomName: room is Map ? room['name'] : null,
      inspectorId:
          inspector is Map ? inspector['_id'] : inspector?.toString() ?? '',
      inspectorName: inspector is Map ? inspector['name'] : null,
      status: json['status'] ?? 'Pending',
      notes: json['notes'],
      issues: List<String>.from(json['issues'] ?? []),
      inspectionDate: json['inspectionDate'] != null
          ? DateTime.parse(json['inspectionDate'])
          : null,
    );
  }
}

// ============================================
// DASHBOARD STATS MODEL
// ============================================
class DashboardStats {
  final int totalReservations;
  final int availableRooms;
  final int maintainanceRooms;
  final int activeStaff;
  final double monthlyRevenue;
  final int lowStockItems;

  const DashboardStats({
    this.totalReservations = 0,
    this.availableRooms = 0,
    this.maintainanceRooms = 0,
    this.activeStaff = 0,
    this.monthlyRevenue = 0,
    this.lowStockItems = 0,
  });

  factory DashboardStats.fromJson(Map<String, dynamic> json) {
    return DashboardStats(
      totalReservations: json['totalReservations'] ?? 0,
      availableRooms: json['availableRooms'] ?? 0,
      maintainanceRooms: json['maintainanceRooms'] ?? 0,
      activeStaff: json['activeStaff'] ?? 0,
      monthlyRevenue: (json['monthlyRevenue'] ?? 0).toDouble(),
      lowStockItems: json['lowStockItems'] ?? 0,
    );
  }
}

// ============================================
// SENSOR READING MODEL
// ============================================
class SensorReading {
  final double? temperature;
  final double? turbidity;
  final double? ph;
  final DateTime? timestamp;

  const SensorReading({
    this.temperature,
    this.turbidity,
    this.ph,
    this.timestamp,
  });

  factory SensorReading.fromJson(Map<String, dynamic> json) {
    return SensorReading(
      temperature: json['temperature']?.toDouble(),
      turbidity: json['turbidity']?.toDouble(),
      ph: json['ph']?.toDouble(),
      timestamp: json['timestamp'] != null
          ? DateTime.parse(json['timestamp'])
          : null,
    );
  }
}

// ============================================
// NOTIFICATION MODEL
// ============================================
class NotificationModel {
  final String id;
  final String message;
  final String type;
  final bool isRead;
  final DateTime? createdAt;

  const NotificationModel({
    required this.id,
    required this.message,
    this.type = 'info',
    this.isRead = false,
    this.createdAt,
  });

  factory NotificationModel.fromJson(Map<String, dynamic> json) {
    return NotificationModel(
      id: json['_id'] ?? '',
      message: json['message'] ?? '',
      type: json['type'] ?? 'info',
      isRead: json['isRead'] ?? false,
      createdAt:
          json['createdAt'] != null ? DateTime.parse(json['createdAt']) : null,
    );
  }
}
