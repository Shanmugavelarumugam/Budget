import '../entities/goal_entity.dart';

abstract class GoalRepository {
  Future<void> addGoal(GoalEntity goal);
  Future<void> updateGoal(GoalEntity goal);
  Future<void> deleteGoal(String userId, String goalId);
  Stream<List<GoalEntity>> getGoals(String userId);
}
