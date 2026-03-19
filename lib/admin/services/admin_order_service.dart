import '../models/order_analytics_model.dart';

class AdminOrderService {
  static final List<AdminOrder> _orders = [
    AdminOrder(
      id: 'ORD-001',
      customerId: 'CUST-001',
      customerName: 'John Doe',
      customerEmail: 'john@example.com',
      totalAmount: 599.98,
      status: 'pending',
      createdAt: DateTime.now().subtract(const Duration(hours: 2)),
      items: [
        OrderItem(
          productId: '1',
          productName: 'Acoustic Guitar',
          quantity: 2,
          price: 299.99,
        ),
      ],
      shippingInfo: ShippingInfo(
        address: '123 Main St',
        city: 'New York',
        state: 'NY',
        zipCode: '10001',
        country: 'USA',
      ),
      paymentStatus: 'completed',
    ),
    AdminOrder(
      id: 'ORD-002',
      customerId: 'CUST-002',
      customerName: 'Jane Smith',
      customerEmail: 'jane@example.com',
      totalAmount: 349.99,
      status: 'processing',
      createdAt: DateTime.now().subtract(const Duration(hours: 24)),
      updatedAt: DateTime.now().subtract(const Duration(hours: 12)),
      items: [
        OrderItem(
          productId: '2',
          productName: 'Electric Bass',
          quantity: 1,
          price: 349.99,
        ),
      ],
      shippingInfo: ShippingInfo(
        address: '456 Oak Ave',
        city: 'Los Angeles',
        state: 'CA',
        zipCode: '90001',
        country: 'USA',
      ),
      paymentStatus: 'completed',
      trackingNumber: 'TRK-123456',
    ),
    AdminOrder(
      id: 'ORD-003',
      customerId: 'CUST-003',
      customerName: 'Mike Johnson',
      customerEmail: 'mike@example.com',
      totalAmount: 799.98,
      status: 'shipped',
      createdAt: DateTime.now().subtract(const Duration(days: 3)),
      updatedAt: DateTime.now().subtract(const Duration(hours: 6)),
      items: [
        OrderItem(
          productId: '3',
          productName: 'Synthesizer',
          quantity: 1,
          price: 599.99,
        ),
        OrderItem(
          productId: '4',
          productName: 'Microphone',
          quantity: 1,
          price: 199.99,
        ),
      ],
      shippingInfo: ShippingInfo(
        address: '789 Pine Rd',
        city: 'Chicago',
        state: 'IL',
        zipCode: '60601',
        country: 'USA',
      ),
      paymentStatus: 'completed',
      trackingNumber: 'TRK-789012',
    ),
  ];

  List<AdminOrder> getAllOrders() {
    return _orders;
  }

  List<AdminOrder> getOrdersByStatus(String status) {
    return _orders.where((o) => o.status == status).toList();
  }

  List<AdminOrder> getOrdersByCustomer(String customerId) {
    return _orders.where((o) => o.customerId == customerId).toList();
  }

  AdminOrder? getOrderById(String id) {
    try {
      return _orders.firstWhere((o) => o.id == id);
    } catch (e) {
      return null;
    }
  }

  void updateOrderStatus(String orderId, String newStatus) {
    final index = _orders.indexWhere((o) => o.id == orderId);
    if (index != -1) {
      final order = _orders[index];
      _orders[index] = AdminOrder(
        id: order.id,
        customerId: order.customerId,
        customerName: order.customerName,
        customerEmail: order.customerEmail,
        totalAmount: order.totalAmount,
        status: newStatus,
        createdAt: order.createdAt,
        updatedAt: DateTime.now(),
        items: order.items,
        shippingInfo: order.shippingInfo,
        paymentStatus: order.paymentStatus,
        trackingNumber: order.trackingNumber,
      );
    }
  }

  void updateTrackingNumber(String orderId, String trackingNumber) {
    final index = _orders.indexWhere((o) => o.id == orderId);
    if (index != -1) {
      final order = _orders[index];
      _orders[index] = AdminOrder(
        id: order.id,
        customerId: order.customerId,
        customerName: order.customerName,
        customerEmail: order.customerEmail,
        totalAmount: order.totalAmount,
        status: order.status,
        createdAt: order.createdAt,
        updatedAt: DateTime.now(),
        items: order.items,
        shippingInfo: order.shippingInfo,
        paymentStatus: order.paymentStatus,
        trackingNumber: trackingNumber,
      );
    }
  }

  List<String> getOrderStatuses() {
    return ['pending', 'processing', 'shipped', 'delivered', 'cancelled'];
  }
}
