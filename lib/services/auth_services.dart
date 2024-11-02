import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:tugas_akhir/utils.dart';
import 'package:tugas_akhir/services/database_helper.dart';

class AuthService {
  final FirebaseAuth _firebaseAuth = FirebaseAuth.instance;
  final CollectionReference usersCollection =
      FirebaseFirestore.instance.collection('users');

  Future<bool> login(String username, String password) async {
    try {
      UserCredential userCredential =
          await _firebaseAuth.signInWithEmailAndPassword(
        email: username,
        password: password,
      );
      QuerySnapshot result = await usersCollection
          .where('username', isEqualTo: userCredential.user!.email)
          .limit(1)
          .get();

      if (result.docs.isNotEmpty) {
        var userData = result.docs.first.data() as Map<String, dynamic>;
        String role = userData['role'];
        await _saveUserToLocal(username, role);
        return true;
      }
    } catch (e) {
      print("Login error: $e");
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

  // Fungsi logout
  Future<void> logout() async {
    await _firebaseAuth.signOut();

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

    try {
      User user = _firebaseAuth.currentUser!;
      AuthCredential credential = EmailAuthProvider.credential(
        email: username,
        password: oldPassword,
      );
      print(1);
      await user.reauthenticateWithCredential(credential);
      print(2);

      await user.updatePassword(newPassword);

      DatabaseHelper dbHelper = DatabaseHelper();
      await dbHelper.updateUserPassword(username, newPassword);

      return true;
    } catch (e) {
      print("Change password error: $e");
      return false;
    }
  }
}
