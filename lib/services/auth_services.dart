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
      await _saveUserToLocal(username);
      return true;
    }

    return false;
  }

  Future<void> _saveUserToLocal(String username) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setString('username', username);
  }

  Future<void> logout() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.remove('username');
  }

  Future<bool> isLoggedIn() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? username = prefs.getString('username');
    return username != null && username.isNotEmpty;
  }
}
