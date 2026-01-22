import 'package:equatable/equatable.dart';

class BudgetEntity extends Equatable {
  final String id; // Format: "yyyy-MM" e.g. "2024-01"
  final double amount;
  final DateTime createdAt;
  final String userId;

  const BudgetEntity({
    required this.id,
    required this.amount,
    required this.createdAt,
    required this.userId,
  });

  @override
  List<Object?> get props => [id, amount, createdAt, userId];
}
