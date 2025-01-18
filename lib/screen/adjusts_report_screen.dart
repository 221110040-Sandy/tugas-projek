import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:tugas_akhir/localization/app_localization.dart';
import 'package:tugas_akhir/services/firestore_services.dart';
import 'package:tugas_akhir/theme/colors.dart';

class AdjustReportScreen extends StatefulWidget {
  @override
  _AdjustReportScreenState createState() => _AdjustReportScreenState();
}

class _AdjustReportScreenState extends State<AdjustReportScreen> {
  final FirestoreService firestoreService = FirestoreService();
  late Future<List<Map<String, dynamic>>> adjustmentData;
  DateTimeRange? dateRange;

  @override
  void initState() {
    super.initState();
    adjustmentData = firestoreService.getAdjusts();
  }

  Future<void> filterAdjustmentsByDate() async {
    if (dateRange != null) {
      setState(() {
        adjustmentData = firestoreService.getAdjusts().then((adjustments) {
          return adjustments.where((adjustment) {
            DateTime adjustmentDate =
                (adjustment['created_at'] as Timestamp).toDate();
            return adjustmentDate.isAfter(dateRange!.start) &&
                adjustmentDate.isBefore(dateRange!.end);
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
      filterAdjustmentsByDate();
    }
  }

  @override
  Widget build(BuildContext context) {
    final loc = AppLocalization.of(context);
    return Scaffold(
      appBar: AppBar(
        title: Text(loc.translate('adjusts')),
        backgroundColor: secondaryColor,
        actions: [
          IconButton(
            icon: Icon(Icons.calendar_today),
            onPressed: pickDateRange,
          ),
        ],
      ),
      body: FutureBuilder<List<Map<String, dynamic>>>(
        future: adjustmentData,
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
              var adjustment = snapshot.data![index];
              var adjustmentDate =
                  (adjustment['created_at'] as Timestamp).toDate();
              var items = adjustment['items'] as List<dynamic>;

              return Card(
                margin: EdgeInsets.symmetric(vertical: 8, horizontal: 12),
                child: Padding(
                  padding: const EdgeInsets.all(12.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                          '${loc.translate('date')}: ${DateFormat('yyyy-MM-dd').format(adjustmentDate)}'),
                      SizedBox(height: 8),
                      Text('${loc.translate('item')}:',
                          style: TextStyle(fontWeight: FontWeight.bold)),
                      for (var item in items)
                        Padding(
                          padding: const EdgeInsets.only(top: 4.0),
                          child: Text(
                            '${item['nama']} : ${item['jumlah']}',
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
