class Transaction {
  final String id;
  final String userId;
  final double amount;
  final String description;
  final DateTime date;
  final String categoryId;
  final String type;
  final String? note;
  final String? imagePath;

  Transaction({
    required this.id,
    required this.userId,
    required this.amount,
    required this.description,
    required this.date,
    required this.categoryId,
    required this.type,
    this.note,
    this.imagePath,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'user_id': userId,
      'amount': amount,
      'description': description,
      'date': date.toIso8601String(),
      'category_id': categoryId,
      'type': type,
      'note': note,
      'image_path': imagePath,
    };
  }

  factory Transaction.fromMap(Map<String, dynamic> map) {
    return Transaction(
      id: map['id'] as String,
      userId: (map['user_id'] as String?) ?? '',
      amount: map['amount'] as double,
      description: map['description'] as String,
      date: DateTime.parse(map['date'] as String),
      categoryId: map['category_id'] as String,
      type: map['type'] as String,
      note: map['note'] as String?,
      imagePath: map['image_path'] as String?,
    );
  }

  Transaction copyWith({
    String? id,
    String? userId,
    double? amount,
    String? description,
    DateTime? date,
    String? categoryId,
    String? type,
    String? note,
    String? imagePath,
  }) {
    return Transaction(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      amount: amount ?? this.amount,
      description: description ?? this.description,
      date: date ?? this.date,
      categoryId: categoryId ?? this.categoryId,
      type: type ?? this.type,
      note: note ?? this.note,
      imagePath: imagePath ?? this.imagePath,
    );
  }
}
