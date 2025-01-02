import 'package:flutter/material.dart';
import 'package:tugas_akhir/localization/app_localization.dart';
import 'package:tugas_akhir/theme/colors.dart';

class TransactionScreen extends StatelessWidget {
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
        child: GridView.count(
          crossAxisCount: 2,
          padding: const EdgeInsets.all(16.0),
          children: <Widget>[
            _buildGridItem(
              context,
              loc.translate('sales'),
              Icons.attach_money,
              () {
                Navigator.pushNamed(context, '/sales-transaction');
              },
            ),
            _buildGridItem(
              context,
              loc.translate('buys'),
              Icons.shopping_cart,
              () {
                Navigator.pushNamed(context, '/buys-transaction');
              },
            ),
            _buildGridItem(
              context,
              loc.translate('adjusts'),
              Icons.compare_arrows,
              () {
                Navigator.pushNamed(context, '/adjusts-transaction');
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildGridItem(
      BuildContext context, String title, IconData icon, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Card(
        color: secondaryColor,
        elevation: 4,
        margin: const EdgeInsets.all(8.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              icon,
              size: 50,
              color: primaryColor,
            ),
            const SizedBox(height: 10),
            Text(
              title,
              style: const TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
