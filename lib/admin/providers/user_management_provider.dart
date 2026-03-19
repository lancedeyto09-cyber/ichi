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

  void loadCustomers() {
    _isLoading = true;
    notifyListeners();

    try {
      _customers = _userService.getAllCustomers();
      _applyFilters();
      _error = null;
    } catch (e) {
      _error = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  void searchCustomers(String query) {
    _searchQuery = query;
    _applyFilters();
  }

  void filterByStatus(String status) {
    _filterStatus = status;
    _applyFilters();
  }

  void _applyFilters() {
    _filteredCustomers = _customers;

    if (_filterStatus != 'All') {
      if (_filterStatus == 'Active') {
        _filteredCustomers =
            _filteredCustomers.where((c) => c.isActive).toList();
      } else if (_filterStatus == 'Suspended') {
        _filteredCustomers =
            _filteredCustomers.where((c) => !c.isActive).toList();
      }
    }

    if (_searchQuery.isNotEmpty) {
      _filteredCustomers = _userService.searchCustomers(_searchQuery);
    }

    notifyListeners();
  }

  void suspendCustomer(String customerId) {
    _userService.suspendCustomer(customerId);
    loadCustomers();
  }

  void activateCustomer(String customerId) {
    _userService.activateCustomer(customerId);
    loadCustomers();
  }

  AdminCustomerUser? getCustomerById(String id) {
    return _userService.getCustomerById(id);
  }
}
