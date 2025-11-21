import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'savings_helpers.dart';

class QuickAmountSelector extends StatelessWidget {
  final TextEditingController controller;
  final VoidCallback? onChanged;

  const QuickAmountSelector({
    super.key,
    required this.controller,
    this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    final amounts = ['10000', '100000', '1000000', '00','000'];
    return Row(
      children: [
        for (var i = 0; i < amounts.length; i++)
          Expanded(
            child: Padding(
              padding: EdgeInsets.only(right: i < amounts.length - 1 ? 8 : 0), 
              child: _buildButton(amounts[i]),
            ),
          ),
      ],
    );
  }

  Widget _buildButton(String amount) {
    String buttonText;
    if (amount == '00') {
      buttonText = '.00'; 
    } else if (amount == '000') {
      buttonText = '.000'; 
    } else {
      // Dùng NumberFormat.compact() để format 10000 -> 10K, 1000000 -> 1M
      buttonText = '+${NumberFormat.compact().format(int.parse(amount))}';
    }

    return InkWell(
      onTap: () => _addAmount(amount),
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 10),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.grey.shade200, width: 1.5),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.04),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Center(
          child: Text(
            buttonText, 
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w600,
              color: Colors.grey.shade700,
            ),
          ),
        ),
      ),
    );
  }

  void _addAmount(String amount) {
    double current = SavingsHelpers.parseAmount(controller.text) ?? 0;

    if (amount == '00') {
      current *= 100;
    } else if (amount == '000') {
      current *= 1000;
    } else {
      current += double.parse(amount);
    }
    
    // Format back to string with dots as thousands separators
    final formatter = NumberFormat.decimalPattern('vi_VN');
    controller.text = formatter.format(current);
    
    // Trigger callback if provided (to update UI/State)
    onChanged?.call();
  }
}
