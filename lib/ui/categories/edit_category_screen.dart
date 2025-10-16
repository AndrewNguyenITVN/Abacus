import 'package:flutter/material.dart';
import '../../models/my_category.dart';

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

  // Danh sách màu sắc có sẵn
  final List<String> _availableColors = [
    '#FF5722', // Deep Orange
    '#4CAF50', // Green
    '#2196F3', // Blue
    '#9C27B0', // Purple
    '#FFC107', // Amber
    '#8BC34A', // Light Green
    '#F44336', // Red
    '#00BCD4', // Cyan
    '#FF9800', // Orange
    '#E91E63', // Pink
    '#3F51B5', // Indigo
    '#009688', // Teal
  ];

  // Danh sách icon có sẵn
  final Map<String, IconData> _availableIcons = {
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
  };

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.category?.name ?? '');
    _selectedIcon = widget.category?.icon ?? 'shopping_bag';
    _selectedColor = widget.category?.color ?? '#FF5722';
  }

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  Color _parseColor(String hexCode) {
    return Color(int.parse(hexCode.substring(1, 7), radix: 16) + 0xFF000000);
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

      Navigator.of(context).pop(category);
    }
  }

  @override
  Widget build(BuildContext context) {
    final isEditing = widget.category != null;

    return Scaffold(
      appBar: AppBar(
        title: Text(isEditing ? 'Sửa danh mục' : 'Thêm danh mục'),
        actions: [
          IconButton(
            icon: const Icon(Icons.check),
            onPressed: _saveCategory,
          ),
        ],
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            // Tên danh mục
            TextFormField(
              controller: _nameController,
              decoration: const InputDecoration(
                labelText: 'Tên danh mục',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.label),
              ),
              validator: (value) {
                if (value == null || value.trim().isEmpty) {
                  return 'Vui lòng nhập tên danh mục';
                }
                return null;
              },
            ),

            const SizedBox(height: 24),

            // Chọn màu sắc
            const Text(
              'Chọn màu sắc',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),
            Wrap(
              spacing: 12,
              runSpacing: 12,
              children: _availableColors.map((color) {
                final isSelected = _selectedColor == color;
                return GestureDetector(
                  onTap: () {
                    setState(() {
                      _selectedColor = color;
                    });
                  },
                  child: Container(
                    width: 50,
                    height: 50,
                    decoration: BoxDecoration(
                      color: _parseColor(color),
                      shape: BoxShape.circle,
                      border: isSelected
                          ? Border.all(color: Colors.black, width: 3)
                          : null,
                    ),
                    child: isSelected
                        ? const Icon(Icons.check, color: Colors.white)
                        : null,
                  ),
                );
              }).toList(),
            ),

            const SizedBox(height: 24),

            // Chọn icon
            const Text(
              'Chọn biểu tượng',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),
            Wrap(
              spacing: 12,
              runSpacing: 12,
              children: _availableIcons.entries.map((entry) {
                final isSelected = _selectedIcon == entry.key;
                return GestureDetector(
                  onTap: () {
                    setState(() {
                      _selectedIcon = entry.key;
                    });
                  },
                  child: Container(
                    width: 60,
                    height: 60,
                    decoration: BoxDecoration(
                      color: isSelected
                          ? _parseColor(_selectedColor)
                          : Colors.grey[200],
                      borderRadius: BorderRadius.circular(12),
                      border: isSelected
                          ? Border.all(color: Colors.black, width: 2)
                          : null,
                    ),
                    child: Icon(
                      entry.value,
                      color: isSelected ? Colors.white : Colors.grey[600],
                      size: 30,
                    ),
                  ),
                );
              }).toList(),
            ),

            const SizedBox(height: 24),

            // Preview
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Row(
                  children: [
                    CircleAvatar(
                      backgroundColor: _parseColor(_selectedColor),
                      radius: 24,
                      child: Icon(
                        _availableIcons[_selectedIcon],
                        color: Colors.white,
                        size: 28,
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Xem trước',
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.grey,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            _nameController.text.isEmpty
                                ? 'Tên danh mục'
                                : _nameController.text,
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

