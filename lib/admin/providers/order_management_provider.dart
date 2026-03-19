import 'package:flutter/material.dart';
import '../models/order_analytics_model.dart';
import '../services/admin_order_service.dart';

class OrderManagementProvider extends ChangeNotifier {
  final AdminOrderService _orderService = AdminOrderService();

  List<AdminOrder> _orders = [];
  List<AdminOrder> _filteredOrders = [];
  bool _isLoading = false;
  String? _error;
  String _selectedStatus = 'All';
  String _searchQuery = '';

  List<AdminOrder> get orders => _filteredOrders;
  bool get isLoading => _isLoading;
  String? get error => _error;
  String get selectedStatus => _selectedStatus;
  List<String> get statuses => ['All', ..._orderService.getOrderStatuses()];

  OrderManagementProvider() {
    loadOrders();
  }

  void loadOrders() {
    _isLoading = true;
    notifyListeners();

    try {
      _orders = _orderService.getAllOrders();
      _applyFilters();
      _error = null;
    } catch (e) {
      _error = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  void filterByStatus(String status) {
    _selectedStatus = status;
    _applyFilters();
  }

  void searchOrders(String query) {
    _searchQuery = query;
    _applyFilters();
  }

  void _applyFilters() {
    _filteredOrders = _orders;

    if (_selectedStatus != 'All') {
      _filteredOrders =
          _filteredOrders.where((o) => o.status == _selectedStatus).toList();
    }

    if (_searchQuery.isNotEmpty) {
      _filteredOrders = _filteredOrders
          .where((o) =>
              o.id.toLowerCase().contains(_searchQuery.toLowerCase()) ||
              o.customerName
                  .toLowerCase()
                  .contains(_searchQuery.toLowerCase()) ||
              o.customerEmail
                  .toLowerCase()
                  .contains(_searchQuery.toLowerCase()))
          .toList();
    }

    notifyListeners();
  }

  void updateOrderStatus(String orderId, String newStatus) {
    _orderService.updateOrderStatus(orderId, newStatus);
    loadOrders();
  }

  void updateTrackingNumber(String orderId, String trackingNumber) {
    _orderService.updateTrackingNumber(orderId, trackingNumber);
    loadOrders();
  }

  AdminOrder? getOrderById(String id) {
    return _orderService.getOrderById(id);
  }

  int getPendingOrdersCount() {
    return _orders.where((o) => o.status == 'pending').length;
  }

  int getProcessingOrdersCount() {
    return _orders.where((o) => o.status == 'processing').length;
  }
}
