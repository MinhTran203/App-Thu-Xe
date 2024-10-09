import 'package:billiard/Cart/RevenueManagementScreen%20.dart';
import 'package:billiard/Cue/CueAdmin.dart';
import 'package:billiard/Cue/CueAll.dart';
import 'package:billiard/Cue/CueTest.dart';
import 'package:billiard/Homepage/StoreManagementPage.dart';
import 'package:billiard/Homepage/home_page.dart';
import 'package:billiard/payment/historypay.dart';
import 'package:billiard/payment/payment_page.dart';
import 'package:billiard/payment/paymentpage.dart';
import 'package:billiard/product/productadmin.dart';
import 'package:flutter/material.dart';
import 'Cue/cuelist.dart';
import 'cuetype/cue_type_page.dart';
import 'Account/register.dart';
import 'Account/login.dart';
import 'Cue/cuelist.dart';
import 'cuetype/cue_type.dart';
import 'Cue/cuelist.dart';
import 'Account/account.dart';
import 'Cart/cart_page.dart';
import 'package:billiard/payment/payment.dart';
import 'product/product_list.dart';
import 'data/billard_helper.dart';

import 'Account/TrangThongTinCaNhan .dart';
import 'cuetype/cue_type_page.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await DatabaseHelper().database; // Ensure database is initialized

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      initialRoute:
          '/login', // Thiết lập màn hình đăng nhập là màn hình khởi đầu
      routes: {
        '/login': (context) =>
            LoginScreen(), // Định tuyến cho màn hình đăng nhập
        '/home': (context) => HomePage(
              accountId: ModalRoute.of(context)!.settings.arguments as int,
            ),

        '/cue_type': (context) => ProductListScreen(
            accountId: ModalRoute.of(context)!.settings.arguments as int),
        '/cue': (context) => CueScreen(),
        '/account': (context) => AccountListPage(),
        '/cart': (context) => CueTypeAdmin(),
        '/payment': (context) => ProductAdminPage(),
        '/donhang': (context) => PaymentPage(),
        '/revenue_management': (context) => RevenueManagementScreen(),
        '/cueall': (context) => CueAll(),
      },
      // Thiết lập màn hình chính
    );
  }
}
