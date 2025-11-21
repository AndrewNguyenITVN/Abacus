import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class TransactionHelpers {
  // --- Formatting ---

  static String formatCurrency(double amount) {
    final formatter = NumberFormat.currency(locale: 'vi_VN', symbol: '₫');
    return formatter.format(amount);
  }

  static String formatDate(DateTime date) {
    final formatter = DateFormat('d MMMM, y', 'vi_VN');
    return formatter.format(date);
  }

  static String formatShortDate(DateTime date) {
    final formatter = DateFormat('dd/MM/yyyy', 'vi_VN');
    return formatter.format(date);
  }

  static double? parseAmount(String? value) {
    if (value == null || value.isEmpty) return null;
    // Remove dots (thousands separator) and replace comma with dot (decimal)
    String clean = value.replaceAll('.', '').replaceAll(',', '.');
    return double.tryParse(clean);
  }

  // --- UI Helpers ---

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

  static IconData getIconData(String iconName) {
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
      'savings': Icons.savings,
      'two_wheeler': Icons.two_wheeler,
      'beach_access': Icons.beach_access,
      'laptop': Icons.laptop,
      'phone_android': Icons.phone_android,
      'account_balance': Icons.account_balance,
      'card_giftcard': Icons.card_giftcard,
    };
    return iconMap[iconName] ?? Icons.help_outline;
  }

  // --- Constants ---
  
  static const List<Color> incomeGradient = [Color(0xFF11998e), Color(0xFF38ef7d)];
  static const List<Color> expenseGradient = [Color(0xFFee0979), Color(0xFFff6a00)];
  
  static const Color incomeColor = Color(0xFF11998e);
  static const Color expenseColor = Color(0xFFee0979);
}


