import 'package:flutter/material.dart';
import '../shared/app_constants.dart';
import '../shared/app_helpers.dart';

class CategoryForm extends StatefulWidget {
  final TextEditingController nameController;
  final String selectedIcon;
  final ValueChanged<String> onIconChanged;
  final String selectedColor;
  final ValueChanged<String> onColorChanged;
  final String actionButtonText;
  final VoidCallback onActionTap;

  const CategoryForm({
    super.key,
    required this.nameController,
    required this.selectedIcon,
    required this.onIconChanged,
    required this.selectedColor,
    required this.onColorChanged,
    required this.actionButtonText,
    required this.onActionTap,
  });

  @override
  State<CategoryForm> createState() => _CategoryFormState();
}

class _CategoryFormState extends State<CategoryForm> {
  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildNameInput(colorScheme),
        const SizedBox(height: 24),
        _buildColorPicker(colorScheme),
        const SizedBox(height: 24),
        _buildIconPicker(colorScheme),
        const SizedBox(height: 24),
        _buildPreviewCard(colorScheme),
        const SizedBox(height: 32),
        _buildActionButton(colorScheme),
        const SizedBox(height: 24),
      ],
    );
  }

  Widget _buildNameInput(ColorScheme colorScheme) {
    return TextFormField(
      controller: widget.nameController,
      style: TextStyle(color: colorScheme.onSurface),
      decoration: InputDecoration(
        labelText: 'Tên danh mục',
        labelStyle: TextStyle(color: colorScheme.onSurfaceVariant),
        hintText: 'Nhập tên danh mục...',
        hintStyle: TextStyle(color: colorScheme.onSurface.withOpacity(0.4)),
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
          borderSide: BorderSide(color: colorScheme.primary, width: 2),
        ),
        prefixIcon: Icon(Icons.label_outline_rounded, color: colorScheme.onSurfaceVariant),
        filled: true,
        fillColor: colorScheme.surfaceContainer ?? colorScheme.surface,
      ),
      validator: (value) {
        if (value == null || value.trim().isEmpty) {
          return 'Vui lòng nhập tên danh mục';
        }
        return null;
      },
    );
  }

  Widget _buildColorPicker(ColorScheme colorScheme) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Chọn màu sắc',
          style: TextStyle(
            fontSize: 16, 
            fontWeight: FontWeight.bold,
            color: colorScheme.onSurface,
          ),
        ),
        const SizedBox(height: 12),
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: colorScheme.surfaceContainer ?? colorScheme.surface,
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.04),
                blurRadius: 10,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Wrap(
            spacing: 12,
            runSpacing: 12,
            children: AppConstants.colorOptions.map((option) {
              final hex = option['hex'] as String;
              final color = option['color'] as Color;
              final isSelected = widget.selectedColor == hex;
              
              return GestureDetector(
                onTap: () => widget.onColorChanged(hex),
                child: Container(
                  width: 45,
                  height: 45,
                  decoration: BoxDecoration(
                    color: color,
                    shape: BoxShape.circle,
                    border: isSelected
                        ? Border.all(color: colorScheme.onSurface, width: 3)
                        : Border.all(color: colorScheme.outlineVariant, width: 1),
                    boxShadow: [
                      if (isSelected)
                        BoxShadow(
                          color: color.withOpacity(0.4),
                          blurRadius: 8,
                          offset: const Offset(0, 2),
                        ),
                    ],
                  ),
                  child: isSelected
                      ? const Icon(Icons.check, color: Colors.white, size: 24)
                      : null,
                ),
              );
            }).toList(),
          ),
        ),
      ],
    );
  }

  Widget _buildIconPicker(ColorScheme colorScheme) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Chọn biểu tượng',
          style: TextStyle(
            fontSize: 16, 
            fontWeight: FontWeight.bold,
            color: colorScheme.onSurface,
          ),
        ),
        const SizedBox(height: 12),
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: colorScheme.surfaceContainer ?? colorScheme.surface,
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.04),
                blurRadius: 10,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          height: 300, // Fixed height for scrollable area
          child: GridView.builder(
            shrinkWrap: true,
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 5,
              crossAxisSpacing: 12,
              mainAxisSpacing: 12,
            ),
            itemCount: AppConstants.iconMap.length,
            itemBuilder: (context, index) {
              final entry = AppConstants.iconMap.entries.elementAt(index);
              final isSelected = widget.selectedIcon == entry.key;
              final colorValue = AppHelpers.parseColor(widget.selectedColor);
              
              return GestureDetector(
                onTap: () => widget.onIconChanged(entry.key),
                child: Container(
                  decoration: BoxDecoration(
                    color: isSelected
                        ? colorValue.withOpacity(0.1)
                        : colorScheme.surfaceContainerHighest,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: isSelected ? colorValue : colorScheme.outlineVariant,
                      width: isSelected ? 2 : 1,
                    ),
                  ),
                  child: Icon(
                    entry.value,
                    color: isSelected ? colorValue : colorScheme.onSurfaceVariant,
                    size: 28,
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildPreviewCard(ColorScheme colorScheme) {
    return Card(
      elevation: 0,
      color: colorScheme.surfaceContainer ?? colorScheme.surface,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(color: colorScheme.outlineVariant),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            Container(
              width: 56,
              height: 56,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    AppHelpers.parseColor(widget.selectedColor).withOpacity(0.8),
                    AppHelpers.parseColor(widget.selectedColor),
                  ],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: AppHelpers.parseColor(widget.selectedColor).withOpacity(0.3),
                    blurRadius: 8,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Icon(
                AppHelpers.getIconData(widget.selectedIcon),
                color: Colors.white,
                size: 28,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Xem trước hiển thị',
                    style: TextStyle(
                      fontSize: 12,
                      color: colorScheme.onSurfaceVariant,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    widget.nameController.text.isEmpty
                        ? 'Tên danh mục'
                        : widget.nameController.text,
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: colorScheme.onSurface,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildActionButton(ColorScheme colorScheme) {
    return Container(
      width: double.infinity,
      height: 56,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [colorScheme.primary, colorScheme.secondary],
        ),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: colorScheme.primary.withOpacity(0.4),
            blurRadius: 20,
            offset: const Offset(0, 8),
            spreadRadius: -4,
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: widget.onActionTap,
          borderRadius: BorderRadius.circular(16),
          child: Center(
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.check_circle_rounded, color: colorScheme.onPrimary),
                const SizedBox(width: 12),
                Text(
                  widget.actionButtonText,
                  style: TextStyle(
                    color: colorScheme.onPrimary,
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                    letterSpacing: 0.5,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
