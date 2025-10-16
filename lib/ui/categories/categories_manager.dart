import 'package:flutter/foundation.dart';
import '../../models/my_category.dart';

class CategoriesManager extends ChangeNotifier {
  final List<MyCategory> _expenseCategories = [
    MyCategory(id: '1', name: 'Ăn uống', icon: 'restaurant', color: '#FF5722', type: 'expense', isDefault: true),
    MyCategory(id: '2', name: 'Mua sắm', icon: 'shopping_bag', color: '#4CAF50', type: 'expense', isDefault: true),
    MyCategory(id: '3', name: 'Di chuyển', icon: 'local_gas_station', color: '#2196F3', type: 'expense', isDefault: false),
    MyCategory(id: '4', name: 'Nhà cửa', icon: 'house', color: '#9C27B0', type: 'expense', isDefault: true),
  ];

  final List<MyCategory> _incomeCategories = [
    MyCategory(id: '5', name: 'Lương', icon: 'work', color: '#8BC34A', type: 'income', isDefault: true),
    MyCategory(id: '6', name: 'Thưởng', icon: 'attach_money', color: '#FFC107', type: 'income', isDefault: false),
  ];

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

  // Thêm danh mục mới
  void addCategory(MyCategory category) {
    if (category.type == 'expense') {
      _expenseCategories.add(category);
    } else {
      _incomeCategories.add(category);
    }
    notifyListeners();
  }

  // Sửa danh mục
  void updateCategory(MyCategory category) {
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
  }

  // Xóa danh mục
  void deleteCategory(String id) {
    _expenseCategories.removeWhere((c) => c.id == id);
    _incomeCategories.removeWhere((c) => c.id == id);
    notifyListeners();
  }
}