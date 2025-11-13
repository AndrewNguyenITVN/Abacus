import 'package:flutter/foundation.dart';
import '../../models/my_category.dart';
import '../../services/category_service.dart';

class CategoriesManager extends ChangeNotifier {
  final CategoryService _categoryService = CategoryService();
  String? _userId;
  
  List<MyCategory> _expenseCategories = [];
  List<MyCategory> _incomeCategories = [];
  bool _isLoaded = false;

  CategoriesManager();

  // Set userId và load data
  Future<void> setUserId(String userId) async {
    if (_userId != userId) {
      _userId = userId;
      _isLoaded = false;
      await _loadCategories();
    }
  }

  List<MyCategory> get expenseCategories => List.unmodifiable(_expenseCategories);
  List<MyCategory> get incomeCategories => List.unmodifiable(_incomeCategories);

  int get itemCount {
    return _expenseCategories.length + _incomeCategories.length;
  }

  List<MyCategory> get items {
    return [..._expenseCategories, ..._incomeCategories];
  }

  List<MyCategory> get favoriteItems {
    return items.where((item) => item.isDefault).toList();
  }

  bool get isLoaded => _isLoaded;

  // Load categories từ SQLite
  Future<void> _loadCategories() async {
    if (_userId == null) return;
    try {
      final categories = await _categoryService.getCategories(_userId!);
      
      // Nếu chưa có category nào, thêm các category mặc định
      if (categories.isEmpty) {
        await _initDefaultCategories();
      } else {
        _expenseCategories = categories.where((c) => c.type == 'expense').toList();
        _incomeCategories = categories.where((c) => c.type == 'income').toList();
      }
      
      _isLoaded = true;
      notifyListeners();
    } catch (e) {
      print('Error loading categories: $e');
      _isLoaded = true;
      notifyListeners();
    }
  }

  // Khởi tạo các category mặc định
  Future<void> _initDefaultCategories() async {
    if (_userId == null) return;
    
    final defaultCategories = [
      MyCategory(id: '1', name: 'Ăn uống', icon: 'restaurant', color: '#FF5722', type: 'expense', isDefault: false),
      MyCategory(id: '2', name: 'Mua sắm', icon: 'shopping_bag', color: '#4CAF50', type: 'expense', isDefault: false),
      MyCategory(id: '3', name: 'Di chuyển', icon: 'local_gas_station', color: '#2196F3', type: 'expense', isDefault: false),
      MyCategory(id: '4', name: 'Nhà cửa', icon: 'house', color: '#9C27B0', type: 'expense', isDefault: false),
      MyCategory(id: '5', name: 'Lương', icon: 'work', color: '#8BC34A', type: 'income', isDefault: false),
      MyCategory(id: '6', name: 'Thưởng', icon: 'attach_money', color: '#FFC107', type: 'income', isDefault: false),
    ];

    for (var category in defaultCategories) {
      await _categoryService.insertCategory(_userId!, category);
    }

    _expenseCategories = defaultCategories.where((c) => c.type == 'expense').toList();
    _incomeCategories = defaultCategories.where((c) => c.type == 'income').toList();
  }

  // Thêm danh mục mới
  Future<void> addCategory(MyCategory category) async {
    if (_userId == null) return;
    try {
      await _categoryService.insertCategory(_userId!, category);
      
      if (category.type == 'expense') {
        _expenseCategories.add(category);
      } else {
        _incomeCategories.add(category);
      }
      notifyListeners();
    } catch (e) {
      print('Error adding category: $e');
      rethrow;
    }
  }

  // Sửa danh mục
  Future<void> updateCategory(MyCategory category) async {
    if (_userId == null) return;
    try {
      await _categoryService.updateCategory(_userId!, category);
      
      if (category.type == 'expense') {
        final index = _expenseCategories.indexWhere((c) => c.id == category.id);
        if (index != -1) {
          _expenseCategories[index] = category;
        }
      } else {
        final index = _incomeCategories.indexWhere((c) => c.id == category.id);
        if (index != -1) {
          _incomeCategories[index] = category;
        }
      }
      notifyListeners();
    } catch (e) {
      print('Error updating category: $e');
      rethrow;
    }
  }

  // Xóa danh mục
  Future<void> deleteCategory(String id) async {
    if (_userId == null) return;
    try {
      await _categoryService.deleteCategory(_userId!, id);
      
      _expenseCategories.removeWhere((c) => c.id == id);
      _incomeCategories.removeWhere((c) => c.id == id);
      notifyListeners();
    } catch (e) {
      print('Error deleting category: $e');
      rethrow;
    }
  }

  // Refresh categories từ database
  Future<void> refreshCategories() async {
    _isLoaded = false;
    await _loadCategories();
  }
}