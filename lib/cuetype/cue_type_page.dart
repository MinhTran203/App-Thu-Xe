import 'package:billiard/data/billard_helper.dart';
import 'package:flutter/material.dart';
import 'package:billiard/config/const.dart';

class CueTypeAdmin extends StatefulWidget {
  const CueTypeAdmin({Key? key}) : super(key: key);

  @override
  State<CueTypeAdmin> createState() => _CueTypeAdminState();
}

class _CueTypeAdminState extends State<CueTypeAdmin> {
  late Future<List<Map<String, dynamic>>> _cueTypes;

  @override
  void initState() {
    super.initState();
    _refreshCueTypes();
  }

  Future<void> _refreshCueTypes() async {
    setState(() {
      _cueTypes = DatabaseHelper().getAllCueTypes();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Cue Types'),
      ),
      body: FutureBuilder<List<Map<String, dynamic>>>(
        future: _cueTypes,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return Center(child: Text('No cue types available.'));
          } else {
            return ListView.builder(
              itemCount: snapshot.data!.length,
              itemBuilder: (context, index) {
                final cueType = snapshot.data![index];
                return ListTile(
                  title: Text(cueType['name']),
                  subtitle: Text(cueType['description']),
                  leading: cueType['img'] != null
                      ? Image.asset(
                          urlimg + cueType['img'],
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
                          _editCueType(context, cueType);
                        },
                      ),
                      IconButton(
                        icon: Icon(Icons.delete),
                        onPressed: () async {
                          await DatabaseHelper().deleteCueType(cueType['id']);
                          _refreshCueTypes();
                        },
                      ),
                    ],
                  ),
                  onTap: () {
                    // Display detailed information
                  },
                );
              },
            );
          }
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          _addCueType(context);
        },
        child: Icon(Icons.add),
      ),
    );
  }

  Future<void> _addCueType(BuildContext context) async {
    final TextEditingController nameController = TextEditingController();
    final TextEditingController descriptionController = TextEditingController();
    final TextEditingController imgController = TextEditingController();
    final TextEditingController productIdController = TextEditingController();

    await showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text('Add Cue Type'),
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
              TextField(
                controller: productIdController,
                keyboardType: TextInputType.number,
                decoration: InputDecoration(labelText: 'Product ID'),
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
                if (nameController.text.isEmpty ||
                    descriptionController.text.isEmpty) {
                  print('Name and description must not be empty');
                  return;
                }

                final newCueType = {
                  'name': nameController.text,
                  'description': descriptionController.text,
                  'img': imgController.text,
                  'product_id': int.tryParse(productIdController.text) ?? 0,
                };

                try {
                  await DatabaseHelper().insertCueType(newCueType);
                  _refreshCueTypes();
                } catch (e) {
                  print('Error inserting cue type: $e');
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

  Future<void> _editCueType(
      BuildContext context, Map<String, dynamic> cueType) async {
    final TextEditingController nameController =
        TextEditingController(text: cueType['name']);
    final TextEditingController descriptionController =
        TextEditingController(text: cueType['description']);
    final TextEditingController imgController =
        TextEditingController(text: cueType['img']);
    final TextEditingController productIdController =
        TextEditingController(text: cueType['product_id'].toString());

    await showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text('Edit Cue Type'),
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
              TextField(
                controller: productIdController,
                keyboardType: TextInputType.number,
                decoration: InputDecoration(labelText: 'Product ID'),
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
                if (nameController.text.isEmpty ||
                    descriptionController.text.isEmpty) {
                  print('Name and description must not be empty');
                  return;
                }

                final updatedCueType = {
                  'id': cueType['id'],
                  'name': nameController.text,
                  'description': descriptionController.text,
                  'img': imgController.text,
                  'product_id': int.tryParse(productIdController.text) ?? 0,
                };

                try {
                  await DatabaseHelper().updateCueType(updatedCueType);
                  _refreshCueTypes();
                } catch (e) {
                  print('Error updating cue type: $e');
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
