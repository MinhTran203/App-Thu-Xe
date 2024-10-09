import 'package:billiard/data/billard_helper.dart';
import 'package:flutter/material.dart';

// Import your DatabaseHelper
class CueTestPage extends StatefulWidget {
  const CueTestPage({super.key});

  @override
  State<CueTestPage> createState() => _CueTestPageState();
}

class _CueTestPageState extends State<CueTestPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Cue List'),
      ),
      body: FutureBuilder<List<Map<String, dynamic>>>(
        future: DatabaseHelper().getAllCues(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return Center(child: Text('No cues found.'));
          } else {
            return ListView.builder(
              itemCount: snapshot.data!.length,
              itemBuilder: (context, index) {
                var cue = snapshot.data![index];
                var cueId = cue['id'] as int?;
                var imgPath = cue['img'] as String?; // Đường dẫn hình ảnh

                return ListTile(
                  title: Text(cue['name'] ?? ''),
                  leading: imgPath != null
                      ? Image.asset(
                          'assets/images/$imgPath', // Cập nhật đường dẫn hình ảnh
                          width: 50,
                          height: 50,
                        )
                      : SizedBox(width: 50, height: 50),
                );
              },
            );
          }
        },
      ),
    );
  }
}
