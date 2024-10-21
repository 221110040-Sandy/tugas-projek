import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:tugas_akhir/utils.dart';

class FirestoreService {
  final CollectionReference usersCollection =
      FirebaseFirestore.instance.collection('users');

  Future<bool> checkSuperAdminExists() async {
    QuerySnapshot result = await usersCollection
        .where('role', isEqualTo: 'super_admin')
        .limit(1)
        .get();

    return result.docs.isNotEmpty;
  }

  Future<void> addSuperAdmin(String username, String password) async {
    String hashedPassword = hashPassword(password);
    await usersCollection.add({
      'username': username,
      'password': hashedPassword,
      'role': 'super_admin',
      'createdAt': FieldValue.serverTimestamp(),
    });
  }
}
