import 'package:flutter/material.dart';
import '/ui/shared/app_drawer.dart';

class AccountScreen extends StatelessWidget {
  const AccountScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Tài khoản')),
      drawer: const AppDrawer(),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: const [
            Icon(Icons.person, size: 100, color: Colors.deepPurple),
            SizedBox(height: 20),
            Text(
              'Tài khoản',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 10),
            Text(
              'Thông tin tài khoản người dùng',
              style: TextStyle(fontSize: 16),
            ),
          ],
        ),
      ),
    );
  }
}
