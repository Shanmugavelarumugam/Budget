import 'package:cloud_firestore/cloud_firestore.dart';
import '../../domain/entities/budget_entity.dart';

class BudgetModel extends BudgetEntity {
  const BudgetModel({
    required super.id,
    required super.amount,
    required super.createdAt,
    required super.userId,
  });

  factory BudgetModel.fromEntity(BudgetEntity entity) {
    return BudgetModel(
      id: entity.id,
      amount: entity.amount,
      createdAt: entity.createdAt,
      userId: entity.userId,
    );
  }

  factory BudgetModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return BudgetModel(
      id: doc.id,
      amount: (data['totalLimit'] as num).toDouble(),
      createdAt: (data['createdAt'] as Timestamp).toDate(),
      userId: data['userId'] ?? '', // Fallback if not stored
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'totalLimit': amount,
      'createdAt': Timestamp.fromDate(createdAt),
      'updatedAt': FieldValue.serverTimestamp(),
      'userId': userId,
    };
  }

  // For Guest Mode (Hive)
  factory BudgetModel.fromLocalMap(Map<String, dynamic> map) {
    return BudgetModel(
      id: map['id'],
      amount: (map['amount'] as num).toDouble(),
      createdAt: DateTime.parse(map['createdAt']),
      userId: map['userId'],
    );
  }

  Map<String, dynamic> toLocalMap() {
    return {
      'id': id,
      'amount': amount,
      'createdAt': createdAt.toIso8601String(),
      'userId': userId,
    };
  }
}
