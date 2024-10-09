import 'dart:convert';

import 'package:billiard/Cart/RevenueManagementScreen%20.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart' show rootBundle;
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

class DatabaseHelper {
  static final DatabaseHelper _databaseService = DatabaseHelper._internal();
  factory DatabaseHelper() => _databaseService;
  DatabaseHelper._internal();

  static Database? _database;
  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDatabase();

    return _database!;
  }

  Future<Database> _initDatabase() async {
    final databasePath = await getDatabasesPath();
    final path = join(databasePath, 'billiard_shop.db');

    print(
        "Database path: $databasePath"); // Hiển thị đường dẫn tệp cơ sở dữ liệu
    return await openDatabase(
      path,
      onCreate: _onCreate,
      version: 1,
      onOpen: (db) async {
        // Thực hiện các thao tác cần thiết khi mở cơ sở dữ liệu
      },
    );
  }

  Future<void> _onCreate(Database db, int version) async {
    await db.execute('''
      CREATE TABLE Product (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        name TEXT NOT NULL,
        description TEXT,
        img TEXT
      )
    ''');

    await db.execute('''
      CREATE TABLE CueType (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        name TEXT NOT NULL,
        img TEXT,
        description TEXT,
        product_id INTEGER,
        FOREIGN KEY (product_id) REFERENCES Product(id)
      )
    ''');

    await db.execute('''
      CREATE TABLE Cue (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        name TEXT NOT NULL,
        description TEXT,
        img TEXT,
        price REAL NOT NULL,
        cue_type_id INTEGER,
        FOREIGN KEY (cue_type_id) REFERENCES CueType(id)
      )
    ''');

    await db.execute('''
      CREATE TABLE Account (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        username TEXT NOT NULL UNIQUE,
        password TEXT NOT NULL,
        email TEXT NOT NULL UNIQUE
      )
    ''');

    await db.execute('''
      CREATE TABLE Cart (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        account_id INTEGER,
        total_price REAL,
        created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
        FOREIGN KEY (account_id) REFERENCES Account(id)
      )
    ''');

    await db.execute('''
      CREATE TABLE CartItem (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        cart_id INTEGER,
        cue_id INTEGER,
        quantity INTEGER NOT NULL DEFAULT 1,
        FOREIGN KEY (cart_id) REFERENCES Cart(id),
        FOREIGN KEY (cue_id) REFERENCES Cue(id)
      )
    ''');

    await db.execute('''
      CREATE TABLE Invoice (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        account_id INTEGER,
        total_price REAL,
        created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
        FOREIGN KEY (account_id) REFERENCES Account(id)
      )
    ''');

    await db.execute('''
      CREATE TABLE InvoiceItem (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        invoice_id INTEGER,
        cue_id INTEGER,
        quantity INTEGER NOT NULL,
        price REAL NOT NULL,
        FOREIGN KEY (invoice_id) REFERENCES Invoice(id),
        FOREIGN KEY (cue_id) REFERENCES Cue(id)
      )
    ''');

    await db.execute('''
      CREATE TABLE Payment (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        account_id INTEGER,
        amount REAL NOT NULL,
        payment_date TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
        FOREIGN KEY (account_id) REFERENCES Account(id)
      )
    
    ''');
  }

  Future<void> _deleteIfExists(
      Database db, String table, String column, dynamic value) async {
    await db.delete(table, where: '$column = ?', whereArgs: [value]);
  }

  // CRUD operations for Product table
  Future<int> insertProduct(Map<String, dynamic> product) async {
    Database db = await database;
    return await db.insert('Product', product);
  }

  Future<List<Map<String, dynamic>>> getAllInvoices() async {
    final db = await database;
    return await db.query('Invoice');
  }

  Future<int> updateProduct(Map<String, dynamic> product) async {
    Database db = await database;
    return await db.update('Product', product,
        where: 'id = ?', whereArgs: [product['id']]);
  }

  Future<int> deleteProduct(int id) async {
    Database db = await database;
    return await db.delete('Product', where: 'id = ?', whereArgs: [id]);
  }

  Future<List<Map<String, dynamic>>> getAllProducts() async {
    Database db = await database;
    return await db.query('Product');
  }

  // CRUD operations for CueType table
  Future<int> insertCueType(Map<String, dynamic> cueType) async {
    Database db = await database;
    return await db.insert('CueType', cueType);
  }

  Future<int> updateCueType(Map<String, dynamic> cueType) async {
    Database db = await database;
    return await db.update('CueType', cueType,
        where: 'id = ?', whereArgs: [cueType['id']]);
  }

  Future<int> deleteCueType(int id) async {
    Database db = await database;
    return await db.delete('CueType', where: 'id = ?', whereArgs: [id]);
  }

  Future<List<Map<String, dynamic>>> getAllCueTypes() async {
    Database db = await database;
    return await db.query('CueType');
  }

  // CRUD operations for Cue table
  Future<int> insertCue(Map<String, dynamic> cue) async {
    Database db = await database;
    return await db.insert('Cue', cue);
  }

  Future<int> updateCue(Map<String, dynamic> cue) async {
    Database db = await database;
    return await db.update('Cue', cue, where: 'id = ?', whereArgs: [cue['id']]);
  }

  Future<int> deleteCue(int id) async {
    Database db = await database;
    return await db.delete('Cue', where: 'id = ?', whereArgs: [id]);
  }

  Future<List<Map<String, dynamic>>> getAllCues() async {
    Database db = await database;
    return await db.query('Cue');
  }

  // CRUD operations for Account table
  Future<int> insertAccount(Map<String, dynamic> account) async {
    Database db = await database;
    return await db.insert('Account', account);
  }

  Future<int> updateAccount(Map<String, dynamic> account) async {
    Database db = await database;
    return await db.update('Account', account,
        where: 'id = ?', whereArgs: [account['id']]);
  }

  Future<int> deleteAccount(int id) async {
    Database db = await database;
    return await db.delete('Account', where: 'id = ?', whereArgs: [id]);
  }

  Future<List<Map<String, dynamic>>> getAllAccounts() async {
    Database db = await database;
    return await db.query('Account');
  }

  // CRUD operations for Cart table
  Future<int> insertCart(Map<String, dynamic> cart) async {
    Database db = await database;
    return await db.insert('Cart', cart);
  }

  Future<List<Map<String, dynamic>>> getAllCarts() async {
    Database db = await database;
    return await db.query('Cart');
  }

  Future<int> updateCart(Map<String, dynamic> cart) async {
    Database db = await database;
    return await db
        .update('Cart', cart, where: 'id = ?', whereArgs: [cart['id']]);
  }

  Future<int> deleteCart(int id) async {
    Database db = await database;
    return await db.delete('Cart', where: 'id = ?', whereArgs: [id]);
  }

  // CRUD operations for CartItem table
  Future<int> insertCartItem(Map<String, dynamic> cartItem) async {
    Database db = await database;
    return await db.insert('CartItem', cartItem);
  }

  // CRUD operations for CartItem table
  Future<int> updateCartItem(Map<String, dynamic> cartItem) async {
    Database db = await database;
    return await db.update('CartItem', cartItem,
        where: 'id = ?', whereArgs: [cartItem['id']]);
  }

  Future<int> deleteCartItem(int id) async {
    Database db = await database;
    return await db.delete('CartItem', where: 'id = ?', whereArgs: [id]);
  }

  Future<List<Map<String, dynamic>>> getCartItems(int cartId) async {
    Database db = await database;
    return await db
        .query('CartItem', where: 'cart_id = ?', whereArgs: [cartId]);
  }

// CRUD operations for Invoice table
  Future<int> insertInvoice(Map<String, dynamic> invoice) async {
    Database db = await database;
    return await db.insert('Invoice', invoice);
  }

  Future<List<Map<String, dynamic>>> getInvoicesByAccountId(
      int accountId) async {
    Database db = await database;
    return await db
        .query('Invoice', where: 'account_id = ?', whereArgs: [accountId]);
  }

// CRUD operations for InvoiceItem table
  Future<int> insertInvoiceItem(Map<String, dynamic> invoiceItem) async {
    Database db = await database;
    return await db.insert('InvoiceItem', invoiceItem);
  }

  Future<List<Map<String, dynamic>>> getInvoiceItemsByInvoiceId(
      int invoiceId) async {
    Database db = await database;
    return await db
        .query('InvoiceItem', where: 'invoice_id = ?', whereArgs: [invoiceId]);
  }

// CRUD operations for Payment table
  Future<int> insertPayment(Map<String, dynamic> payment) async {
    Database db = await database;
    return await db.insert('Payment', payment);
  }

  Future<List<Map<String, dynamic>>> getAllPayments() async {
    Database db = await database;
    return await db.query('Payment');
  }

  Future<int> deletePayment(int id) async {
    Database db = await database;
    return await db.delete('Payment', where: 'id = ?', whereArgs: [id]);
  }

// Additional helper functions

  Future<int> getCartIdByAccountId(int accountId) async {
    Database db = await database;
    List<Map<String, dynamic>> carts = await db.query('Cart',
        where: 'account_id = ?',
        whereArgs: [accountId],
        orderBy: 'created_at DESC',
        limit: 1);
    if (carts.isNotEmpty) {
      return carts.first['id'];
    } else {
      return -1; // Return -1 if no cart found
    }
  }

  Future<void> clearCart(int cartId) async {
    Database db = await database;
    await db.delete('CartItem', where: 'cart_id = ?', whereArgs: [cartId]);
  }

  Future<int> createInvoice(int accountId, double totalPrice) async {
    Database db = await database;
    return await db.insert('Invoice', {
      'account_id': accountId,
      'total_price': totalPrice,
    });
  }

  Future<Map<String, dynamic>?> getInvoiceDetails(int invoiceId) async {
    Database db = await database;
    List<Map<String, dynamic>> results = await db.query(
      'Invoice',
      where: 'id = ?',
      whereArgs: [invoiceId],
    );

    if (results.isNotEmpty) {
      return results.first;
    } else {
      return null;
    }
  }

  Future<List<Map<String, dynamic>>> getCuesByCueTypeId(int cueTypeId) async {
    Database db = await database;
    return await db
        .query('Cue', where: 'cue_type_id = ?', whereArgs: [cueTypeId]);
  }

  Future<List<Map<String, dynamic>>> getCueTypesByProductId(
      int productId) async {
    Database db = await database;
    return await db
        .query('CueType', where: 'product_id = ?', whereArgs: [productId]);
  }

  Future<Map<String, dynamic>?> getProductById(int id) async {
    Database db = await database;
    List<Map<String, dynamic>> results = await db.query(
      'Product',
      where: 'id = ?',
      whereArgs: [id],
    );

    if (results.isNotEmpty) {
      return results.first;
    } else {
      return null;
    }
  }

  Future<List<Map<String, dynamic>>> getCartItemsWithCueDetails(
      int cartId) async {
    Database db = await database;
    return await db.rawQuery('''
      SELECT CartItem.*, 
             Cue.name AS cue_name, 
             Cue.description AS cue_description, 
             Cue.img AS cue_img, 
             Cue.price AS cue_price
      FROM CartItem
      INNER JOIN Cue ON CartItem.cue_id = Cue.id
      WHERE CartItem.cart_id = ?
    ''', [cartId]);
  }

  Future<Map<String, dynamic>?> authenticateUser(
      String username, String password) async {
    Database db = await database;
    final List<Map<String, dynamic>> users = await db.query(
      'Account',
      where: 'username = ? AND password = ?',
      whereArgs: [username, password],
    );

    return users.isNotEmpty ? users.first : null;
  }

  Future<void> insertSampleData() async {
    // Lấy đối tượng Database
    Database db = await database;

    // Insert một số dữ liệu mẫu cho bảng Product
    await insertProduct({
      'name': 'Cue Stick 1',
      'description': 'High-quality cue stick for professionals',
      'img': 'anhco.png',
    });

    await insertProduct({
      'name': 'Cue Stick 2',
      'description': 'Entry-level cue stick for beginners',
      'img': 'anhbi.png',
    });

    // Insert một số dữ liệu mẫu cho bảng CueType
    await insertCueType({
      'name': 'Professional Cue',
      'img': 'furyop.png',
      'description': 'Cue sticks designed for professional players',
      'product_id': 1, // Thay đổi ID sản phẩm tương ứng
    });

    await insertCueType({
      'name': 'Beginner Cue',
      'img': 'rhino.png',
      'description': 'Cue sticks designed for beginners',
      'product_id': 1, // Thay đổi ID sản phẩm tương ứng
    });

    // Insert một số dữ liệu mẫu cho bảng Cue
    await insertCue({
      'name': 'Professional Cue Model A',
      'description': 'Premium cue stick for serious players',
      'img': 'furyly.png',
      'price': 299.99,
      'cue_type_id': 1, // Thay đổi ID loại cue tương ứng
    });

    await insertCue({
      'name': 'Beginner Cue Model X',
      'description': 'Affordable cue stick for new players',
      'img': 'mit.png',
      'price': 49.99,
      'cue_type_id': 1, // Thay đổi ID loại cue tương ứng
    });

    // Insert một số dữ liệu mẫu cho bảng Account
    await insertAccount({
      'username': 'phat',
      'password': '123',
      'email': 'john.doe@example.com',
    });

    await insertAccount({
      'username': 'jane_smith',
      'password': 'jane456',
      'email': 'jane.smith@example.com',
    });

    print('Sample data inserted successfully.');
  }

  Future<int> countCartItems(int cartId) async {
    Database db = await database;
    List<Map<String, dynamic>> countResult = await db.rawQuery('''
    SELECT COUNT(*) AS count
    FROM CartItem
    WHERE cart_id = ?
  ''', [cartId]);

    int count = Sqflite.firstIntValue(countResult)!;
    return count;
  }

  Future<List<Map<String, dynamic>>> getAllInvoicesWithUsernames() async {
    final db = await database;
    return await db.rawQuery('''
      SELECT 
        Invoice.id AS invoice_id, 
        Account.username AS username,
        Invoice.total_price, 
        Invoice.created_at 
      FROM Invoice 
      INNER JOIN Account ON Invoice.account_id = Account.id
    ''');
  }
}
