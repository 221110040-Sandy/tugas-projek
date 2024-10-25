import 'package:flutter/material.dart';
import 'package:tugas_akhir/services/auth_services.dart';
import 'package:tugas_akhir/screen/settings_screen.dart'; // Impor halaman Settings

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final AuthService _authService = AuthService();
  int _currentIndex = 0;

  // List of widgets for each bottom navigation item
  final List<Widget> _pages = [
    const Center(child: Text('Home Page')),
    const Center(child: Text('Master Data Page')), // Master data page
    const Center(child: Text('Transactions Page')),
    const Center(child: Text('Reports Page')),
    SettingsScreen(), // Utility page replaced with SettingsPage
  ];

  // Handle bottom nav item taps
  void _onItemTapped(int index) {
    setState(() {
      _currentIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(_getAppBarTitle()), // Dynamic app bar title
        actions: [
          IconButton(
            onPressed: () async {
              await _authService.logout();
              Navigator.pushReplacementNamed(context, '/login');
            },
            icon: const Icon(Icons.power_settings_new),
          )
        ],
      ),
      body: _pages[_currentIndex], // Display current page
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex, // Track selected tab
        onTap: _onItemTapped, // Handle tab change
        selectedItemColor: Colors.orangeAccent,
        unselectedItemColor: Colors.grey,
        type: BottomNavigationBarType.fixed, // Show all items
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.home),
            label: 'Home',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.storage),
            label: 'Master',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.swap_horiz),
            label: 'Transactions',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.bar_chart),
            label: 'Reports',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.settings),
            label: 'Utility',
          ),
        ],
      ),
    );
  }

  // Function to set AppBar title based on the selected page
  String _getAppBarTitle() {
    switch (_currentIndex) {
      case 0:
        return 'Home';
      case 1:
        return 'Master Data';
      case 2:
        return 'Transactions';
      case 3:
        return 'Reports';
      case 4:
        return 'Utility';
      default:
        return 'Home';
    }
  }
}
