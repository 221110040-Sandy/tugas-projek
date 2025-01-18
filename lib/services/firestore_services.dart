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
  final CollectionReference salesCollection =
      FirebaseFirestore.instance.collection('sales');
  final CollectionReference buysCollection =
      FirebaseFirestore.instance.collection('buys');
  final CollectionReference adjustsCollection =
      FirebaseFirestore.instance.collection('adjusts');
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

  Future<void> addItem(String kode, String nama, int stokAwal, double harga,
      String? imageUrl) async {
    try {
      await itemsCollection.add({
        'kode': kode,
        'nama': nama,
        'stok_awal': stokAwal,
        'harga': harga,
        'imageUrl': imageUrl,
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

  Future<List<Map<String, dynamic>>> getCustomers() async {
    try {
      QuerySnapshot snapshot = await customersCollection.get();
      return snapshot.docs
          .map((doc) => {'id': doc.id, ...doc.data() as Map<String, dynamic>})
          .toList();
    } catch (e) {
      print('Error getting customers: $e');
      return [];
    }
  }

  Future<List<Map<String, dynamic>>> getSales() async {
    try {
      QuerySnapshot snapshot = await salesCollection.get();
      return snapshot.docs
          .map((doc) => {'id': doc.id, ...doc.data() as Map<String, dynamic>})
          .toList();
    } catch (e) {
      print('Error getting sales: $e');
      return [];
    }
  }

  Future<String> generateSaleCode() async {
    try {
      QuerySnapshot snapshot = await salesCollection
          .orderBy('created_at', descending: true)
          .limit(1)
          .get();

      if (snapshot.docs.isNotEmpty) {
        final lastCode = snapshot.docs.first['kode_sale'] as String;
        final lastNumber = int.tryParse(lastCode.split('-').last) ?? 0;
        return 'SALE-${lastNumber + 1}';
      } else {
        return 'SALE-1';
      }
    } catch (e) {
      print('Error generating sale code: $e');
      return 'SALE-1';
    }
  }

  Future<void> saveSale(
    String kodeSale,
    String customerKode,
    String customerName,
    List<Map<String, dynamic>> selectedItems,
    double totalAmount,
  ) async {
    try {
      await salesCollection.add({
        'kode_sale': kodeSale,
        'kode_pelanggan': customerKode,
        'nama_pelanggan': customerName,
        'items': selectedItems,
        'total_amount': totalAmount,
        'created_at': Timestamp.now(),
      });
    } catch (e) {
      print('Error saving sale: $e');
    }
  }

  Future<void> deleteSale(String saleId) async {
    try {
      await FirebaseFirestore.instance.collection('sales').doc(saleId).delete();
    } catch (e) {
      print("Error deleting sale: $e");
      throw e;
    }
  }

  Future<List<Map<String, dynamic>>> getBuys() async {
    try {
      QuerySnapshot snapshot = await buysCollection.get();
      return snapshot.docs
          .map((doc) => {'id': doc.id, ...doc.data() as Map<String, dynamic>})
          .toList();
    } catch (e) {
      print('Error getting buys: $e');
      return [];
    }
  }

  Future<String> generateBuyCode() async {
    try {
      QuerySnapshot snapshot = await buysCollection
          .orderBy('created_at', descending: true)
          .limit(1)
          .get();

      if (snapshot.docs.isNotEmpty) {
        final lastCode = snapshot.docs.first['kode_buy'] as String;
        final lastNumber = int.tryParse(lastCode.split('-').last) ?? 0;
        return 'BUY-${lastNumber + 1}';
      } else {
        return 'BUY-1';
      }
    } catch (e) {
      print('Error generating buy code: $e');
      return 'BUY-1';
    }
  }

  Future<void> saveBuy(
    String kodeBuy,
    List<Map<String, dynamic>> selectedItems,
    double totalAmount,
  ) async {
    try {
      await buysCollection.add({
        'kode_buy': kodeBuy,
        'items': selectedItems,
        'total_amount': totalAmount,
        'created_at': Timestamp.now(),
      });
    } catch (e) {
      print('Error saving buy: $e');
    }
  }

  Future<void> deleteBuy(String buyId) async {
    try {
      await FirebaseFirestore.instance.collection('buys').doc(buyId).delete();
    } catch (e) {
      print("Error deleting buy: $e");
      throw e;
    }
  }

  Future<List<Map<String, dynamic>>> getAdjusts() async {
    try {
      QuerySnapshot snapshot = await adjustsCollection.get();
      return snapshot.docs
          .map((doc) => {'id': doc.id, ...doc.data() as Map<String, dynamic>})
          .toList();
    } catch (e) {
      print('Error getting adjusts: $e');
      return [];
    }
  }

  Future<String> generateAdjustCode() async {
    try {
      QuerySnapshot snapshot = await adjustsCollection
          .orderBy('created_at', descending: true)
          .limit(1)
          .get();

      if (snapshot.docs.isNotEmpty) {
        final lastCode = snapshot.docs.first['kode_adjust'] as String;
        final lastNumber = int.tryParse(lastCode.split('-').last) ?? 0;
        return 'ADJ-${lastNumber + 1}';
      } else {
        return 'ADJ-1';
      }
    } catch (e) {
      print('Error generating adjust code: $e');
      return 'ADJ-1';
    }
  }

  Future<void> saveAdjust(
    String kodeAdjust,
    List<Map<String, dynamic>> selectedItems,
  ) async {
    try {
      await adjustsCollection.add({
        'kode_adjust': kodeAdjust,
        'items': selectedItems,
        'created_at': Timestamp.now(),
      });
    } catch (e) {
      print('Error saving adjust: $e');
    }
  }

  Future<void> deleteAdjust(String adjustId) async {
    try {
      await FirebaseFirestore.instance
          .collection('adjusts')
          .doc(adjustId)
          .delete();
    } catch (e) {
      print("Error deleting adjust: $e");
      throw e;
    }
  }

  Future<Map<String, dynamic>> getStockReport() async {
    try {
      QuerySnapshot itemsSnapshot = await itemsCollection.get();
      List<Map<String, dynamic>> items = itemsSnapshot.docs
          .map((doc) => {'id': doc.id, ...doc.data() as Map<String, dynamic>})
          .toList();

      print('Fetched items: $items');

      Map<String, int> stockLevels = {};

      for (var item in items) {
        String itemId = item['id'] ?? '';
        int initialStock = item['stok_awal'] ?? 0;

        stockLevels[itemId] = initialStock;
      }

      print('Stock levels after initialization: $stockLevels');

      QuerySnapshot buysSnapshot = await buysCollection.get();
      for (var buy in buysSnapshot.docs) {
        var buyData = buy.data() as Map<String, dynamic>;
        var buyItems = buyData['items'] as List<dynamic>;

        for (var buyItem in buyItems) {
          String itemId = buyItem['id'] ?? '';
          int quantity = buyItem['jumlah'] ?? 0;

          if (stockLevels.containsKey(itemId)) {
            stockLevels[itemId] = stockLevels[itemId]! + quantity;
          }
        }
      }

      print('Stock levels after adding buy stock: $stockLevels');

      QuerySnapshot salesSnapshot = await salesCollection.get();
      for (var sale in salesSnapshot.docs) {
        var saleData = sale.data() as Map<String, dynamic>;
        var saleItems = saleData['items'] as List<dynamic>;

        for (var saleItem in saleItems) {
          String itemId = saleItem['id'] ?? '';
          int quantity = saleItem['jumlah'] ?? 0;
          if (stockLevels.containsKey(itemId)) {
            stockLevels[itemId] = stockLevels[itemId]! - quantity;
          }
        }
      }

      print('Stock levels after subtracting sale stock: $stockLevels');

      QuerySnapshot adjustsSnapshot = await adjustsCollection.get();
      for (var adjust in adjustsSnapshot.docs) {
        var adjustData = adjust.data() as Map<String, dynamic>;
        var adjustItems = adjustData['items'] as List<dynamic>;

        for (var adjustItem in adjustItems) {
          String itemId = adjustItem['id'] ?? '';
          int quantity = adjustItem['jumlah'] ?? 0;

          if (stockLevels.containsKey(itemId)) {
            stockLevels[itemId] = stockLevels[itemId]! + quantity;
          }
        }
      }

      print('Stock levels after adjustments: $stockLevels');

      return stockLevels;
    } catch (e) {
      print('Error generating stock report: $e');
      return {};
    }
  }

  Future<List<Map<String, dynamic>>> getPenjualan(
      DateTime? startDate, DateTime? endDate) async {
    QuerySnapshot snapshot = await FirebaseFirestore.instance
        .collection('sales')
        .where('created_at', isGreaterThanOrEqualTo: startDate)
        .where('created_at', isLessThanOrEqualTo: endDate)
        .get();

    return snapshot.docs
        .map((doc) => doc.data() as Map<String, dynamic>)
        .toList();
  }

  Future<List<Map<String, dynamic>>> getPembelian(
      DateTime? startDate, DateTime? endDate) async {
    QuerySnapshot snapshot = await FirebaseFirestore.instance
        .collection('buys')
        .where('created_at', isGreaterThanOrEqualTo: startDate)
        .where('created_at', isLessThanOrEqualTo: endDate)
        .get();

    return snapshot.docs
        .map((doc) => doc.data() as Map<String, dynamic>)
        .toList();
  }
}
