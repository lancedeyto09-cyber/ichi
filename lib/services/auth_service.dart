import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

abstract class AuthService {
  Stream<User?> authStateChanges();
  User? get currentUser;

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

class FirebaseAuthService implements AuthService {
  final FirebaseAuth _auth;
  final FirebaseFirestore _firestore;

  FirebaseAuthService({FirebaseAuth? auth, FirebaseFirestore? firestore})
      : _auth = auth ?? FirebaseAuth.instance,
        _firestore = firestore ?? FirebaseFirestore.instance;

  @override
  Stream<User?> authStateChanges() {
    return _auth.authStateChanges();
  }

  @override
  User? get currentUser => _auth.currentUser;

  /// 🔥 FINAL USER PROFILE CREATION (100% SAFE)
  Future<void> _ensureUserProfile({
    required User user,
    String? fallbackUsername,
    String? fallbackEmail,
  }) async {
    final userRef = _firestore.collection('users').doc(user.uid);

    final userDoc = await userRef.get();
    final existingData = userDoc.data();

    await userRef.set({
      'uid': user.uid,

      'username': (existingData?['username'] ??
              user.displayName ??
              fallbackUsername ??
              'User')
          .toString(),

      'email': (existingData?['email'] ?? user.email ?? fallbackEmail ?? '')
          .toString(),

      /// 🔒 ROLE SYSTEM
      'role': (existingData?['role'] ?? 'user').toString(),

      /// 👤 PROFILE DATA
      'phone': existingData?['phone'] ?? '',
      'address': existingData?['address'] ??
          {
            'houseNumber': '',
            'barangay': '',
            'municipalityOrCity': '',
            'province': '',
            'zipCode': '',
          },

      /// ❤️ FAVORITES
      'favoriteProducts': existingData?['favoriteProducts'] is List
          ? List<String>.from(existingData!['favoriteProducts'])
          : <String>[],

      /// 🔐 STATUS CONTROL
      'isActive': existingData?['isActive'] ?? true,
      'accountStatus': (existingData?['accountStatus'] ?? 'active').toString(),

      /// 🕒 TIMESTAMPS
      'createdAt': existingData?['createdAt'] ?? FieldValue.serverTimestamp(),
      'updatedAt': FieldValue.serverTimestamp(),
    }, SetOptions(merge: true));
  }

  /// LOGIN
  @override
  Future<void> signIn({
    required String email,
    required String password,
    required bool asAdmin,
  }) async {
    try {
      final credential = await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );

      final user = credential.user;
      if (user == null) {
        throw Exception('Login failed.');
      }

      await _ensureUserProfile(
        user: user,
        fallbackEmail: email,
      );

      final userDoc = await _firestore.collection('users').doc(user.uid).get();

      if (!userDoc.exists) {
        throw Exception('User profile not found.');
      }

      final data = userDoc.data()!;
      final role = (data['role'] ?? 'user').toString();
      final isActive = (data['isActive'] ?? true) == true;
      final accountStatus = (data['accountStatus'] ?? 'active').toString();

      /// 🔒 ACCOUNT CONTROL
      if (!isActive || accountStatus == 'suspended') {
        await _auth.signOut();
        throw Exception('This account is suspended.');
      }

      /// 🔒 ADMIN CHECK
      if (asAdmin && role != 'admin' && role != 'super_admin') {
        await _auth.signOut();
        throw Exception('Not an admin account.');
      }

      if (!asAdmin && (role == 'admin' || role == 'super_admin')) {
        throw Exception('Use admin login.');
      }
    } on FirebaseAuthException catch (e) {
      throw Exception(_mapAuthError(e));
    }
  }

  /// SIGNUP
  @override
  Future<void> signUp({
    required String username,
    required String email,
    required String password,
  }) async {
    try {
      final credential = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      final user = credential.user;
      if (user == null) {
        throw Exception('Signup failed.');
      }

      await user.updateDisplayName(username);

      await _ensureUserProfile(
        user: user,
        fallbackUsername: username,
        fallbackEmail: email,
      );

      /// 🔥 IMPORTANT: DO NOT AUTO LOGIN
      await _auth.signOut();
    } on FirebaseAuthException catch (e) {
      throw Exception(_mapAuthError(e));
    }
  }

  /// LOGOUT
  @override
  Future<void> signOut() async {
    await _auth.signOut();
  }

  /// ERROR HANDLING
  String _mapAuthError(FirebaseAuthException e) {
    switch (e.code) {
      case 'invalid-email':
        return 'Invalid email.';
      case 'user-disabled':
        return 'Account disabled.';
      case 'user-not-found':
        return 'No user found.';
      case 'wrong-password':
      case 'invalid-credential':
        return 'Incorrect email or password.';
      case 'email-already-in-use':
        return 'Email already used.';
      case 'weak-password':
        return 'Weak password.';
      case 'too-many-requests':
        return 'Too many attempts. Try later.';
      default:
        return e.message ?? 'Auth error.';
    }
  }
}
