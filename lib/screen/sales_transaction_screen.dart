import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:tugas_akhir/services/firestore_services.dart';
import 'package:intl/intl.dart';
import 'package:tugas_akhir/theme/colors.dart';

class SalesTransactionScreen extends StatefulWidget {
  @override
  _SalesTransactionScreenState createState() => _SalesTransactionScreenState();
}

class _SalesTransactionScreenState extends State<SalesTransactionScreen> {
  final FirestoreService firestoreService = FirestoreService();
  final TextEditingController searchController = TextEditingController();
  List<Map<String, dynamic>> sales = [];
  List<Map<String, dynamic>> filteredSales = [];

  @override
  void initState() {
    super.initState();
    firestoreService.getSales().then((data) {
      setState(() {
        sales = data;
        filteredSales = sales;
      });
    });
  }

  void _filterSales(String query) {
    setState(() {
      filteredSales = sales.where((sale) {
        final saleData = sale;
        final customerName = saleData['nama_pelanggan']?.toLowerCase() ?? '';
        final saleCode = saleData['kode_sale']?.toLowerCase() ?? '';
        return customerName.contains(query.toLowerCase()) ||
            saleCode.contains(query.toLowerCase());
      }).toList();
    });
  }

  Future<void> _deleteSale(String saleId) async {
    final confirmation = await showDialog<bool>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Hapus Transaksi'),
          content: const Text('Yakin ingin menghapus transaksi ini?'),
          actions: [
            TextButton(
              child: const Text('Batal'),
              onPressed: () => Navigator.of(context).pop(false),
            ),
            TextButton(
              child: const Text('Hapus'),
              onPressed: () => Navigator.of(context).pop(true),
            ),
          ],
        );
      },
    );

    if (confirmation == true) {
      try {
        await firestoreService.deleteSale(saleId);
        setState(() {
          sales.removeWhere((sale) => sale['id'] == saleId);
          filteredSales = List.from(sales);
        });
      } catch (e) {
        print("Error deleting sale: $e");
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Sales Transactions'),
        backgroundColor: secondaryColor,
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: () {
              Navigator.pushNamed(context, '/add-sales');
            },
          ),
        ],
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: TextField(
              controller: searchController,
              decoration: const InputDecoration(
                labelText: 'Search Transaction',
                border: OutlineInputBorder(),
                suffixIcon: Icon(Icons.search),
              ),
              onChanged: _filterSales,
            ),
          ),
          Expanded(
            child: ListView.builder(
              itemCount: filteredSales.length,
              itemBuilder: (context, index) {
                final sale = filteredSales[index];
                final customerName = sale['nama_pelanggan'] ?? 'Unknown';
                final totalAmount = sale['total_amount'] ?? 0.0;
                final createdAt = (sale['created_at'] as Timestamp?)?.toDate();
                final formattedDate = createdAt != null
                    ? DateFormat('yyyy-MM-dd HH:mm').format(createdAt)
                    : 'Unknown Date';
                final saleId = sale['id'];

                return Dismissible(
                  key: Key(saleId),
                  direction: DismissDirection.endToStart,
                  onDismissed: (direction) async {
                    await _deleteSale(saleId);
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('Sale deleted')),
                    );
                  },
                  background: Container(
                    color: Colors.red,
                    alignment: Alignment.centerRight,
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: const Icon(Icons.delete, color: Colors.white),
                  ),
                  child: ListTile(
                    title: Text('Sale: ${sale['kode_sale'] ?? 'Unknown'}'),
                    subtitle: Text(
                      'Customer: $customerName\n'
                      'Date: $formattedDate\n'
                      'Total: \$${totalAmount.toStringAsFixed(2)}',
                    ),
                    isThreeLine: true,
                    trailing: IconButton(
                      icon: const Icon(Icons.delete),
                      onPressed: () {
                        _deleteSale(saleId);
                      },
                      color: Colors.redAccent,
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
