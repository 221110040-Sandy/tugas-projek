import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:tugas_akhir/localization/app_localization.dart';
import 'dart:convert';

import 'package:tugas_akhir/theme/colors.dart';

class HotProductsScreen extends StatelessWidget {
  Future<List<dynamic>> fetchHotProducts() async {
    final response = await http.get(
      Uri.parse(
          "https://fakestoreapi.com/products/category/women's%20clothing"),
    );

    if (response.statusCode == 200) {
      return json.decode(response.body);
    } else {
      throw Exception('Failed to load hot products');
    }
  }

  @override
  Widget build(BuildContext context) {
    final loc = AppLocalization.of(context);
    return Scaffold(
      appBar: AppBar(
        title: Text(loc.translate('hot_products')),
        backgroundColor: secondaryColor,
      ),
      body: FutureBuilder<List<dynamic>>(
        future: fetchHotProducts(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return Center(child: Text('No products found'));
          }

          final products = snapshot.data!;
          return ListView.builder(
            itemCount: products.length,
            itemBuilder: (context, index) {
              final product = products[index];
              print('sad');
              return Card(
                margin: EdgeInsets.all(8.0),
                child: ListTile(
                  contentPadding: EdgeInsets.all(10.0),
                  leading: Image.network(
                    product['image'],
                    width: 50,
                    height: 50,
                    fit: BoxFit.cover,
                  ),
                  title: Text(
                    product['title'],
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                  subtitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      SizedBox(height: 5.0),
                      Text(
                        'Price: \$${product['price']}',
                        style: TextStyle(color: Colors.green[700]),
                      ),
                      SizedBox(height: 5.0),
                      Text(
                        product['description'],
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                      SizedBox(height: 5.0),
                      Row(
                        children: [
                          Icon(Icons.star, color: Colors.yellow[700], size: 16),
                          SizedBox(width: 5),
                          Text(
                            '${product['rating']['rate']} (${product['rating']['count']} reviews)',
                          ),
                        ],
                      ),
                    ],
                  ),
                  onTap: () {},
                ),
              );
            },
          );
        },
      ),
    );
  }
}
