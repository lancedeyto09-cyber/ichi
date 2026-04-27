import 'package:cloud_firestore/cloud_firestore.dart';

class UserOrder {
  final String id;
  final String customerId;
  final String customerName;
  final String customerEmail;
  final double totalAmount;
  final String status;
  final String paymentStatus;
  final String? trackingNumber;
  final DateTime createdAt;
  final List<OrderItem> items;

  UserOrder({
    required this.id,
    required this.customerId,
    required this.customerName,
    required this.customerEmail,
    required this.totalAmount,
    required this.status,
    required this.paymentStatus,
    required this.createdAt,
    required this.items,
    this.trackingNumber,
  });

  factory UserOrder.fromMap(Map<String, dynamic> map, String id) {
    return UserOrder(
      id: id,
      customerId: map['customerId'] ?? '',
      customerName: map['customerName'] ?? '',
      customerEmail: map['customerEmail'] ?? '',
      totalAmount: (map['totalAmount'] ?? 0).toDouble(),
      status: map['status'] ?? 'pending',
      paymentStatus: map['paymentStatus'] ?? 'pending',
      trackingNumber: map['trackingNumber'],
      createdAt: (map['createdAt'] as Timestamp).toDate(),
      items: (map['items'] as List).map((e) => OrderItem.fromMap(e)).toList(),
    );
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
      productId: map['productId'].toString(),
      productName: map['productName'],
      quantity: map['quantity'],
      price: (map['price']).toDouble(),
    );
  }
}
