import '../models/admin_user_model.dart';

class AdminAuthService {
  static final List<AdminUser> _admins = [
    AdminUser(
      id: 'admin-001',
      name: 'Super Admin',
      email: 'admin@ichi.com',
      role: 'super_admin',
      lastLogin: DateTime.now().subtract(const Duration(hours: 2)),
      isActive: true,
      permissions: [
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
      permissions: [
        AdminPermissions.viewDashboard,
        AdminPermissions.manageProducts,
        AdminPermissions.manageOrders,
        AdminPermissions.viewAnalytics,
      ],
    ),
  ];

  Future<AdminUser?> loginAdmin(String email, String password) async {
    await Future.delayed(const Duration(milliseconds: 800));

    try {
      // Simple validation - in real app, use proper authentication
      if (email.isEmpty || password.isEmpty) {
        return null;
      }

      final admin = _admins.firstWhere(
        (a) => a.email == email && a.isActive,
        orElse: () => throw Exception('Admin not found'),
      );

      return admin;
    } catch (e) {
      return null;
    }
  }

  Future<void> logoutAdmin() async {
    await Future.delayed(const Duration(milliseconds: 500));
  }

  AdminUser? getCurrentAdmin() {
    // This would normally retrieve from secure storage
    return _admins.isNotEmpty ? _admins[0] : null;
  }
}
