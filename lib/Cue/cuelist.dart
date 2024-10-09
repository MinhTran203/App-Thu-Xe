import 'package:billiard/data/billard_helper.dart';
import 'package:flutter/material.dart';

import 'package:billiard/config/const.dart';
import 'package:billiard/Cart/cart_page.dart';

import 'package:billiard/data/billard_helper.dart';
import 'package:flutter/material.dart';

import 'package:billiard/config/const.dart';
import 'package:billiard/Cart/cart_page.dart';

class CueListScreen extends StatefulWidget {
  final int cueTypeId;
  final int accountId;

  CueListScreen({required this.cueTypeId, required this.accountId});

  @override
  _CueListScreenState createState() => _CueListScreenState();
}

class _CueListScreenState extends State<CueListScreen> {
  late Future<int> _cartItemCountFuture;
  late Future<List<Map<String, dynamic>>> _cuesFuture;
  TextEditingController _searchController = TextEditingController();
  List<Map<String, dynamic>> _cues = [];
  List<Map<String, dynamic>> _filteredCues = [];
  bool _isActive = true;

  @override
  void initState() {
    super.initState();
    _cartItemCountFuture = _getCartItemCount();
    _cuesFuture = _loadCues();
  }

  @override
  void dispose() {
    _isActive = false;
    _searchController.dispose();
    super.dispose();
  }

  Future<List<Map<String, dynamic>>> _loadCues() async {
    _cues = await DatabaseHelper().getCuesByCueTypeId(widget.cueTypeId);
    _filteredCues = List.from(_cues);
    return _filteredCues;
  }

  void _performSearch() {
    String query = _searchController.text.toLowerCase();
    setState(() {
      _filteredCues = _cues.where((cue) {
        return cue['name'].toLowerCase().contains(query);
      }).toList();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: TextField(
          controller: _searchController,
          decoration: InputDecoration(
            hintText: 'Search by cue name...',
            border: InputBorder.none,
          ),
          style: TextStyle(color: Color.fromARGB(255, 33, 33, 33)),
          onChanged: (value) {
            _performSearch();
          },
        ),
        actions: [
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
                      onPressed: () {
                        if (widget.accountId == -1) {
                          Navigator.pushReplacementNamed(context, '/login');
                        } else {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) =>
                                  CartPage(accountId: widget.accountId),
                            ),
                          );
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
        ],
      ),
      body: FutureBuilder<List<Map<String, dynamic>>>(
        future: _cuesFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return Center(child: Text('No cues found for this cue type.'));
          } else {
            return GridView.builder(
              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                childAspectRatio: 0.7,
                crossAxisSpacing: 16,
                mainAxisSpacing: 16,
              ),
              itemCount: _filteredCues.length,
              itemBuilder: (context, index) {
                var cue = _filteredCues[index];
                return _buildCueItem(context, cue);
              },
            );
          }
        },
      ),
    );
  }

  Widget _buildCueItem(BuildContext context, Map<String, dynamic> cue) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        color: Colors.yellow[100],
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.5),
            spreadRadius: 2,
            blurRadius: 5,
            offset: Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ClipRRect(
            borderRadius: BorderRadius.only(
              topLeft: Radius.circular(12),
              topRight: Radius.circular(12),
            ),
            child: Image.asset(
              urlimg + cue['img'],
              width: double.infinity,
              height: 140,
              fit: BoxFit.cover,
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  cue['name'],
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
                SizedBox(height: 4),
                Text(
                  '\$${cue['price']}',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: Colors.green,
                    fontSize: 14,
                  ),
                ),
                Align(
                  alignment: Alignment.bottomRight,
                  child: IconButton(
                    icon: Icon(Icons.add_shopping_cart),
                    onPressed: () async {
                      if (widget.accountId == -1) {
                        Navigator.pushReplacementNamed(context, '/login');
                      } else {
                        await _addToCart(context, cue['id']);
                      }
                    },
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _addToCart(BuildContext context, int cueId) async {
    DatabaseHelper db = DatabaseHelper();
    int cartId = await db.getCartIdByAccountId(widget.accountId);

    if (cartId == -1) {
      cartId = await db
          .insertCart({'account_id': widget.accountId, 'total_price': 0.0});
    }

    Map<String, dynamic> cartItem = {
      'cart_id': cartId,
      'cue_id': cueId,
      'quantity': 1,
    };

    await db.insertCartItem(cartItem);

    if (_isActive) {
      setState(() {
        _cartItemCountFuture = _getCartItemCount();
      });
    }

    int itemCount = await _cartItemCountFuture;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
          content: Text(
              'Đã thêm vào giỏ hàng. Số lượng sản phẩm trong giỏ hàng: $itemCount')),
    );
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
}
