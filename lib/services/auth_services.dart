import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:tugas_akhir/utils.dart';
import 'package:tugas_akhir/services/database_helper.dart';

class AuthService {
  final CollectionReference usersCollection =
      FirebaseFirestore.instance.collection('users');

  /// Login method to authenticate the user.
  Future<bool> login(String username, String password) async {
    String hashedInputPassword = hashPassword(password);

    // Try logging into Firebase first
    QuerySnapshot result = await usersCollection
        .where('username', isEqualTo: username)
        .limit(1)
        .get();

    if (result.docs.isNotEmpty) {
      var userData = result.docs.first.data() as Map<String, dynamic>;
      String storedPassword = userData['password'];

      // Compare the hashed input password with the stored password
      if (hashedInputPassword == storedPassword) {
        String role = userData['role'];
        await _saveUserToLocal(username, role);
        return true;
      }
    }

    // If login to Firebase fails, try logging into SQLite
    DatabaseHelper dbHelper = DatabaseHelper();
    String? role = await dbHelper.login(username, password);
    if (role != null) {
      await _saveUserToLocal(username, role);
      return true;
    }

    return false; // Login failed
  }

  /// Save the user's credentials locally.
  Future<void> _saveUserToLocal(String username, String role) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setString('username', username);
    await prefs.setString('role', role);
  }

  /// Logout the user by removing local credentials.
  Future<void> logout() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.remove('username');
    await prefs.remove('role');
  }

  /// Check if the user is logged in by verifying local credentials.
  Future<bool> isLoggedIn() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? username = prefs.getString('username');
    return username != null && username.isNotEmpty;
  }

  /// Retrieve the user's role from local storage.
  Future<String?> getRole() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.getString('role');
  }

  /// Change the user's password.
  Future<bool> changePassword(String oldPassword, String newPassword) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? username = prefs.getString('username');

    if (username == null) return false; // No user logged in

    // Get user data from Firestore
    QuerySnapshot result = await usersCollection
        .where('username', isEqualTo: username)
        .limit(1)
        .get();

    if (result.docs.isEmpty) {
      return false; // User does not exist
    }

    var userData = result.docs.first.data() as Map<String, dynamic>;
    String storedPassword = userData['password'];

    // Verify the old password
    if (hashPassword(oldPassword) == storedPassword) {
      // Update the new password in Firestore
      await usersCollection.doc(result.docs.first.id).update({
        'password': hashPassword(newPassword),
      });

      // Also update the new password in SQLite
      DatabaseHelper dbHelper = DatabaseHelper();
      await dbHelper.updateUserPassword(username, newPassword);
      return true; // Password changed successfully
    }

    return false; // Old password verification failed
  }
}
