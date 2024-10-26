import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:tugas_akhir/utils.dart';
import 'package:tugas_akhir/services/database_helper.dart';

class AuthService {
  final CollectionReference usersCollection =
      FirebaseFirestore.instance.collection('users');

  Future<bool> login(String username, String password) async {
    String hashedInputPassword = hashPassword(password);

    QuerySnapshot result = await usersCollection
        .where('username', isEqualTo: username)
        .limit(1)
        .get();

    if (result.docs.isNotEmpty) {
      var userData = result.docs.first.data() as Map<String, dynamic>;
      String storedPassword = userData['password'];

      if (hashedInputPassword == storedPassword) {
        String role = userData['role'];
        await _saveUserToLocal(username, role);
        return true;
      }
    }

    DatabaseHelper dbHelper = DatabaseHelper();
    String? role = await dbHelper.login(username, password);
    if (role != null) {
      await _saveUserToLocal(username, role);
      return true;
    }

    return false;
  }

  Future<void> _saveUserToLocal(String username, String role) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setString('username', username);
    await prefs.setString('role', role);
  }

  Future<void> logout() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.remove('username');
    await prefs.remove('role');
  }

  Future<bool> isLoggedIn() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? username = prefs.getString('username');
    return username != null && username.isNotEmpty;
  }

  Future<String?> getRole() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.getString('role');
  }

  Future<bool> changePassword(String oldPassword, String newPassword) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? username = prefs.getString('username');

    if (username == null) return false;

    QuerySnapshot result = await usersCollection
        .where('username', isEqualTo: username)
        .limit(1)
        .get();

    if (result.docs.isEmpty) {
      return false;
    }

    var userData = result.docs.first.data() as Map<String, dynamic>;
    String storedPassword = userData['password'];

    if (hashPassword(oldPassword) == storedPassword) {
      await usersCollection.doc(result.docs.first.id).update({
        'password': hashPassword(newPassword),
      });

      DatabaseHelper dbHelper = DatabaseHelper();
      await dbHelper.updateUserPassword(username, newPassword);
      return true;
    }

    return false;
  }
}
