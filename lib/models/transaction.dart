class Transaction {
  final String id;
  final double amount;
  final String description;
  final DateTime date;
  final String categoryId;
  final String type;
  final String? note;

  Transaction({
    required this.id,
    required this.amount,
    required this.description,
    required this.date,
    required this.categoryId,
    required this.type,
    this.note,
  });
}
