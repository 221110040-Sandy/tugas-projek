import 'dart:async';
import 'package:contacts_service/contacts_service.dart';
import 'package:flutter/material.dart';
import 'package:tugas_akhir/localization/app_localization.dart';
import 'package:tugas_akhir/theme/colors.dart';

class ContactScreen extends StatefulWidget {
  const ContactScreen({Key? key}) : super(key: key);

  @override
  State<ContactScreen> createState() => _ContactScreenState();
}

class _ContactScreenState extends State<ContactScreen> {
  final TextEditingController searchController = TextEditingController();
  final TextEditingController nameController = TextEditingController();
  final TextEditingController phoneController = TextEditingController();

  List<Contact> _contacts = [];
  List<Contact> _filteredContacts = [];

  @override
  void initState() {
    super.initState();
    _fetchContacts();
  }

  Future<void> _fetchContacts() async {
    final contacts = (await ContactsService.getContacts()).toList();
    setState(() {
      _contacts = contacts;
      _filteredContacts = contacts;
    });
  }

  Future<void> _addContact(loc) async {
    if (nameController.text.isEmpty || phoneController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(loc.translate('name_phone_required')),
        ),
      );
      return;
    }

    final newContact = Contact(
      givenName: nameController.text,
      phones: [Item(label: 'mobile', value: phoneController.text)],
    );
    await ContactsService.addContact(newContact);
    await _fetchContacts();

    nameController.clear();
    phoneController.clear();
    Navigator.of(context).pop();
  }

  void _showAddContactDialog(loc) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text(loc.translate('add') + loc.translate('contact')),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: nameController,
                decoration: InputDecoration(labelText: loc.translate('name')),
              ),
              TextField(
                controller: phoneController,
                decoration: InputDecoration(labelText: loc.translate('phone')),
                keyboardType: TextInputType.phone,
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: Text(loc.translate('cancel')),
            ),
            ElevatedButton(
              onPressed: () => _addContact(loc),
              child: Text(loc.translate('add')),
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
        title: Text(loc.translate('contacts')),
        backgroundColor: secondaryColor,
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: () => _showAddContactDialog(loc),
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
                labelText: loc.translate('search') + loc.translate('contact'),
                border: const OutlineInputBorder(),
              ),
              onChanged: (value) {
                setState(() {
                  _filteredContacts = _contacts
                      .where((contact) => (contact.displayName ?? '')
                          .toLowerCase()
                          .contains(value.toLowerCase()))
                      .toList();
                });
              },
            ),
          ),
          Expanded(
            child: _filteredContacts.isNotEmpty
                ? ListView.builder(
                    itemCount: _filteredContacts.length,
                    itemBuilder: (context, index) {
                      final contact = _filteredContacts[index];
                      return ListTile(
                        title: Text(
                            contact.displayName ?? loc.translate('no_name')),
                        subtitle: Text(contact.phones?.isNotEmpty == true
                            ? contact.phones!.first.value!
                            : loc.translate('no_phone')),
                        leading: (contact.avatar != null &&
                                contact.avatar!.isNotEmpty)
                            ? CircleAvatar(
                                backgroundImage: MemoryImage(contact.avatar!),
                              )
                            : CircleAvatar(
                                child: Text(
                                  contact.initials(),
                                ),
                              ),
                      );
                    },
                  )
                : Center(
                    child: Text(loc.translate('no_contact_found')),
                  ),
          ),
        ],
      ),
    );
  }
}
