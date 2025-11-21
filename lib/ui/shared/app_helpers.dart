import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'app_constants.dart';

class AppHelpers {
  // --- Formatting ---

  static String formatCurrency(double amount) {
    final formatter = NumberFormat.currency(locale: 'vi_VN', symbol: '₫');
    return formatter.format(amount);
  }

  static String formatDate(DateTime date) {
    final formatter = DateFormat('dd/MM/yyyy', 'vi_VN');
    return formatter.format(date);
  }

  static String formatLongDate(DateTime date) {
    final formatter = DateFormat('d MMMM, y', 'vi_VN');
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
    return AppConstants.iconMap[iconName] ?? Icons.help_outline;
  }
}

