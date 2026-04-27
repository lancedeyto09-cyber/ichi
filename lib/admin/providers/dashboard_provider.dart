import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class DashboardProvider with ChangeNotifier {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  StreamSubscription? _ordersSub;
  StreamSubscription? _productsSub;

  int totalOrders = 0;
  int pendingOrders = 0;
  int deliveredOrders = 0;
  int lowStockCount = 0;
  double totalRevenue = 0.0;

  bool isLoading = true;

  void startRealtimeDashboard() {
    isLoading = true;
    notifyListeners();

    _ordersSub?.cancel();
    _productsSub?.cancel();

    _ordersSub = _firestore.collection('orders').snapshots().listen((snapshot) {
      totalOrders = snapshot.docs.length;
      pendingOrders = 0;
      deliveredOrders = 0;
      totalRevenue = 0.0;

      for (final doc in snapshot.docs) {
        final data = doc.data();

        final status = (data['status'] ?? '').toString().toLowerCase();
        final amount = ((data['totalAmount'] ?? 0) as num).toDouble();

        if (status == 'pending') {
          pendingOrders++;
        }

        if (status == 'delivered') {
          deliveredOrders++;
          totalRevenue += amount;
        }
      }

      isLoading = false;
      notifyListeners();
    });

    _productsSub =
        _firestore.collection('products').snapshots().listen((snapshot) {
      lowStockCount = snapshot.docs.where((doc) {
        final data = doc.data();
        final stock = ((data['stock'] ?? 0) as num).toInt();
        return stock <= 5;
      }).length;

      isLoading = false;
      notifyListeners();
    });
  }

  Future<void> fetchDashboard() async {
    startRealtimeDashboard();
  }

  @override
  void dispose() {
    _ordersSub?.cancel();
    _productsSub?.cancel();
    super.dispose();
  }
}
