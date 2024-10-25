import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:tugas_akhir/utils.dart';

class AuthService {
  final CollectionReference usersCollection =
      FirebaseFirestore.instance.collection('users');

  Future<bool> login(String username, String password) async {
    String hashedInputPassword = hashPassword(password);

    QuerySnapshot result = await usersCollection
        .where('username', isEqualTo: username)
        .limit(1)
        .get();

    if (result.docs.isEmpty) {
      return false;
    }

    var userData = result.docs.first.data() as Map<String, dynamic>;
    String storedPassword = userData['password'];

    if (hashedInputPassword == storedPassword) {
      String role = userData['role']; // Assume role is stored in Firestore
      await _saveUserToLocal(username, role); // Save role along with username
      return true;
    }

    return false;
  }

  Future<void> _saveUserToLocal(String username, String role) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setString('username', username);
    await prefs.setString('role', role); // Save role locally
  }

  Future<void> logout() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.remove('username');
    await prefs.remove('role'); // Remove role on logout
  }

  Future<bool> isLoggedIn() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? username = prefs.getString('username');
    return username != null && username.isNotEmpty;
  }

  Future<String?> getRole() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.getString('role'); // Retrieve role from local storage
  }

  Future<bool> changePassword(String oldPassword, String newPassword) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? username = prefs.getString('username');

    if (username == null) return false;

    // Mendapatkan data pengguna dari Firestore
    QuerySnapshot result = await usersCollection
        .where('username', isEqualTo: username)
        .limit(1)
        .get();

    if (result.docs.isEmpty) {
      return false;
    }

    var userData = result.docs.first.data() as Map<String, dynamic>;
    String storedPassword = userData['password'];

    // Verifikasi kata sandi lama
    if (hashPassword(oldPassword) == storedPassword) {
      // Update kata sandi baru
      await usersCollection.doc(result.docs.first.id).update({
        'password': hashPassword(newPassword),
      });
      return true;
    }

    return false;
  }
}
