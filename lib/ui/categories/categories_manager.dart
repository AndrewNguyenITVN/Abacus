import 'package:flutter/material.dart';
import '/models/category.dart';

class CategoriesManager {
    final List<Category> expenseCategories = [
    Category(id: '1', name: 'Ăn uống', icon: 'restaurant', color: '#FF5722', type: 'expense', isDefault: true),
    Category(id: '2', name: 'Mua sắm', icon: 'shopping_bag', color: '#4CAF50', type: 'expense', isDefault: true),
    Category(id: '3', name: 'Di chuyển', icon: 'local_gas_station', color: '#2196F3', type: 'expense', isDefault: false),
    Category(id: '4', name: 'Nhà cửa', icon: 'house', color: '#9C27B0', type: 'expense', isDefault: true),
  ];

    final List<Category> incomeCategories = [
    Category(id: '5', name: 'Lương', icon: 'work', color: '#8BC34A', type: 'income', isDefault: true),
    Category(id: '6', name: 'Thưởng', icon: 'attach_money', color: '#FFC107', type: 'income', isDefault: false),
  ];

  int get itemCount {
    return expenseCategories.length + incomeCategories.length;
  }

  List<Category> get items {
    return [...expenseCategories, ...incomeCategories];
  }

  List<Category> get favoriteItems {
    return items.where((item) => item.isDefault).toList();
  }
}