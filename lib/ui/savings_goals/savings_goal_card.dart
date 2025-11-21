import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '/models/savings_goal.dart';
import '../shared/app_helpers.dart';
import 'goal_action_dialogs.dart';
import 'add_edit_goal_screen.dart';
import 'savings_goals_manager.dart';

class SavingsGoalCard extends StatelessWidget {
  final SavingsGoal goal;
  final bool isDetailMode; // True for full list, False for block/summary

  const SavingsGoalCard({
    super.key,
    required this.goal,
    this.isDetailMode = true,
  });

  @override
  Widget build(BuildContext context) {
    final color = AppHelpers.parseColor(goal.color);
    final daysRemaining = goal.daysRemaining;

    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      elevation: isDetailMode ? 2 : 0,
      color: isDetailMode ? null : Colors.white,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: isDetailMode 
            ? BorderSide.none 
            : BorderSide(color: color.withOpacity(0.2)),
      ),
      child: InkWell(
        onTap: () => showGoalDetailDialog(context, goal),
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: color.withOpacity(0.15),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Icon(
                      AppHelpers.getIconData(goal.icon),
                      color: color,
                      size: 28,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          goal.name,
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                            color: Colors.black87,
                          ),
                        ),
                        if (isDetailMode && goal.description != null && goal.description!.isNotEmpty)
                          Text(
                            goal.description!,
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.grey.shade600,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        if (!isDetailMode && daysRemaining != null)
                          Text(
                            daysRemaining > 0
                                ? 'Còn $daysRemaining ngày'
                                : 'Đã đến hạn',
                            style: TextStyle(
                              fontSize: 11,
                              color: daysRemaining > 30
                                  ? Colors.grey.shade600
                                  : Colors.orange.shade700,
                              fontWeight: daysRemaining <= 30
                                  ? FontWeight.w600
                                  : FontWeight.normal,
                            ),
                          ),
                      ],
                    ),
                  ),
                  if (isDetailMode)
                    _buildPopupMenu(context, goal)
                  else
                    _buildMiniProgress(context, color),
                ],
              ),

              const SizedBox(height: 16),

              // Progress Bar & Stats
              if (isDetailMode) ...[
                 Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Tiến độ',
                      style: TextStyle(
                        fontSize: 13,
                        color: Colors.grey.shade600,
                      ),
                    ),
                    Text(
                      '${goal.progressPercentage.toStringAsFixed(1)}%',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                        color: color,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
              ],
              
              ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: LinearProgressIndicator(
                  value: goal.progressPercentage / 100,
                  minHeight: isDetailMode ? 10 : 6,
                  backgroundColor: Colors.grey.shade200,
                  valueColor: AlwaysStoppedAnimation<Color>(color),
                ),
              ),
              
              const SizedBox(height: 8),
              
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    AppHelpers.formatCurrency(goal.currentAmount),
                    style: TextStyle(
                      fontSize: isDetailMode ? 13 : 11,
                      fontWeight: FontWeight.w600,
                      color: Colors.green.shade700,
                    ),
                  ),
                  Text(
                    AppHelpers.formatCurrency(goal.targetAmount),
                    style: TextStyle(
                      fontSize: isDetailMode ? 13 : 11,
                      color: Colors.grey.shade600,
                    ),
                  ),
                ],
              ),

              if (isDetailMode) ...[
                const SizedBox(height: 12),
                // Detailed Info Row
                Row(
                  children: [
                    if (daysRemaining != null) ...[
                      Icon(
                        Icons.calendar_today,
                        size: 14,
                        color: Colors.grey.shade600,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        daysRemaining > 0
                            ? 'Còn $daysRemaining ngày'
                            : 'Đã đến hạn',
                        style: TextStyle(
                          fontSize: 12,
                          color: daysRemaining > 30
                              ? Colors.grey.shade600
                              : Colors.orange.shade700,
                          fontWeight: daysRemaining <= 30
                              ? FontWeight.w600
                              : FontWeight.normal,
                        ),
                      ),
                      const SizedBox(width: 16),
                    ],
                    Icon(
                      Icons.trending_up,
                      size: 14,
                      color: Colors.grey.shade600,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      'Còn ${AppHelpers.formatCurrency(goal.remainingAmount)}',
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.grey.shade600,
                      ),
                    ),
                  ],
                ),

                if (!goal.isCompleted) ...[
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Expanded(
                        child: OutlinedButton.icon(
                          onPressed: () => showUpdateProgressDialog(context, goal, isAdd: true),
                          icon: const Icon(Icons.add, size: 18),
                          label: const Text('Thêm tiền'),
                          style: OutlinedButton.styleFrom(
                            foregroundColor: Colors.green,
                            side: const BorderSide(color: Colors.green),
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: OutlinedButton.icon(
                          onPressed: () => showUpdateProgressDialog(context, goal, isAdd: false),
                          icon: const Icon(Icons.remove, size: 18),
                          label: const Text('Rút tiền'),
                          style: OutlinedButton.styleFrom(
                            foregroundColor: Colors.orange,
                            side: const BorderSide(color: Colors.orange),
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ],
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildMiniProgress(BuildContext context, Color color) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        Text(
          '${goal.progressPercentage.toStringAsFixed(0)}%',
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.bold,
            color: color,
          ),
        ),
        Text(
          AppHelpers.formatCurrency(goal.remainingAmount),
          style: TextStyle(
            fontSize: 10,
            color: Colors.grey.shade600,
          ),
        ),
      ],
    );
  }

  Widget _buildPopupMenu(BuildContext context, SavingsGoal goal) {
    return PopupMenuButton(
      itemBuilder: (context) => [
        const PopupMenuItem(
          value: 'edit',
          child: Row(
            children: [
              Icon(Icons.edit, size: 20),
              SizedBox(width: 8),
              Text('Chỉnh sửa'),
            ],
          ),
        ),
        const PopupMenuItem(
          value: 'delete',
          child: Row(
            children: [
              Icon(Icons.delete, size: 20, color: Colors.red),
              SizedBox(width: 8),
              Text('Xóa', style: TextStyle(color: Colors.red)),
            ],
          ),
        ),
      ],
      onSelected: (value) {
        if (value == 'edit') {
          Navigator.of(context).push(
            MaterialPageRoute(
              builder: (context) => AddEditGoalScreen(goal: goal),
            ),
          );
        } else if (value == 'delete') {
          _showDeleteConfirmDialog(context, goal);
        }
      },
    );
  }

  void _showDeleteConfirmDialog(BuildContext context, SavingsGoal goal) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text('Xác nhận xóa'),
        content: Text('Bạn có chắc chắn muốn xóa mục tiêu "${goal.name}"?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Hủy'),
          ),
          ElevatedButton(
            onPressed: () async {
              final goalsManager = context.read<SavingsGoalsManager>();
              await goalsManager.deleteGoal(goal.id);
              
              if (context.mounted) {
                Navigator.of(context).pop(); // Close dialog
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Đã xóa mục tiêu')),
                );
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              foregroundColor: Colors.white,
            ),
            child: const Text('Xóa'),
          ),
        ],
      ),
    );
  }
}
