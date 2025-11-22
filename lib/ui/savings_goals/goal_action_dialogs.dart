import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '/models/savings_goal.dart';
import '../shared/app_helpers.dart';
import 'savings_goals_manager.dart';
import 'add_edit_goal_screen.dart';
import 'quick_amount_selector.dart';

// --- Update Progress Dialog ---

void showUpdateProgressDialog(BuildContext context, SavingsGoal goal, {required bool isAdd}) {
  final controller = TextEditingController();
  final formKey = GlobalKey<FormState>();

  showDialog(
    context: context,
    builder: (context) {
      final colorScheme = Theme.of(context).colorScheme;
      return StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          backgroundColor: colorScheme.surfaceContainer,
          title: Text(
            isAdd ? 'Thêm tiền vào mục tiêu' : 'Rút tiền từ mục tiêu',
            style: TextStyle(color: colorScheme.onSurface),
          ),
          content: Form(
            key: formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  goal.name,
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: colorScheme.onSurface,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Số dư hiện tại: ${AppHelpers.formatCurrency(goal.currentAmount)}',
                  style: TextStyle(fontSize: 13, color: colorScheme.onSurface.withOpacity(0.6)),
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: controller,
                  keyboardType: TextInputType.number,
                  style: TextStyle(color: colorScheme.onSurface),
                  decoration: InputDecoration(
                    labelText: 'Số tiền',
                    labelStyle: TextStyle(color: colorScheme.onSurfaceVariant),
                    hintText: 'Nhập số tiền',
                    hintStyle: TextStyle(color: colorScheme.onSurface.withOpacity(0.4)),
                    prefixText: '₫ ',
                    prefixStyle: TextStyle(color: colorScheme.onSurface),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide(color: colorScheme.outlineVariant),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide(color: colorScheme.outlineVariant),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide(color: colorScheme.primary),
                    ),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) return 'Vui lòng nhập số tiền';
                    final amount = AppHelpers.parseAmount(value);
                    if (amount == null || amount <= 0) return 'Số tiền không hợp lệ';
                    if (!isAdd && amount > goal.currentAmount) return 'Số tiền vượt quá số dư hiện tại';
                    return null;
                  },
                ),
                const SizedBox(height: 8),
                QuickAmountSelector(
                  controller: controller,
                  onChanged: () => setDialogState(() {}),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: Text('Hủy', style: TextStyle(color: colorScheme.onSurface.withOpacity(0.6))),
            ),
            ElevatedButton(
              onPressed: () async {
                if (formKey.currentState!.validate()) {
                  final amount = AppHelpers.parseAmount(controller.text)!;
                  final goalsManager = context.read<SavingsGoalsManager>();
                  try {
                    await goalsManager.updateProgress(goal.id, isAdd ? amount : -amount);
                    if (context.mounted) {
                      Navigator.of(context).pop();
                      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                        content: Text(isAdd
                            ? 'Đã thêm ${AppHelpers.formatCurrency(amount)} vào mục tiêu'
                            : 'Đã rút ${AppHelpers.formatCurrency(amount)} từ mục tiêu'),
                        backgroundColor: Colors.green,
                      ));
                    }
                  } catch (e) {
                    if (context.mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text('Có lỗi xảy ra: $e'), backgroundColor: Colors.red));
                    }
                  }
                }
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: isAdd ? Colors.green : Colors.orange,
                foregroundColor: Colors.white,
              ),
              child: Text(isAdd ? 'Thêm tiền' : 'Rút tiền'),
            ),
          ],
        ),
      );
    },
  );
}

// --- Goal Detail Dialog ---

void showGoalDetailDialog(BuildContext context, SavingsGoal goal) {
  final color = AppHelpers.parseColor(goal.color);
  final colorScheme = Theme.of(context).colorScheme;
  final isDark = Theme.of(context).brightness == Brightness.dark;
  
  Widget buildDetailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: TextStyle(fontSize: 14, color: colorScheme.onSurface.withOpacity(0.6))),
          Text(value, style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: colorScheme.onSurface)),
        ],
      ),
    );
  }

  showDialog(
    context: context,
    builder: (context) => AlertDialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      backgroundColor: colorScheme.surfaceContainer,
      title: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: color.withOpacity(isDark ? 0.2 : 0.15),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(AppHelpers.getIconData(goal.icon), color: color, size: 24),
          ),
          const SizedBox(width: 12),
          Expanded(child: Text(goal.name, style: TextStyle(fontSize: 18, color: colorScheme.onSurface))),
        ],
      ),
      content: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            if (goal.description != null && goal.description!.isNotEmpty) ...[
              Text(goal.description!, style: TextStyle(fontSize: 14, color: colorScheme.onSurface.withOpacity(0.8))),
              const SizedBox(height: 16),
            ],
            buildDetailRow('Mục tiêu', AppHelpers.formatCurrency(goal.targetAmount)),
            buildDetailRow('Đã tiết kiệm', AppHelpers.formatCurrency(goal.currentAmount)),
            buildDetailRow('Còn lại', AppHelpers.formatCurrency(goal.remainingAmount)),
            buildDetailRow('Tiến độ', '${goal.progressPercentage.toStringAsFixed(1)}%'),
            if (goal.targetDate != null)
              buildDetailRow('Hạn hoàn thành', AppHelpers.formatDate(goal.targetDate!)),
            if (goal.daysRemaining != null)
              buildDetailRow(
                'Còn lại',
                goal.daysRemaining! > 0 ? '${goal.daysRemaining} ngày' : 'Đã đến hạn',
              ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: Text('Đóng', style: TextStyle(color: colorScheme.onSurface.withOpacity(0.6))),
        ),
        ElevatedButton(
          onPressed: () {
            Navigator.of(context).pop();
            Navigator.of(context).push(
              MaterialPageRoute(builder: (context) => AddEditGoalScreen(goal: goal)),
            );
          },
          style: ElevatedButton.styleFrom(
            backgroundColor: colorScheme.primary,
            foregroundColor: colorScheme.onPrimary,
          ),
          child: const Text('Chỉnh sửa'),
        ),
      ],
    ),
  );
}
