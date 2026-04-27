import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/admin_user_management_model.dart';

class AdminUserService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  CollectionReference<Map<String, dynamic>> get _usersRef =>
      _firestore.collection('users');

  CollectionReference<Map<String, dynamic>> get _ordersRef =>
      _firestore.collection('orders');

  Future<List<AdminCustomerUser>> getAllCustomers() async {
    final usersSnapshot = await _usersRef.get();
    final ordersSnapshot = await _ordersRef.get();

    final ordersByCustomer = <String, List<Map<String, dynamic>>>{};

    for (final doc in ordersSnapshot.docs) {
      final data = doc.data();
      final customerId = (data['customerId'] ?? '').toString();

      if (customerId.isEmpty) continue;

      ordersByCustomer.putIfAbsent(customerId, () => []);
      ordersByCustomer[customerId]!.add(data);
    }

    final customers = usersSnapshot.docs.where((doc) {
      final role = (doc.data()['role'] ?? 'user').toString();
      return role != 'admin';
    }).map((doc) {
      final userData = doc.data();
      final userOrders = ordersByCustomer[doc.id] ?? [];

      final totalOrders = userOrders.length;
      final totalSpent = userOrders.fold<double>(0.0, (sum, order) {
        final amount = order['totalAmount'];
        if (amount is num) return sum + amount.toDouble();
        return sum + (double.tryParse(amount.toString()) ?? 0.0);
      });

      return AdminCustomerUser.fromMap(
        userData,
        doc.id,
        totalOrders: totalOrders,
        totalSpent: totalSpent,
      );
    }).toList();

    customers.sort((a, b) => b.registeredDate.compareTo(a.registeredDate));
    return customers;
  }

  Future<List<AdminCustomerUser>> getActiveCustomers() async {
    final allCustomers = await getAllCustomers();
    return allCustomers
        .where((c) => c.isActive && c.accountStatus == 'active')
        .toList();
  }

  Future<AdminCustomerUser?> getCustomerById(String id) async {
    final doc = await _usersRef.doc(id).get();
    if (!doc.exists || doc.data() == null) return null;

    final ordersSnapshot =
        await _ordersRef.where('customerId', isEqualTo: id).get();

    final totalOrders = ordersSnapshot.docs.length;
    final totalSpent = ordersSnapshot.docs.fold<double>(0.0, (sum, doc) {
      final amount = doc.data()['totalAmount'];
      if (amount is num) return sum + amount.toDouble();
      return sum + (double.tryParse(amount.toString()) ?? 0.0);
    });

    return AdminCustomerUser.fromMap(
      doc.data()!,
      doc.id,
      totalOrders: totalOrders,
      totalSpent: totalSpent,
    );
  }

  Future<List<AdminCustomerUser>> searchCustomers(String query) async {
    final allCustomers = await getAllCustomers();
    final q = query.toLowerCase();

    return allCustomers.where((c) {
      return c.name.toLowerCase().contains(q) ||
          c.email.toLowerCase().contains(q);
    }).toList();
  }

  Future<void> suspendCustomer(String customerId) async {
    await _usersRef.doc(customerId).set({
      'isActive': false,
      'accountStatus': 'suspended',
      'updatedAt': FieldValue.serverTimestamp(),
    }, SetOptions(merge: true));
  }

  Future<void> activateCustomer(String customerId) async {
    await _usersRef.doc(customerId).set({
      'isActive': true,
      'accountStatus': 'active',
      'updatedAt': FieldValue.serverTimestamp(),
    }, SetOptions(merge: true));
  }
}
