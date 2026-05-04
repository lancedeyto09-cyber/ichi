import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class DashboardRecentOrder {
  final String id;
  final String customerName;
  final double totalAmount;
  final String status;

  DashboardRecentOrder({
    required this.id,
    required this.customerName,
    required this.totalAmount,
    required this.status,
  });
}

class DashboardLowStockProduct {
  final String id;
  final String name;
  final int stock;

  DashboardLowStockProduct({
    required this.id,
    required this.name,
    required this.stock,
  });
}

class DashboardTopProduct {
  final String productId;
  final String productName;
  final int quantitySold;
  final double revenue;

  DashboardTopProduct({
    required this.productId,
    required this.productName,
    required this.quantitySold,
    required this.revenue,
  });
}

class DashboardProvider with ChangeNotifier {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  StreamSubscription? _ordersSub;
  StreamSubscription? _productsSub;
  StreamSubscription? _usersSub;

  int totalOrders = 0;
  int pendingOrders = 0;
  int deliveredOrders = 0;
  int lowStockCount = 0;
  int totalUsers = 0;

  double totalRevenue = 0.0;

  List<DashboardRecentOrder> recentOrders = [];
  List<DashboardLowStockProduct> lowStockProducts = [];
  List<DashboardTopProduct> topProducts = [];

  bool isLoading = true;

  void startRealtimeDashboard() {
    isLoading = true;
    notifyListeners();

    _ordersSub?.cancel();
    _productsSub?.cancel();
    _usersSub?.cancel();

    _listenOrders();
    _listenProducts();
    _listenUsers();
  }

  void _listenOrders() {
    _ordersSub = _firestore
        .collection('orders')
        .orderBy('createdAt', descending: true)
        .snapshots()
        .listen((snapshot) {
      totalOrders = snapshot.docs.length;
      pendingOrders = 0;
      deliveredOrders = 0;
      totalRevenue = 0.0;

      final productSalesMap = <String, DashboardTopProduct>{};

      recentOrders = snapshot.docs.take(5).map((doc) {
        final data = doc.data();

        return DashboardRecentOrder(
          id: doc.id,
          customerName: (data['customerName'] ?? 'Customer').toString(),
          totalAmount: _toDouble(data['totalAmount']),
          status: (data['status'] ?? 'pending').toString(),
        );
      }).toList();

      for (final doc in snapshot.docs) {
        final data = doc.data();
        final status = (data['status'] ?? '').toString().toLowerCase();
        final amount = _toDouble(data['totalAmount']);

        if (status == 'pending') {
          pendingOrders++;
        }

        if (status == 'delivered') {
          deliveredOrders++;
          totalRevenue += amount;
        }

        if (status == 'cancelled') continue;

        final items = data['items'];

        if (items is List) {
          for (final item in items) {
            final itemMap = Map<String, dynamic>.from(item as Map);

            final productId = (itemMap['productId'] ?? '').toString();
            final productName =
                (itemMap['productName'] ?? 'Product').toString();
            final quantity = _toInt(itemMap['quantity']);
            final price = _toDouble(itemMap['price']);

            if (productId.isEmpty || quantity <= 0) continue;

            final existing = productSalesMap[productId];

            if (existing == null) {
              productSalesMap[productId] = DashboardTopProduct(
                productId: productId,
                productName: productName,
                quantitySold: quantity,
                revenue: price * quantity,
              );
            } else {
              productSalesMap[productId] = DashboardTopProduct(
                productId: existing.productId,
                productName: existing.productName,
                quantitySold: existing.quantitySold + quantity,
                revenue: existing.revenue + (price * quantity),
              );
            }
          }
        }
      }

      topProducts = productSalesMap.values.toList()
        ..sort((a, b) => b.quantitySold.compareTo(a.quantitySold));

      topProducts = topProducts.take(5).toList();

      isLoading = false;
      notifyListeners();
    });
  }

  void _listenProducts() {
    _productsSub = _firestore.collection('products').snapshots().listen(
      (snapshot) {
        final lowStockDocs = snapshot.docs.where((doc) {
          final data = doc.data();
          final stock = _toInt(data['stock']);
          return stock <= 5;
        }).toList();

        lowStockCount = lowStockDocs.length;

        lowStockProducts = lowStockDocs.map((doc) {
          final data = doc.data();

          return DashboardLowStockProduct(
            id: doc.id,
            name: (data['name'] ?? 'Product').toString(),
            stock: _toInt(data['stock']),
          );
        }).toList()
          ..sort((a, b) => a.stock.compareTo(b.stock));

        lowStockProducts = lowStockProducts.take(5).toList();

        isLoading = false;
        notifyListeners();
      },
    );
  }

  void _listenUsers() {
    _usersSub = _firestore.collection('users').snapshots().listen(
      (snapshot) {
        totalUsers = snapshot.docs.where((doc) {
          final data = doc.data();
          final role = (data['role'] ?? 'user').toString();
          return role == 'user';
        }).length;

        isLoading = false;
        notifyListeners();
      },
    );
  }

  Future<void> fetchDashboard() async {
    startRealtimeDashboard();
  }

  static double _toDouble(dynamic value) {
    if (value == null) return 0.0;
    if (value is num) return value.toDouble();
    return double.tryParse(value.toString()) ?? 0.0;
  }

  static int _toInt(dynamic value) {
    if (value == null) return 0;
    if (value is num) return value.toInt();
    return int.tryParse(value.toString()) ?? 0;
  }

  @override
  void dispose() {
    _ordersSub?.cancel();
    _productsSub?.cancel();
    _usersSub?.cancel();
    super.dispose();
  }
}
