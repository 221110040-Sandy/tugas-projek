import 'package:flutter/material.dart';
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
    if (selectedItems.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Please select at least one item.')),
      );
      return;
    }

    bool confirmed = await showDialog<bool>(
          context: context,
          builder: (context) => AlertDialog(
            title: Text('Confirm Buy'),
            content: Text(
              'Total: \$${totalAmount.toStringAsFixed(2)}\nDo you want to proceed?',
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context, false),
                child: Text('Cancel'),
              ),
              ElevatedButton(
                onPressed: () => Navigator.pop(context, true),
                child: Text('Confirm'),
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
      SnackBar(content: Text('Buy added successfully!')),
    );

    Navigator.of(context).pop();
  }

  Future<void> showPriceInputDialog(Map<String, dynamic> selectedItem) async {
    priceController.clear();
    double? enteredPrice = await showDialog<double>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Enter Price for ${selectedItem['nama']}'),
        content: TextField(
          controller: priceController,
          keyboardType: TextInputType.number,
          decoration: InputDecoration(hintText: 'Enter price'),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              final price = double.tryParse(priceController.text);
              if (price != null && price > 0) {
                Navigator.pop(context, price);
              } else {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('Please enter a valid price.')),
                );
              }
            },
            child: Text('Add'),
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
    return Scaffold(
      appBar: AppBar(
        title: Text('Add Buys Transaction'),
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
                    return Center(child: Text('No items available.'));
                  }

                  final availableItems = snapshot.data!
                      .where((item) => !selectedItems
                          .any((selected) => selected['id'] == item['id']))
                      .toList();

                  if (availableItems.isEmpty) {
                    return Center(child: Text('All items have been added.'));
                  }

                  return DropdownButton<String>(
                    hint: Text('Select Item'),
                    value: selectedItemId,
                    isExpanded: true,
                    onChanged: (value) {
                      final selectedItem = snapshot.data!
                          .firstWhere((item) => item['id'] == value);
                      setState(() {
                        selectedItemId = null;
                      });
                      showPriceInputDialog(selectedItem);
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
                    subtitle: Text('Price: \$${item['harga']}'),
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
                  Text('Total: \$${totalAmount.toStringAsFixed(2)}'),
                  ElevatedButton(
                    onPressed: submitBuy,
                    child: Text('Submit'),
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
