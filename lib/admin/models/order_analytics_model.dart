import 'package:cloud_firestore/cloud_firestore.dart';

class AdminOrder {
  final String id;
  final String customerId;
  final String customerName;
  final String customerEmail;
  final double totalAmount;
  final String status;
  final DateTime createdAt;
  final DateTime? updatedAt;
  final List<OrderItem> items;
  final ShippingInfo shippingInfo;
  final String paymentStatus;
  final String? trackingNumber;

  AdminOrder({
    required this.id,
    required this.customerId,
    required this.customerName,
    required this.customerEmail,
    required this.totalAmount,
    required this.status,
    required this.createdAt,
    this.updatedAt,
    required this.items,
    required this.shippingInfo,
    required this.paymentStatus,
    this.trackingNumber,
  });

  factory AdminOrder.fromMap(Map<String, dynamic> map, String documentId) {
    return AdminOrder(
      id: (map['id'] ?? documentId).toString(),
      customerId: (map['customerId'] ?? '').toString(),
      customerName: (map['customerName'] ?? '').toString(),
      customerEmail: (map['customerEmail'] ?? '').toString(),
      totalAmount: (map['totalAmount'] ?? 0).toDouble(),
      status: (map['status'] ?? 'pending').toString(),
      createdAt: _parseDateTime(map['createdAt']) ?? DateTime.now(),
      updatedAt: _parseDateTime(map['updatedAt']),
      items: (map['items'] as List<dynamic>? ?? [])
          .map((item) => OrderItem.fromMap(Map<String, dynamic>.from(item)))
          .toList(),
      shippingInfo: ShippingInfo.fromMap(
        Map<String, dynamic>.from(map['shippingInfo'] ?? {}),
      ),
      paymentStatus: (map['paymentStatus'] ?? 'pending').toString(),
      trackingNumber: map['trackingNumber']?.toString(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'customerId': customerId,
      'customerName': customerName,
      'customerEmail': customerEmail,
      'totalAmount': totalAmount,
      'status': status,
      'createdAt': Timestamp.fromDate(createdAt),
      'updatedAt': updatedAt != null ? Timestamp.fromDate(updatedAt!) : null,
      'items': items.map((item) => item.toMap()).toList(),
      'shippingInfo': shippingInfo.toMap(),
      'paymentStatus': paymentStatus,
      'trackingNumber': trackingNumber,
    };
  }

  static DateTime? _parseDateTime(dynamic value) {
    if (value == null) return null;
    if (value is Timestamp) return value.toDate();
    if (value is DateTime) return value;
    return DateTime.tryParse(value.toString());
  }
}

class OrderItem {
  final String productId;
  final String productName;
  final int quantity;
  final double price;

  OrderItem({
    required this.productId,
    required this.productName,
    required this.quantity,
    required this.price,
  });

  factory OrderItem.fromMap(Map<String, dynamic> map) {
    return OrderItem(
      productId: (map['productId'] ?? '').toString(),
      productName: (map['productName'] ?? '').toString(),
      quantity: (map['quantity'] ?? 0) is int
          ? map['quantity'] as int
          : int.tryParse(map['quantity'].toString()) ?? 0,
      price: (map['price'] ?? 0).toDouble(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'productId': productId,
      'productName': productName,
      'quantity': quantity,
      'price': price,
    };
  }
}

class ShippingInfo {
  final String barangay;
  final String houseNumber;
  final String municipalityOrCity;
  final String phoneNumber;
  final String province;
  final String zipcode;

  ShippingInfo({
    required this.barangay,
    required this.houseNumber,
    required this.municipalityOrCity,
    required this.phoneNumber,
    required this.province,
    required this.zipcode,
  });

  factory ShippingInfo.fromMap(Map<String, dynamic> map) {
    return ShippingInfo(
      barangay: (map['barangay'] ?? '').toString(),
      houseNumber: (map['house number'] ?? '').toString(),
      municipalityOrCity: (map['municipality or city'] ?? '').toString(),
      phoneNumber: (map['phone number'] ?? '').toString(),
      province: (map['province'] ?? '').toString(),
      zipcode: (map['zipcode'] ?? '').toString(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'barangay': barangay,
      'house number': houseNumber,
      'municipality or city': municipalityOrCity,
      'phone number': phoneNumber,
      'province': province,
      'zipcode': zipcode,
    };
  }
}
