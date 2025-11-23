import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../models/my_category.dart';
import '/ui/categories/categories_manager.dart';
import 'category_item.dart';
import 'package:go_router/go_router.dart';

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
    final result = await context.push<MyCategory>(
      '/categories/add?type=$type',
    );

    if (result != null && mounted) {
      try {
        await categoriesManager.addCategory(result);
        if (mounted) {
          _showSnackBar(
            context,
            'Đã thêm danh mục mới',
            Icons.check_circle_rounded,
            const Color(0xFF11998e),
          );
        }
      } catch (e) {
        if (mounted) {
          _showSnackBar(
            context,
            'Lỗi: $e',
            Icons.error_rounded,
            const Color(0xFFee0979),
          );
        }
      }
    }
  }

  Future<void> _editCategory(MyCategory category) async {
    final categoriesManager = Provider.of<CategoriesManager>(context, listen: false);
    final result = await context.push<MyCategory>(
      '/categories/edit/${category.id}',
    );

    if (result != null && mounted) {
      try {
        await categoriesManager.updateCategory(result);
        if (mounted) {
          _showSnackBar(
            context,
            'Đã cập nhật danh mục',
            Icons.check_circle_rounded,
            const Color(0xFF11998e),
          );
        }
      } catch (e) {
        if (mounted) {
          _showSnackBar(
            context,
            'Lỗi: $e',
            Icons.error_rounded,
            const Color(0xFFee0979),
          );
        }
      }
    }
  }

  Future<void> _deleteCategory(MyCategory category) async {
    final categoriesManager = Provider.of<CategoriesManager>(context, listen: false);
    final colorScheme = Theme.of(context).colorScheme;
    
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
        title: Row(
          children: [
            Icon(Icons.warning_rounded, color: colorScheme.error),
            const SizedBox(width: 12),
            Text(
              'Xác nhận xóa',
              style: TextStyle(
                fontWeight: FontWeight.w700,
                fontSize: 18,
                color: colorScheme.onSurface,
              ),
            ),
          ],
        ),
        content: Text(
          'Bạn có chắc chắn muốn xóa danh mục "${category.name}"?',
          style: TextStyle(
            fontSize: 15,
            color: colorScheme.onSurfaceVariant,
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            style: TextButton.styleFrom(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
            ),
            child: Text(
              'Hủy',
              style: TextStyle(
                color: colorScheme.onSurface.withOpacity(0.6),
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          Container(
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [Color(0xFFee0979), Color(0xFFff6a00)],
              ),
              borderRadius: BorderRadius.circular(10),
            ),
            child: TextButton(
              onPressed: () => Navigator.pop(context, true),
              style: TextButton.styleFrom(
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              ),
              child: const Text(
                'Xóa',
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
          ),
        ],
      ),
    );

    if (confirmed == true && mounted) {
      try {
        await categoriesManager.deleteCategory(category.id);
        if (mounted) {
          _showSnackBar(
            context,
            'Đã xóa danh mục',
            Icons.check_circle_rounded,
            const Color(0xFF11998e),
          );
        }
      } catch (e) {
        if (mounted) {
          _showSnackBar(
            context,
            'Lỗi: $e',
            Icons.error_rounded,
            const Color(0xFFee0979),
          );
        }
      }
    }
  }

  void _showSnackBar(BuildContext context, String message, IconData icon, Color color) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            Icon(icon, color: Colors.white),
            const SizedBox(width: 12),
            Expanded(child: Text(message)),
          ],
        ),
        backgroundColor: color,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        margin: const EdgeInsets.all(16),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final categoriesManager = context.watch<CategoriesManager>();
    final colorScheme = Theme.of(context).colorScheme;
    
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Danh mục',
          style: TextStyle(
            fontWeight: FontWeight.w700,
            fontSize: 20,
            letterSpacing: -0.5,
          ),
        ),
        elevation: 0,
        surfaceTintColor: Colors.transparent,
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: () => _addCategory(),
          ),
          const SizedBox(width: 8),
        ],
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(60),
          child: Container(
            margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            decoration: BoxDecoration(
              color: colorScheme.surfaceContainerHigh, // Theme aware background
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.04),
                  blurRadius: 10,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: TabBar(
              controller: _tabController,
              labelColor: colorScheme.primary,
              unselectedLabelColor: colorScheme.onSurface.withOpacity(0.5),
              labelStyle: const TextStyle(
                fontWeight: FontWeight.w700,
                fontSize: 15,
                letterSpacing: -0.3,
              ),
              unselectedLabelStyle: const TextStyle(
                fontWeight: FontWeight.w600,
                fontSize: 15,
              ),
              indicator: BoxDecoration(
                color: colorScheme.primary.withOpacity(0.1),
                borderRadius: BorderRadius.circular(16),
              ),
              indicatorSize: TabBarIndicatorSize.tab,
              dividerColor: Colors.transparent,
              padding: const EdgeInsets.all(4),
              tabs: const [
                Tab(text: 'Chi tiêu'),
                Tab(text: 'Thu nhập'),
              ],
            ),
          ),
        ),
      ),
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
      return _buildEmptyState();
    }

    return ListView.builder(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 16),
      itemCount: categories.length,
      itemBuilder: (context, index) {
        final category = categories[index];
        return CategoryItem(
          category: category,
          onTap: () => _editCategory(category),
          onDelete: () => _deleteCategory(category),
        );
      },
    );
  }

  Widget _buildEmptyState() {
    final colorScheme = Theme.of(context).colorScheme;
    
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 120,
            height: 120,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  Colors.orange.shade100,
                  Colors.pink.shade100,
                ],
              ),
              shape: BoxShape.circle,
            ),
            child: Icon(
              Icons.category_rounded,
              size: 60,
              color: Colors.orange.shade300,
            ),
          ),
          const SizedBox(height: 24),
          Text(
            'Chưa có danh mục nào',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: colorScheme.onSurface,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Nhấn nút + để thêm danh mục mới',
            style: TextStyle(
              fontSize: 14,
              color: colorScheme.onSurface.withOpacity(0.6),
            ),
          ),
        ],
      ),
    );
  }
}
