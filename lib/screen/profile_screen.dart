import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:flutter/material.dart';

class ProfileScreen extends StatelessWidget {
  final String username;
  final String role;

  const ProfileScreen({Key? key, required this.username, required this.role})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Profile'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Username: $username', // Menampilkan username
              style: const TextStyle(fontSize: 20),
            ),
            const SizedBox(height: 8),
            Text(
              'Role: $role', // Menampilkan role
              style: const TextStyle(fontSize: 20),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                // Tambahkan tindakan untuk mengedit profil jika perlu
              },
              child: const Text('Edit Profile'),
            ),
          ],
        ),
      ),
    );
  }
}
