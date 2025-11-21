import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '/models/savings_goal.dart';
import 'savings_helpers.dart';
import 'savings_goals_manager.dart';
import 'add_edit_goal_screen.dart';
import 'quick_amount_selector.dart';

// --- Update Progress Dialog ---

void showUpdateProgressDialog(BuildContext context, SavingsGoal goal, {required bool isAdd}) {
  final controller = TextEditingController();
  final formKey = GlobalKey<FormState>();

  showDialog(
    context: context,
    builder: (context) => StatefulBuilder(
      builder: (context, setDialogState) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Text(isAdd ? 'Thêm tiền vào mục tiêu' : 'Rút tiền từ mục tiêu'),
        content: Form(
          key: formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                goal.name,
                style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
              ),
              const SizedBox(height: 8),
              Text(
                'Số dư hiện tại: ${SavingsHelpers.formatCurrency(goal.currentAmount)}',
                style: TextStyle(fontSize: 13, color: Colors.grey.shade600),
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: controller,
                keyboardType: TextInputType.number,
                decoration: InputDecoration(
                  labelText: 'Số tiền',
                  hintText: 'Nhập số tiền',
                  prefixText: '₫ ',
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) return 'Vui lòng nhập số tiền';
                  final amount = SavingsHelpers.parseAmount(value);
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
          TextButton(onPressed: () => Navigator.of(context).pop(), child: const Text('Hủy')),
          ElevatedButton(
            onPressed: () async {
              if (formKey.currentState!.validate()) {
                final amount = SavingsHelpers.parseAmount(controller.text)!;
                final goalsManager = context.read<SavingsGoalsManager>();
                try {
                  await goalsManager.updateProgress(goal.id, isAdd ? amount : -amount);
                  if (context.mounted) {
                    Navigator.of(context).pop();
                    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                      content: Text(isAdd
                          ? 'Đã thêm ${SavingsHelpers.formatCurrency(amount)} vào mục tiêu'
                          : 'Đã rút ${SavingsHelpers.formatCurrency(amount)} từ mục tiêu'),
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
            style: ElevatedButton.styleFrom(backgroundColor: isAdd ? Colors.green : Colors.orange),
            child: Text(isAdd ? 'Thêm tiền' : 'Rút tiền'),
          ),
        ],
      ),
    ),
  );
}

// --- Goal Detail Dialog ---

void showGoalDetailDialog(BuildContext context, SavingsGoal goal) {
  final color = SavingsHelpers.parseColor(goal.color);
  
  Widget buildDetailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: TextStyle(fontSize: 14, color: Colors.grey.shade600)),
          Text(value, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: Colors.black87)),
        ],
      ),
    );
  }

  showDialog(
    context: context,
    builder: (context) => AlertDialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      title: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: color.withOpacity(0.15),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(SavingsHelpers.getIconData(goal.icon), color: color, size: 24),
          ),
          const SizedBox(width: 12),
          Expanded(child: Text(goal.name, style: const TextStyle(fontSize: 18))),
        ],
      ),
      content: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            if (goal.description != null && goal.description!.isNotEmpty) ...[
              Text(goal.description!, style: TextStyle(fontSize: 14, color: Colors.grey.shade700)),
              const SizedBox(height: 16),
            ],
            buildDetailRow('Mục tiêu', SavingsHelpers.formatCurrency(goal.targetAmount)),
            buildDetailRow('Đã tiết kiệm', SavingsHelpers.formatCurrency(goal.currentAmount)),
            buildDetailRow('Còn lại', SavingsHelpers.formatCurrency(goal.remainingAmount)),
            buildDetailRow('Tiến độ', '${goal.progressPercentage.toStringAsFixed(1)}%'),
            if (goal.targetDate != null)
              buildDetailRow('Hạn hoàn thành', SavingsHelpers.formatDate(goal.targetDate!)),
            if (goal.daysRemaining != null)
              buildDetailRow(
                'Còn lại',
                goal.daysRemaining! > 0 ? '${goal.daysRemaining} ngày' : 'Đã đến hạn',
              ),
          ],
        ),
      ),
      actions: [
        TextButton(onPressed: () => Navigator.of(context).pop(), child: const Text('Đóng')),
        ElevatedButton(
          onPressed: () {
            Navigator.of(context).pop();
            Navigator.of(context).push(
              MaterialPageRoute(builder: (context) => AddEditGoalScreen(goal: goal)),
            );
          },
          child: const Text('Chỉnh sửa'),
        ),
      ],
    ),
  );
}
