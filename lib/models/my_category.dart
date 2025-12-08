class MyCategory {
  final String id;
  final String userId; 
  final String name;
  final String icon;
  final String color;
  final String type;
  final bool isDefault;

  MyCategory({
    required this.id,
    required this.userId, 
    required this.name,
    required this.icon,
    required this.color,
    required this.type,
    this.isDefault = false,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'user_id': userId, 
      'name': name,
      'icon': icon,
      'color': color,
      'type': type,
      'is_default': isDefault ? 1 : 0,
    };
  }

  factory MyCategory.fromMap(Map<String, dynamic> map) {
    return MyCategory(
      id: map['id'] as String,
      userId: (map['user_id'] as String?) ?? '', 
      name: map['name'] as String,
      icon: map['icon'] as String,
      color: map['color'] as String,
      type: map['type'] as String,
      isDefault: (map['is_default'] ?? 0) == 1,
    );
  }

  MyCategory copyWith({
    String? id,
    String? userId, 
    String? name,
    String? icon,
    String? color,
    String? type,
    bool? isDefault,
  }) {
    return MyCategory(
      id: id ?? this.id,
      userId: userId ?? this.userId, 
      name: name ?? this.name,
      icon: icon ?? this.icon,
      color: color ?? this.color,
      type: type ?? this.type,
      isDefault: isDefault ?? this.isDefault,
    );
  }
}
