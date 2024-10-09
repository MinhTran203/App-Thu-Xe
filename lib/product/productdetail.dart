import 'package:billiard/config/const.dart';
import 'package:flutter/material.dart';
import 'package:billiard/data/billard_helper.dart';

class ProductDetailScreen extends StatelessWidget {
  final int productId;
  final int accountId;

  ProductDetailScreen({required this.productId, required this.accountId});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Chi Tiết Sản Phẩm'),
      ),
      body: FutureBuilder<Map<String, dynamic>?>(
        future: DatabaseHelper().getProductById(productId),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Lỗi: ${snapshot.error}'));
          } else if (!snapshot.hasData || snapshot.data == null) {
            return Center(child: Text('Không tìm thấy sản phẩm.'));
          } else {
            var product = snapshot.data!;
            return Padding(
              padding: EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  product['img'] != null
                      ? Image.asset(urlimg + product['img'])
                      : Container(height: 200, color: Colors.grey),
                  SizedBox(height: 16.0),
                  Text(
                    product['name'] ?? '',
                    style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                  ),
                  SizedBox(height: 8.0),
                  Text(
                    product['description'] ?? '',
                    style: TextStyle(fontSize: 16),
                  ),
                ],
              ),
            );
          }
        },
      ),
    );
  }
}
