import 'package:flutter/material.dart';

class TrangThongTin extends StatefulWidget {
  const TrangThongTin({super.key});

  @override
  State<TrangThongTin> createState() => _TrangThongTinState();
}

class _TrangThongTinState extends State<TrangThongTin> {
  String hoTen = 'Trần Văn Minh';
  String tenTaiKhoan = 'minh';
  String matKhau = '123@abcd';
  String sdt = '0123456789';

  TextEditingController controller = TextEditingController();

  void editField(String title, String currentValue, Function(String) onSave) {
    controller.text = currentValue;
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Chỉnh sửa $title'),
        content: TextField(
          controller: controller,
          decoration: InputDecoration(hintText: 'Nhập $title mới'),
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
            },
            child: Text('Hủy'),
          ),
          TextButton(
            onPressed: () {
              onSave(controller.text);
              Navigator.of(context).pop();
            },
            child: Text('Lưu'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: Icon(Icons.arrow_back),
        title: Text('Chi tiết tài khoản'),
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            CircleAvatar(
              radius: 50,
              backgroundImage:
                  AssetImage('assets/profile.jpg'), // Thêm hình ảnh vào assets
            ),
            SizedBox(height: 16),
            buildProfileInfoRow('Họ tên', hoTen, (value) {
              setState(() {
                hoTen = value;
              });
            }),
            buildProfileInfoRow('Tên tài khoản', tenTaiKhoan, (value) {
              setState(() {
                tenTaiKhoan = value;
              });
            }),
            buildProfileInfoRow('Mật khẩu', matKhau, (value) {
              setState(() {
                matKhau = value;
              });
            }),
            buildProfileInfoRow('SĐT', sdt, (value) {
              setState(() {
                sdt = value;
              });
            }),
          ],
        ),
      ),
    );
  }

  Widget buildProfileInfoRow(
      String title, String value, Function(String) onSave) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        children: [
          Expanded(
            flex: 2,
            child: Text(
              title,
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
          ),
        ],
      ),
    );
  }
}
