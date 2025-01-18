import 'package:flutter/material.dart';
import 'package:tugas_akhir/localization/app_localization.dart';
import 'package:tugas_akhir/services/firestore_services.dart';
import 'package:tugas_akhir/theme/colors.dart';

class StockReportScreen extends StatefulWidget {
  @override
  _StockReportScreenState createState() => _StockReportScreenState();
}

class _StockReportScreenState extends State<StockReportScreen> {
  final FirestoreService _firestoreService = FirestoreService();
  bool _isLoading = true;
  Map<String, int> _stockLevels = {};
  List<Map<String, dynamic>> _items = [];
  List<Map<String, dynamic>> _filteredItems = [];
  TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _fetchStockReport();
  }

  Future<void> _fetchStockReport() async {
    setState(() {
      _isLoading = true;
    });

    try {
      Map<String, int> stockReport =
          (await _firestoreService.getStockReport()).cast<String, int>();
      setState(() {
        _stockLevels = stockReport;
      });

      List<Map<String, dynamic>> items = await _firestoreService.getItems();
      setState(() {
        _items = items;
        _filteredItems = items;
      });
    } catch (e) {
      print("Error fetching stock report: $e");
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  void _filterItems(String query) {
    setState(() {
      _filteredItems = _items
          .where((item) =>
              item['nama'].toLowerCase().contains(query.toLowerCase()))
          .toList();
    });
  }

  @override
  Widget build(BuildContext context) {
    final loc = AppLocalization.of(context);
    return Scaffold(
        appBar: AppBar(
          title: Text(loc.translate('stock')),
          backgroundColor: secondaryColor,
        ),
        body: _isLoading
            ? Center(child: CircularProgressIndicator())
            : Column(children: [
                PreferredSize(
                  preferredSize: Size.fromHeight(50),
                  child: Padding(
                    padding: EdgeInsets.symmetric(horizontal: 16.0),
                    child: TextField(
                      controller: _searchController,
                      onChanged: _filterItems,
                      decoration: InputDecoration(
                        hintText: loc.translate('search'),
                        border: OutlineInputBorder(),
                        prefixIcon: Icon(Icons.search),
                      ),
                    ),
                  ),
                ),
                Expanded(
                  child: ListView.builder(
                    itemCount: _filteredItems.length,
                    itemBuilder: (context, index) {
                      var item = _filteredItems[index];
                      String itemName = item['nama'] ?? 'Unknown';
                      String itemId = item['id'];
                      int stockLevel = _stockLevels[itemId] ?? 0;

                      return ListTile(
                        title: Text(itemName),
                        subtitle: Text("Stock: $stockLevel"),
                      );
                    },
                  ),
                )
              ]));
  }
}
