import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:tugas_akhir/localization/app_localization.dart';
import 'package:tugas_akhir/main.dart';
import 'package:tugas_akhir/screen/change_password_screen.dart';
import 'package:tugas_akhir/screen/profile_screen.dart';
import 'package:tugas_akhir/screen/user_list_screen.dart';
import 'package:tugas_akhir/theme/colors.dart';

class SettingsScreen extends StatefulWidget {
  @override
  _SettingsScreenState createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  String? _role;
  String? _username;
  String _currentLanguage = 'en';

  @override
  void initState() {
    super.initState();
    _loadUserData();
    _loadLanguagePreference();
  }

  Future<void> _loadUserData() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      _role = prefs.getString('role');
      _username = prefs.getString('username');
    });
  }

  Future<void> _loadLanguagePreference() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      _currentLanguage = prefs.getString('language') ?? 'en';
    });
  }

  Future<void> _changeLanguage(String languageCode) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setString('language', languageCode);

    setState(() {
      _currentLanguage = languageCode;
    });

    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
          builder: (context) => MyApp(
              username: _username,
              role: _role,
              languageCode: _currentLanguage)),
    );
  }

  @override
  Widget build(BuildContext context) {
    final loc = AppLocalization.of(context);

    return Scaffold(
      body: Container(
        padding: const EdgeInsets.all(16.0),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              secondaryColor.withOpacity(0.7),
              accentColor.withOpacity(0.7),
            ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: Column(
          children: [
            const SizedBox(height: 20),
            Text(
              loc
                  .translate('hello_user')
                  .replaceAll('{username}', _username ?? ''),
              style: const TextStyle(
                fontSize: 28,
                fontWeight: FontWeight.bold,
                color: Colors.black,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 30),
            Card(
              color: Colors.white,
              elevation: 5,
              margin: const EdgeInsets.symmetric(vertical: 10),
              child: ListTile(
                leading: const Icon(Icons.language, color: Colors.blue),
                title: Text(
                  loc.translate('language'),
                  style: const TextStyle(
                      fontSize: 18, fontWeight: FontWeight.w600),
                ),
                trailing: DropdownButton<String>(
                  value: _currentLanguage,
                  items: const [
                    DropdownMenuItem(value: 'en', child: Text('English')),
                    DropdownMenuItem(value: 'id', child: Text('Indonesia')),
                  ],
                  onChanged: (value) {
                    if (value != null) {
                      _changeLanguage(value);
                    }
                  },
                ),
              ),
            ),
            const SizedBox(height: 20),
            _buildListTile(
              title: loc.translate('profile'),
              icon: Icons.person,
              onTap: () {
                Navigator.pushNamed(context, '/profile');
              },
            ),
            _buildListTile(
              title: loc.translate('change_password'),
              icon: Icons.lock,
              onTap: () {
                Navigator.pushNamed(context, '/change-password');
              },
            ),
            if (_role == 'super_admin')
              _buildListTile(
                title: loc.translate('user_list'),
                icon: Icons.list,
                onTap: () {
                  Navigator.pushNamed(context, '/user-list');
                },
              ),
            const SizedBox(height: 20),
            _buildListTile(
              title: loc.translate('logout'),
              icon: Icons.logout,
              onTap: () async {
                SharedPreferences prefs = await SharedPreferences.getInstance();
                await prefs.remove('username');
                await prefs.remove('role');
                Navigator.pushReplacementNamed(context, '/login');
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildListTile({
    required String title,
    required IconData icon,
    required VoidCallback onTap,
  }) {
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 10),
      color: Colors.white,
      elevation: 5,
      child: ListTile(
        leading: Icon(icon, color: primaryColor),
        title: Text(
          title,
          style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
        ),
        onTap: onTap,
        trailing: const Icon(Icons.arrow_forward_ios, color: Colors.black),
      ),
    );
  }
}
