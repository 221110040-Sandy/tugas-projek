import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:tugas_akhir/services/firestore_services.dart';
import 'package:tugas_akhir/theme/colors.dart';

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
    final lastItem = await firestoreService.getLastItem();
    final newKode = (lastItem != null
            ? (lastItem['kode'] is String
                ? int.parse(lastItem['kode']) + 1
                : lastItem['kode'] + 1)
            : 1)
        .toString();

    await firestoreService.addItem(newKode, namaController.text,
        int.parse(stokAwalController.text), double.parse(hargaController.text));
    namaController.clear();
    stokAwalController.clear();
    Navigator.of(context).pop();
    hargaController.clear();
  }

  void _showAddItemDialog() {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Tambah Barang'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: namaController,
                decoration: const InputDecoration(labelText: 'Nama Barang'),
              ),
              TextField(
                controller: stokAwalController,
                decoration: const InputDecoration(labelText: 'Stok Awal'),
                keyboardType: TextInputType.number,
              ),
              TextField(
                controller: hargaController,
                decoration: const InputDecoration(labelText: 'Harga'),
                keyboardType: TextInputType.number,
              ),
            ],
          ),
          actions: [
            TextButton(
              child: const Text('Batal'),
              onPressed: () => Navigator.of(context).pop(),
            ),
            TextButton(
              child: const Text('Tambah'),
              onPressed: () async {
                await _addNewItem();
              },
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
        title: const Text('Master Barang'),
        backgroundColor: secondaryColor,
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: _showAddItemDialog,
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
                labelText: 'Cari Barang',
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

                return ListTile(
                  title: Text('${itemData['nama']} - ${itemData['kode']}'),
                  subtitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Stok Awal: ${itemData['stok_awal']}'),
                      Text('Harga: Rp${itemData['harga']}'),
                    ],
                  ),
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      IconButton(
                        icon: const Icon(Icons.edit),
                        onPressed: () {
                          _showEditItemDialog(context, itemId, itemData);
                        },
                        color: Colors.blueAccent,
                      ),
                      IconButton(
                        icon: const Icon(Icons.delete),
                        onPressed: () {
                          _deleteItem(context, itemId);
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
      BuildContext context, String itemId, Map<String, dynamic> itemData) {
    final namaController = TextEditingController(text: itemData['nama']);
    final stokAwalController =
        TextEditingController(text: itemData['stok_awal'].toString());
    final hargaController =
        TextEditingController(text: itemData['harga'].toString());

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Edit Barang'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'Kode: ${itemData['kode']}',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              TextField(
                controller: namaController,
                decoration: const InputDecoration(labelText: 'Nama Barang'),
              ),
              TextField(
                controller: stokAwalController,
                decoration: const InputDecoration(labelText: 'Stok Awal'),
                keyboardType: TextInputType.number,
              ),
              TextField(
                controller: hargaController,
                decoration: const InputDecoration(labelText: 'Harga'),
                keyboardType: TextInputType.number,
              ),
            ],
          ),
          actions: [
            TextButton(
              child: const Text('Batal'),
              onPressed: () => Navigator.of(context).pop(),
            ),
            TextButton(
              child: const Text('Simpan'),
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

  Future<void> _deleteItem(BuildContext context, String itemId) async {
    final confirmation = await showDialog<bool>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Hapus Barang'),
          content: const Text('Yakin ingin menghapus barang ini?'),
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
      await firestoreService.deleteItem(itemId);
    }
  }
}
