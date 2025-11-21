import 'package:flutter/material.dart';

class CategoriesHelpers {
  // --- Color Helper ---

  static Color parseColor(String hexCode) {
    try {
      if (hexCode.startsWith('#')) {
        hexCode = hexCode.substring(1);
      }
      // Handle cases where alpha is missing (assume FF)
      if (hexCode.length == 6) {
        hexCode = 'FF$hexCode';
      }
      return Color(int.parse(hexCode, radix: 16));
    } catch (e) {
      return Colors.grey;
    }
  }

  // --- Icon Helper ---

  static IconData getIconData(String iconName) {
    return defaultIcons[iconName] ?? Icons.help_outline;
  }

  // --- Constants ---

  static const List<String> defaultColors = [
    '#FF5722', // Deep Orange
    '#4CAF50', // Green
    '#2196F3', // Blue
    '#9C27B0', // Purple
    '#FFC107', // Amber
    '#8BC34A', // Light Green
    '#F44336', // Red
    '#00BCD4', // Cyan
    '#FF9800', // Orange
    '#E91E63', // Pink
    '#3F51B5', // Indigo
    '#009688', // Teal
    '#795548', // Brown
    '#607D8B', // Blue Grey
    '#000000', // Black
  ];

  static const Map<String, IconData> defaultIcons = {
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

