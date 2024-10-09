import 'package:billiard/data/billard_helper.dart';
import 'package:flutter/material.dart';

import 'payment.dart';

import 'package:flutter/material.dart';
import 'package:billiard/data/billard_helper.dart';

class PaymentPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Invoices'),
      ),
      body: FutureBuilder<List<Map<String, dynamic>>>(
        future: DatabaseHelper().getAllInvoicesWithUsernames(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return Center(child: Text('No invoices found.'));
          } else {
            return ListView.builder(
              itemCount: snapshot.data!.length,
              itemBuilder: (context, index) {
                var invoice = snapshot.data![index];
                var invoiceId = invoice['invoice_id'] as int?;
                var username = invoice['username'] as String?;
                var totalPrice = invoice['total_price'] as double?;
                var createdAt = invoice['created_at'] as String?;

                return ListTile(
                  title: Text('Invoice ID: $invoiceId'),
                  subtitle: Text(
                      'Username: $username\nTotal Price: \$${totalPrice?.toStringAsFixed(2) ?? '0.00'}\nDate: $createdAt'),
                );
              },
            );
          }
        },
      ),
    );
  }
}
