import 'package:flutter/material.dart';
import 'package:tugas_akhir/services/auth_services.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final AuthService _authService = AuthService();
  int _currentIndex = 0; // Track the current bottom nav index

  // List of widgets for each bottom navigation item
  final List<Widget> _pages = [
    const Center(child: Text('Dashboard Page')),
    const Center(child: Text('Sales Page')),
    const Center(child: Text('Purchases Page')),
    const Center(child: Text('Settings Page')),
  ];

  // Update the current page based on the tapped item
  void _onItemTapped(int index) {
    setState(() {
      _currentIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(_getAppBarTitle()), // Dynamic app bar title based on page
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
      body: _pages[
          _currentIndex], // Show the page corresponding to the selected nav item
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex, // Track selected item
        onTap: _onItemTapped, // Handle bottom nav item taps
        selectedItemColor: Colors.orangeAccent, // Color for selected items
        unselectedItemColor: Colors.grey, // Color for unselected items
        type: BottomNavigationBarType.fixed, // Ensures all items are displayed
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.dashboard),
            label: 'Dashboard',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.shopping_cart),
            label: 'Sales',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.shopping_bag),
            label: 'Purchases',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.settings),
            label: 'Settings',
          ),
        ],
      ),
    );
  }

  // Function to set the AppBar title based on the selected page
  String _getAppBarTitle() {
    switch (_currentIndex) {
      case 0:
        return 'Dashboard';
      case 1:
        return 'Sales';
      case 2:
        return 'Purchases';
      case 3:
        return 'Settings';
      default:
        return 'Home';
    }
  }
}
