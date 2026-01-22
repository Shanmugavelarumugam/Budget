enum TransactionType { income, expense }

class TransactionEntity {
  final String id;
  final String userId;
  final double amount;
  final TransactionType type;
  final String category;
  final DateTime date;
  final String? description;

  const TransactionEntity({
    required this.id,
    required this.userId,
    required this.amount,
    required this.type,
    required this.category,
    required this.date,
    this.description,
  });

  // Helper to check if it's an expense
  bool get isExpense => type == TransactionType.expense;
  bool get isIncome => type == TransactionType.income;
}
