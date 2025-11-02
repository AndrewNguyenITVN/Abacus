import 'package:flutter/material.dart';
import '/ui/home/home_screen.dart';
import '/ui/transactions/transactions_screen.dart';
import '/ui/transactions/add_transaction_screen.dart';
import '/ui/categories/categories_screen.dart';
import '/ui/account/account_screen.dart';

class BottomNavBarScreen extends StatefulWidget {
  const BottomNavBarScreen({super.key});

  @override
  State<BottomNavBarScreen> createState() => _BottomNavBarScreenState();
}

class _BottomNavBarScreenState extends State<BottomNavBarScreen> {
  int _selectedIndex = 0;

  // Danh sách các màn hình
  final List<Widget> _screens = [
    const HomeScreen(), // Trang chủ
    const TransactionsScreen(), // Sổ giao dịch
    const SizedBox(), // Placeholder để phù hợp với vị trí nút thêm
    const CategoriesScreen(), // Danh mục
    const AccountScreen(), // Tài khoản
  ];

  // Xử lý khi chọn một mục trên thanh điều hướng
  void _onItemTapped(int index) {
    // Nếu là nút thêm giao dịch (index 2), mở màn hình thêm giao dịch
    if (index == 2) {
      _showAddTransactionScreen();
      return;
    }

    setState(() {
      _selectedIndex = index;
    });
  }

  // Hiển thị màn hình thêm giao dịch
  void _showAddTransactionScreen() {
    Navigator.of(context).push(
      MaterialPageRoute(builder: (context) => const AddTransactionScreen()),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _screens[_selectedIndex],
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.08),
              blurRadius: 15,
              offset: const Offset(0, -3),
              spreadRadius: -2,
            ),
          ],
        ),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                // Trang chủ
                Expanded(child: _buildNavItem(0, Icons.home, 'Trang chủ')),
                // Sổ giao dịch
                Expanded(
                  child: _buildNavItem(
                    1,
                    Icons.account_balance_wallet,
                    'Giao dịch',
                  ),
                ),
                // Nút thêm giao dịch - ngang hàng với các nút khác
                Expanded(child: _buildAddButton()),
                // Danh mục
                Expanded(child: _buildNavItem(3, Icons.category, 'Danh mục')),
                // Tài khoản
                Expanded(child: _buildNavItem(4, Icons.person, 'Tài khoản')),
              ],
            ),
          ),
        ),
      ),
      resizeToAvoidBottomInset: false,
    );
  }

  // Widget xây dựng mục điều hướng
  Widget _buildNavItem(int index, IconData icon, String label) {
    final isSelected = _selectedIndex == index;
    return InkWell(
      onTap: () => _onItemTapped(index),
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 8),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              icon,
              size: 24,
              color: isSelected
                  ? Theme.of(context).colorScheme.primary
                  : Colors.grey.shade600,
            ),
            const SizedBox(height: 4),
            Text(
              label,
              style: TextStyle(
                fontSize: 11,
                fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
                color: isSelected
                    ? Theme.of(context).colorScheme.primary
                    : Colors.grey.shade600,
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Widget xây dựng nút thêm giao dịch (đặc biệt)
  Widget _buildAddButton() {
    return InkWell(
      onTap: _showAddTransactionScreen,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 8),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    const Color(0xFF11998e),
                    const Color(0xFF38ef7d),
                  ],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: const Color(0xFF11998e).withOpacity(0.4),
                    blurRadius: 12,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: const Icon(
                Icons.add_rounded,
                color: Colors.white,
                size: 28,
              ),
            ),
            const SizedBox(height: 4)
          ],
        ),
      ),
    );
  }
}
