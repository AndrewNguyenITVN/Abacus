import 'package:flutter/material.dart';

class AppConstants {
  // --- Colors ---
  
  static const Color incomeColor = Color(0xFF11998e);
  static const Color expenseColor = Color(0xFFee0979);

  static const List<Color> incomeGradient = [Color(0xFF11998e), Color(0xFF38ef7d)];
  static const List<Color> expenseGradient = [Color(0xFFee0979), Color(0xFFff6a00)];

  // Detailed list for pickers (with labels)
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
    {'hex': '#3F51B5', 'color': const Color(0xFF3F51B5), 'label': 'Chàm'}, 
    {'hex': '#FFC107', 'color': const Color(0xFFFFC107), 'label': 'Hổ phách'}, 
    {'hex': '#8BC34A', 'color': const Color(0xFF8BC34A), 'label': 'Xanh nõn chuối'}, 
    {'hex': '#000000', 'color': const Color(0xFF000000), 'label': 'Đen'}, 
  ];

  // --- Icons ---

  // Map for quick lookup
  static const Map<String, IconData> iconMap = {
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
    'savings': Icons.savings,
    'two_wheeler': Icons.two_wheeler,
    'beach_access': Icons.beach_access,
    'laptop': Icons.laptop,
    'phone_android': Icons.phone_android,
    'account_balance': Icons.account_balance,
    'card_giftcard': Icons.card_giftcard,
    'coffee': Icons.coffee,
    'fastfood': Icons.fastfood,
    'wifi': Icons.wifi,
    'electricity': Icons.electric_bolt,
    'water_drop': Icons.water_drop,
  };
}
