import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:tugas_akhir/services/firestore_services.dart';
import 'package:tugas_akhir/theme/colors.dart';

class CustomerScreen extends StatefulWidget {
  @override
  _CustomerScreenState createState() => _CustomerScreenState();
}

class _CustomerScreenState extends State<CustomerScreen> {
  final FirestoreService firestoreService = FirestoreService();
  final TextEditingController kodeController = TextEditingController();
  final TextEditingController namaController = TextEditingController();
  final TextEditingController alamatController = TextEditingController();
  final TextEditingController noHpController = TextEditingController();
  final TextEditingController searchController = TextEditingController();

  List<QueryDocumentSnapshot> customers = [];
  List<QueryDocumentSnapshot> filteredCustomers = [];

  @override
  void initState() {
    super.initState();
    firestoreService.customersCollection.snapshots().listen((snapshot) {
      setState(() {
        customers = snapshot.docs;
        filteredCustomers = customers;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: const Text('Customer'),
          backgroundColor: secondaryColor,
          actions: [
            IconButton(
              icon: const Icon(Icons.add),
              onPressed: () {
                _showAddCustomerDialog();
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
                  labelText: 'Search Customer',
                  border: OutlineInputBorder(),
                ),
                onChanged: (value) {
                  setState(() {
                    filteredCustomers = customers.where((customer) {
                      final customerData =
                          customer.data() as Map<String, dynamic>;
                      return customerData['nama']
                              .toLowerCase()
                              .contains(value.toLowerCase()) ||
                          customerData['alamat']
                              .toLowerCase()
                              .contains(value.toLowerCase()) ||
                          customerData['no_hp']
                              .toLowerCase()
                              .contains(value.toLowerCase());
                    }).toList();
                  });
                },
              ),
            ),
            Expanded(
              child: Container(
                child: ListView.builder(
                  itemCount: filteredCustomers.length,
                  itemBuilder: (context, index) {
                    final customerData =
                        filteredCustomers[index].data() as Map<String, dynamic>;
                    final customerId = filteredCustomers[index].id;

                    return Container(
                      margin: const EdgeInsets.symmetric(
                          vertical: 8.0, horizontal: 16.0),
                      padding: const EdgeInsets.all(12.0),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(15.0),
                        border: Border.all(color: Colors.grey.withOpacity(0.2)),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.grey.withOpacity(0.3),
                            blurRadius: 8.0,
                            offset: Offset(0, 4),
                          ),
                        ],
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            '${customerData['nama']} - ${customerData['kode']}',
                            style: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 16,
                                color: Colors.black87),
                          ),
                          const SizedBox(height: 6),
                          Text(
                            'Alamat: ${customerData['alamat']}',
                            style: TextStyle(color: Colors.grey[700]),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            'No HP: ${customerData['no_hp']}',
                            style: TextStyle(color: Colors.grey[700]),
                          ),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.end,
                            children: [
                              IconButton(
                                icon: const Icon(Icons.edit),
                                onPressed: () {
                                  _showEditCustomerDialog(
                                      context, customerId, customerData);
                                },
                                color: Colors.blueAccent,
                              ),
                              IconButton(
                                icon: const Icon(Icons.delete),
                                onPressed: () {
                                  _deleteCustomer(context, customerId);
                                },
                                color: Colors.redAccent,
                              ),
                            ],
                          ),
                        ],
                      ),
                    );
                  },
                ),
              ),
            )
          ],
        ));
  }

  void _showAddCustomerDialog() {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Add Customer'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: kodeController,
                decoration: const InputDecoration(labelText: 'Kode'),
              ),
              TextField(
                controller: namaController,
                decoration: const InputDecoration(labelText: 'Nama'),
              ),
              TextField(
                controller: alamatController,
                decoration: const InputDecoration(labelText: 'Alamat'),
              ),
              TextField(
                controller: noHpController,
                decoration: const InputDecoration(labelText: 'No HP'),
              ),
            ],
          ),
          actions: [
            TextButton(
              child: const Text('Cancel'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            TextButton(
              child: const Text('Add'),
              onPressed: () async {
                await firestoreService.addCustomer(
                  kodeController.text,
                  namaController.text,
                  alamatController.text,
                  noHpController.text,
                );
                kodeController.clear();
                namaController.clear();
                alamatController.clear();
                noHpController.clear();
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  void _showEditCustomerDialog(BuildContext context, String customerId,
      Map<String, dynamic> customerData) {
    final kodeController = TextEditingController(text: customerData['kode']);
    final namaController = TextEditingController(text: customerData['nama']);
    final alamatController =
        TextEditingController(text: customerData['alamat']);
    final noHpController = TextEditingController(text: customerData['no_hp']);

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Edit Customer'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'Kode: ${customerData['kode']}',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              TextField(
                controller: namaController,
                decoration: const InputDecoration(labelText: 'Nama'),
              ),
              TextField(
                controller: alamatController,
                decoration: const InputDecoration(labelText: 'Alamat'),
              ),
              TextField(
                controller: noHpController,
                decoration: const InputDecoration(labelText: 'No HP'),
              ),
            ],
          ),
          actions: [
            TextButton(
              child: const Text('Cancel'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            TextButton(
              child: const Text('Save'),
              onPressed: () async {
                await firestoreService.updateCustomer(
                  customerId,
                  kodeController.text,
                  namaController.text,
                  alamatController.text,
                  noHpController.text,
                );
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  Future<void> _deleteCustomer(BuildContext context, String customerId) async {
    final confirmation = await showDialog<bool>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Delete Customer'),
          content: const Text('Are you sure you want to delete this customer?'),
          actions: [
            TextButton(
              child: const Text('Cancel'),
              onPressed: () => Navigator.of(context).pop(false),
            ),
            TextButton(
              child: const Text('Delete'),
              onPressed: () => Navigator.of(context).pop(true),
            ),
          ],
        );
      },
    );

    if (confirmation == true) {
      await firestoreService.deleteCustomer(customerId);
    }
  }
}
