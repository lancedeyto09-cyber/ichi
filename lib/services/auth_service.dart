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
              '')
          .toString(),
      'email': (existingData?['email'] ?? user.email ?? fallbackEmail ?? '')
          .toString(),
      'role': (existingData?['role'] ?? 'user').toString(),
      'createdAt': existingData?['createdAt'] ?? FieldValue.serverTimestamp(),
      'updatedAt': FieldValue.serverTimestamp(),
      'isActive': existingData?['isActive'] ?? true,
      'accountStatus': (existingData?['accountStatus'] ?? 'active').toString(),
      'favoriteProducts': existingData?['favoriteProducts'] is List
          ? List<String>.from(existingData!['favoriteProducts'])
          : <String>[],
    }, SetOptions(merge: true));
  }

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
        throw Exception('Login failed. Please try again.');
      }

      await _ensureUserProfile(
        user: user,
        fallbackEmail: email,
      );

      final userDoc = await _firestore.collection('users').doc(user.uid).get();

      if (!userDoc.exists) {
        throw Exception('User profile not found in database.');
      }

      final data = userDoc.data()!;
      final role = (data['role'] ?? 'user').toString();
      final isActive = (data['isActive'] ?? true) == true;
      final accountStatus = (data['accountStatus'] ?? 'active').toString();

      if (!isActive || accountStatus == 'suspended') {
        await _auth.signOut();
        throw Exception('This account has been suspended.');
      }

      if (asAdmin && role != 'admin' && role != 'super_admin') {
        await _auth.signOut();
        throw Exception('This account is not an admin account.');
      }

      if (!asAdmin && (role == 'admin' || role == 'super_admin')) {
        throw Exception('Please use the admin login page for this account.');
      }
    } on FirebaseAuthException catch (e) {
      throw Exception(_mapAuthError(e));
    } catch (e) {
      rethrow;
    }
  }

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
        throw Exception('Signup failed. Please try again.');
      }

      await user.updateDisplayName(username);

      await _ensureUserProfile(
        user: user,
        fallbackUsername: username,
        fallbackEmail: email,
      );
    } on FirebaseAuthException catch (e) {
      throw Exception(_mapAuthError(e));
    } catch (e) {
      rethrow;
    }
  }

  @override
  Future<void> signOut() async {
    await _auth.signOut();
  }

  String _mapAuthError(FirebaseAuthException e) {
    switch (e.code) {
      case 'invalid-email':
        return 'Invalid email address.';
      case 'user-disabled':
        return 'This account has been disabled.';
      case 'user-not-found':
        return 'No user found for that email.';
      case 'wrong-password':
      case 'invalid-credential':
        return 'Incorrect email or password.';
      case 'email-already-in-use':
        return 'That email is already registered.';
      case 'weak-password':
        return 'Password must be at least 6 characters.';
      case 'too-many-requests':
        return 'Too many attempts. Please try again later.';
      default:
        return e.message ?? 'Authentication failed.';
    }
  }
}
