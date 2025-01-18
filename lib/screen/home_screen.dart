import 'package:flutter/material.dart';
import 'package:tugas_akhir/localization/app_localization.dart';
import 'package:tugas_akhir/screen/dashboard_screen.dart';
import 'package:tugas_akhir/screen/master_screen.dart';
import 'package:tugas_akhir/screen/report_screen.dart';
import 'package:tugas_akhir/screen/transaction_screen.dart';
import 'package:tugas_akhir/services/auth_services.dart';
import 'package:tugas_akhir/screen/settings_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final AuthService _authService = AuthService();
  int _currentIndex = 0;

  final List<Widget> _pages = [
    DashboardScreen(),
    MasterScreen(),
    TransactionScreen(),
    ReportScreen(),
    SettingsScreen(),
  ];

  void _onItemTapped(int index) {
    setState(() {
      _currentIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    final loc = AppLocalization.of(context);
    return Scaffold(
      appBar: AppBar(
        title: Text(_getAppBarTitle(loc)),
      ),
      body: _pages[_currentIndex],
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: _onItemTapped,
        selectedItemColor: Colors.orangeAccent,
        unselectedItemColor: Colors.grey,
        type: BottomNavigationBarType.fixed,
        items: [
          BottomNavigationBarItem(
            icon: Icon(Icons.home),
            label: loc.translate('home'),
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.storage),
            label: loc.translate('master'),
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.swap_horiz),
            label: loc.translate('transaction'),
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.bar_chart),
            label: loc.translate('report'),
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.settings),
            label: loc.translate('settings'),
          ),
        ],
      ),
    );
  }

  String _getAppBarTitle(loc) {
    switch (_currentIndex) {
      case 0:
        return loc.translate('home');
      case 1:
        return loc.translate('master');
      case 2:
        return loc.translate('transaction');
      case 3:
        return loc.translate('report');
      case 4:
        return loc.translate('settings');
      default:
        return 'Home';
    }
  }
}
