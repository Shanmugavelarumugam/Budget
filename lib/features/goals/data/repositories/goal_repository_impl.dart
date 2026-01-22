import 'package:cloud_firestore/cloud_firestore.dart';
import '../../domain/entities/goal_entity.dart';
import '../../domain/repositories/goal_repository.dart';
import '../models/goal_model.dart';

class GoalRepositoryImpl implements GoalRepository {
  final FirebaseFirestore _firestore;

  GoalRepositoryImpl({FirebaseFirestore? firestore})
    : _firestore = firestore ?? FirebaseFirestore.instance;

  @override
  Future<void> addGoal(GoalEntity goal) async {
    final model = GoalModel.fromEntity(goal);
    await _firestore
        .collection('users')
        .doc(goal.userId)
        .collection('goals')
        .doc(goal.id)
        .set(model.toMap());
  }

  @override
  Future<void> updateGoal(GoalEntity goal) async {
    final model = GoalModel.fromEntity(goal);
    await _firestore
        .collection('users')
        .doc(goal.userId)
        .collection('goals')
        .doc(goal.id)
        .update(model.toMap());
  }

  @override
  Future<void> deleteGoal(String userId, String goalId) async {
    await _firestore
        .collection('users')
        .doc(userId)
        .collection('goals')
        .doc(goalId)
        .delete();
  }

  @override
  Stream<List<GoalEntity>> getGoals(String userId) {
    return _firestore
        .collection('users')
        .doc(userId)
        .collection('goals')
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snapshot) {
          return snapshot.docs
              .map((doc) => GoalModel.fromFirestore(doc))
              .toList();
        });
  }
}
