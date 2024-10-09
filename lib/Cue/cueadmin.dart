import 'package:billiard/data/billard_helper.dart';
import 'package:flutter/material.dart';
import 'package:billiard/config/const.dart';

import 'package:billiard/data/billard_helper.dart';
import 'package:flutter/material.dart';
import 'package:billiard/config/const.dart';

class CueScreen extends StatefulWidget {
  const CueScreen({Key? key}) : super(key: key);

  @override
  State<CueScreen> createState() => _CueScreenState();
}

class _CueScreenState extends State<CueScreen> {
  late Future<List<Map<String, dynamic>>> _cues;

  @override
  void initState() {
    super.initState();
    _refreshCues();
  }

  Future<void> _refreshCues() async {
    setState(() {
      _cues = DatabaseHelper().getAllCues();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Cues'),
      ),
      body: FutureBuilder<List<Map<String, dynamic>>>(
        future: _cues,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return Center(child: Text('No cues available.'));
          } else {
            return ListView.builder(
              itemCount: snapshot.data!.length,
              itemBuilder: (context, index) {
                final cue = snapshot.data![index];
                return ListTile(
                  title: Text(cue['name']),
                  subtitle: Text('Price: \$${cue['price']}'),
                  leading: cue['img'] != null
                      ? Image.asset(
                          urlimg + cue['img'],
                          width: 50,
                          height: 50,
                        )
                      : SizedBox(
                          width: 50,
                          height: 50,
                        ), // Replace with a default image or icon
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      IconButton(
                        icon: Icon(Icons.edit),
                        onPressed: () {
                          _editCue(context, cue);
                        },
                      ),
                      IconButton(
                        icon: Icon(Icons.delete),
                        onPressed: () async {
                          await _deleteCue(cue);
                        },
                      ),
                    ],
                  ),
                  onTap: () {
                    // Show detailed information
                  },
                );
              },
            );
          }
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          _addCue(context);
        },
        child: Icon(Icons.add),
      ),
    );
  }

  Future<void> _addCue(BuildContext context) async {
    final TextEditingController nameController = TextEditingController();
    final TextEditingController descriptionController = TextEditingController();
    final TextEditingController imgController = TextEditingController();
    final TextEditingController priceController = TextEditingController();
    final TextEditingController cueTypeIdController = TextEditingController();

    await showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text('Add Cue'),
          content: SingleChildScrollView(
            child: Column(
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
                  controller: priceController,
                  decoration: InputDecoration(labelText: 'Price'),
                  keyboardType: TextInputType.number,
                ),
                TextField(
                  controller: cueTypeIdController,
                  decoration: InputDecoration(labelText: 'Cue Type ID'),
                  keyboardType: TextInputType.number,
                ),
              ],
            ),
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
                final newCue = {
                  'name': nameController.text,
                  'description': descriptionController.text,
                  'img': imgController.text,
                  'price': double.tryParse(priceController.text) ?? 0.0,
                  'cue_type_id': int.tryParse(cueTypeIdController.text),
                };
                await DatabaseHelper().insertCue(newCue);
                _refreshCues(); // Refresh the list after adding a new cue
                // Sync data with server after adding
                Navigator.of(context).pop();
              },
              child: Text('Add'),
            ),
          ],
        );
      },
    );
  }

  Future<void> _editCue(BuildContext context, Map<String, dynamic> cue) async {
    final TextEditingController nameController =
        TextEditingController(text: cue['name']);
    final TextEditingController descriptionController =
        TextEditingController(text: cue['description']);
    final TextEditingController imgController =
        TextEditingController(text: cue['img']);
    final TextEditingController priceController =
        TextEditingController(text: cue['price'].toString());
    final TextEditingController cueTypeIdController =
        TextEditingController(text: cue['cue_type_id'].toString());

    await showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text('Edit Cue'),
          content: SingleChildScrollView(
            child: Column(
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
                  controller: priceController,
                  decoration: InputDecoration(labelText: 'Price'),
                  keyboardType: TextInputType.number,
                ),
                TextField(
                  controller: cueTypeIdController,
                  decoration: InputDecoration(labelText: 'Cue Type ID'),
                  keyboardType: TextInputType.number,
                ),
              ],
            ),
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
                final updatedCue = {
                  'id': cue['id'],
                  'name': nameController.text,
                  'description': descriptionController.text,
                  'img': imgController.text,
                  'price': double.tryParse(priceController.text) ?? 0.0,
                  'cue_type_id': int.tryParse(cueTypeIdController.text),
                };
                await DatabaseHelper().updateCue(updatedCue);
                _refreshCues(); // Refresh the list after updating the cue
                // Sync data with server after updating
                Navigator.of(context).pop();
              },
              child: Text('Update'),
            ),
          ],
        );
      },
    );
  }

  Future<void> _deleteCue(Map<String, dynamic> cue) async {
    await DatabaseHelper().deleteCue(cue['id']);
    _refreshCues(); // Refresh the list after deleting the cue
    // Sync data with server after deleting
  }
}
