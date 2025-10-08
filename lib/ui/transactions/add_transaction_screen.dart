import 'package:flutter/material.dart';

class AddTransactionScreen extends StatelessWidget {
  const AddTransactionScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Thêm giao dịch')),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: const [
            Icon(Icons.add_circle, size: 100, color: Colors.deepPurple),
            SizedBox(height: 20),
            Text(
              'Thêm giao dịch mới',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 10),
            Text(
              'Màn hình thêm giao dịch chi tiêu mới',
              style: TextStyle(fontSize: 16),
            ),
          ],
        ),
      ),
    );
  }
}
