import 'dart:async';
import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:uuid/uuid.dart';
import '../../domain/entities/goal_entity.dart';
import '../../domain/repositories/goal_repository.dart';
import '../../../auth/domain/entities/user_entity.dart';
import '../../data/models/goal_model.dart';

class GoalProvider extends ChangeNotifier {
  final GoalRepository _repository;

  List<GoalEntity> _goals = [];
  StreamSubscription<List<GoalEntity>>? _subscription;
  UserEntity? _currentUser;
  bool _isLoading = false;

  GoalProvider(this._repository);

  List<GoalEntity> get goals => _goals;
  bool get isLoading => _isLoading;

  void updateUser(UserEntity? user) {
    if (_currentUser?.uid == user?.uid) return;
    _currentUser = user;
    _initStream();
  }

  void _initStream() {
    _subscription?.cancel();
    _goals = [];
    notifyListeners();

    if (_currentUser == null) return;

    _isLoading = true;
    notifyListeners();

    if (_currentUser!.isGuest) {
      _loadGuestGoals();
      return;
    }

    _subscription = _repository
        .getGoals(_currentUser!.uid)
        .listen(
          (data) {
            _goals = data;
            _isLoading = false;
            notifyListeners();
          },
          onError: (error) {
            _isLoading = false;
            notifyListeners();
          },
        );
  }

  void _loadGuestGoals() {
    try {
      final box = Hive.box('guest_goals');
      final data = box.values.toList();
      final List<GoalEntity> loaded = [];

      for (var e in data) {
        try {
          if (e is Map) {
            final map = Map<String, dynamic>.from(e);
            loaded.add(GoalModel.fromLocalMap(map));
          }
        } catch (_) {}
      }

      loaded.sort((a, b) => b.createdAt.compareTo(a.createdAt));
      _goals = loaded;
      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _goals = [];
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> addGoal(GoalEntity goal) async {
    if (_currentUser?.isGuest == true || goal.userId == 'guest') {
      try {
        final box = Hive.box('guest_goals');
        String id = goal.id.isEmpty ? const Uuid().v4() : goal.id;

        final newGoal = GoalEntity(
          id: id,
          userId: 'guest',
          name: goal.name,
          targetAmount: goal.targetAmount,
          currentAmount: goal.currentAmount,
          targetDate: goal.targetDate,
          description: goal.description,
          createdAt: DateTime.now(),
        );

        final model = GoalModel.fromEntity(newGoal);
        await box.put(id, model.toLocalMap());
        _loadGuestGoals();
      } catch (e) {
        rethrow;
      }
      return;
    }

    try {
      final id = goal.id.isEmpty ? const Uuid().v4() : goal.id;
      final newGoal = goal.copyWith(id: id);
      await _repository.addGoal(newGoal);
    } catch (e) {
      rethrow;
    }
  }

  Future<void> updateGoal(GoalEntity goal) async {
    if (_currentUser?.isGuest == true || goal.userId == 'guest') {
      try {
        final box = Hive.box('guest_goals');
        final model = GoalModel.fromEntity(goal);
        await box.put(goal.id, model.toLocalMap());
        _loadGuestGoals();
      } catch (e) {
        rethrow;
      }
      return;
    }

    try {
      await _repository.updateGoal(goal);
    } catch (e) {
      rethrow;
    }
  }

  Future<void> deleteGoal(String goalId) async {
    if (_currentUser == null) return;

    if (_currentUser!.isGuest || _currentUser!.uid == 'guest') {
      try {
        final box = Hive.box('guest_goals');
        await box.delete(goalId);
        _loadGuestGoals();
      } catch (e) {
        rethrow;
      }
      return;
    }

    try {
      await _repository.deleteGoal(_currentUser!.uid, goalId);
    } catch (e) {
      rethrow;
    }
  }

  Future<void> contributeToGoal(String goalId, double amount) async {
    final goalIndex = _goals.indexWhere((g) => g.id == goalId);
    if (goalIndex == -1) return;

    final goal = _goals[goalIndex];

    // Create new log entry
    final newLog = GoalLogEntity(
      id: const Uuid().v4(),
      amount: amount,
      date: DateTime.now(),
      type: 'deposit',
    );

    // Append to logs
    final updatedLogs = List<GoalLogEntity>.from(goal.logs)..add(newLog);

    final updatedGoal = goal.copyWith(
      currentAmount: goal.currentAmount + amount,
      isCompleted: (goal.currentAmount + amount) >= goal.targetAmount,
      logs: updatedLogs,
    );

    await updateGoal(updatedGoal);
  }
}
