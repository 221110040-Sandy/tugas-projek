import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:tugas_akhir/utils.dart';
import 'package:tugas_akhir/services/database_helper.dart';

class AuthService {
  final FirebaseAuth _firebaseAuth = FirebaseAuth.instance;
  final CollectionReference usersCollection =
      FirebaseFirestore.instance.collection('users');

  // Fungsi login menggunakan Firebase Authentication
  Future<bool> login(String username, String password) async {
    try {
      // Login ke Firebase Authentication menggunakan email (konversi username ke email)
      UserCredential userCredential =
          await _firebaseAuth.signInWithEmailAndPassword(
        email: username, // Sesuaikan ke format email dari username
        password: password,
      );
      // Ambil data tambahan dari Firestore
      QuerySnapshot result = await usersCollection
          .where('username', isEqualTo: userCredential.user!.email)
          .limit(1)
          .get();
      // DocumentSnapshot userData =
      //     await usersCollection.doc(userCredential.user!.uid).get();

      if (result.docs.isNotEmpty) {
        var userData = result.docs.first.data() as Map<String, dynamic>;
        String role = userData['role'];
        await _saveUserToLocal(username, role);
        return true;
      }
    } catch (e) {
      print("Login error: $e");
    }

    // Jika login Firebase gagal, cek login melalui SQLite

    DatabaseHelper dbHelper = DatabaseHelper();
    String? role = await dbHelper.login(username, password);
    if (role != null) {
      await _saveUserToLocal(username, role);
      return true;
    }

    return false;
  }

  // Fungsi untuk menyimpan data user ke SharedPreferences
  Future<void> _saveUserToLocal(String username, String role) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setString('username', username);
    await prefs.setString('role', role);
  }

  // Fungsi logout
  Future<void> logout() async {
    // Logout dari Firebase Authentication
    await _firebaseAuth.signOut();

    // Hapus data dari SharedPreferences
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.remove('username');
    await prefs.remove('role');
  }

  // Fungsi untuk memeriksa apakah user sudah login
  Future<bool> isLoggedIn() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? username = prefs.getString('username');
    return username != null && username.isNotEmpty;
  }

  // Fungsi untuk mendapatkan role user
  Future<String?> getRole() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.getString('role');
  }

  // Fungsi untuk mengubah password, Firebase Authentication akan menangani hashing-nya
  Future<bool> changePassword(String oldPassword, String newPassword) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? username = prefs.getString('username');

    if (username == null) return false;

    // Verifikasi dengan Firebase Auth
    try {
      // Re-authenticate user sebelum mengubah password
      User user = _firebaseAuth.currentUser!;
      AuthCredential credential = EmailAuthProvider.credential(
        email:
            "$username@example.com", // Konversi username ke email jika diperlukan
        password: oldPassword,
      );
      await user.reauthenticateWithCredential(credential);

      // Ubah password
      await user.updatePassword(newPassword);

      // Update juga di SQLite (jika diimplementasikan)
      DatabaseHelper dbHelper = DatabaseHelper();
      await dbHelper.updateUserPassword(username, newPassword);

      return true;
    } catch (e) {
      print("Change password error: $e");
      return false;
    }
  }
}
