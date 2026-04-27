import 'package:cloud_firestore/cloud_firestore.dart';

class AdminCustomerUser {
  final String id;
  final String name;
  final String email;
  final String? phone;
  final String? profileImage;
  final DateTime registeredDate;
  final int totalOrders;
  final double totalSpent;
  final bool isActive;
  final String accountStatus; // active, suspended, deleted
  final List<String> favoriteProducts;

  AdminCustomerUser({
    required this.id,
    required this.name,
    required this.email,
    this.phone,
    this.profileImage,
    required this.registeredDate,
    required this.totalOrders,
    required this.totalSpent,
    required this.isActive,
    required this.accountStatus,
    required this.favoriteProducts,
  });

  AdminCustomerUser copyWith({
    String? id,
    String? name,
    String? email,
    String? phone,
    String? profileImage,
    DateTime? registeredDate,
    int? totalOrders,
    double? totalSpent,
    bool? isActive,
    String? accountStatus,
    List<String>? favoriteProducts,
  }) {
    return AdminCustomerUser(
      id: id ?? this.id,
      name: name ?? this.name,
      email: email ?? this.email,
      phone: phone ?? this.phone,
      profileImage: profileImage ?? this.profileImage,
      registeredDate: registeredDate ?? this.registeredDate,
      totalOrders: totalOrders ?? this.totalOrders,
      totalSpent: totalSpent ?? this.totalSpent,
      isActive: isActive ?? this.isActive,
      accountStatus: accountStatus ?? this.accountStatus,
      favoriteProducts: favoriteProducts ?? this.favoriteProducts,
    );
  }

  factory AdminCustomerUser.fromMap(
    Map<String, dynamic> map,
    String documentId, {
    int totalOrders = 0,
    double totalSpent = 0.0,
  }) {
    return AdminCustomerUser(
      id: (map['uid'] ?? map['id'] ?? documentId).toString(),
      name: (map['username'] ?? map['name'] ?? '').toString(),
      email: (map['email'] ?? '').toString(),
      phone: map['phone']?.toString(),
      profileImage: map['profileImage']?.toString(),
      registeredDate: _toDateTime(map['createdAt']) ?? DateTime.now(),
      totalOrders: totalOrders,
      totalSpent: totalSpent,
      isActive: _toBool(map['isActive'], fallback: true),
      accountStatus: (map['accountStatus'] ?? 'active').toString(),
      favoriteProducts: (map['favoriteProducts'] as List<dynamic>? ?? [])
          .map((e) => e.toString())
          .toList(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'uid': id,
      'username': name,
      'email': email,
      'phone': phone,
      'profileImage': profileImage,
      'createdAt': Timestamp.fromDate(registeredDate),
      'isActive': isActive,
      'accountStatus': accountStatus,
      'favoriteProducts': favoriteProducts,
    };
  }

  static DateTime? _toDateTime(dynamic value) {
    if (value == null) return null;
    if (value is Timestamp) return value.toDate();
    if (value is DateTime) return value;
    return DateTime.tryParse(value.toString());
  }

  static bool _toBool(dynamic value, {bool fallback = false}) {
    if (value == null) return fallback;
    if (value is bool) return value;
    final normalized = value.toString().toLowerCase();
    return normalized == 'true' || normalized == '1';
  }
}
