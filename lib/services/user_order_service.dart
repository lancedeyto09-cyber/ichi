import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../models/user_order_model.dart';

class UserOrderService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  /// =========================
  /// 🔥 GET USER ORDERS (REALTIME)
  /// =========================
  Stream<List<UserOrder>> getUserOrders() {
    final user = _auth.currentUser;

    if (user == null) {
      throw Exception('You must be logged in to view orders.');
    }

    return _firestore
        .collection('orders')
        .where('customerId', isEqualTo: user.uid)
        .orderBy('createdAt', descending: true) // 🔥 Firestore sorting
        .snapshots()
        .map((snapshot) {
      return snapshot.docs
          .map((doc) => UserOrder.fromMap(doc.data(), doc.id))
          .toList();
    });
  }

  /// =========================
  /// ❌ CANCEL ORDER (WITH STOCK RESTORE)
  /// =========================
  Future<void> cancelOrder(UserOrder order) async {
    final user = _auth.currentUser;

    if (user == null) {
      throw Exception('You must be logged in.');
    }

    if (order.customerId != user.uid) {
      throw Exception('You are not allowed to cancel this order.');
    }

    final currentStatus = order.status.toLowerCase();

    // ✅ allow pending + processing (flexible)
    if (currentStatus != 'pending' && currentStatus != 'processing') {
      throw Exception('This order can no longer be cancelled.');
    }

    await _firestore.runTransaction((transaction) async {
      final orderRef = _firestore.collection('orders').doc(order.id);
      final orderSnap = await transaction.get(orderRef);

      if (!orderSnap.exists) {
        throw Exception('Order not found.');
      }

      final orderData = orderSnap.data() as Map<String, dynamic>;
      final latestStatus = (orderData['status'] ?? '').toString().toLowerCase();

      // 🔒 double check (important for concurrency)
      if (latestStatus != 'pending' && latestStatus != 'processing') {
        throw Exception('This order can no longer be cancelled.');
      }

      final items = (orderData['items'] as List<dynamic>? ?? [])
          .map((e) => Map<String, dynamic>.from(e as Map))
          .toList();

      /// 🔥 RESTORE STOCK
      for (final item in items) {
        final productId = (item['productId'] ?? '').toString();
        final quantity = ((item['quantity'] ?? 0) as num).toInt();

        if (productId.isEmpty || quantity <= 0) continue;

        final productRef = _firestore.collection('products').doc(productId);

        final productSnap = await transaction.get(productRef);

        if (!productSnap.exists) continue;

        final productData = productSnap.data() as Map<String, dynamic>;
        final currentStock = ((productData['stock'] ?? 0) as num).toInt();

        transaction.update(productRef, {
          'stock': currentStock + quantity, // 🔥 restore stock
        });
      }

      /// 🔥 UPDATE ORDER STATUS
      transaction.update(orderRef, {
        'status': 'cancelled',
        'updatedAt': FieldValue.serverTimestamp(),
      });
    });
  }
}
