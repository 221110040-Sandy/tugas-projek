import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:tugas_akhir/localization/app_localization.dart';
import 'package:tugas_akhir/services/firestore_services.dart';
import 'package:tugas_akhir/theme/colors.dart';

class BuyReportScreen extends StatefulWidget {
  @override
  _BuyReportScreenState createState() => _BuyReportScreenState();
}

class _BuyReportScreenState extends State<BuyReportScreen> {
  final FirestoreService firestoreService = FirestoreService();
  late Future<List<Map<String, dynamic>>> buyData;
  DateTimeRange? dateRange;

  @override
  void initState() {
    super.initState();
    buyData = firestoreService.getBuys();
  }

  Future<void> filterPurchasesByDate() async {
    if (dateRange != null) {
      setState(() {
        buyData = firestoreService.getBuys().then((purchases) {
          return purchases.where((purchase) {
            DateTime purchaseDate =
                (purchase['created_at'] as Timestamp).toDate();
            return purchaseDate.isAfter(dateRange!.start) &&
                purchaseDate.isBefore(dateRange!.end);
          }).toList();
        });
      });
    }
  }

  Future<void> pickDateRange() async {
    DateTimeRange? picked = await showDateRangePicker(
      context: context,
      firstDate: DateTime(2020),
      lastDate: DateTime.now(),
      initialDateRange: dateRange,
    );

    if (picked != null && picked != dateRange) {
      setState(() {
        dateRange = picked;
      });
      filterPurchasesByDate();
    }
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
            icon: Icon(Icons.calendar_today),
            onPressed: pickDateRange,
          ),
        ],
      ),
      body: FutureBuilder<List<Map<String, dynamic>>>(
        future: buyData,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return Center(
                child: Text(loc.translate('error') + ': ${snapshot.error}'));
          }

          if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return Center(child: Text(loc.translate('empty')));
          }

          return ListView.builder(
            itemCount: snapshot.data!.length,
            itemBuilder: (context, index) {
              var purchase = snapshot.data![index];
              var purchaseDate = (purchase['created_at'] as Timestamp).toDate();
              var totalAmount = purchase['total_amount'].toDouble();
              var items = purchase['items'] as List<dynamic>;

              return Card(
                margin: EdgeInsets.symmetric(vertical: 8, horizontal: 12),
                child: Padding(
                  padding: const EdgeInsets.all(12.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                          '${loc.translate('date')}: ${DateFormat('yyyy-MM-dd').format(purchaseDate)}'),
                      Text(
                          '${loc.translate('total')}: \$${totalAmount.toStringAsFixed(2)}'),
                      SizedBox(height: 8),
                      Text('${loc.translate('items')}:',
                          style: TextStyle(fontWeight: FontWeight.bold)),
                      for (var item in items)
                        Padding(
                          padding: const EdgeInsets.only(top: 4.0),
                          child: Text(
                            '${item['nama']} - ${loc.translate('quantity')}: ${item['jumlah']} - ${loc.translate('price')}: \$${(item['harga'] as double).toStringAsFixed(2)}',
                          ),
                        ),
                    ],
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
