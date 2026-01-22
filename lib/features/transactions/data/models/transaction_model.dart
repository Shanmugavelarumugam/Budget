import 'package:cloud_firestore/cloud_firestore.dart';
import '../../domain/entities/transaction_entity.dart';

class TransactionModel extends TransactionEntity {
  const TransactionModel({
    required super.id,
    required super.userId,
    required super.amount,
    required super.type,
    required super.category,
    required super.date,
    super.description,
  });

  factory TransactionModel.fromEntity(TransactionEntity entity) {
    return TransactionModel(
      id: entity.id,
      userId: entity.userId,
      amount: entity.amount,
      type: entity.type,
      category: entity.category,
      date: entity.date,
      description: entity.description,
    );
  }

  factory TransactionModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return TransactionModel(
      id: doc.id,
      userId: data['userId'] ?? '',
      amount: (data['amount'] as num?)?.toDouble() ?? 0.0,
      type: TransactionType.values.firstWhere(
        (e) => e.name == data['type'],
        orElse: () => TransactionType.expense,
      ),
      category: data['category'] ?? 'other',
      date: (data['date'] as Timestamp).toDate(),
      description: data['description'],
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'userId': userId,
      'amount': amount,
      'type': type.name,
      'category': category,
      'date': Timestamp.fromDate(date), // Convert DateTime to Timestamp
      'description': description,
    };
  }

  // Local Storage (Hive) Helpers
  Map<String, dynamic> toLocalMap() {
    return {
      'id': id, // Save ID locally
      'userId': userId,
      'amount': amount,
      'type': type.name,
      'category': category,
      'date': date.toIso8601String(), // Save as String
      'description': description,
    };
  }

  factory TransactionModel.fromLocalMap(Map<String, dynamic> map) {
    // Robust parsing for Hive data
    return TransactionModel(
      id: (map['id'] ?? '') as String,
      userId: (map['userId'] ?? 'guest') as String,
      amount: (map['amount'] as num?)?.toDouble() ?? 0.0,
      type: TransactionType.values.firstWhere(
        (e) => e.name == map['type'],
        orElse: () => TransactionType.expense,
      ),
      category: (map['category'] ?? 'other') as String,
      date: map['date'] != null
          ? (map['date'] is String
                ? DateTime.parse(map['date'] as String)
                : (map['date'] is DateTime
                      ? map['date'] as DateTime
                      : DateTime.now()))
          : DateTime.now(),
      description: map['description'] as String?,
    );
  }
}
