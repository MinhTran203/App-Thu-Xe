import 'package:flutter/material.dart';
import 'package:billiard/data/billard_helper.dart';

class AccountListPage extends StatefulWidget {
  @override
  _AccountListPageState createState() => _AccountListPageState();
}

class _AccountListPageState extends State<AccountListPage> {
  late Future<List<Map<String, dynamic>>> _accounts;
  late TextEditingController _usernameController;
  late TextEditingController _passwordController; // Thêm biến cho mật khẩu
  late TextEditingController _emailController;
  late DatabaseHelper _databaseHelper;

  @override
  void initState() {
    super.initState();
    _databaseHelper = DatabaseHelper();
    _accounts = _databaseHelper.getAllAccounts();
    _usernameController = TextEditingController();
    _passwordController = TextEditingController(); // Khởi tạo biến mật khẩu
    _emailController = TextEditingController();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Account List',
          style: TextStyle(color: Colors.black87),
        ),
        backgroundColor: Colors.yellow,
        centerTitle: true,
        elevation: 0,
      ),
      body: FutureBuilder<List<Map<String, dynamic>>>(
        future: _accounts,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(
              child: CircularProgressIndicator(),
            );
          } else if (snapshot.hasError) {
            return Center(
              child: Text('Error: ${snapshot.error}'),
            );
          } else {
            final accounts = snapshot.data!;
            return ListView.builder(
              itemCount: accounts.length,
              itemBuilder: (context, index) {
                final account = accounts[index];
                return Padding(
                  padding: const EdgeInsets.symmetric(
                      vertical: 8.0, horizontal: 16.0),
                  child: Card(
                    elevation: 2,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: ListTile(
                      title: Text(
                        account['username'],
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                      subtitle: Text(account['email']),
                      trailing: IconButton(
                        icon: Icon(Icons.edit),
                        onPressed: () {
                          _showEditDialog(account);
                        },
                      ),
                    ),
                  ),
                );
              },
            );
          }
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          _showAddDialog();
        },
        backgroundColor: Colors.yellow,
        child: Icon(Icons.add),
      ),
    );
  }

  void _showAddDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Add Account'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: <Widget>[
                TextField(
                  controller: _usernameController,
                  decoration: InputDecoration(labelText: 'Username'),
                ),
                TextField(
                  controller: _passwordController,
                  obscureText: true, // Ẩn mật khẩu
                  decoration: InputDecoration(labelText: 'Password'),
                ),
                TextField(
                  controller: _emailController,
                  decoration: InputDecoration(labelText: 'Email'),
                ),
              ],
            ),
          ),
          actions: <Widget>[
            TextButton(
              child: Text('Cancel'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            TextButton(
              child: Text('Add'),
              onPressed: () {
                _addAccount();
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  void _addAccount() async {
    Map<String, dynamic> newAccount = {
      'username': _usernameController.text,
      'password': _passwordController.text,
      'email': _emailController.text,
    };
    await _databaseHelper.insertAccount(newAccount);
    setState(() {
      _accounts = _databaseHelper.getAllAccounts();
      _usernameController.clear();
      _passwordController.clear();
      _emailController.clear();
    });
  }

  void _showEditDialog(Map<String, dynamic> account) {
    _usernameController.text = account['username'];
    _passwordController.text = account['password'];
    _emailController.text = account['email'];

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Edit Account'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: <Widget>[
                TextField(
                  controller: _usernameController,
                  decoration: InputDecoration(labelText: 'Username'),
                ),
                TextField(
                  controller: _passwordController,
                  obscureText: true, // Ẩn mật khẩu
                  decoration: InputDecoration(labelText: 'Password'),
                ),
                TextField(
                  controller: _emailController,
                  decoration: InputDecoration(labelText: 'Email'),
                ),
              ],
            ),
          ),
          actions: <Widget>[
            TextButton(
              child: Text('Cancel'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            TextButton(
              child: Text('Save'),
              onPressed: () {
                _editAccount(account['id']);
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  void _editAccount(int accountId) async {
    Map<String, dynamic> updatedAccount = {
      'id': accountId,
      'username': _usernameController.text,
      'password': _passwordController.text,
      'email': _emailController.text,
    };
    await _databaseHelper.updateAccount(updatedAccount);
    setState(() {
      _accounts = _databaseHelper.getAllAccounts();
      _usernameController.clear();
      _passwordController.clear();
      _emailController.clear();
    });
  }
}
