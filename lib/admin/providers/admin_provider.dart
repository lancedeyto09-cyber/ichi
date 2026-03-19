import 'package:flutter/material.dart';
import '../models/admin_user_model.dart';
import '../services/admin_auth_service.dart';

class AdminProvider extends ChangeNotifier {
  final AdminAuthService _authService = AdminAuthService();

  AdminUser? _currentAdmin;
  bool _isLoading = false;
  String? _error;

  AdminUser? get currentAdmin => _currentAdmin;
  bool get isLoading => _isLoading;
  String? get error => _error;
  bool get isLoggedIn => _currentAdmin != null;

  Future<bool> loginAdmin(String email, String password) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      await Future.delayed(const Duration(milliseconds: 800));

      final admin = await _authService.loginAdmin(email, password);
      if (admin != null) {
        _currentAdmin = admin;
        _isLoading = false;
        notifyListeners();
        return true;
      } else {
        _error = 'Invalid credentials';
        _isLoading = false;
        notifyListeners();
        return false;
      }
    } catch (e) {
      _error = e.toString();
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
      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _error = e.toString();
      _isLoading = false;
      notifyListeners();
    }
  }

  bool hasPermission(String permission) {
    return _currentAdmin?.hasPermission(permission) ?? false;
  }

  void clearError() {
    _error = null;
    notifyListeners();
  }
}
