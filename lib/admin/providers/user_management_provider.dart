import 'package:flutter/material.dart';
import '../models/admin_user_management_model.dart';
import '../services/admin_user_service.dart';

class UserManagementProvider extends ChangeNotifier {
  final AdminUserService _userService = AdminUserService();

  List<AdminCustomerUser> _customers = [];
  List<AdminCustomerUser> _filteredCustomers = [];
  bool _isLoading = false;
  String? _error;
  String _searchQuery = '';
  String _filterStatus = 'All'; // All, Active, Suspended

  List<AdminCustomerUser> get customers => _filteredCustomers;
  bool get isLoading => _isLoading;
  String? get error => _error;
  int get totalCustomers => _customers.length;
  int get activeCustomers => _customers.where((c) => c.isActive).length;

  UserManagementProvider() {
    loadCustomers();
  }

  Future<void> loadCustomers() async {
    _isLoading = true;
    notifyListeners();

    try {
      _customers = await _userService.getAllCustomers();
      _applyFilters();
      _error = null;
    } catch (e) {
      _error = e.toString();
      _isLoading = false;
      notifyListeners();
      return;
    }

    _isLoading = false;
    notifyListeners();
  }

  void searchCustomers(String query) {
    _searchQuery = query.trim();
    _applyFilters();
  }

  void filterByStatus(String status) {
    _filterStatus = status;
    _applyFilters();
  }

  void _applyFilters() {
    List<AdminCustomerUser> result = List.from(_customers);

    if (_filterStatus != 'All') {
      if (_filterStatus == 'Active') {
        result = result.where((c) => c.isActive).toList();
      } else if (_filterStatus == 'Suspended') {
        result = result.where((c) => !c.isActive).toList();
      }
    }

    if (_searchQuery.isNotEmpty) {
      final q = _searchQuery.toLowerCase();
      result = result.where((c) {
        return c.name.toLowerCase().contains(q) ||
            c.email.toLowerCase().contains(q);
      }).toList();
    }

    _filteredCustomers = result;
    notifyListeners();
  }

  Future<void> suspendCustomer(String customerId) async {
    try {
      _isLoading = true;
      notifyListeners();

      await _userService.suspendCustomer(customerId);
      await loadCustomers();
    } catch (e) {
      _error = e.toString();
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> activateCustomer(String customerId) async {
    try {
      _isLoading = true;
      notifyListeners();

      await _userService.activateCustomer(customerId);
      await loadCustomers();
    } catch (e) {
      _error = e.toString();
      _isLoading = false;
      notifyListeners();
    }
  }

  AdminCustomerUser? getCustomerById(String id) {
    try {
      return _customers.firstWhere((c) => c.id == id);
    } catch (_) {
      return null;
    }
  }
}
