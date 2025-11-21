import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class SavingsHelpers {
  // --- Formatter Helpers ---

  static String formatCurrency(double amount) {
    final formatter = NumberFormat.currency(locale: 'vi_VN', symbol: '₫');
    return formatter.format(amount);
  }

  static String formatDate(DateTime date) {
    final formatter = DateFormat('dd/MM/yyyy', 'vi_VN');
    return formatter.format(date);
  }

  static double? parseAmount(String? value) {
    if (value == null || value.isEmpty) return null;
    String clean = value.replaceAll('.', '').replaceAll(',', '.');
    return double.tryParse(clean);
  }

  static Color parseColor(String hexColor) {
    try {
      final hexCode = hexColor.replaceAll('#', '');
      return Color(int.parse('FF$hexCode', radix: 16));
    } catch (e) {
      return Colors.grey;
    }
  }

  static IconData getIconData(String iconName) {
    final icon = iconOptions.firstWhere(
      (element) => element['name'] == iconName,
      orElse: () => {'icon': Icons.savings},
    );
    return icon['icon'] as IconData;
  }

  // --- Constants ---

  static final List<Map<String, dynamic>> iconOptions = [
    {'name': 'savings', 'icon': Icons.savings, 'label': 'Tiết kiệm'},
    {'name': 'home', 'icon': Icons.home, 'label': 'Nhà'},
    {'name': 'directions_car', 'icon': Icons.directions_car, 'label': 'Ô tô'},
    {'name': 'two_wheeler', 'icon': Icons.two_wheeler, 'label': 'Xe máy'},
    {'name': 'flight', 'icon': Icons.flight, 'label': 'Du lịch'},
    {'name': 'beach_access', 'icon': Icons.beach_access, 'label': 'Nghỉ dưỡng'},
    {'name': 'school', 'icon': Icons.school, 'label': 'Học tập'},
    {'name': 'laptop', 'icon': Icons.laptop, 'label': 'Laptop'},
    {'name': 'phone_android', 'icon': Icons.phone_android, 'label': 'Điện thoại'},
    {'name': 'shopping_bag', 'icon': Icons.shopping_bag, 'label': 'Mua sắm'},
    {'name': 'account_balance', 'icon': Icons.account_balance, 'label': 'Ngân hàng'},
    {'name': 'card_giftcard', 'icon': Icons.card_giftcard, 'label': 'Quà tặng'},
  ];

  static final List<Map<String, dynamic>> colorOptions = [
    {'hex': '#4CAF50', 'color': const Color(0xFF4CAF50), 'label': 'Xanh lá'},
    {'hex': '#2196F3', 'color': const Color(0xFF2196F3), 'label': 'Xanh dương'},
    {'hex': '#FF5722', 'color': const Color(0xFFFF5722), 'label': 'Đỏ cam'},
    {'hex': '#9C27B0', 'color': const Color(0xFF9C27B0), 'label': 'Tím'},
    {'hex': '#FF9800', 'color': const Color(0xFFFF9800), 'label': 'Cam'},
    {'hex': '#F44336', 'color': const Color(0xFFF44336), 'label': 'Đỏ'},
    {'hex': '#00BCD4', 'color': const Color(0xFF00BCD4), 'label': 'Xanh cyan'},
    {'hex': '#FFEB3B', 'color': const Color(0xFFFFEB3B), 'label': 'Vàng'},
    {'hex': '#795548', 'color': const Color(0xFF795548), 'label': 'Nâu'},
    {'hex': '#607D8B', 'color': const Color(0xFF607D8B), 'label': 'Xám xanh'},
    {'hex': '#E91E63', 'color': const Color(0xFFE91E63), 'label': 'Hồng'},
    {'hex': '#009688', 'color': const Color(0xFF009688), 'label': 'Xanh ngọc'},
  ];
}
