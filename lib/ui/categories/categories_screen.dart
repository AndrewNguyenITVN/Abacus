import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '/ui/shared/app_drawer.dart';
import '../../models/my_category.dart';
import '/ui/categories/categories_manager.dart';
import '/ui/categories/edit_category_screen.dart';

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
    'local_hospital': Icons.local_hospital,
    'fitness_center': Icons.fitness_center,
    'flight': Icons.flight,
    'phone': Icons.phone,
    'computer': Icons.computer,
    'directions_car': Icons.directions_car,
    'pets': Icons.pets,
    'games': Icons.games,
  };
  return iconMap[iconName] ?? Icons.help_outline;
}


class CategoriesScreen extends StatefulWidget {
  const CategoriesScreen({super.key});

  @override
  State<CategoriesScreen> createState() => _CategoriesScreenState();
}

class _CategoriesScreenState extends State<CategoriesScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _addCategory() async {
    final categoriesManager = Provider.of<CategoriesManager>(context, listen: false);
    final type = _tabController.index == 0 ? 'expense' : 'income';
    final result = await Navigator.push<MyCategory>(
      context,
      MaterialPageRoute(
        builder: (context) => EditCategoryScreen(type: type),
      ),
    );

    if (result != null && mounted) {
      categoriesManager.addCategory(result);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Đã thêm danh mục mới')),
      );
    }
  }

  Future<void> _editCategory(MyCategory category) async {
    final categoriesManager = Provider.of<CategoriesManager>(context, listen: false);
    final result = await Navigator.push<MyCategory>(
      context,
      MaterialPageRoute(
        builder: (context) => EditCategoryScreen(
          category: category,
          type: category.type,
        ),
      ),
    );

    if (result != null && mounted) {
      categoriesManager.updateCategory(result);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Đã cập nhật danh mục')),
      );
    }
  }

  Future<void> _deleteCategory(MyCategory category) async {
    final categoriesManager = Provider.of<CategoriesManager>(context, listen: false);
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Xác nhận xóa'),
        content: Text('Bạn có chắc chắn muốn xóa danh mục "${category.name}"?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Hủy'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Xóa', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );

    if (confirmed == true && mounted) {
      categoriesManager.deleteCategory(category.id);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Đã xóa danh mục')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final categoriesManager = context.watch<CategoriesManager>();
    
    return Scaffold(
      appBar: AppBar(
        title: const Text('Danh mục'),
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: _addCategory,
          ),
        ],
        bottom: TabBar(
          controller: _tabController,
          tabs: const [
            Tab(text: 'Chi tiêu'),
            Tab(text: 'Thu nhập'),
          ],
        ),
      ),
      drawer: const AppDrawer(),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildCategoryList(categoriesManager.expenseCategories),
          _buildCategoryList(categoriesManager.incomeCategories),
        ],
      ),
    );
  }

  Widget _buildCategoryList(List<MyCategory> categories) {
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
                    onPressed: () => _deleteCategory(category),
                  ),
            onTap: category.isDefault
                ? null
                : () => _editCategory(category),
          ),
        );
      },
    );
  }
}


