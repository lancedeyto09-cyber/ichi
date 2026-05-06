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
    String phone = '',
    String houseNumber = '',
    String barangay = '',
    String municipalityOrCity = '',
    String province = '',
    String zipCode = '',
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
    String? phone,
    String? houseNumber,
    String? barangay,
    String? municipalityOrCity,
    String? province,
    String? zipCode,
  }) async {
    final userRef = _firestore.collection('users').doc(user.uid);

    final userDoc = await userRef.get();
    final existingData = userDoc.data();
    final existingAddress = Map<String, dynamic>.from(
      existingData?['address'] ?? {},
    );

    String pick(String? newValue, dynamic oldValue) {
      final cleaned = (newValue ?? '').trim();
      if (cleaned.isNotEmpty) return cleaned;
      return (oldValue ?? '').toString();
    }

    await userRef.set({
      'uid': user.uid,
      'username': (existingData?['username'] ??
              user.displayName ??
              fallbackUsername ??
              'User')
          .toString(),
      'email': (existingData?['email'] ?? user.email ?? fallbackEmail ?? '')
          .toString(),
      'role': (existingData?['role'] ?? 'user').toString(),
      'phone': pick(phone, existingData?['phone']),
      'address': {
        'houseNumber': pick(houseNumber, existingAddress['houseNumber']),
        'barangay': pick(barangay, existingAddress['barangay']),
        'municipalityOrCity': pick(
          municipalityOrCity,
          existingAddress['municipalityOrCity'],
        ),
        'province': pick(province, existingAddress['province']),
        'zipCode': pick(zipCode, existingAddress['zipCode']),
      },
      'favoriteProducts': existingData?['favoriteProducts'] is List
          ? List<String>.from(existingData!['favoriteProducts'])
          : <String>[],
      'isActive': existingData?['isActive'] ?? true,
      'accountStatus': (existingData?['accountStatus'] ?? 'active').toString(),
      'createdAt': existingData?['createdAt'] ?? FieldValue.serverTimestamp(),
      'updatedAt': FieldValue.serverTimestamp(),
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

      if (!isActive || accountStatus == 'suspended') {
        await _auth.signOut();
        throw Exception('This account is suspended.');
      }

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

  @override
  Future<void> signUp({
    required String username,
    required String email,
    required String password,
    String phone = '',
    String houseNumber = '',
    String barangay = '',
    String municipalityOrCity = '',
    String province = '',
    String zipCode = '',
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
        phone: phone,
        houseNumber: houseNumber,
        barangay: barangay,
        municipalityOrCity: municipalityOrCity,
        province: province,
        zipCode: zipCode,
      );

      await _auth.signOut();
    } on FirebaseAuthException catch (e) {
      throw Exception(_mapAuthError(e));
    }
  }

  @override
  Future<void> signOut() async {
    await _auth.signOut();
  }

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
