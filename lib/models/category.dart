class Category {
  final String id;
  final String name;
  final String icon;
  final String color;
  final String type;
  final bool isDefault;

  Category({
    required this.id,
    required this.name,
    required this.icon,
    required this.color,
    required this.type,
    this.isDefault = false,
  });
}
