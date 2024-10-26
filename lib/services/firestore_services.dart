import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:tugas_akhir/utils.dart';
import 'package:tugas_akhir/services/database_helper.dart';

class FirestoreService {
  final CollectionReference usersCollection =
      FirebaseFirestore.instance.collection('users');
  final CollectionReference customersCollection =
      FirebaseFirestore.instance.collection('customers');
  final DatabaseHelper dbHelper = DatabaseHelper();

  /// Checks if a Super Admin already exists in Firestore.
  Future<bool> checkSuperAdminExists() async {
    try {
      QuerySnapshot result = await usersCollection
          .where('role', isEqualTo: 'super_admin')
          .limit(1)
          .get();
      return result.docs.isNotEmpty;
    } catch (e) {
      print('Error checking Super Admin existence: $e');
      return false;
    }
  }

  /// Adds a new Super Admin to Firestore and SQLite.
  Future<void> addSuperAdmin(String username, String password) async {
    String hashedPassword = hashPassword(password);
    try {
      // Check if Super Admin already exists
      if (await checkSuperAdminExists()) {
        print('Super Admin already exists in Firestore.');
        return;
      }

      DocumentReference docRef = await usersCollection.add({
        'username': username,
        'password': hashedPassword,
        'role': 'super_admin',
        'createdAt': FieldValue.serverTimestamp(),
      });
      // Save to SQLite
      await dbHelper.insertUser(username, hashedPassword, 'super_admin');
      print('Super Admin $username added successfully.');
    } catch (e) {
      print('Error adding Super Admin: $e');
    }
  }

  /// Adds a new user (general function for all roles).
  Future<void> addUser(String username, String password, String role) async {
    String hashedPassword = hashPassword(password);
    try {
      DocumentReference docRef = await usersCollection.add({
        'username': username,
        'password': hashedPassword,
        'role': role,
        'createdAt': FieldValue.serverTimestamp(),
      });
      // Save to SQLite
      await dbHelper.insertUser(username, hashedPassword, role);
      print('User $username added successfully.');
    } catch (e) {
      print('Error adding user: $e');
    }
  }

  /// Retrieves all users from Firestore.
  Future<List<Map<String, dynamic>>> getUsers() async {
    try {
      QuerySnapshot snapshot = await usersCollection.get();
      return snapshot.docs
          .map((doc) => {
                'id': doc.id, // Include the Firestore document ID
                ...doc.data() as Map<String, dynamic>
              })
          .toList();
    } catch (e) {
      print('Error getting users: $e');
      return [];
    }
  }

  /// Updates the role of a user in Firestore and SQLite.
  Future<void> updateUserRole(
      String userId, String username, String newRole) async {
    try {
      await usersCollection.doc(userId).update({'role': newRole});
      // Update SQLite
      await dbHelper.updateUserRole(username, newRole);
      print('User role updated to $newRole for user ID: $userId.');
    } catch (e) {
      print('Error updating user role: $e');
    }
  }

  /// Deletes a user from Firestore and SQLite.
  Future<void> deleteUser(String userId, String username) async {
    try {
      await usersCollection.doc(userId).delete();
      // Delete from SQLite using username instead of userId
      await dbHelper.deleteUser(
          username); // Pastikan Anda menggunakan username jika perlu
      print('User with ID: $userId deleted successfully.');
    } catch (e) {
      print('Error deleting user: $e');
    }
  }

  /// Menambahkan pelanggan baru ke Firestore.
  Future<void> addCustomer(
      String kode, String nama, String alamat, String noHp) async {
    try {
      await customersCollection.add({
        'kode': kode,
        'nama': nama,
        'alamat': alamat,
        'no_hp': noHp,
        'createdAt': FieldValue.serverTimestamp(),
      });
      print('Customer $nama added successfully.');
    } catch (e) {
      print('Error adding customer: $e');
    }
  }

  /// Memperbarui informasi pelanggan.
  Future<void> updateCustomer(String customerId, String kode, String nama,
      String alamat, String noHp) async {
    try {
      await customersCollection.doc(customerId).update({
        'kode': kode,
        'nama': nama,
        'alamat': alamat,
        'no_hp': noHp,
      });
      print('Customer $nama updated successfully.');
    } catch (e) {
      print('Error updating customer: $e');
    }
  }

  /// Menghapus pelanggan dari Firestore.
  Future<void> deleteCustomer(String customerId) async {
    try {
      await customersCollection.doc(customerId).delete();
      print('Customer with ID: $customerId deleted successfully.');
    } catch (e) {
      print('Error deleting customer: $e');
    }
  }
  // Additional CRUD operations can be added here if needed.
}
