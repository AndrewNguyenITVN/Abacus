import 'package:flutter/material.dart';
import '/ui/home/home_screen.dart';
import '/ui/transactions/transactions_screen.dart';
import '/ui/transactions/add_transaction_screen.dart';
import '/ui/categories/categories_screen.dart';
import '/ui/account/account_screen.dart';
import '/ui/shared/custom_page_transitions.dart';

class BottomNavBarScreen extends StatefulWidget {
  const BottomNavBarScreen({super.key});

  @override
  State<BottomNavBarScreen> createState() => BottomNavBarScreenState();
}

class BottomNavBarScreenState extends State<BottomNavBarScreen> {
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

  // Public method để navigate từ child widgets
  void navigateToIndex(int index) {
    if (index != 2 && index >= 0 && index < _screens.length) {
      setState(() {
        _selectedIndex = index;
      });
    }
  }

  // Hiển thị màn hình thêm giao dịch
  void _showAddTransactionScreen() {
    Navigator.of(
      context,
    ).push(SlideUpPageRoute(page: const AddTransactionScreen()));
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    
    return Scaffold(
      body: Stack(
        children: _screens.asMap().entries.map((entry) {
          final index = entry.key;
          final screen = entry.value;
          final isSelected = _selectedIndex == index;

          return AnimatedScale(
            scale: isSelected ? 1.0 : 1.15,
            duration: const Duration(milliseconds: 300),
            curve: Curves.easeInOut,
            child: AnimatedOpacity(
              opacity: isSelected ? 1.0 : 0.0,
              duration: const Duration(milliseconds: 300),
              curve: Curves.easeInOut,
              child: IgnorePointer(ignoring: !isSelected, child: screen),
            ),
          );
        }).toList(),
      ),
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          color: colorScheme.surfaceContainer,
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
                Expanded(child: _buildNavItem(0, Icons.home_rounded, 'Trang chủ')),
                // Sổ giao dịch
                Expanded(
                  child: _buildNavItem(
                    1,
                    Icons.account_balance_wallet_rounded,
                    'Giao dịch',
                  ),
                ),
                // Nút thêm giao dịch - ngang hàng với các nút khác
                Expanded(child: _buildAddButton()),
                // Danh mục
                Expanded(child: _buildNavItem(3, Icons.category_rounded, 'Danh mục')),
                // Tài khoản
                Expanded(child: _buildNavItem(4, Icons.person_rounded, 'Tài khoản')),
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
    final colorScheme = Theme.of(context).colorScheme;
    
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
                  ? colorScheme.primary
                  : colorScheme.onSurfaceVariant,
            ),
            const SizedBox(height: 4),
            Text(
              label,
              style: TextStyle(
                fontSize: 11,
                fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
                color: isSelected
                    ? colorScheme.primary
                    : colorScheme.onSurfaceVariant,
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
                  colors: [const Color(0xFF11998e), const Color(0xFF38ef7d)],
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
            const SizedBox(height: 4),
          ],
        ),
      ),
    );
  }
}
