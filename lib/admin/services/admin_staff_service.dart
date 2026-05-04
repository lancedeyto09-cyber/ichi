import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/admin_user_model.dart';

class AdminStaffService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  CollectionReference<Map<String, dynamic>> get _adminsRef =>
      _firestore.collection('admins');

  Stream<List<AdminUser>> listenAdmins() {
    return _adminsRef.snapshots().map((snapshot) {
      return snapshot.docs.map((doc) {
        final data = doc.data();

        return AdminUser(
          id: doc.id,
          name: (data['name'] ?? '').toString(),
          email: (data['email'] ?? '').toString(),
          role: (data['role'] ?? 'manager').toString(),
          lastLogin: data['lastLogin'] is Timestamp
              ? (data['lastLogin'] as Timestamp).toDate()
              : DateTime.now(),
          isActive: data['isActive'] == true,
          permissions: List<String>.from(data['permissions'] ?? []),
        );
      }).toList();
    });
  }

  Future<void> addAdmin({
    required String name,
    required String email,
    required String role,
    required List<String> permissions,
  }) async {
    await _adminsRef.add({
      'name': name,
      'email': email,
      'role': role,
      'permissions': permissions,
      'isActive': true,
      'lastLogin': null,
      'createdAt': FieldValue.serverTimestamp(),
      'updatedAt': FieldValue.serverTimestamp(),
    });
  }

  Future<void> removeAdmin(String id) async {
    await _adminsRef.doc(id).delete();
  }
}
