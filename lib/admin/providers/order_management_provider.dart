import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import '../models/order_analytics_model.dart';

class OrderManagementProvider extends ChangeNotifier {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  List<AdminOrder> _orders = [];
  List<AdminOrder> _filteredOrders = [];
  bool _isLoading = false;
  String? _error;
  String _selectedStatus = 'All';
  String _searchQuery = '';

  StreamSubscription<QuerySnapshot<Map<String, dynamic>>>? _subscription;

  List<AdminOrder> get orders => _filteredOrders;
  bool get isLoading => _isLoading;
  String? get error => _error;
  String get selectedStatus => _selectedStatus;
  List<String> get statuses => [
        'All',
        'pending',
        'processing',
        'shipped',
        'delivered',
        'cancelled',
      ];

  OrderManagementProvider() {
    loadOrders();
  }

  void loadOrders() {
    _isLoading = true;
    notifyListeners();

    _subscription?.cancel();
    _subscription = _firestore.collection('orders').snapshots().listen(
      (snapshot) {
        _orders = snapshot.docs
            .map((doc) => AdminOrder.fromMap(doc.data(), doc.id))
            .toList();

        _orders.sort((a, b) => b.createdAt.compareTo(a.createdAt));

        _error = null;
        _isLoading = false;
        _applyFilters();
      },
      onError: (e) {
        _error = e.toString();
        _isLoading = false;
        notifyListeners();
      },
    );
  }

  Future<void> refreshOrders() async {
    try {
      _isLoading = true;
      notifyListeners();

      final snapshot = await _firestore.collection('orders').get();

      _orders = snapshot.docs
          .map((doc) => AdminOrder.fromMap(doc.data(), doc.id))
          .toList();

      _orders.sort((a, b) => b.createdAt.compareTo(a.createdAt));

      _error = null;
      _isLoading = false;
      _applyFilters();
    } catch (e) {
      _error = e.toString();
      _isLoading = false;
      notifyListeners();
    }
  }

  void filterByStatus(String status) {
    _selectedStatus = status;
    _applyFilters();
  }

  void searchOrders(String query) {
    _searchQuery = query.trim();
    _applyFilters();
  }

  void _applyFilters() {
    List<AdminOrder> result = List.from(_orders);

    if (_selectedStatus != 'All') {
      result = result.where((o) => o.status == _selectedStatus).toList();
    }

    if (_searchQuery.isNotEmpty) {
      final q = _searchQuery.toLowerCase();
      result = result.where((o) {
        return o.id.toLowerCase().contains(q) ||
            o.customerName.toLowerCase().contains(q) ||
            o.customerEmail.toLowerCase().contains(q);
      }).toList();
    }

    _filteredOrders = result;
    notifyListeners();
  }

  Future<void> updateOrderStatus(String orderId, String newStatus) async {
    await _firestore.collection('orders').doc(orderId).update({
      'status': newStatus,
      'updatedAt': FieldValue.serverTimestamp(),
    });
  }

  Future<void> updateTrackingNumber(
      String orderId, String trackingNumber) async {
    await _firestore.collection('orders').doc(orderId).update({
      'trackingNumber': trackingNumber,
      'updatedAt': FieldValue.serverTimestamp(),
    });
  }

  AdminOrder? getOrderById(String id) {
    try {
      return _orders.firstWhere((o) => o.id == id);
    } catch (_) {
      return null;
    }
  }

  int getPendingOrdersCount() {
    return _orders.where((o) => o.status == 'pending').length;
  }

  int getProcessingOrdersCount() {
    return _orders.where((o) => o.status == 'processing').length;
  }

  @override
  void dispose() {
    _subscription?.cancel();
    super.dispose();
  }
}
