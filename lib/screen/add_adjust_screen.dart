import 'package:flutter/material.dart';
import 'package:tugas_akhir/services/firestore_services.dart';

class AddAdjustsScreen extends StatefulWidget {
  @override
  _AddAdjustsScreenState createState() => _AddAdjustsScreenState();
}

class _AddAdjustsScreenState extends State<AddAdjustsScreen> {
  final FirestoreService firestoreService = FirestoreService();
  String? selectedItemId;
  List<Map<String, dynamic>> selectedItems = [];

  void addItemToTransaction(Map<String, dynamic> item) {
    setState(() {
      selectedItems.add({...item, 'jumlah': 0});
    });
  }

  void updateItemQuantity(int index, int quantity) {
    setState(() {
      selectedItems[index]['jumlah'] = quantity;
    });
  }

  void removeItemFromTransaction(int index) {
    setState(() {
      selectedItems.removeAt(index);
    });
  }

  Future<void> submitAdjust() async {
    if (selectedItems.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Please select at least one item.')),
      );
      return;
    }

    bool confirmed = await showDialog<bool>(
          context: context,
          builder: (context) => AlertDialog(
            title: Text('Confirm Adjust'),
            content: Text(
              'Do you want to proceed with these adjustments?',
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

    final kodeAdjust = await firestoreService.generateAdjustCode();

    await firestoreService.saveAdjust(
      kodeAdjust,
      selectedItems.map((item) {
        return {
          'kode': item['kode'],
          'nama': item['nama'],
          'jumlah': item['jumlah'],
        };
      }).toList(),
    );

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Adjust added successfully!')),
    );

    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Add Adjusts Transaction'),
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
                      addItemToTransaction(selectedItem);
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
                    subtitle: Text('Quantity: ${item['jumlah']}'),
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        IconButton(
                          icon: Icon(Icons.remove),
                          onPressed: () => updateItemQuantity(
                            index,
                            item['jumlah'] - 1,
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
                  ElevatedButton(
                    onPressed: submitAdjust,
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
