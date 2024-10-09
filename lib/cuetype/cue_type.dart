import 'package:flutter/material.dart';
import 'package:billiard/config/const.dart';
import 'package:billiard/data/billard_helper.dart';
import 'package:billiard/Cue/cuelist.dart';

class CueTypeScreen extends StatelessWidget {
  final int productId;
  final int accountId;

  CueTypeScreen({required this.productId, required this.accountId});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Cue Types'),
      ),
      body: Container(
        decoration: BoxDecoration(
          image: DecorationImage(
            image: AssetImage('assets/images/background.jpg'),
            fit: BoxFit.cover, // để phù hợp với kích thước màn hình
          ),
        ),
        child: FutureBuilder<List<Map<String, dynamic>>>(
          future: DatabaseHelper().getCueTypesByProductId(productId),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return Center(child: CircularProgressIndicator());
            } else if (snapshot.hasError) {
              return Center(child: Text('Error: ${snapshot.error}'));
            } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
              return Center(child: Text('No cue types found.'));
            } else {
              return ListView.builder(
                itemCount: snapshot.data!.length,
                itemBuilder: (context, index) {
                  var cueType = snapshot.data![index];
                  var cueTypeId = cueType['id'] as int?;
                  var imgType = cueType['img'] as String?;

                  return GestureDetector(
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => CueListScreen(
                            cueTypeId: cueTypeId!,
                            accountId: accountId,
                          ),
                        ),
                      );
                    },
                    child: Card(
                      elevation: 5.0,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10.0),
                      ),
                      margin: EdgeInsets.symmetric(
                          horizontal: 50, vertical: 10), // Cách trái phải 50
                      child: Padding(
                        padding: EdgeInsets.all(10.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: <Widget>[
                            ClipRRect(
                              borderRadius: BorderRadius.circular(10.0),
                              child: imgType != null
                                  ? Image.asset(
                                      urlimg + imgType,
                                      width: double.infinity,
                                      height: 150.0,
                                      fit: BoxFit.cover,
                                    )
                                  : Image.asset(
                                      'assets/images/default_image.jpg',
                                      width: double.infinity,
                                      height: 150.0,
                                      fit: BoxFit.cover,
                                    ),
                            ),
                            SizedBox(height: 10.0),
                            Text(
                              cueType['name'] ?? '',
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 18.0,
                              ),
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                            ),
                            SizedBox(height: 5.0),
                          ],
                        ),
                      ),
                    ),
                  );
                },
              );
            }
          },
        ),
      ),
    );
  }
}
