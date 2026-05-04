import 'dart:async';
import 'package:flutter/material.dart';
import '../models/admin_user_model.dart';
import '../services/admin_auth_service.dart';
import '../services/admin_staff_service.dart';

class AdminProvider extends ChangeNotifier {
  final AdminAuthService _authService = AdminAuthService();
  final AdminStaffService _staffService = AdminStaffService();

  AdminUser? _currentAdmin;
  bool _isLoading = false;
  String? _error;

  List<AdminUser> _adminUsers = [];
  StreamSubscription? _adminSub;

  AdminUser? get currentAdmin => _currentAdmin;
  bool get isLoading => _isLoading;
  String? get error => _error;
  bool get isLoggedIn => _currentAdmin != null;
  List<AdminUser> get adminUsers => _adminUsers;

  AdminProvider() {
    _currentAdmin = _authService.getCurrentAdmin();
    _listenAdmins();
  }

  void _listenAdmins() {
    _adminSub?.cancel();

    _adminSub = _staffService.listenAdmins().listen((admins) {
      _adminUsers = admins;
      notifyListeners();
    });
  }

  // ================= LOGIN =================
  Future<bool> loginAdmin(String email, String password) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final admin = await _authService.loginAdmin(email, password);

      if (admin != null) {
        _currentAdmin = admin;
        _isLoading = false;
        notifyListeners();
        return true;
      } else {
        _error = 'Invalid email or password';
      }
    } catch (e) {
      _error = 'Login failed: $e';
    }

    _isLoading = false;
    notifyListeners();
    return false;
  }

  // ================= LOGOUT =================
  Future<void> logoutAdmin() async {
    _isLoading = true;
    notifyListeners();

    try {
      await _authService.logoutAdmin();
      _currentAdmin = null;
      _error = null;
    } catch (e) {
      _error = e.toString();
    }

    _isLoading = false;
    notifyListeners();
  }

  // ================= ADD ADMIN =================
  Future<void> addAdmin(String name, String email, String role) async {
    try {
      _isLoading = true;
      notifyListeners();

      final permissions = role == 'super_admin'
          ? <String>[
              AdminPermissions.viewDashboard,
              AdminPermissions.manageProducts,
              AdminPermissions.manageOrders,
              AdminPermissions.manageUsers,
              AdminPermissions.viewAnalytics,
              AdminPermissions.manageSettings,
              AdminPermissions.manageStaff,
            ]
          : <String>[
              AdminPermissions.viewDashboard,
              AdminPermissions.manageProducts,
              AdminPermissions.manageOrders,
              AdminPermissions.viewAnalytics,
            ];

      await _staffService.addAdmin(
        name: name,
        email: email,
        role: role,
        permissions: permissions,
      );

      _error = null;
    } catch (e) {
      _error = e.toString();
    }

    _isLoading = false;
    notifyListeners();
  }

  // ================= DELETE ADMIN =================
  Future<void> removeAdmin(String id) async {
    try {
      await _staffService.removeAdmin(id);
    } catch (e) {
      _error = e.toString();
      notifyListeners();
    }
  }

  // ================= PERMISSION =================
  bool hasPermission(String permission) {
    return _currentAdmin?.hasPermission(permission) ?? false;
  }

  void clearError() {
    _error = null;
    notifyListeners();
  }

  @override
  void dispose() {
    _adminSub?.cancel();
    super.dispose();
  }
}
