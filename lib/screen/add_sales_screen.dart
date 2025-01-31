import 'package:flutter/material.dart';
import 'package:tugas_akhir/localization/app_localization.dart';
import 'package:tugas_akhir/services/firestore_services.dart';

class AddSalesScreen extends StatefulWidget {
  @override
  _AddSalesScreenState createState() => _AddSalesScreenState();
}

class _AddSalesScreenState extends State<AddSalesScreen> {
  final FirestoreService firestoreService = FirestoreService();
  String? selectedCustomerId;
  String? selectedItemId;
  List<Map<String, dynamic>> selectedItems = [];
  double totalAmount = 0;

  void addItemToTransaction(Map<String, dynamic> item) {
    setState(() {
      selectedItems.add({...item, 'jumlah': 1});
      totalAmount += item['harga'];
    });
  }

  void updateItemQuantity(int index, int quantity) {
    setState(() {
      final item = selectedItems[index];
      totalAmount -= item['harga'] * item['jumlah'];
      selectedItems[index]['jumlah'] = quantity;
      totalAmount += item['harga'] * quantity;
    });
  }

  void removeItemFromTransaction(int index) {
    setState(() {
      totalAmount -=
          selectedItems[index]['harga'] * selectedItems[index]['jumlah'];
      selectedItems.removeAt(index);
    });
  }

  Future<void> submitSale() async {
    final loc = AppLocalization.of(context);

    if (selectedCustomerId == null || selectedItems.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
            content: Text(loc.translate('customer') +
                " & " +
                loc.translate('item') +
                " " +
                loc.translate('empty'))),
      );
      return;
    }

    final customerData = await firestoreService.customersCollection
        .doc(selectedCustomerId)
        .get();

    final customerName = customerData['nama'];
    final customerKode = customerData['kode'];

    bool confirmed = await showDialog<bool>(
          context: context,
          builder: (context) => AlertDialog(
            title: Text(loc.translate('confirm') + loc.translate('sale')),
            content: Text(
              '${loc.translate('customer')}: $customerName\n${loc.translate('total')}: \$${totalAmount.toStringAsFixed(2)}\n}',
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context, false),
                child: Text(loc.translate('cancel')),
              ),
              ElevatedButton(
                onPressed: () => Navigator.pop(context, true),
                child: Text(loc.translate('confirm')),
              ),
            ],
          ),
        ) ??
        false;

    if (!confirmed) return;

    final kodeSale = await firestoreService.generateSaleCode();

    await firestoreService.saveSale(
      kodeSale,
      customerKode,
      customerName,
      selectedItems.map((item) {
        return {
          'kode': item['kode'],
          'nama': item['nama'],
          'jumlah': item['jumlah'],
          'harga': item['harga'],
        };
      }).toList(),
      totalAmount,
    );

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(loc.translate('success'))),
    );

    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    final loc = AppLocalization.of(context);
    return Scaffold(
      appBar: AppBar(
        title: Text(loc.translate('add') + loc.translate('sales')),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.only(left: 8.0),
              child: FutureBuilder(
                future: firestoreService.getCustomers(),
                builder: (context,
                    AsyncSnapshot<List<Map<String, dynamic>>> snapshot) {
                  if (!snapshot.hasData || snapshot.data!.isEmpty) {
                    return Center(child: Text(loc.translate('empty')));
                  }

                  return DropdownButton<String>(
                    hint: Text(
                        loc.translate('select') + loc.translate('customer')),
                    value: selectedCustomerId,
                    isExpanded: true,
                    onChanged: (value) {
                      setState(() {
                        selectedCustomerId = value;
                      });
                    },
                    items: snapshot.data!
                        .map<DropdownMenuItem<String>>((customer) {
                      return DropdownMenuItem<String>(
                        value: customer['id'],
                        child: Text(customer['nama']),
                      );
                    }).toList(),
                  );
                },
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(left: 8.0),
              child: FutureBuilder(
                future: firestoreService.getItems(),
                builder: (context,
                    AsyncSnapshot<List<Map<String, dynamic>>> snapshot) {
                  if (!snapshot.hasData || snapshot.data!.isEmpty) {
                    return Center(child: Text(loc.translate('empty')));
                  }

                  final availableItems = snapshot.data!
                      .where((item) => !selectedItems
                          .any((selected) => selected['id'] == item['id']))
                      .toList();

                  if (availableItems.isEmpty) {
                    return Center(child: Text(loc.translate('empty')));
                  }

                  return DropdownButton<String>(
                    hint: Text(loc.translate('select') + loc.translate('item')),
                    value: selectedItemId,
                    isExpanded: true,
                    onChanged: (value) {
                      final selectedItem = snapshot.data!
                          .firstWhere((item) => item['id'] == value);
                      addItemToTransaction(selectedItem);
                      setState(() {
                        selectedItemId = null;
                      });
                    },
                    items: availableItems.map<DropdownMenuItem<String>>((item) {
                      return DropdownMenuItem<String>(
                        value: item['id'],
                        child: Text('${item['nama']} - \$${item['harga']}'),
                      );
                    }).toList(),
                  );
                },
              ),
            ),
            Expanded(
              child: ListView.builder(
                itemCount: selectedItems.length,
                itemBuilder: (context, index) {
                  final item = selectedItems[index];
                  return ListTile(
                    title: Text(item['nama']),
                    subtitle:
                        Text('${loc.translate('price')}: \$${item['harga']}'),
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        IconButton(
                          icon: Icon(Icons.remove),
                          onPressed: () => updateItemQuantity(
                            index,
                            (item['jumlah'] > 1) ? item['jumlah'] - 1 : 1,
                          ),
                        ),
                        Text('${item['jumlah']}'),
                        IconButton(
                          icon: Icon(Icons.add),
                          onPressed: () =>
                              updateItemQuantity(index, item['jumlah'] + 1),
                        ),
                        IconButton(
                          icon: Icon(Icons.delete),
                          onPressed: () => removeItemFromTransaction(index),
                        ),
                      ],
                    ),
                  );
                },
              ),
            ),
            Center(
              child: Column(
                children: [
                  Text(
                      '${loc.translate('total')}: \$${totalAmount.toStringAsFixed(2)}'),
                  ElevatedButton(
                    onPressed: submitSale,
                    child: Text(loc.translate('submit')),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
