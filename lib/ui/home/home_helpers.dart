import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

/// Format số tiền theo định dạng Việt Nam
String formatCurrency(double amount) {
  final formatter = NumberFormat.currency(locale: 'vi_VN', symbol: '₫');
  return formatter.format(amount);
}

/// Format ngày tháng theo định dạng dd/MM/yyyy
String formatDate(DateTime date) {
  final formatter = DateFormat('dd/MM/yyyy', 'vi_VN');
  return formatter.format(date);
}

/// Lấy IconData từ tên icon
IconData getIconData(String iconName) {
  const iconMap = {
    'restaurant': Icons.restaurant,
    'shopping_bag': Icons.shopping_bag,
    'local_gas_station': Icons.local_gas_station,
    'house': Icons.house,
    'work': Icons.work,
    'attach_money': Icons.attach_money,
  };
  return iconMap[iconName] ?? Icons.category;
}

/// Parse màu từ hex string
Color parseColor(String hexColor) {
  final hexCode = hexColor.replaceAll('#', '');
  return Color(int.parse('FF$hexCode', radix: 16));
}
