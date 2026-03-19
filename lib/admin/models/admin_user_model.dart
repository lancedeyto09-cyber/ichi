class AdminUser {
  final String id;
  final String name;
  final String email;
  final String role; // 'super_admin', 'manager', 'operator'
  final String? profileImage;
  final DateTime lastLogin;
  final bool isActive;
  final List<String> permissions;

  AdminUser({
    required this.id,
    required this.name,
    required this.email,
    required this.role,
    this.profileImage,
    required this.lastLogin,
    required this.isActive,
    required this.permissions,
  });

  bool hasPermission(String permission) {
    return permissions.contains(permission);
  }
}

class AdminPermissions {
  static const String viewDashboard = 'view_dashboard';
  static const String manageProducts = 'manage_products';
  static const String manageOrders = 'manage_orders';
  static const String manageUsers = 'manage_users';
  static const String viewAnalytics = 'view_analytics';
  static const String manageSettings = 'manage_settings';
  static const String manageStaff = 'manage_staff';
}
