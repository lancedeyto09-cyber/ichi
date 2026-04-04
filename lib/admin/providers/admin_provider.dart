import 'package:flutter/material.dart';
import '../models/admin_user_model.dart';
import '../services/admin_auth_service.dart';

class AdminProvider extends ChangeNotifier {
  final AdminAuthService _authService = AdminAuthService();

  AdminUser? _currentAdmin;
  bool _isLoading = false;
  String? _error;

  final List<AdminUser> _adminUsers = [];

  AdminUser? get currentAdmin => _currentAdmin;
  bool get isLoading => _isLoading;
  String? get error => _error;
  bool get isLoggedIn => _currentAdmin != null;
  List<AdminUser> get adminUsers => List.unmodifiable(_adminUsers);

  AdminProvider() {
    _currentAdmin = _authService.getCurrentAdmin();

    if (_adminUsers.isEmpty) {
      _adminUsers.addAll([
        AdminUser(
          id: 'admin-001',
          name: 'Super Admin',
          email: 'admin@ichi.com',
          role: 'super_admin',
          lastLogin: DateTime.now().subtract(const Duration(hours: 2)),
          isActive: true,
          permissions: const [
            AdminPermissions.viewDashboard,
            AdminPermissions.manageProducts,
            AdminPermissions.manageOrders,
            AdminPermissions.manageUsers,
            AdminPermissions.viewAnalytics,
            AdminPermissions.manageSettings,
            AdminPermissions.manageStaff,
          ],
        ),
        AdminUser(
          id: 'admin-002',
          name: 'Manager',
          email: 'manager@ichi.com',
          role: 'manager',
          lastLogin: DateTime.now().subtract(const Duration(hours: 5)),
          isActive: true,
          permissions: const [
            AdminPermissions.viewDashboard,
            AdminPermissions.manageProducts,
            AdminPermissions.manageOrders,
            AdminPermissions.viewAnalytics,
          ],
        ),
      ]);
    }
  }

  Future<bool> loginAdmin(String email, String password) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final admin = await _authService.loginAdmin(email, password);

      if (admin != null) {
        _currentAdmin = admin;

        final exists = _adminUsers.any((a) => a.email == admin.email);
        if (!exists) {
          _adminUsers.add(admin);
        }

        _isLoading = false;
        notifyListeners();
        return true;
      } else {
        _error = 'Invalid email or password';
        _isLoading = false;
        notifyListeners();
        return false;
      }
    } catch (e) {
      _error = 'Login failed: $e';
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  Future<void> logoutAdmin() async {
    _isLoading = true;
    notifyListeners();

    try {
      await _authService.logoutAdmin();
      _currentAdmin = null;
      _error = null;
    } catch (e) {
      _error = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  bool hasPermission(String permission) {
    return _currentAdmin?.hasPermission(permission) ?? false;
  }

  void addAdmin(String name, String email, String role) {
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

    _adminUsers.add(
      AdminUser(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        name: name,
        email: email,
        role: role,
        lastLogin: DateTime.now(),
        isActive: true,
        permissions: permissions,
      ),
    );
    notifyListeners();
  }

  void removeAdmin(String id) {
    _adminUsers.removeWhere((admin) => admin.id == id);
    notifyListeners();
  }

  void clearError() {
    _error = null;
    notifyListeners();
  }
}
