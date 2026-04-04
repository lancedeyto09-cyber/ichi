import 'package:firebase_auth/firebase_auth.dart' as fb;
import '../models/admin_user_model.dart';

class AdminAuthService {
  final fb.FirebaseAuth _auth = fb.FirebaseAuth.instance;

  Future<AdminUser?> loginAdmin(String email, String password) async {
    try {
      final credential = await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );

      final user = credential.user;
      if (user == null) return null;

      final isSuperAdmin = email.toLowerCase() == 'admin@ichi.com';

      return AdminUser(
        id: user.uid,
        name: user.displayName ?? (isSuperAdmin ? 'Super Admin' : 'Admin User'),
        email: user.email ?? email,
        role: isSuperAdmin ? 'super_admin' : 'manager',
        lastLogin: DateTime.now(),
        isActive: true,
        permissions: isSuperAdmin
            ? const [
                AdminPermissions.viewDashboard,
                AdminPermissions.manageProducts,
                AdminPermissions.manageOrders,
                AdminPermissions.manageUsers,
                AdminPermissions.viewAnalytics,
                AdminPermissions.manageSettings,
                AdminPermissions.manageStaff,
              ]
            : const [
                AdminPermissions.viewDashboard,
                AdminPermissions.manageProducts,
                AdminPermissions.manageOrders,
                AdminPermissions.viewAnalytics,
              ],
      );
    } on fb.FirebaseAuthException {
      return null;
    } catch (_) {
      return null;
    }
  }

  Future<void> logoutAdmin() async {
    await _auth.signOut();
  }

  AdminUser? getCurrentAdmin() {
    final user = _auth.currentUser;
    if (user == null) return null;

    final isSuperAdmin = (user.email ?? '').toLowerCase() == 'admin@ichi.com';

    return AdminUser(
      id: user.uid,
      name: user.displayName ?? (isSuperAdmin ? 'Super Admin' : 'Admin User'),
      email: user.email ?? '',
      role: isSuperAdmin ? 'super_admin' : 'manager',
      lastLogin: DateTime.now(),
      isActive: true,
      permissions: isSuperAdmin
          ? const [
              AdminPermissions.viewDashboard,
              AdminPermissions.manageProducts,
              AdminPermissions.manageOrders,
              AdminPermissions.manageUsers,
              AdminPermissions.viewAnalytics,
              AdminPermissions.manageSettings,
              AdminPermissions.manageStaff,
            ]
          : const [
              AdminPermissions.viewDashboard,
              AdminPermissions.manageProducts,
              AdminPermissions.manageOrders,
              AdminPermissions.viewAnalytics,
            ],
    );
  }
}
