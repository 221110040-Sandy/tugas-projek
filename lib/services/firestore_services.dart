import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:tugas_akhir/utils.dart';
import 'package:tugas_akhir/services/database_helper.dart';
import 'package:firebase_auth/firebase_auth.dart';

class FirestoreService {
  final CollectionReference usersCollection =
      FirebaseFirestore.instance.collection('users');
  final CollectionReference customersCollection =
      FirebaseFirestore.instance.collection('customers');
  final CollectionReference itemsCollection =
      FirebaseFirestore.instance.collection('items');
  final FirebaseAuth _firebaseAuth = FirebaseAuth.instance;
  final DatabaseHelper dbHelper = DatabaseHelper();

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

  Future<void> addSuperAdmin(String username, String password) async {
    String hashedPassword = hashPassword(password);
    try {
      if (await checkSuperAdminExists()) {
        print('Super Admin already exists in Firestore.');
        return;
      }

      DocumentReference docRef = await usersCollection.add({
        'username': username,
        'role': 'super_admin',
        'createdAt': FieldValue.serverTimestamp(),
      });

      try {
        await _firebaseAuth.createUserWithEmailAndPassword(
          email: username,
          password: password,
        );
      } catch (e) {
        print('Pendaftaran gagal. Coba lagi.');
      }

      await dbHelper.insertUser(username, hashedPassword, 'super_admin');
      print('Super Admin $username added successfully.');
    } catch (e) {
      print('Error adding Super Admin: $e');
    }
  }

  Future<void> addUser(String username, String password, String role) async {
    String hashedPassword = hashPassword(password);
    try {
      DocumentReference docRef = await usersCollection.add({
        'username': username,
        'role': role,
        'createdAt': FieldValue.serverTimestamp(),
      });

      try {
        await _firebaseAuth.createUserWithEmailAndPassword(
          email: username,
          password: password,
        );
      } catch (e) {
        print('Pendaftaran gagal. Coba lagi.');
      }

      await dbHelper.insertUser(username, hashedPassword, role);
      print('User $username added successfully.');
    } catch (e) {
      print('Error adding user: $e');
    }
  }

  Future<List<Map<String, dynamic>>> getUsers() async {
    try {
      QuerySnapshot snapshot = await usersCollection.get();
      return snapshot.docs
          .map((doc) => {'id': doc.id, ...doc.data() as Map<String, dynamic>})
          .toList();
    } catch (e) {
      print('Error getting users: $e');
      return [];
    }
  }

  Future<void> updateUserRole(
      String userId, String username, String newRole) async {
    try {
      await usersCollection.doc(userId).update({'role': newRole});
      await dbHelper.updateUserRole(username, newRole);
      print('User role updated to $newRole for user ID: $userId.');
    } catch (e) {
      print('Error updating user role: $e');
    }
  }

  Future<void> deleteUser(String userId, String username) async {
    try {
      await usersCollection.doc(userId).delete();
      await dbHelper.deleteUser(username);
      print('User with ID: $userId deleted successfully.');
    } catch (e) {
      print('Error deleting user: $e');
    }
  }

  Future<void> addItem(
      String kode, String nama, int stokAwal, double harga) async {
    try {
      await itemsCollection.add({
        'kode': kode,
        'nama': nama,
        'stok_awal': stokAwal,
        'harga': harga,
        'createdAt': FieldValue.serverTimestamp(),
      });
      print('Item $nama added successfully.');
    } catch (e) {
      print('Error adding item: $e');
    }
  }

  Future<void> updateItem(
      String itemId, String nama, int stokAwal, double harga) async {
    try {
      await itemsCollection.doc(itemId).update({
        'nama': nama,
        'stok_awal': stokAwal,
        'harga': harga,
      });
      print('Item $nama updated successfully.');
    } catch (e) {
      print('Error updating item: $e');
    }
  }

  Future<List<Map<String, dynamic>>> getItems() async {
    try {
      QuerySnapshot snapshot = await itemsCollection.get();
      return snapshot.docs
          .map((doc) => {'id': doc.id, ...doc.data() as Map<String, dynamic>})
          .toList();
    } catch (e) {
      print('Error getting items: $e');
      return [];
    }
  }

  Future<Map<String, dynamic>?> getLastItem() async {
    try {
      QuerySnapshot snapshot = await itemsCollection
          .orderBy('createdAt', descending: true)
          .limit(1)
          .get();

      if (snapshot.docs.isNotEmpty) {
        return {
          'id': snapshot.docs.first.id,
          ...snapshot.docs.first.data() as Map<String, dynamic>
        };
      } else {
        print('No items found.');
        return null;
      }
    } catch (e) {
      print('Error getting last item: $e');
      return null;
    }
  }

  Future<void> deleteItem(String itemId) async {
    try {
      await itemsCollection.doc(itemId).delete();
      print('Item with ID: $itemId deleted successfully.');
    } catch (e) {
      print('Error deleting item: $e');
    }
  }

  // CRUD untuk Customers
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

  Future<void> deleteCustomer(String customerId) async {
    try {
      await customersCollection.doc(customerId).delete();
      print('Customer with ID: $customerId deleted successfully.');
    } catch (e) {
      print('Error deleting customer: $e');
    }
  }
}
