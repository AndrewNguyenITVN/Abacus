import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class BottomNavBarScreen extends StatelessWidget {
  final StatefulNavigationShell navigationShell;

  const BottomNavBarScreen({
    super.key,
    required this.navigationShell,
  });

  void _onItemTapped(int index, BuildContext context) {
    // Xử lý nút Add Transaction (Nút giữa - index 2)
    if (index == 2) {
      context.push('/add-transaction');
      return;
    }

    // Logic ánh xạ Index UI -> Index Branch Router
    // UI: [0:Home, 1:Trans, 2:ADD, 3:Cat, 4:Acc]
    // Router: [0:Home, 1:Trans, -- , 2:Cat, 3:Acc]
    
    int branchIndex = index < 2 ? index : index - 1;

    navigationShell.goBranch(
      branchIndex,
      // Cho phép quay về route đầu tiên của branch khi tap lại tab đang active
      initialLocation: branchIndex == navigationShell.currentIndex,
    );
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    
    int routerIndex = navigationShell.currentIndex;
    int uiIndex = routerIndex < 2 ? routerIndex : routerIndex + 1;

    return Scaffold(
      body: navigationShell,
      
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
                Expanded(child: _buildNavItem(context, 0, Icons.home_rounded, 'Trang chủ', uiIndex)),
                Expanded(child: _buildNavItem(context, 1, Icons.account_balance_wallet_rounded, 'Giao dịch', uiIndex)),
                Expanded(child: _buildAddButton(context)), // Nút giữa (Index 2)
                Expanded(child: _buildNavItem(context, 3, Icons.category_rounded, 'Danh mục', uiIndex)),
                Expanded(child: _buildNavItem(context, 4, Icons.person_rounded, 'Tài khoản', uiIndex)),
              ],
            ),
          ),
        ),
      ),
      resizeToAvoidBottomInset: false,
    );
  }

  Widget _buildNavItem(BuildContext context, int index, IconData icon, String label, int currentUiIndex) {
    final isSelected = currentUiIndex == index;
    final colorScheme = Theme.of(context).colorScheme;

    return InkWell(
      onTap: () => _onItemTapped(index, context),
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
              color: isSelected ? colorScheme.primary : colorScheme.onSurfaceVariant,
            ),
            const SizedBox(height: 4),
            Text(
              label,
              style: TextStyle(
                fontSize: 11,
                fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
                color: isSelected ? colorScheme.primary : colorScheme.onSurfaceVariant,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAddButton(BuildContext context) {
    return InkWell(
      onTap: () => _onItemTapped(2, context),
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
                gradient: const LinearGradient(
                  colors: [Color(0xFF11998e), Color(0xFF38ef7d)],
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
              child: const Icon(Icons.add_rounded, color: Colors.white, size: 28),
            ),
            const SizedBox(height: 4),
          ],
        ),
      ),
    );
  }
}