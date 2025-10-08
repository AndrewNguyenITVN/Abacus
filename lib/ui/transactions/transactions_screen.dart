import 'package:flutter/material.dart';
import '/ui/shared/app_drawer.dart';

class TransactionsScreen extends StatelessWidget {
  const TransactionsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Sổ giao dịch')),
      drawer: const AppDrawer(),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: const [
            Icon(
              Icons.account_balance_wallet,
              size: 100,
              color: Colors.deepPurple,
            ),
            SizedBox(height: 20),
            Text(
              'Sổ giao dịch',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 10),
            Text('Danh sách các giao dịch', style: TextStyle(fontSize: 16)),
          ],
        ),
      ),
    );
  }
}
