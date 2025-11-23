import 'package:flutter/material.dart';
import '../../models/my_category.dart';
import 'category_form.dart';
import '../shared/app_constants.dart';
import 'package:go_router/go_router.dart';

class EditCategoryScreen extends StatefulWidget {
  final MyCategory? category; // null khi thêm mới
  final String type; // 'expense' hoặc 'income'

  const EditCategoryScreen({
    super.key,
    this.category,
    required this.type,
  });

  @override
  State<EditCategoryScreen> createState() => _EditCategoryScreenState();
}

class _EditCategoryScreenState extends State<EditCategoryScreen> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _nameController;
  late String _selectedIcon;
  late String _selectedColor;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.category?.name ?? '');
    _selectedIcon = widget.category?.icon ?? 'shopping_bag';
    // Use colorOptions instead of defaultColors
    _selectedColor = widget.category?.color ?? AppConstants.colorOptions[0]['hex'] as String;
  }

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  void _saveCategory() {
    if (_formKey.currentState!.validate()) {
      final category = MyCategory(
        id: widget.category?.id ?? DateTime.now().millisecondsSinceEpoch.toString(),
        name: _nameController.text.trim(),
        icon: _selectedIcon,
        color: _selectedColor,
        type: widget.type,
        isDefault: widget.category?.isDefault ?? false,
      );
      context.pop(category);
    }
  }

  @override
  Widget build(BuildContext context) {
    final isEditing = widget.category != null;

    return Scaffold(
      appBar: AppBar(
        title: Text(
          isEditing ? 'Sửa danh mục' : 'Thêm danh mục',
          style: const TextStyle(
            fontWeight: FontWeight.w700,
            fontSize: 20,
            letterSpacing: -0.5,
          ),
        ),
        elevation: 0,
        surfaceTintColor: Colors.transparent,
        centerTitle: true,
      ),
      body: Form(
        key: _formKey,
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: CategoryForm(
            nameController: _nameController,
            selectedIcon: _selectedIcon,
            onIconChanged: (icon) {
              setState(() {
                _selectedIcon = icon;
              });
            },
            selectedColor: _selectedColor,
            onColorChanged: (color) {
              setState(() {
                _selectedColor = color;
              });
            },
            actionButtonText: isEditing ? 'Cập nhật' : 'Lưu danh mục',
            onActionTap: _saveCategory,
          ),
        ),
      ),
    );
  }
}
