import 'dart:ui';

import 'package:billiard/cuetype/cue_type.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import '../data/billard_helper.dart';
import '../Cart/cart_page.dart';

class HomePage extends StatefulWidget {
  final int accountId;

  HomePage({required this.accountId});

  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final PageController _pageController = PageController();
  final List<String> _imagePaths = [
    'assets/images/anhbia1.png',
    'assets/images/anhbia2.png',
    'assets/images/anhbia3.png',
  ];
  int _currentPage = 0;
  bool _isLoggedIn = false;
  late Future<int> _cartItemCountFuture;
  late DatabaseHelper db;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    db = DatabaseHelper();
  }

  @override
  void initState() {
    super.initState();
    _checkLoginStatus();
    _startAutoScroll();
    _cartItemCountFuture = _getCartItemCount();
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  void _checkLoginStatus() {
    setState(() {
      _isLoggedIn = widget.accountId != -1; // Giả sử -1 là không đăng nhập
    });
  }

  void _startAutoScroll() {
    Future.delayed(Duration(seconds: 10), () {
      if (_pageController.hasClients) {
        final nextPage = (_currentPage + 1) % _imagePaths.length;
        _pageController.animateToPage(
          nextPage,
          duration: Duration(milliseconds: 2000),
          curve: Curves.easeInOut,
        );
        setState(() {
          _currentPage = nextPage;
        });
      }
      _startAutoScroll();
    });
  }

  Future<int> _getCartItemCount() async {
    DatabaseHelper db = DatabaseHelper();
    int cartId = await db.getCartIdByAccountId(widget.accountId);
    if (cartId != -1) {
      return await db.countCartItems(cartId);
    } else {
      return 0;
    }
  }

  void _refreshCartItemCount() {
    setState(() {
      _cartItemCountFuture = _getCartItemCount();
    });
  }

  void _logout() {
    setState(() {
      _isLoggedIn = false;
      Navigator.pushReplacementNamed(context, '/login');
    });
  }

  Widget _buildTableItem(
    String tableName,
    String route,
    String imagePath,
    Color color,
  ) {
    return GestureDetector(
      onTap: () {
        if (_isLoggedIn) {
          Navigator.pushNamed(
            context,
            route,
            arguments: widget.accountId,
          );
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Please log in to access this feature')),
          );
        }
      },
      child: Container(
        width: 160.0, // Độ rộng của mỗi mục
        margin: EdgeInsets.symmetric(horizontal: 10.0),
        child: Card(
          elevation: 5.0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10.0),
            side: BorderSide(
              width: 2,
              color: Colors.yellow, // Màu sắc và độ dày border
            ),
          ),
          color: Colors.white, // Màu nền của Card là trắng
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Container(
                height: 80.0,
                width: 80.0,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: _isLoggedIn ? color : Colors.grey,
                ),
                child: Image.asset(
                  imagePath,
                  fit: BoxFit.contain,
                  color: _isLoggedIn ? null : Colors.grey,
                ),
              ),
              SizedBox(height: 10.0),
              Text(
                tableName,
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 16.0,
                  fontWeight: FontWeight.bold,
                  color: _isLoggedIn
                      ? Colors.black
                      : Colors.grey, // Màu sắc văn bản
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

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
        actions: _isLoggedIn
            ? [
                FutureBuilder<int>(
                  future: _cartItemCountFuture,
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return IconButton(
                        icon: Icon(Icons.shopping_cart),
                        onPressed: null,
                      );
                    } else {
                      int itemCount = snapshot.data ?? 0;
                      return Stack(
                        children: [
                          IconButton(
                            icon: Icon(Icons.shopping_cart),
                            onPressed: () async {
                              if (widget.accountId == -1) {
                                Navigator.pushReplacementNamed(
                                    context, '/login');
                              } else {
                                await Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) =>
                                        CartPage(accountId: widget.accountId),
                                  ),
                                );
                                _refreshCartItemCount();
                              }
                            },
                            tooltip: 'Cart ($itemCount)',
                          ),
                          Positioned(
                            right: 6,
                            top: 6,
                            child: Container(
                              padding: EdgeInsets.all(2),
                              decoration: BoxDecoration(
                                color: Colors.red,
                                borderRadius: BorderRadius.circular(10),
                              ),
                              constraints: BoxConstraints(
                                minWidth: 16,
                                minHeight: 16,
                              ),
                              child: Text(
                                '$itemCount',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 10,
                                ),
                                textAlign: TextAlign.center,
                              ),
                            ),
                          ),
                        ],
                      );
                    }
                  },
                ),
                IconButton(
                  icon: Icon(Icons.logout),
                  onPressed: _logout,
                ),
              ]
            : [],
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
                    controller: _pageController,
                    onPageChanged: (int page) {
                      setState(() {
                        _currentPage = page;
                      });
                      _startAutoScroll();
                    },
                    itemBuilder: (BuildContext context, int index) {
                      return Image.asset(
                        _imagePaths[index],
                        fit: BoxFit.cover,
                      );
                    },
                    itemCount: _imagePaths.length,
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      IconButton(
                        icon: Icon(Icons.arrow_back_ios),
                        onPressed: () {
                          _pageController.previousPage(
                            duration: Duration(milliseconds: 500),
                            curve: Curves.easeInOut,
                          );
                        },
                      ),
                      IconButton(
                        icon: Icon(Icons.arrow_forward_ios),
                        onPressed: () {
                          _pageController.nextPage(
                            duration: Duration(milliseconds: 500),
                            curve: Curves.easeInOut,
                          );
                        },
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
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                itemCount: 5,
                itemBuilder: (context, index) {
                  return _buildTableItem(
                    index == 0
                        ? 'Xem Sản Phẩm'
                        : index == 1
                            ? 'Quản Lí Chi Tiết Sản Phẩm'
                            : index == 2
                                ? 'Quản Lí Tài Khoản'
                                : index == 3
                                    ? "Quản Lí Loại Sản Phẩm "
                                    : 'Quản Lí Sản Phẩm',
                    index == 0
                        ? '/cue_type'
                        : index == 1
                            ? '/cue'
                            : index == 2
                                ? '/account'
                                : index == 3
                                    ? '/cart'
                                    : '/payment',
                    index == 0
                        ? 'assets/images/fury.png'
                        : index == 1
                            ? 'assets/images/mezzcues.png'
                            : index == 2
                                ? 'assets/images/peri.png'
                                : index == 3
                                    ? 'assets/images/rhino.png'
                                    : 'assets/images/mit.png',
                    index == 0
                        ? Colors.white
                        : index == 1
                            ? Colors.white
                            : index == 2
                                ? Colors.white
                                : index == 3
                                    ? Colors.white
                                    : Colors.white,
                  );
                },
              ),
            ),
            SizedBox(height: 20.0),
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Text(
                'Loại Sản Phẩm',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 24.0,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            Container(
              height: 250.0,
              child: FutureBuilder<List<Map<String, dynamic>>>(
                future: db.getAllProducts(),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return Center(child: CircularProgressIndicator());
                  } else if (snapshot.hasError) {
                    return Center(child: Text('Error: ${snapshot.error}'));
                  } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                    return Center(child: Text('No products found.'));
                  } else {
                    final products = snapshot.data!;
                    return ListView.builder(
                      scrollDirection: Axis.horizontal,
                      itemCount: products.length,
                      itemBuilder: (context, index) {
                        final product = products[index];
                        return _buildProductItem(product);
                      },
                    );
                  }
                },
              ),
            ),
            SizedBox(height: 20.0),
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Text(
                'Sản Phẩm Mới Nhất',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 24.0,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            Container(
              height: 250.0,
              child: FutureBuilder<List<Map<String, dynamic>>>(
                future: db
                    .getAllCues(), // Sử dụng hàm để lấy danh sách các mặt hàng Cue mới nhất từ database
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return Center(child: CircularProgressIndicator());
                  } else if (snapshot.hasError) {
                    return Center(child: Text('Error: ${snapshot.error}'));
                  } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                    return Center(child: Text('No cues found.'));
                  } else {
                    final cues = snapshot.data!;
                    return ListView.builder(
                      scrollDirection: Axis.horizontal,
                      itemCount: cues.length,
                      itemBuilder: (context, index) {
                        final cue = cues[index];
                        return _buildCueItem(cue);
                      },
                    );
                  }
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCueItem(Map<String, dynamic> cue) {
    final imagePath = 'assets/images/${cue['img']}';
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => CueTypeScreen(
              productId:
                  cue['id'], // Sử dụng cue['id'] thay vì widget.productId
              accountId: widget.accountId,
            ),
          ),
        );
      },
      child: Container(
        width: 200.0,
        color: Colors.yellow, // Màu nền của mỗi Card chứa mặt hàng Cue
        margin: EdgeInsets.symmetric(horizontal: 10.0),
        child: Card(
          elevation: 5.0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10.0),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Image.asset(
                imagePath,
                fit: BoxFit.cover,
                height: 150.0,
              ),
              SizedBox(height: 10.0),
              Text(
                cue['name'],
                style: TextStyle(
                  fontSize: 16.0,
                  fontWeight: FontWeight.bold,
                ),
              ),
              SizedBox(height: 10.0),
              Text(
                '${cue['price']} VNĐ', // Hiển thị giá của mặt hàng Cue
                style: TextStyle(
                  fontSize: 14.0,
                  color: Colors.grey,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildProductItem(Map<String, dynamic> product) {
    final imagePath = 'assets/images/${product['img']}';
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => CueTypeScreen(
              productId: product[
                  'id'], // Sử dụng product['id'] thay vì widget.productId
              accountId: widget.accountId,
            ),
          ),
        );
      },
      child: Container(
        width: 200.0,
        color: Colors.blue, // Màu nền của mỗi Card chứa sản phẩm
        margin: EdgeInsets.symmetric(horizontal: 10.0),
        child: Card(
          elevation: 5.0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10.0),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Image.asset(
                imagePath,
                fit: BoxFit.cover,
                height: 150.0,
              ),
              SizedBox(height: 10.0),
              Text(
                product['name'],
                style: TextStyle(
                  fontSize: 16.0,
                  fontWeight: FontWeight.bold,
                ),
              ),
              SizedBox(height: 10.0),
            ],
          ),
        ),
      ),
    );
  }
}
