import 'package:cloud_firestore/cloud_firestore.dart';
import '../../domain/entities/goal_entity.dart';

class GoalModel extends GoalEntity {
  const GoalModel({
    required super.id,
    required super.userId,
    required super.name,
    required super.targetAmount,
    super.currentAmount = 0.0,
    super.targetDate,
    super.description,
    required super.createdAt,
    super.isCompleted = false,
    super.logs = const [],
  });

  factory GoalModel.fromEntity(GoalEntity entity) {
    return GoalModel(
      id: entity.id,
      userId: entity.userId,
      name: entity.name,
      targetAmount: entity.targetAmount,
      currentAmount: entity.currentAmount,
      targetDate: entity.targetDate,
      description: entity.description,
      createdAt: entity.createdAt,
      isCompleted: entity.isCompleted,
      logs: entity.logs,
    );
  }

  factory GoalModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return GoalModel(
      id: doc.id,
      userId: data['userId'] ?? '',
      name: data['name'] ?? '',
      targetAmount: (data['targetAmount'] as num?)?.toDouble() ?? 0.0,
      currentAmount: (data['currentAmount'] as num?)?.toDouble() ?? 0.0,
      targetDate: data['targetDate'] != null
          ? (data['targetDate'] as Timestamp).toDate()
          : null,
      description: data['description'],
      createdAt: (data['createdAt'] as Timestamp? ?? Timestamp.now()).toDate(),
      isCompleted: data['isCompleted'] ?? false,
      logs:
          (data['logs'] as List<dynamic>?)
              ?.map((e) => GoalLogModel.fromMap(e as Map<String, dynamic>))
              .toList() ??
          [],
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'userId': userId,
      'name': name,
      'targetAmount': targetAmount,
      'currentAmount': currentAmount,
      'targetDate': targetDate != null ? Timestamp.fromDate(targetDate!) : null,
      'description': description,
      'createdAt': Timestamp.fromDate(createdAt),
      'isCompleted': isCompleted,
      'logs': logs.map((e) => GoalLogModel.fromEntity(e).toMap()).toList(),
    };
  }

  // Local Storage (Hive) Helpers
  Map<String, dynamic> toLocalMap() {
    return {
      'id': id,
      'userId': userId,
      'name': name,
      'targetAmount': targetAmount,
      'currentAmount': currentAmount,
      'targetDate': targetDate?.toIso8601String(),
      'description': description,
      'createdAt': createdAt.toIso8601String(),
      'isCompleted': isCompleted,
      'logs': logs.map((e) => GoalLogModel.fromEntity(e).toLocalMap()).toList(),
    };
  }

  factory GoalModel.fromLocalMap(Map<String, dynamic> map) {
    return GoalModel(
      id: (map['id'] ?? '') as String,
      userId: (map['userId'] ?? 'guest') as String,
      name: (map['name'] ?? '') as String,
      targetAmount: (map['targetAmount'] as num?)?.toDouble() ?? 0.0,
      currentAmount: (map['currentAmount'] as num?)?.toDouble() ?? 0.0,
      targetDate: map['targetDate'] != null
          ? DateTime.parse(map['targetDate'] as String)
          : null,
      description: map['description'] as String?,
      createdAt: map['createdAt'] != null
          ? DateTime.parse(map['createdAt'] as String)
          : DateTime.now(),
      isCompleted: (map['isCompleted'] ?? false) as bool,
      logs:
          (map['logs'] as List<dynamic>?)
              ?.map((e) => GoalLogModel.fromLocalMap(e as Map<String, dynamic>))
              .toList() ??
          [],
    );
  }
}

class GoalLogModel extends GoalLogEntity {
  const GoalLogModel({
    required super.id,
    required super.amount,
    required super.date,
    super.type,
  });

  factory GoalLogModel.fromEntity(GoalLogEntity entity) {
    return GoalLogModel(
      id: entity.id,
      amount: entity.amount,
      date: entity.date,
      type: entity.type,
    );
  }

  factory GoalLogModel.fromMap(Map<String, dynamic> map) {
    return GoalLogModel(
      id: map['id'] ?? '',
      amount: (map['amount'] as num?)?.toDouble() ?? 0.0,
      date: (map['date'] as Timestamp).toDate(),
      type: map['type'] ?? 'deposit',
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'amount': amount,
      'date': Timestamp.fromDate(date),
      'type': type,
    };
  }

  // For Hive
  factory GoalLogModel.fromLocalMap(Map<String, dynamic> map) {
    return GoalLogModel(
      id: map['id'] ?? '',
      amount: (map['amount'] as num?)?.toDouble() ?? 0.0,
      date: DateTime.parse(map['date']),
      type: map['type'] ?? 'deposit',
    );
  }

  Map<String, dynamic> toLocalMap() {
    return {
      'id': id,
      'amount': amount,
      'date': date.toIso8601String(),
      'type': type,
    };
  }
}
