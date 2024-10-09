import 'package:flutter/material.dart';

class StoreManagementPage extends StatefulWidget {
  const StoreManagementPage({Key? key}) : super(key: key);

  @override
  State<StoreManagementPage> createState() => _StoreManagementPageState();
}

class _StoreManagementPageState extends State<StoreManagementPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'LOUIS BILLIARD SHOP',
          style: TextStyle(
            color: Colors.black87,
            fontFamily: 'Roboto',
            fontWeight: FontWeight.bold,
          ),
        ),
        backgroundColor: Colors.amber,
        centerTitle: true,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Container(
              height: 200.0,
              child: Stack(
                alignment: Alignment.bottomCenter,
                children: [
                  PageView.builder(
                    itemCount: 5,
                    itemBuilder: (context, index) {
                      return Image.asset(
                        'assets/images/anhbia2.png',
                        fit: BoxFit.cover,
                      );
                    },
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      IconButton(
                        icon: Icon(Icons.arrow_back_ios),
                        onPressed: () {},
                      ),
                      IconButton(
                        icon: Icon(Icons.arrow_forward_ios),
                        onPressed: () {},
                      ),
                    ],
                  ),
                ],
              ),
            ),
            SizedBox(height: 20.0),
            Align(
              alignment: Alignment.center,
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Text(
                  'Danh Mục',
                  style: TextStyle(
                    fontSize: 24.0,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
            Container(
              height: 160.0,
              child: ListView(
                scrollDirection: Axis.horizontal,
                children: [
                  _buildManagementCard(
                    Icons.inventory,
                    'Sản Phẩm',
                    () {
                      // Handle tap for 'Sản Phẩm' card
                      Navigator.pushNamed(context, '/cueall');
                    },
                  ),
                  _buildManagementCard(
                    Icons.local_shipping,
                    'Đơn Hàng',
                    () {
                      // Handle tap for 'Đơn Hàng' card
                      Navigator.pushNamed(context, '/donhang');
                    },
                  ),
                  _buildManagementCard(
                    Icons.account_circle,
                    'Quản Lý Tài Khoản',
                    () {
                      // Handle tap for 'Quản Lý Tài Khoản' card
                      Navigator.pushNamed(context, '/account');
                    },
                  ),
                  _buildManagementCard(
                    Icons.pie_chart,
                    'Quản Lý Doanh Thu',
                    () {
                      // Handle tap for 'Quản Lý Doanh Thu' card
                      Navigator.pushNamed(context, '/revenue_management');
                    },
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildManagementCard(
    IconData icon,
    String title,
    VoidCallback onTap,
  ) {
    return Container(
      width: 160.0,
      margin: EdgeInsets.symmetric(horizontal: 10.0),
      child: Card(
        elevation: 5.0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10.0),
        ),
        child: InkWell(
          onTap: onTap,
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(icon, size: 50),
                SizedBox(height: 10),
                Text(
                  title,
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 16),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
