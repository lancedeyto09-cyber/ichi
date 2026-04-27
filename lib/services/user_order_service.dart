import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../models/user_order_model.dart';

class UserOrderService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  Stream<List<UserOrder>> getUserOrders() {
    final user = _auth.currentUser;

    if (user == null) {
      return const Stream.empty();
    }

    return _firestore
        .collection('orders')
        .where('customerId', isEqualTo: user.uid)
        .snapshots()
        .map((snapshot) {
      final orders = snapshot.docs
          .map((doc) => UserOrder.fromMap(doc.data(), doc.id))
          .toList();

      orders.sort((a, b) => b.createdAt.compareTo(a.createdAt));
      return orders;
    });
  }

  Future<void> cancelOrder(UserOrder order) async {
    final user = _auth.currentUser;

    if (user == null) {
      throw Exception('You must be logged in.');
    }

    if (order.customerId != user.uid) {
      throw Exception('You are not allowed to cancel this order.');
    }

    final currentStatus = order.status.toLowerCase();
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

      if (latestStatus != 'pending' && latestStatus != 'processing') {
        throw Exception('This order can no longer be cancelled.');
      }

      final items = (orderData['items'] as List<dynamic>? ?? [])
          .map((e) => Map<String, dynamic>.from(e as Map))
          .toList();

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
          'stock': currentStock + quantity,
        });
      }

      transaction.update(orderRef, {
        'status': 'cancelled',
        'updatedAt': FieldValue.serverTimestamp(),
      });
    });
  }
}
