// Minimal Auth abstraction + MockAuthService with admin support. to be replaced with real backend integration later.

import 'dart:async';

class AuthUser {
  final String uid;
  final String email;
  final bool isAdmin;
  AuthUser({required this.uid, required this.email, this.isAdmin = false});
}

abstract class AuthService {
  Stream<AuthUser?> authStateChanges();
  Future<AuthUser> signIn({
    required String email,
    required String password,
    bool asAdmin = false,
  });
  Future<AuthUser> signUp({
    required String username,
    required String email,
    required String password,
  });
  Future<void> signOut();
}

class MockAuthService implements AuthService {
  AuthUser? _user;
  final _ctrl = StreamController<AuthUser?>.broadcast();

  // Pre-set admin credentials for testing -- change for real backend
  static const _adminEmail = 'admin@ichi.com';
  static const _adminPassword = 'admin123';

  MockAuthService() {
    _ctrl.add(_user);
  }

  @override
  Stream<AuthUser?> authStateChanges() => _ctrl.stream;

  @override
  Future<AuthUser> signIn({
    required String email,
    required String password,
    bool asAdmin = false,
  }) async {
    await Future.delayed(const Duration(milliseconds: 700));
    if (asAdmin) {
      if (email.toLowerCase() != _adminEmail || password != _adminPassword) {
        throw Exception('Invalid admin credentials');
      }
      _user = AuthUser(uid: 'admin-1', email: email, isAdmin: true);
    } else {
      // accept any non-empty email/password for mock (except this special fail case)
      if (email.trim().isEmpty || password.isEmpty) {
        throw Exception('Enter email and password');
      }
      _user = AuthUser(
          uid: 'user-${DateTime.now().millisecondsSinceEpoch}',
          email: email,
          isAdmin: false);
    }
    _ctrl.add(_user);
    return _user!;
  }

  @override
  Future<AuthUser> signUp(
      {required String username,
      required String email,
      required String password}) async {
    await Future.delayed(const Duration(milliseconds: 700));
    if (!email.contains('@')) throw Exception('Invalid email');
    if (password.length < 6) throw Exception('Password too short');
    // create a mock user
    _user = AuthUser(
        uid: 'user-${DateTime.now().millisecondsSinceEpoch}',
        email: email,
        isAdmin: false);
    _ctrl.add(_user);
    return _user!;
  }

  @override
  Future<void> signOut() async {
    _user = null;
    await Future.delayed(const Duration(milliseconds: 200));
    _ctrl.add(_user);
  }
}
