import 'package:flutter/material.dart';
import '/ui/shared/app_drawer.dart';
import '/models/category.dart';
import '/ui/categories/categories_manager.dart';

// Helper functions to mock dialogs and helpers from the original project
Color _parseColor(String hexCode) {
  return Color(int.parse(hexCode.substring(1, 7), radix: 16) + 0xFF000000);
}

IconData _getIconData(String iconName) {
  // A simple map to mock the icon picker
  const iconMap = {
    'shopping_bag': Icons.shopping_bag,
    'restaurant': Icons.restaurant,
    'movie': Icons.movie,
    'house': Icons.house,
    'local_gas_station': Icons.local_gas_station,
    'school': Icons.school,
    'work': Icons.work,
    'attach_money': Icons.attach_money,
  };
  return iconMap[iconName] ?? Icons.help_outline;
}


class CategoriesScreen extends StatelessWidget {
  const CategoriesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Danh mục'),
          actions: [
            IconButton(
              icon: const Icon(Icons.add),
              onPressed: () {
                // Mock FAB action
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Chức năng thêm danh mục chưa được cài đặt.')),
                );
              },
            ),
          ],
          bottom: const TabBar(
            tabs: [
              Tab(text: 'Chi tiêu'),
              Tab(text: 'Thu nhập'),
            ],
          ),
        ),
        drawer: const AppDrawer(),
        body: TabBarView(
          children: [
            _buildCategoryList(context, CategoriesManager().expenseCategories),
            _buildCategoryList(context, CategoriesManager().incomeCategories),
          ],
        ),
      ),
    );
  }

  Widget _buildCategoryList(BuildContext context, List<Category> categories) {
    if (categories.isEmpty) {
      return const Center(child: Text('Chưa có danh mục nào'));
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: categories.length,
      itemBuilder: (context, index) {
        final category = categories[index];
        return Card(
          margin: const EdgeInsets.only(bottom: 12),
          child: ListTile(
            leading: CircleAvatar(
              backgroundColor: _parseColor(category.color),
              child: Icon(
                _getIconData(category.icon),
                color: Colors.white,
              ),
            ),
            title: Text(category.name),
            subtitle: category.isDefault
                ? const Text('Mặc định')
                : const Text('Tùy chỉnh'),
            trailing: category.isDefault
                ? null
                : IconButton(
                    icon: const Icon(Icons.delete),
                    onPressed: () {
                       ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Chức năng xóa chưa được cài đặt.')),
                      );
                    },
                  ),
            onTap: category.isDefault
                ? null
                : () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Chức năng sửa chưa được cài đặt.')),
                    );
                  }
          ),
        );
      },
    );
  }
}


