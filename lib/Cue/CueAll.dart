import 'package:flutter/material.dart';
import 'package:billiard/data/billard_helper.dart'; // Ensure this imports your DatabaseHelper

class CueAll extends StatefulWidget {
  @override
  _CueListPageState createState() => _CueListPageState();
}

class _CueListPageState extends State<CueAll> {
  late Future<List<Map<String, dynamic>>> _cuesFuture;
  TextEditingController _searchController = TextEditingController();
  late List<Map<String, dynamic>> _cues;
  late List<Map<String, dynamic>> _filteredCues;

  @override
  void initState() {
    super.initState();
    _cuesFuture = _loadCues(); // Assign the future to _cuesFuture
    _cues = [];
    _filteredCues = [];
  }

  Future<List<Map<String, dynamic>>> _loadCues() async {
    _cues = await DatabaseHelper().getAllCues();
    _filteredCues = List.from(_cues); // Initialize filteredCues with all cues
    return _cues; // Return _cues as the result of the future
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Cue List'),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                hintText: 'Search by cue name...',
                suffixIcon: IconButton(
                  icon: Icon(Icons.search),
                  onPressed: () {
                    _performSearch();
                  },
                ),
              ),
              onChanged: (value) {
                _performSearch();
              },
            ),
          ),
          Expanded(
            child: FutureBuilder<List<Map<String, dynamic>>>(
              future: _cuesFuture,
              builder: (BuildContext context,
                  AsyncSnapshot<List<Map<String, dynamic>>> snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return Center(child: CircularProgressIndicator());
                } else if (snapshot.hasError) {
                  return Center(child: Text('Error: ${snapshot.error}'));
                } else if (snapshot.hasData) {
                  // Assign _cues and _filteredCues based on snapshot.data
                  _cues = snapshot.data!;
                  if (_searchController.text.isEmpty) {
                    _filteredCues = List.from(_cues);
                  }
                  return ListView.builder(
                    itemCount: _filteredCues.length,
                    itemBuilder: (context, index) {
                      var cue = _filteredCues[index];
                      return _buildCueCard(context, cue);
                    },
                  );
                } else {
                  return Center(child: Text('No cues found.'));
                }
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCueCard(BuildContext context, Map<String, dynamic> cue) {
    return Card(
      margin: EdgeInsets.all(10),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(15),
      ),
      elevation: 5,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ClipRRect(
            borderRadius: BorderRadius.only(
              topLeft: Radius.circular(15),
              topRight: Radius.circular(15),
            ),
            child: Image.asset(
              'assets/images/${cue['img']}', // Adjust the path as necessary
              width: double.infinity,
              height: 200,
              fit: BoxFit.cover,
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(10.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  cue['name'],
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 20,
                  ),
                ),
                SizedBox(height: 5),
                Text(
                  cue['description'] ?? '',
                  style: TextStyle(
                    fontSize: 16,
                    color: Colors.grey[600],
                  ),
                ),
                SizedBox(height: 10),
                Text(
                  '\VND${cue['price'].toStringAsFixed(2)}',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 18,
                    color: Colors.green,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  void _performSearch() {
    String query = _searchController.text.toLowerCase();
    setState(() {
      _filteredCues = _cues
          .where((cue) => cue['name'].toLowerCase().contains(query))
          .toList();
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }
}
