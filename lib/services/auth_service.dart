abstract class AuthService {
  Future<void> signIn({
    required String email,
    required String password,
    required bool asAdmin,
  });

  Future<void> signUp({
    required String username,
    required String email,
    required String password,
  });

  Future<void> signOut();
}

class MockAuthService implements AuthService {
  @override
  Future<void> signIn({
    required String email,
    required String password,
    required bool asAdmin,
  }) async {
    await Future.delayed(const Duration(milliseconds: 800));
    if (email.isEmpty || password.isEmpty) {
      throw Exception('Invalid credentials');
    }
  }

  @override
  Future<void> signUp({
    required String username,
    required String email,
    required String password,
  }) async {
    await Future.delayed(const Duration(milliseconds: 800));
    if (username.isEmpty || email.isEmpty || password.isEmpty) {
      throw Exception('Please fill all fields');
    }
  }

  @override
  Future<void> signOut() async {
    await Future.delayed(const Duration(milliseconds: 500));
  }
}
