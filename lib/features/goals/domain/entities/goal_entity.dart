import 'package:equatable/equatable.dart';

class GoalEntity extends Equatable {
  final String id;
  final String userId;
  final String name;
  final double targetAmount;
  final double currentAmount;
  final DateTime? targetDate;
  final String? description;
  final DateTime createdAt;
  final bool isCompleted;
  final List<GoalLogEntity> logs;

  const GoalEntity({
    required this.id,
    required this.userId,
    required this.name,
    required this.targetAmount,
    this.currentAmount = 0.0,
    this.targetDate,
    this.description,
    required this.createdAt,
    this.isCompleted = false,
    this.logs = const [],
  });

  double get progress => (currentAmount / targetAmount).clamp(0.0, 1.0);
  double get remainingAmount =>
      (targetAmount - currentAmount).clamp(0.0, targetAmount);

  @override
  List<Object?> get props => [
    id,
    userId,
    name,
    targetAmount,
    currentAmount,
    targetDate,
    description,
    createdAt,
    isCompleted,
    logs,
  ];

  GoalEntity copyWith({
    String? id,
    String? name,
    double? targetAmount,
    double? currentAmount,
    DateTime? targetDate,
    String? description,
    bool? isCompleted,
    List<GoalLogEntity>? logs,
  }) {
    return GoalEntity(
      id: id ?? this.id,
      userId: userId,
      name: name ?? this.name,
      targetAmount: targetAmount ?? this.targetAmount,
      currentAmount: currentAmount ?? this.currentAmount,
      targetDate: targetDate ?? this.targetDate,
      description: description ?? this.description,
      createdAt: createdAt,
      isCompleted: isCompleted ?? this.isCompleted,
      logs: logs ?? this.logs,
    );
  }
}

class GoalLogEntity extends Equatable {
  final String id;
  final double amount;
  final DateTime date;
  final String type; // 'deposit' or 'withdraw'

  const GoalLogEntity({
    required this.id,
    required this.amount,
    required this.date,
    this.type = 'deposit',
  });

  @override
  List<Object?> get props => [id, amount, date, type];
}
