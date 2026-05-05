import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

import 'cloudinary_service.dart';

class UserProfileService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final CloudinaryService _cloudinaryService = CloudinaryService();

  DocumentReference<Map<String, dynamic>> get _userRef {
    final user = _auth.currentUser;
    if (user == null) {
      throw Exception('You must be logged in.');
    }
    return _firestore.collection('users').doc(user.uid);
  }

  Future<Map<String, dynamic>?> getUserProfile() async {
    final doc = await _userRef.get();
    return doc.data();
  }

  Future<String> uploadAvatar(File imageFile) async {
    final avatarUrl = await _cloudinaryService.uploadImage(imageFile);

    await _userRef.set({
      'avatar': avatarUrl,
      'updatedAt': FieldValue.serverTimestamp(),
    }, SetOptions(merge: true));

    return avatarUrl;
  }

  Future<void> updateProfile({
    required String username,
    required String phone,
    required String houseNumber,
    required String barangay,
    required String municipalityOrCity,
    required String province,
    required String zipCode,
  }) async {
    await _userRef.set({
      'username': username,
      'phone': phone,
      'address': {
        'houseNumber': houseNumber,
        'barangay': barangay,
        'municipalityOrCity': municipalityOrCity,
        'province': province,
        'zipCode': zipCode,
      },
      'updatedAt': FieldValue.serverTimestamp(),
    }, SetOptions(merge: true));
  }
}
