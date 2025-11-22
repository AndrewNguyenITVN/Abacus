import 'package:flutter/material.dart';
import '../../models/my_category.dart';
import '../shared/app_helpers.dart';

class CategoryItem extends StatelessWidget {
  final MyCategory category;
  final VoidCallback? onTap;
  final VoidCallback? onDelete;

  const CategoryItem({
    super.key,
    required this.category,
    this.onTap,
    this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    final categoryColor = AppHelpers.parseColor(category.color);
    final colorScheme = Theme.of(context).colorScheme;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      margin: const EdgeInsets.only(bottom: 10), // Changed from 12 to 10 to match TransactionItem
      decoration: BoxDecoration(
        color: colorScheme.surfaceContainer ?? colorScheme.surface,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 10,
            offset: const Offset(0, 2),
            spreadRadius: -2,
          ),
        ],
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 10, // Changed from 8 to 10 to match TransactionItem
        ),
        leading: Container(
          width: 48,
          height: 48,
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                categoryColor.withOpacity(0.8),
                categoryColor,
              ],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(14),
            boxShadow: [
              BoxShadow(
                color: categoryColor.withOpacity(0.3),
                blurRadius: 8,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Icon(
            AppHelpers.getIconData(category.icon),
            color: Colors.white,
            size: 22,
          ),
        ),
        title: Text(
          category.name,
          style: TextStyle(
            fontWeight: FontWeight.w600,
            fontSize: 15,
            color: colorScheme.onSurface,
            letterSpacing: -0.2,
          ),
        ),
        subtitle: Padding(
          padding: const EdgeInsets.only(top: 4),
          child: Align(
            alignment: Alignment.centerLeft,
            child: Container(
              padding: const EdgeInsets.symmetric(
                horizontal: 8,
                vertical: 2,
              ),
              decoration: BoxDecoration(
                color: (category.isDefault ? Colors.blue : Colors.purple)
                    .withOpacity(isDark ? 0.2 : 0.1),
                borderRadius: BorderRadius.circular(4),
              ),
              child: Text(
                category.isDefault ? 'Mặc định' : 'Tùy chỉnh',
                style: TextStyle(
                  color: category.isDefault
                      ? Colors.blue.shade400
                      : Colors.purple.shade400,
                  fontSize: 11,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ),
        ),
        trailing: category.isDefault
            ? null
            : IconButton(
                icon: Icon(
                  Icons.delete_outline_rounded,
                  color: colorScheme.error,
                ),
                onPressed: onDelete,
                tooltip: 'Xóa danh mục',
              ),
        onTap: category.isDefault ? null : onTap,
      ),
    );
  }
}
