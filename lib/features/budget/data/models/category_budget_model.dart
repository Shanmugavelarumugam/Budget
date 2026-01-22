import '../../domain/entities/category_budget_entity.dart';

/// Model for category budget with JSON serialization
class CategoryBudgetModel {
  final String categoryId;
  final double amount;
  final String month;

  const CategoryBudgetModel({
    required this.categoryId,
    required this.amount,
    required this.month,
  });

  /// Convert to entity
  CategoryBudgetEntity toEntity() {
    return CategoryBudgetEntity(
      categoryId: categoryId,
      amount: amount,
      month: month,
    );
  }

  /// Create from entity
  factory CategoryBudgetModel.fromEntity(CategoryBudgetEntity entity) {
    return CategoryBudgetModel(
      categoryId: entity.categoryId,
      amount: entity.amount,
      month: entity.month,
    );
  }

  /// Convert to JSON (for Hive/Firestore)
  Map<String, dynamic> toJson() {
    return {'categoryId': categoryId, 'amount': amount, 'month': month};
  }

  /// Create from JSON
  factory CategoryBudgetModel.fromJson(Map<String, dynamic> json) {
    return CategoryBudgetModel(
      categoryId: json['categoryId'] as String,
      amount: (json['amount'] as num).toDouble(),
      month: json['month'] as String,
    );
  }
}
