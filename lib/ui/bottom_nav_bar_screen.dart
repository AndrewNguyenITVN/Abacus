import 'package:flutter/material.dart';
import '/ui/home/home_screen.dart';
import '/ui/transactions/transactions_screen.dart';
import '/ui/transactions/add_transaction_screen.dart';
import '/ui/categories/categories_screen.dart';
import '/ui/account/account_screen.dart';

// Custom FloatingActionButtonLocation để giữ vị trí cố định
class _CustomCenterDockedFabLocation extends FloatingActionButtonLocation {
  const _CustomCenterDockedFabLocation();

  @override
  Offset getOffset(ScaffoldPrelayoutGeometry scaffoldGeometry) {
    final double fabX =
        (scaffoldGeometry.scaffoldSize.width -
            scaffoldGeometry.floatingActionButtonSize.width) /
        2.0;
    final double contentBottom = scaffoldGeometry.contentBottom;
    final double fabHeight = scaffoldGeometry.floatingActionButtonSize.height;
    final double fabY = contentBottom - fabHeight / 2.0;
    return Offset(fabX, fabY);
  }
}

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
      bottomNavigationBar: BottomAppBar(
        shape: const CircularNotchedRectangle(),
        notchMargin: 8,
        elevation: 8,
        child: SizedBox(
          height: 65,
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
              // Khoảng trống cho nút thêm
              const SizedBox(width: 56),
              // Danh mục
              Expanded(child: _buildNavItem(3, Icons.category, 'Danh mục')),
              // Tài khoản
              Expanded(child: _buildNavItem(4, Icons.person, 'Tài khoản')),
            ],
          ),
        ),
      ),
      // Nút thêm giao dịch nổi giữa thanh điều hướng
      floatingActionButton: FloatingActionButton(
        backgroundColor: Colors.green,
        onPressed: _showAddTransactionScreen,
        elevation: 4,
        child: const Icon(Icons.add, color: Colors.white, size: 32),
      ),
      floatingActionButtonLocation: const _CustomCenterDockedFabLocation(),
      resizeToAvoidBottomInset: false,
    );
  }

  // Widget xây dựng mục điều hướng
  Widget _buildNavItem(int index, IconData icon, String label) {
    final isSelected = _selectedIndex == index;
    return InkWell(
      onTap: () => _onItemTapped(index),
      borderRadius: BorderRadius.circular(8),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 4),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              icon,
              size: 24,
              color: isSelected
                  ? Theme.of(context).colorScheme.primary
                  : Colors.grey,
            ),
            const SizedBox(height: 2),
            Text(
              label,
              style: TextStyle(
                fontSize: 11,
                color: isSelected
                    ? Theme.of(context).colorScheme.primary
                    : Colors.grey,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
