import 'package:flutter/material.dart';
import 'package:billiard/data/billard_helper.dart';

class InvoicePage extends StatelessWidget {
  final int invoiceId;

  InvoicePage({required this.invoiceId});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Hóa đơn của bạn'),
      ),
      body: FutureBuilder<Map<String, dynamic>?>(
        future: DatabaseHelper().getInvoiceDetails(invoiceId),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Lỗi: ${snapshot.error}'));
          } else if (!snapshot.hasData || snapshot.data == null) {
            return Center(child: Text('Không tìm thấy hóa đơn.'));
          } else {
            var invoice = snapshot.data!;
            return Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Hóa đơn số: ${invoice['id']}',
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                  ),
                  SizedBox(height: 16),
                  Text('Tổng giá: ${invoice['total_price']} VND'),
                  SizedBox(height: 16),
                  Text('Ngày tạo: ${invoice['created_at']}'),
                  SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: () {
                      Navigator.pop(context);
                    },
                    child: Text('Quay lại'),
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
