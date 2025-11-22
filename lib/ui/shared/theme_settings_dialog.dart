import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'theme_manager.dart';
import 'theme_constants.dart';

class ThemeSettingsDialog extends StatelessWidget {
  const ThemeSettingsDialog({super.key});

  @override
  Widget build(BuildContext context) {
    final themeManager = context.watch<ThemeManager>();

    return AlertDialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
      ),
      title: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: Colors.grey.shade100,
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(
              Icons.palette_rounded,
              color: Colors.grey.shade700,
              size: 24,
            ),
          ),
          const SizedBox(width: 12),
          const Text(
            'Giao diện & Màu sắc',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700),
          ),
        ],
      ),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Toggle Dark Mode
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: themeManager.isDarkMode 
                    ? Colors.grey.shade800 
                    : Colors.grey.shade100,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Icon(
                              themeManager.isDarkMode 
                                  ? Icons.dark_mode_rounded 
                                  : Icons.light_mode_rounded,
                              size: 18,
                              color: themeManager.isDarkMode ? Colors.white : Colors.black87,
                            ),
                            const SizedBox(width: 6),
                            Flexible(
                              child: Text(
                                'Chế độ tối',
                                style: TextStyle(
                                  fontSize: 15,
                                  fontWeight: FontWeight.w600,
                                  color: themeManager.isDarkMode ? Colors.white : Colors.black87,
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 4),
                        Text(
                          themeManager.isDarkMode 
                              ? 'Giao diện nền tối dịu mắt' 
                              : 'Giao diện nền sáng tiêu chuẩn',
                          style: TextStyle(
                            fontSize: 13,
                            color: themeManager.isDarkMode ? Colors.grey.shade400 : Colors.grey.shade600,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Switch(
                    value: themeManager.isDarkMode,
                    onChanged: (value) {
                      context.read<ThemeManager>().toggleTheme(value);
                    },
                    activeColor: themeManager.colorSelected.color,
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),
            
            // Color Selection
            const Text(
              'Màu chủ đạo',
              style: TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 12),
            Wrap(
              spacing: 12,
              runSpacing: 12,
              children: ColorSelection.values.map((colorOption) {
                final isSelected = themeManager.colorSelected == colorOption;
                return GestureDetector(
                  onTap: () {
                    context.read<ThemeManager>().changeColor(colorOption);
                  },
                  child: Column(
                    children: [
                      Container(
                        width: 45,
                        height: 45,
                        decoration: BoxDecoration(
                          color: colorOption.color,
                          shape: BoxShape.circle,
                          border: isSelected
                              ? Border.all(color: Colors.black87, width: 2.5)
                              : null,
                          boxShadow: [
                            BoxShadow(
                              color: colorOption.color.withOpacity(0.4),
                              blurRadius: 6,
                              offset: const Offset(0, 3),
                            ),
                          ],
                        ),
                        child: isSelected
                            ? const Icon(Icons.check, color: Colors.white, size: 24)
                            : null,
                      ),
                      const SizedBox(height: 4),
                      // Optional: Show label for selected or all? 
                      // Showing simple dot grid is cleaner, labels maybe cluttered
                    ],
                  ),
                );
              }).toList(),
            ),
            
            const SizedBox(height: 16),
             Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: themeManager.colorSelected.color.withOpacity(0.1),
                borderRadius: BorderRadius.circular(10),
                border: Border.all(
                  color: themeManager.colorSelected.color.withOpacity(0.3),
                  width: 1,
                ),
              ),
              child: Row(
                children: [
                  Icon(
                    Icons.info_outline_rounded,
                    color: themeManager.colorSelected.color,
                    size: 20,
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'Màu sắc "${themeManager.colorSelected.label}" sẽ được áp dụng cho các nút, biểu tượng và điểm nhấn.',
                      style: TextStyle(
                        fontSize: 12,
                        color: themeManager.isDarkMode ? Colors.white70 : Colors.black87,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: Text(
            'Đóng',
            style: TextStyle(color: Colors.grey.shade600),
          ),
        ),
      ],
    );
  }
}

