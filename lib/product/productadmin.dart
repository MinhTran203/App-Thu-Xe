import 'package:flutter/material.dart';
import 'package:billiard/data/billard_helper.dart';

class ProductAdminPage extends StatefulWidget {
  const ProductAdminPage({Key? key}) : super(key: key);

  @override
  _ProductAdminPageState createState() => _ProductAdminPageState();
}

class _ProductAdminPageState extends State<ProductAdminPage> {
  late Future<List<Map<String, dynamic>>> _products;

  @override
  void initState() {
    super.initState();
    _refreshProducts();
  }

  Future<void> _refreshProducts() async {
    setState(() {
      _products = DatabaseHelper().getAllProducts();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Manage Products'),
      ),
      body: FutureBuilder<List<Map<String, dynamic>>>(
        future: _products,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return Center(child: Text('No products available.'));
          } else {
            return ListView.builder(
              itemCount: snapshot.data!.length,
              itemBuilder: (context, index) {
                final product = snapshot.data![index];
                return ListTile(
                  title: Text(product['name']),
                  subtitle: Text(product['description'] ?? ''),
                  leading: product['img'] != null
                      ? Image.asset(
                          'assets/images/${product['img']}',
                          width: 50,
                          height: 50,
                        )
                      : SizedBox(
                          width: 50,
                          height: 50,
                        ),
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      IconButton(
                        icon: Icon(Icons.edit),
                        onPressed: () {
                          _editProduct(context, product);
                        },
                      ),
                      IconButton(
                        icon: Icon(Icons.delete),
                        onPressed: () async {
                          await DatabaseHelper().deleteProduct(product['id']);
                          _refreshProducts();
                        },
                      ),
                    ],
                  ),
                  onTap: () {
                    // Handle tap to view details if needed
                  },
                );
              },
            );
          }
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          _addProduct(context);
        },
        child: Icon(Icons.add),
      ),
    );
  }

  Future<void> _addProduct(BuildContext context) async {
    final TextEditingController nameController = TextEditingController();
    final TextEditingController descriptionController = TextEditingController();
    final TextEditingController imgController = TextEditingController();

    await showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text('Add Product'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: nameController,
                decoration: InputDecoration(labelText: 'Name'),
              ),
              TextField(
                controller: descriptionController,
                decoration: InputDecoration(labelText: 'Description'),
              ),
              TextField(
                controller: imgController,
                decoration: InputDecoration(labelText: 'Image URL'),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: Text('Cancel'),
            ),
            TextButton(
              onPressed: () async {
                if (nameController.text.isEmpty) {
                  print('Name must not be empty');
                  return;
                }

                final newProduct = {
                  'name': nameController.text,
                  'description': descriptionController.text,
                  'img': imgController.text,
                };

                try {
                  await DatabaseHelper().insertProduct(newProduct);
                  _refreshProducts();
                } catch (e) {
                  print('Error inserting product: $e');
                }

                Navigator.of(context).pop();
              },
              child: Text('Add'),
            ),
          ],
        );
      },
    );
  }

  Future<void> _editProduct(
      BuildContext context, Map<String, dynamic> product) async {
    final TextEditingController nameController =
        TextEditingController(text: product['name']);
    final TextEditingController descriptionController =
        TextEditingController(text: product['description']);
    final TextEditingController imgController =
        TextEditingController(text: product['img']);

    await showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text('Edit Product'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: nameController,
                decoration: InputDecoration(labelText: 'Name'),
              ),
              TextField(
                controller: descriptionController,
                decoration: InputDecoration(labelText: 'Description'),
              ),
              TextField(
                controller: imgController,
                decoration: InputDecoration(labelText: 'Image URL'),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: Text('Cancel'),
            ),
            TextButton(
              onPressed: () async {
                if (nameController.text.isEmpty) {
                  print('Name must not be empty');
                  return;
                }

                final updatedProduct = {
                  'id': product['id'],
                  'name': nameController.text,
                  'description': descriptionController.text,
                  'img': imgController.text,
                };

                try {
                  await DatabaseHelper().updateProduct(updatedProduct);
                  _refreshProducts();
                } catch (e) {
                  print('Error updating product: $e');
                }

                Navigator.of(context).pop();
              },
              child: Text('Update'),
            ),
          ],
        );
      },
    );
  }
}
