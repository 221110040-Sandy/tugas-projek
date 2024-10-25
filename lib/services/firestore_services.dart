import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:tugas_akhir/utils.dart';

class FirestoreService {
  final CollectionReference usersCollection =
      FirebaseFirestore.instance.collection('users');

  // Check if a Super Admin already exists
  Future<bool> checkSuperAdminExists() async {
    QuerySnapshot result = await usersCollection
        .where('role', isEqualTo: 'super_admin')
        .limit(1)
        .get();

    return result.docs.isNotEmpty;
  }

  // Add a new Super Admin
  Future<void> addSuperAdmin(String username, String password) async {
    String hashedPassword = hashPassword(password);
    await usersCollection.add({
      'username': username,
      'password': hashedPassword,
      'role': 'super_admin',
      'createdAt': FieldValue.serverTimestamp(),
    });
  }

  // Add a new user (general function for all roles)
  Future<void> addUser(String username, String password, String role) async {
    String hashedPassword = hashPassword(password);
    await usersCollection.add({
      'username': username,
      'password': hashedPassword,
      'role': role,
      'createdAt': FieldValue.serverTimestamp(),
    });
  }

  // Get all users
  Future<List<Map<String, dynamic>>> getUsers() async {
    QuerySnapshot snapshot = await usersCollection.get();
    return snapshot.docs
        .map((doc) => doc.data() as Map<String, dynamic>)
        .toList();
  }

  // Update user role
  Future<void> updateUserRole(String userId, String newRole) async {
    await usersCollection.doc(userId).update({
      'role': newRole,
    });
  }

  // Delete a user
  Future<void> deleteUser(String userId) async {
    await usersCollection.doc(userId).delete();
  }

  // Additional CRUD operations can be added here if needed
}
