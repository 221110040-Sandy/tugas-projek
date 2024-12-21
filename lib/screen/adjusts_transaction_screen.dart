import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:tugas_akhir/services/firestore_services.dart';
import 'package:intl/intl.dart';
import 'package:tugas_akhir/theme/colors.dart';

class AdjustsTransactionScreen extends StatefulWidget {
  @override
  _AdjustsTransactionScreenState createState() =>
      _AdjustsTransactionScreenState();
}

class _AdjustsTransactionScreenState extends State<AdjustsTransactionScreen> {
  final FirestoreService firestoreService = FirestoreService();
  final TextEditingController searchController = TextEditingController();
  List<Map<String, dynamic>> adjusts = [];
  List<Map<String, dynamic>> filteredAdjusts = [];

  @override
  void initState() {
    super.initState();
    firestoreService.getAdjusts().then((data) {
      setState(() {
        adjusts = data;
        filteredAdjusts = adjusts;
      });
    });
  }

  void _filterAdjusts(String query) {
    setState(() {
      filteredAdjusts = adjusts.where((adjust) {
        final adjustData = adjust;
        final adjustCode = adjustData['kode_adjust']?.toLowerCase() ?? '';
        return adjustCode.contains(query.toLowerCase());
      }).toList();
    });
  }

  Future<void> _deleteAdjust(String adjustId) async {
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
        await firestoreService.deleteAdjust(adjustId);
        setState(() {
          adjusts.removeWhere((adjust) => adjust['id'] == adjustId);
          filteredAdjusts = List.from(adjusts);
        });
      } catch (e) {
        print("Error deleting adjust: $e");
      }
    }
  }

  void _showAdjustDetails(Map<String, dynamic> adjust) {
    showDialog(
      context: context,
      builder: (context) {
        final createdAt = (adjust['created_at'] as Timestamp?)?.toDate();
        final formattedDate = createdAt != null
            ? DateFormat('yyyy-MM-dd HH:mm').format(createdAt)
            : 'Unknown Date';

        return AlertDialog(
          title: Text(
            'Details for Adjust: ${adjust['kode_adjust'] ?? 'Unknown'}',
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
          content: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text('Date: $formattedDate'),
                Text(
                    'Total Amount: \$${adjust['total_amount']?.toStringAsFixed(2) ?? '0.00'}'),
                const SizedBox(height: 16),
                Text(
                  'Items:',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                ...((adjust['items'] as List<dynamic>? ?? []).map((item) {
                  return Text('- ${item['nama']} (${item['jumlah']} pcs)');
                }).toList()),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Close'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Adjusts Transactions'),
        backgroundColor: secondaryColor,
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: () {
              Navigator.pushNamed(context, '/add-adjusts');
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
              onChanged: _filterAdjusts,
            ),
          ),
          Expanded(
            child: ListView.builder(
              itemCount: filteredAdjusts.length,
              itemBuilder: (context, index) {
                final adjust = filteredAdjusts[index];
                final totalAmount = adjust['total_amount'] ?? 0.0;
                final createdAt =
                    (adjust['created_at'] as Timestamp?)?.toDate();
                final formattedDate = createdAt != null
                    ? DateFormat('yyyy-MM-dd HH:mm').format(createdAt)
                    : 'Unknown Date';
                final adjustId = adjust['id'];

                return Dismissible(
                  key: Key(adjustId),
                  direction: DismissDirection.endToStart,
                  onDismissed: (direction) async {
                    await _deleteAdjust(adjustId);
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('Adjust deleted')),
                    );
                  },
                  background: Container(
                    color: Colors.red,
                    alignment: Alignment.centerRight,
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: const Icon(Icons.delete, color: Colors.white),
                  ),
                  child: ListTile(
                    title:
                        Text('Adjust: ${adjust['kode_adjust'] ?? 'Unknown'}'),
                    subtitle: Text(
                      'Date: $formattedDate\n'
                      'Total: \$${totalAmount.toStringAsFixed(2)}',
                    ),
                    isThreeLine: true,
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        IconButton(
                          icon: const Icon(Icons.info),
                          onPressed: () => _showAdjustDetails(adjust),
                        ),
                        IconButton(
                          icon: const Icon(Icons.delete),
                          onPressed: () {
                            _deleteAdjust(adjustId);
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
