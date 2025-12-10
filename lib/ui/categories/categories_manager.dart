import 'package:flutter/foundation.dart';
import '../../models/my_category.dart';
import '../../models/account.dart';
import '../../services/category_service.dart';

class CategoriesManager extends ChangeNotifier {
  final CategoryService _categoryService = CategoryService();
  
  List<MyCategory> _expenseCategories = [];
  List<MyCategory> _incomeCategories = [];
  bool _isLoaded = false;
  String? _userId;

  CategoriesManager();

  void update(Account? user) {
    if (user == null) {
      _userId = null;
      _expenseCategories = [];
      _incomeCategories = [];
      _isLoaded = false;
      notifyListeners();
      return;
    }

    // Nếu user đổi hoặc chưa load data thì load lại
    if (_userId != user.id || !_isLoaded) {
      _userId = user.id;
      _loadCategories();
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
      MyCategory(id: '1', userId: _userId!, name: 'Ăn uống', icon: 'restaurant', color: '#FF5722', type: 'expense', isDefault: false),
      MyCategory(id: '2', userId: _userId!, name: 'Mua sắm', icon: 'shopping_bag', color: '#4CAF50', type: 'expense', isDefault: false),
      MyCategory(id: '3', userId: _userId!, name: 'Di chuyển', icon: 'local_gas_station', color: '#2196F3', type: 'expense', isDefault: false),
      MyCategory(id: '4', userId: _userId!, name: 'Nhà cửa', icon: 'house', color: '#9C27B0', type: 'expense', isDefault: false),
      MyCategory(id: '5', userId: _userId!, name: 'Lương', icon: 'work', color: '#8BC34A', type: 'income', isDefault: false),
      MyCategory(id: '6', userId: _userId!, name: 'Thưởng', icon: 'attach_money', color: '#FFC107', type: 'income', isDefault: false),
    ];

    for (var category in defaultCategories) {
      // Đảm bảo ID duy nhất hơn bằng cách thêm timestamp hoặc userId prefix nếu cần
      // Nhưng ở đây dùng ID tĩnh cho default cũng được nếu logic insert replace
      // Tốt nhất tạo ID mới để tránh trùng nếu nhiều user dùng chung ID '1', '2'... 
      // Nhưng CategoryService.insertCategory dùng ConflictAlgorithm.replace, nên nếu ID trùng nó sẽ đè.
      // Vì vậy ID phải unique globally hoặc kết hợp với userId (nhưng PK hiện tại chỉ là id).
      // => Cần generate ID mới cho mỗi user.
      
      final newId = DateTime.now().millisecondsSinceEpoch.toString() + category.id; // Simple unique ID generation
      final categoryToInsert = category.copyWith(id: newId);

      await _categoryService.insertCategory(categoryToInsert);
    }
    
    // Reload lại để lấy đúng list đã insert (vì ID thay đổi)
    final categories = await _categoryService.getCategories(_userId!);
    _expenseCategories = categories.where((c) => c.type == 'expense').toList();
    _incomeCategories = categories.where((c) => c.type == 'income').toList();
  }

  // Thêm danh mục mới
  Future<void> addCategory(MyCategory category) async {
    if (_userId == null) return;

    try {
      final categoryWithUserId = category.copyWith(userId: _userId);
      await _categoryService.insertCategory(categoryWithUserId);
      
      if (categoryWithUserId.type == 'expense') {
        _expenseCategories.add(categoryWithUserId);
      } else {
        _incomeCategories.add(categoryWithUserId);
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
     // Đảm bảo userId không bị đổi
     final categoryToUpdate = category.copyWith(userId: _userId);

    try {
      await _categoryService.updateCategory(categoryToUpdate);
      
      if (categoryToUpdate.type == 'expense') {
        final index = _expenseCategories.indexWhere((c) => c.id == categoryToUpdate.id);
        if (index != -1) {
          _expenseCategories[index] = categoryToUpdate;
        }
      } else {
        final index = _incomeCategories.indexWhere((c) => c.id == categoryToUpdate.id);
        if (index != -1) {
          _incomeCategories[index] = categoryToUpdate;
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
    try {
      await _categoryService.deleteCategory(id);
      
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

  // Tìm category theo ID
  MyCategory? findById(String id) {
    try {
      return items.firstWhere((c) => c.id == id);
    } catch (e) {
      return null;
    }
  }
}