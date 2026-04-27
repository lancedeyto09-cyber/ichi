import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/order_analytics_model.dart';

class AdminOrderService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  List<String> getOrderStatuses() {
    return ['pending', 'processing', 'shipped', 'delivered', 'cancelled'];
  }

  Future<List<AdminOrder>> getAllOrders() async {
    final snapshot = await _firestore
        .collection('orders')
        .orderBy('createdAt', descending: true)
        .get();

    return snapshot.docs.map((doc) {
      return AdminOrder.fromMap(doc.data(), doc.id);
    }).toList();
  }

  Future<void> updateOrderStatus(String orderId, String status) async {
    await _firestore.collection('orders').doc(orderId).update({
      'status': status,
      'updatedAt': FieldValue.serverTimestamp(),
    });
  }

  Future<void> updateTrackingNumber(String orderId, String tracking) async {
    await _firestore.collection('orders').doc(orderId).update({
      'trackingNumber': tracking,
      'updatedAt': FieldValue.serverTimestamp(),
    });
  }
}
