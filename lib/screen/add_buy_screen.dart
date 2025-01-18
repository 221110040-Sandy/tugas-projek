import 'package:flutter/material.dart';
import 'package:tugas_akhir/localization/app_localization.dart';
import 'package:tugas_akhir/services/firestore_services.dart';

class AddBuysScreen extends StatefulWidget {
  @override
  _AddBuysScreenState createState() => _AddBuysScreenState();
}

class _AddBuysScreenState extends State<AddBuysScreen> {
  final FirestoreService firestoreService = FirestoreService();
  String? selectedItemId;
  List<Map<String, dynamic>> selectedItems = [];
  double totalAmount = 0;

  final TextEditingController priceController = TextEditingController();

  void addItemToTransaction(Map<String, dynamic> item, double price) {
    setState(() {
      selectedItems.add({...item, 'jumlah': 1, 'harga': price});
      totalAmount += price;
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

  Future<void> submitBuy() async {
    final loc = AppLocalization.of(context);

    if (selectedItems.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
            content:
                Text(loc.translate('item') + " " + loc.translate('empty'))),
      );
      return;
    }

    bool confirmed = await showDialog<bool>(
          context: context,
          builder: (context) => AlertDialog(
            title: Text(loc.translate('confirm') + ' ' + loc.translate('buy')),
            content: Text(
              '${loc.translate('total')}: \$${totalAmount.toStringAsFixed(2)}',
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

    final kodeBuy = await firestoreService.generateBuyCode();

    await firestoreService.saveBuy(
      kodeBuy,
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

  Future<void> showPriceInputDialog(
      Map<String, dynamic> selectedItem, loc) async {
    priceController.clear();
    double? enteredPrice = await showDialog<double>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(
            '${loc.translate('enter')}${loc.translate('price')} ${selectedItem['nama']}'),
        content: TextField(
          controller: priceController,
          keyboardType: TextInputType.number,
          decoration: InputDecoration(
              hintText: loc.translate('enter') + loc.translate('price')),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(loc.translate('cancel')),
          ),
          ElevatedButton(
            onPressed: () {
              final price = double.tryParse(priceController.text);
              if (price != null && price > 0) {
                Navigator.pop(context, price);
              } else {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text(loc.translate('valid_price'))),
                );
              }
            },
            child: Text(loc.translate('add')),
          ),
        ],
      ),
    );

    if (enteredPrice != null) {
      addItemToTransaction(selectedItem, enteredPrice);
    }
  }

  @override
  Widget build(BuildContext context) {
    final loc = AppLocalization.of(context);
    return Scaffold(
      appBar: AppBar(
        title: Text(loc.translate('add') + ' ' + loc.translate('buys')),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
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
                    hint: Text(
                        loc.translate('select') + ' ' + loc.translate('item')),
                    value: selectedItemId,
                    isExpanded: true,
                    onChanged: (value) {
                      final selectedItem = snapshot.data!
                          .firstWhere((item) => item['id'] == value);
                      setState(() {
                        selectedItemId = null;
                      });
                      showPriceInputDialog(selectedItem, loc);
                    },
                    items: availableItems.map<DropdownMenuItem<String>>((item) {
                      return DropdownMenuItem<String>(
                        value: item['id'],
                        child: Text(item['nama']),
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
                    onPressed: submitBuy,
                    child: Text(loc.translate('confirm')),
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
