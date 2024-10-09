import 'package:billiard/config/const.dart';
import 'package:flutter/material.dart';
import 'package:billiard/data/billard_helper.dart';
import 'package:billiard/payment/payment.dart';
import 'package:billiard/payment/historypay.dart';

class CartPage extends StatefulWidget {
  final int accountId;

  CartPage({required this.accountId});

  @override
  _CartPageState createState() => _CartPageState();
}

class _CartPageState extends State<CartPage> {
  late Future<List<Map<String, dynamic>>> _cartItemsFuture;

  @override
  void initState() {
    super.initState();
    _refreshCart();
  }

  void _refreshCart() {
    setState(() {
      _cartItemsFuture = _getCartItems();
    });
  }

  Future<List<Map<String, dynamic>>> _getCartItems() async {
    int cartId = await DatabaseHelper().getCartIdByAccountId(widget.accountId);
    if (cartId != -1) {
      return DatabaseHelper().getCartItemsWithCueDetails(cartId);
    } else {
      return [];
    }
  }

  @override
  Widget build(BuildContext context) {
    if (widget.accountId == -1) {
      return Scaffold(
        body: Center(
          child: Text('Vui lòng đăng nhập để xem giỏ hàng của bạn.'),
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: Text('Giỏ hàng của bạn'),
        actions: [
          IconButton(
            icon: Icon(Icons.history),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) =>
                      OrderHistoryPage(accountId: widget.accountId),
                ),
              );
            },
          ),
        ],
      ),
      body: Container(
        decoration: BoxDecoration(
          image: DecorationImage(
            image: AssetImage('assets/images/background.jpg'),
            fit: BoxFit.cover,
          ),
        ),
        child: FutureBuilder<List<Map<String, dynamic>>>(
          future: _cartItemsFuture,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return Center(child: CircularProgressIndicator());
            } else if (snapshot.hasError) {
              return Center(child: Text('Lỗi: ${snapshot.error}'));
            } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
              return Center(
                  child: Text('Không có mặt hàng nào trong giỏ hàng của bạn.'));
            } else {
              double totalPrice = snapshot.data!.fold(0, (sum, item) {
                return sum + (item['cue_price'] * item['quantity']);
              });

              return Column(
                children: [
                  Expanded(
                    child: ListView.builder(
                      itemCount: snapshot.data!.length,
                      itemBuilder: (context, index) {
                        var cartItem = snapshot.data![index];
                        return GestureDetector(
                          onTap: () {},
                          child: Card(
                            elevation: 5.0,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10.0),
                            ),
                            margin: EdgeInsets.symmetric(
                                horizontal: 16,
                                vertical: 10), // Cách trái phải 16
                            child: Padding(
                              padding: EdgeInsets.all(10.0),
                              child: Row(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  cartItem['cue_img'] != null
                                      ? ClipRRect(
                                          borderRadius:
                                              BorderRadius.circular(10.0),
                                          child: Image.asset(
                                            '$urlimg${cartItem['cue_img']}',
                                            width: 100,
                                            height: 100,
                                            fit: BoxFit.cover,
                                          ),
                                        )
                                      : SizedBox(
                                          width: 100,
                                          height: 100,
                                        ),
                                  SizedBox(width: 10),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          cartItem['cue_name'] ??
                                              'Cue ID: ${cartItem['cue_id']}',
                                          style: TextStyle(
                                            fontWeight: FontWeight.bold,
                                            fontSize: 18.0,
                                          ),
                                        ),
                                        SizedBox(height: 5.0),
                                        Text(
                                            'Mô tả: ${cartItem['cue_description']}'),
                                        Text(
                                            'Giá: ${cartItem['cue_price']} VND'),
                                        Text(
                                            'Số lượng: ${cartItem['quantity']}'),
                                      ],
                                    ),
                                  ),
                                  IconButton(
                                    icon: Icon(Icons.delete),
                                    onPressed: () async {
                                      await DatabaseHelper()
                                          .deleteCartItem(cartItem['id']);
                                      _refreshCart();
                                    },
                                  ),
                                ],
                              ),
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                  Card(
                    elevation: 5.0,
                    margin: EdgeInsets.all(16.0),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10.0),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          Text(
                            'Tổng giá: $totalPrice VND',
                            style: TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          SizedBox(height: 16),
                          ElevatedButton(
                            onPressed: () async {
                              int invoiceId =
                                  await _checkout(context, snapshot.data!);
                              _refreshCart();
                            },
                            style: ElevatedButton.styleFrom(
                              padding: EdgeInsets.symmetric(vertical: 16.0),
                              textStyle: TextStyle(fontSize: 18),
                              iconColor: Colors.blue, // Background color
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(10.0),
                              ),
                            ),
                            child: Text('Thanh toán'),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              );
            }
          },
        ),
      ),
    );
  }

  Future<int> _checkout(
      BuildContext context, List<Map<String, dynamic>> cartItems) async {
    double totalPrice = cartItems.fold(0, (sum, item) {
      return sum + (item['cue_price'] * item['quantity']);
    });

    int invoiceId =
        await DatabaseHelper().createInvoice(widget.accountId, totalPrice);
    await DatabaseHelper().clearCart(cartItems.first['cart_id']);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Thanh toán thành công!')),
    );

    return invoiceId;
  }
}
