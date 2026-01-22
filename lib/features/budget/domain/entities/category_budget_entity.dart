import 'package:equatable/equatable.dart';

/// Entity representing a budget limit for a specific category
class CategoryBudgetEntity extends Equatable {
  final String categoryId;
  final double amount;
  final String month; // Format: 'YYYY-MM' (e.g., '2026-01')

  const CategoryBudgetEntity({
    required this.categoryId,
    required this.amount,
    required this.month,
  });

  @override
  List<Object?> get props => [categoryId, amount, month];

  /// Create a copy with modified fields
  CategoryBudgetEntity copyWith({
    String? categoryId,
    double? amount,
    String? month,
  }) {
    return CategoryBudgetEntity(
      categoryId: categoryId ?? this.categoryId,
      amount: amount ?? this.amount,
      month: month ?? this.month,
    );
  }
}
