import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:tugas_akhir/localization/app_localization.dart';
import 'package:tugas_akhir/services/firestore_services.dart';
import 'package:intl/intl.dart';
import 'package:tugas_akhir/theme/colors.dart';

class BuysTransactionScreen extends StatefulWidget {
  @override
  _BuysTransactionScreenState createState() => _BuysTransactionScreenState();
}

class _BuysTransactionScreenState extends State<BuysTransactionScreen> {
  final FirestoreService firestoreService = FirestoreService();
  final TextEditingController searchController = TextEditingController();
  List<Map<String, dynamic>> buys = [];
  List<Map<String, dynamic>> filteredBuys = [];

  @override
  void initState() {
    super.initState();
    firestoreService.getBuys().then((data) {
      setState(() {
        buys = data;
        filteredBuys = buys;
      });
    });
  }

  void _filterBuys(String query) {
    setState(() {
      filteredBuys = buys.where((buy) {
        final buyData = buy;
        final buyCode = buyData['kode_buy']?.toLowerCase() ?? '';
        return buyCode.contains(query.toLowerCase());
      }).toList();
    });
  }

  Future<void> _deleteBuy(String buyId) async {
    final loc = AppLocalization.of(context);
    final confirmation = await showDialog<bool>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text(loc.translate('delete')),
          content: Text(loc.translate('delete_confirmation')),
          actions: [
            TextButton(
              child: Text(loc.translate('cancel')),
              onPressed: () => Navigator.of(context).pop(false),
            ),
            TextButton(
              child: Text(loc.translate('delete')),
              onPressed: () => Navigator.of(context).pop(true),
            ),
          ],
        );
      },
    );

    if (confirmation == true) {
      try {
        await firestoreService.deleteBuy(buyId);
        setState(() {
          buys.removeWhere((buy) => buy['id'] == buyId);
          filteredBuys = List.from(buys);
        });
      } catch (e) {
        print("Error deleting buy: $e");
      }
    }
  }

  void _showBuyDetails(Map<String, dynamic> buy) {
    final loc = AppLocalization.of(context);
    showDialog(
      context: context,
      builder: (context) {
        final createdAt = (buy['created_at'] as Timestamp?)?.toDate();
        final formattedDate = createdAt != null
            ? DateFormat('yyyy-MM-dd HH:mm').format(createdAt)
            : loc.translate('unknown_date');

        return AlertDialog(
          title: Text(
            'Detail: ${buy['kode_buy'] ?? loc.translate('unknown')}',
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
          content: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text('${loc.translate('date')}: $formattedDate'),
                Text(
                    '${loc.translate('total')}: \$${buy['total_amount']?.toStringAsFixed(2) ?? '0.00'}'),
                const SizedBox(height: 16),
                Text(
                  '${loc.translate('items')}:',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                ...((buy['items'] as List<dynamic>? ?? []).map((item) {
                  final itemName = item['nama'] ?? loc.translate('unknown');
                  final itemQuantity = item['jumlah'] ?? 0;
                  final itemPrice = item['harga'] ?? 0.0;
                  final totalItemPrice = itemPrice * itemQuantity;

                  return Padding(
                    padding: const EdgeInsets.symmetric(vertical: 4.0),
                    child: Text(
                      '- $itemName: $itemQuantity pcs x \$${itemPrice.toStringAsFixed(2)} = \$${totalItemPrice.toStringAsFixed(2)}',
                    ),
                  );
                }).toList()),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text(loc.translate('close')),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final loc = AppLocalization.of(context);
    return Scaffold(
      appBar: AppBar(
        title: Text(loc.translate('buys')),
        backgroundColor: secondaryColor,
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: () {
              Navigator.pushNamed(context, '/add-buys');
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
              decoration: InputDecoration(
                labelText:
                    '${loc.translate('search')} ${loc.translate('transaction')}',
                border: const OutlineInputBorder(),
                suffixIcon: const Icon(Icons.search),
              ),
              onChanged: _filterBuys,
            ),
          ),
          Expanded(
            child: ListView.builder(
              itemCount: filteredBuys.length,
              itemBuilder: (context, index) {
                final buy = filteredBuys[index];
                final totalAmount = buy['total_amount'] ?? 0.0;
                final createdAt = (buy['created_at'] as Timestamp?)?.toDate();
                final formattedDate = createdAt != null
                    ? DateFormat('yyyy-MM-dd HH:mm').format(createdAt)
                    : loc.translate('unknown_date');
                final buyId = buy['id'];

                return Dismissible(
                  key: Key(buyId),
                  direction: DismissDirection.endToStart,
                  onDismissed: (direction) async {
                    await _deleteBuy(buyId);
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text(loc.translate('buy_deleted'))),
                    );
                  },
                  background: Container(
                    color: Colors.red,
                    alignment: Alignment.centerRight,
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: const Icon(Icons.delete, color: Colors.white),
                  ),
                  child: ListTile(
                    title: Text(
                        '${loc.translate('code')}: ${buy['kode_buy'] ?? loc.translate('unknown')}'),
                    subtitle: Text(
                      '${loc.translate('date')}: $formattedDate\n'
                      '${loc.translate('total')}: \$${totalAmount.toStringAsFixed(2)}',
                    ),
                    isThreeLine: true,
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        IconButton(
                          icon: const Icon(Icons.info),
                          onPressed: () => _showBuyDetails(buy),
                        ),
                        IconButton(
                          icon: const Icon(Icons.delete),
                          onPressed: () {
                            _deleteBuy(buyId);
                          },
                          color: Colors.redAccent,
                        ),
                      ],
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
