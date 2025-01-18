import 'dart:io';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:tugas_akhir/localization/app_localization.dart';
import 'package:tugas_akhir/services/firestore_services.dart';
import 'package:tugas_akhir/services/imagekit.dart';
import 'package:tugas_akhir/theme/colors.dart';
import 'package:tugas_akhir/components/image_picker_component.dart';

class MasterItemsScreen extends StatefulWidget {
  @override
  _MasterItemsScreenState createState() => _MasterItemsScreenState();
}

class _MasterItemsScreenState extends State<MasterItemsScreen> {
  final FirestoreService firestoreService = FirestoreService();
  final TextEditingController namaController = TextEditingController();
  final TextEditingController stokAwalController = TextEditingController();
  final TextEditingController hargaController = TextEditingController();
  final TextEditingController searchController = TextEditingController();

  File? _selectedImage;
  List<QueryDocumentSnapshot> items = [];
  List<QueryDocumentSnapshot> filteredItems = [];

  @override
  void initState() {
    super.initState();
    firestoreService.itemsCollection.snapshots().listen((snapshot) {
      setState(() {
        items = snapshot.docs;
        filteredItems = items;
      });
    });
  }

  Future<void> _addNewItem() async {
    if (_selectedImage == null) {
      print("No image selected.");
      return;
    }

    final imageUrl = await ImageKitService().uploadImage(_selectedImage!);

    if (imageUrl != null) {
      final lastItem = await firestoreService.getLastItem();
      final newKode = (lastItem != null
              ? (lastItem['kode'] is String
                  ? int.parse(lastItem['kode']) + 1
                  : lastItem['kode'] + 1)
              : 1)
          .toString();

      await firestoreService.addItem(
        newKode,
        namaController.text,
        int.parse(stokAwalController.text),
        double.parse(hargaController.text),
        imageUrl,
      );

      namaController.clear();
      stokAwalController.clear();
      hargaController.clear();
      setState(() {
        _selectedImage = null;
      });
      Navigator.of(context).pop();
    } else {
      print("Image upload failed.");
    }
  }

  void _showAddItemDialog(loc) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text(
            loc.translate('add') + loc.translate('items'),
          ),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: namaController,
                  decoration: InputDecoration(labelText: loc.translate('name')),
                ),
                TextField(
                  controller: stokAwalController,
                  decoration:
                      InputDecoration(labelText: loc.translate('stock')),
                  keyboardType: TextInputType.number,
                ),
                TextField(
                  controller: hargaController,
                  decoration:
                      InputDecoration(labelText: loc.translate('price')),
                  keyboardType: TextInputType.number,
                ),
                SizedBox(height: 16),
                ImagePickerComponent(
                  onImageSelected: (file) {
                    setState(() {
                      _selectedImage = file;
                    });
                  },
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              child: Text(loc.translate('cancel')),
              onPressed: () => Navigator.of(context).pop(),
            ),
            TextButton(
              child: Text(loc.translate('add')),
              onPressed: _addNewItem,
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
        title: Text(loc.translate('items')),
        backgroundColor: secondaryColor,
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: () => _showAddItemDialog(loc),
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
                labelText: loc.translate('search') + loc.translate('items'),
                border: OutlineInputBorder(),
              ),
              onChanged: (value) {
                setState(() {
                  filteredItems = items.where((item) {
                    final itemData = item.data() as Map<String, dynamic>;
                    return itemData['nama']
                        .toLowerCase()
                        .contains(value.toLowerCase());
                  }).toList();
                });
              },
            ),
          ),
          Expanded(
            child: ListView.builder(
              itemCount: filteredItems.length,
              itemBuilder: (context, index) {
                final itemData =
                    filteredItems[index].data() as Map<String, dynamic>;
                final itemId = filteredItems[index].id;

                final imageUrl = itemData['imageUrl'];

                return ListTile(
                  title: Text('${itemData['nama']} - ${itemData['kode']}'),
                  subtitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                          '${loc.translate('stock')}: ${itemData['stok_awal']}'),
                      Text('${loc.translate('price')}: Rp${itemData['harga']}'),
                    ],
                  ),
                  leading: imageUrl != null
                      ? Image.network(imageUrl,
                          width: 50, height: 50, fit: BoxFit.cover)
                      : Icon(Icons.image, size: 50),
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      IconButton(
                        icon: const Icon(Icons.edit),
                        onPressed: () {
                          _showEditItemDialog(context, itemId, itemData, loc);
                        },
                        color: Colors.blueAccent,
                      ),
                      IconButton(
                        icon: const Icon(Icons.delete),
                        onPressed: () {
                          _deleteItem(context, itemId, loc);
                        },
                        color: Colors.redAccent,
                      ),
                    ],
                  ),
                );
              },
            ),
          )
        ],
      ),
    );
  }

  void _showEditItemDialog(
      BuildContext context, String itemId, Map<String, dynamic> itemData, loc) {
    final namaController = TextEditingController(text: itemData['nama']);
    final stokAwalController =
        TextEditingController(text: itemData['stok_awal'].toString());
    final hargaController =
        TextEditingController(text: itemData['harga'].toString());

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text('Edit' + loc.translate('items')),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                '${loc.translate('code')}: ${itemData['kode']}',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              TextField(
                controller: namaController,
                decoration: InputDecoration(labelText: loc.translate('name')),
              ),
              TextField(
                controller: stokAwalController,
                decoration: InputDecoration(labelText: loc.translate('stock')),
                keyboardType: TextInputType.number,
              ),
              TextField(
                controller: hargaController,
                decoration: InputDecoration(labelText: loc.translate('price')),
                keyboardType: TextInputType.number,
              ),
            ],
          ),
          actions: [
            TextButton(
              child: Text(loc.translate('cancel')),
              onPressed: () => Navigator.of(context).pop(),
            ),
            TextButton(
              child: Text(loc.translate('save')),
              onPressed: () async {
                await firestoreService.updateItem(
                  itemId,
                  namaController.text,
                  int.parse(stokAwalController.text),
                  double.parse(hargaController.text),
                );
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  Future<void> _deleteItem(BuildContext context, String itemId, loc) async {
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
      await firestoreService.deleteItem(itemId);
    }
  }
}
