import 'package:flutter/material.dart';
import 'package:tugas_akhir/theme/colors.dart';

class MasterScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Master'),
      ),
      body: GridView.count(
        crossAxisCount: 2, // Jumlah kolom dalam GridView
        padding: const EdgeInsets.all(16.0),
        children: <Widget>[
          _buildGridItem(
            context,
            'Master Barang',
            Icons.shopping_cart,
            () {
              // Navigasi ke halaman Master Barang
              Navigator.pushNamed(context, '/master-items');
            },
          ),
          _buildGridItem(
            context,
            'Pelanggan',
            Icons.people,
            () {
              // Navigasi ke halaman Pelanggan
              Navigator.pushNamed(context, '/customers');
            },
          ),
        ],
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
