class AdminOrder {
  final String id;
  final String customerId;
  final String customerName;
  final String customerEmail;
  final double totalAmount;
  final String status; // pending, processing, shipped, delivered, cancelled
  final DateTime createdAt;
  final DateTime? updatedAt;
  final List<OrderItem> items;
  final ShippingInfo shippingInfo;
  final String paymentStatus; // pending, completed, failed
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
}

class ShippingInfo {
  final String address;
  final String city;
  final String state;
  final String zipCode;
  final String country;

  ShippingInfo({
    required this.address,
    required this.city,
    required this.state,
    required this.zipCode,
    required this.country,
  });
}
