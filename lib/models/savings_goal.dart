class SavingsGoal {
  final String id;
  final String userId;
  final String name;
  final String? description;
  final double targetAmount;
  final double currentAmount;
  final DateTime? targetDate;
  final String icon; // Icon name
  final String color; // Hex color
  final DateTime createdAt;
  final DateTime updatedAt;

  SavingsGoal({
    required this.id,
    required this.userId,
    required this.name,
    this.description,
    required this.targetAmount,
    required this.currentAmount,
    this.targetDate,
    required this.icon,
    required this.color,
    required this.createdAt,
    required this.updatedAt,
  });

  // Calculate progress percentage (0-100)
  double get progressPercentage {
    if (targetAmount <= 0) return 0;
    return ((currentAmount / targetAmount) * 100).clamp(0, 100);
  }

  // Calculate remaining amount
  double get remainingAmount {
    return (targetAmount - currentAmount).clamp(0, double.infinity);
  }

  // Check if goal is completed
  bool get isCompleted => currentAmount >= targetAmount;

  // Calculate days remaining
  int? get daysRemaining {
    if (targetDate == null) return null;
    final now = DateTime.now();
    final difference = targetDate!.difference(now);
    return difference.inDays;
  }

  // To Map for SQLite
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'user_id': userId,
      'name': name,
      'description': description,
      'target_amount': targetAmount,
      'current_amount': currentAmount,
      'target_date': targetDate?.toIso8601String(),
      'icon': icon,
      'color': color,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
    };
  }

  // From Map for SQLite
  factory SavingsGoal.fromMap(Map<String, dynamic> map) {
    return SavingsGoal(
      id: map['id'] as String,
      userId: (map['user_id'] as String?) ?? '',
      name: map['name'] as String,
      description: map['description'] as String?,
      targetAmount: map['target_amount'] as double,
      currentAmount: map['current_amount'] as double,
      targetDate: map['target_date'] != null 
          ? DateTime.parse(map['target_date'] as String)
          : null,
      icon: map['icon'] as String,
      color: map['color'] as String,
      createdAt: DateTime.parse(map['created_at'] as String),
      updatedAt: DateTime.parse(map['updated_at'] as String),
    );
  }

  // From JSON
  factory SavingsGoal.fromJson(Map<String, dynamic> json) {
    return SavingsGoal(
      id: json['id'] ?? '',
      userId: json['user_id'] ?? '',
      name: json['name'] ?? '',
      description: json['description'],
      targetAmount: (json['target_amount'] ?? json['targetAmount'] ?? 0).toDouble(),
      currentAmount: (json['current_amount'] ?? json['currentAmount'] ?? 0).toDouble(),
      targetDate: json['target_date'] != null || json['targetDate'] != null
          ? DateTime.parse(json['target_date'] ?? json['targetDate'])
          : null,
      icon: json['icon'] ?? 'savings',
      color: json['color'] ?? '#4CAF50',
      createdAt: DateTime.parse(json['created'] ?? json['createdAt'] ?? DateTime.now().toIso8601String()),
      updatedAt: DateTime.parse(json['updated'] ?? json['updatedAt'] ?? DateTime.now().toIso8601String()),
    );
  }

  // To JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'user_id': userId,
      'name': name,
      'description': description,
      'target_amount': targetAmount,
      'current_amount': currentAmount,
      'target_date': targetDate?.toIso8601String(),
      'icon': icon,
      'color': color,
      'created': createdAt.toIso8601String(),
      'updated': updatedAt.toIso8601String(),
    };
  }

  // Copy with
  SavingsGoal copyWith({
    String? id,
    String? userId,
    String? name,
    String? description,
    double? targetAmount,
    double? currentAmount,
    DateTime? targetDate,
    String? icon,
    String? color,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return SavingsGoal(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      name: name ?? this.name,
      description: description ?? this.description,
      targetAmount: targetAmount ?? this.targetAmount,
      currentAmount: currentAmount ?? this.currentAmount,
      targetDate: targetDate ?? this.targetDate,
      icon: icon ?? this.icon,
      color: color ?? this.color,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}
