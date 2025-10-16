class MyCategory {
  final String id;
  final String name;
  final String icon;
  final String color;
  final String type;
  final bool isDefault;

  MyCategory({
    required this.id,
    required this.name,
    required this.icon,
    required this.color,
    required this.type,
    this.isDefault = false,
  });
}
