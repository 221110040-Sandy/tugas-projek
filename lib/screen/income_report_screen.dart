import 'package:flutter/material.dart';
import 'package:tugas_akhir/localization/app_localization.dart';
import 'package:tugas_akhir/services/firestore_services.dart';
import 'package:intl/intl.dart';
import 'package:tugas_akhir/theme/colors.dart';

class IncomeScreen extends StatefulWidget {
  @override
  _IncomeScreenState createState() => _IncomeScreenState();
}

class _IncomeScreenState extends State<IncomeScreen> {
  final FirestoreService _firestoreService = FirestoreService();
  bool _isLoading = true;
  double _totalPenjualan = 0.0;
  double _totalPembelian = 0.0;
  double _labaRugi = 0.0;

  DateTime? _startDate;
  DateTime? _endDate;

  @override
  void initState() {
    super.initState();
    _fetchLabaRugi();
  }

  Future<void> _fetchLabaRugi() async {
    setState(() {
      _isLoading = true;
    });

    try {
      var penjualan =
          await _firestoreService.getPenjualan(_startDate, _endDate);
      var pembelian =
          await _firestoreService.getPembelian(_startDate, _endDate);

      double totalPenjualan = 0.0;
      double totalPembelian = 0.0;

      for (var transaksi in penjualan) {
        totalPenjualan += transaksi['total_amount'] ?? 0.0;
      }

      for (var transaksi in pembelian) {
        totalPembelian += transaksi['total_amount'] ?? 0.0;
      }

      double labaRugi = totalPenjualan - totalPembelian;

      setState(() {
        _totalPenjualan = totalPenjualan;
        _totalPembelian = totalPembelian;
        _labaRugi = labaRugi;
      });
    } catch (e) {
      print("Error fetching laba rugi: $e");
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _selectDateRange(BuildContext context) async {
    final DateTimeRange? picked = await showDateRangePicker(
      context: context,
      firstDate: DateTime(2020),
      lastDate: DateTime(2030),
    );

    if (picked != null && picked.start != null && picked.end != null) {
      setState(() {
        _startDate = picked.start;
        _endDate = picked.end;
      });

      _fetchLabaRugi();
    }
  }

  @override
  Widget build(BuildContext context) {
    final loc = AppLocalization.of(context);
    return Scaffold(
      appBar: AppBar(
        title: Text(loc.translate('incomes')),
        backgroundColor: secondaryColor,
        actions: [
          IconButton(
            icon: Icon(Icons.date_range),
            onPressed: () => _selectDateRange(context),
          )
        ],
      ),
      body: _isLoading
          ? Center(child: CircularProgressIndicator())
          : Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "${loc.translate('date')}: ${_startDate != null && _endDate != null ? DateFormat('yyyy-MM-dd').format(_startDate!) + ' - ' + DateFormat('yyyy-MM-dd').format(_endDate!) : '-'}",
                    style: TextStyle(fontSize: 16),
                  ),
                  SizedBox(height: 20),
                  Text(
                    "Total ${loc.translate('sales')}: Rp ${_totalPenjualan.toStringAsFixed(2)}",
                    style: TextStyle(fontSize: 18),
                  ),
                  SizedBox(height: 10),
                  Text(
                    "Total ${loc.translate('buys')}: Rp ${_totalPembelian.toStringAsFixed(2)}",
                    style: TextStyle(fontSize: 18),
                  ),
                  SizedBox(height: 10),
                  Text(
                    "${loc.translate('profitloss')}: Rp ${_labaRugi.toStringAsFixed(2)}",
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: _labaRugi >= 0 ? Colors.green : Colors.red,
                    ),
                  ),
                ],
              ),
            ),
    );
  }
}
