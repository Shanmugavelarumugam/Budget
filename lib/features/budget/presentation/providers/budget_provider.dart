import 'dart:async';
import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:intl/intl.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../domain/entities/budget_entity.dart';
import '../../domain/entities/category_budget_entity.dart';
import '../../data/models/budget_model.dart';
import '../../data/models/category_budget_model.dart';
import '../../../auth/domain/entities/user_entity.dart';

/// BudgetProvider manages budget state independently
/// It does NOT manage transactions - it only reads them for calculations
class BudgetProvider extends ChangeNotifier {
  BudgetEntity? _currentBudget;
  BudgetEntity? get currentBudget => _currentBudget;

  // Category budgets: Map<categoryId, CategoryBudgetEntity>
  Map<String, CategoryBudgetEntity> _categoryBudgets = {};
  Map<String, CategoryBudgetEntity> get categoryBudgets => _categoryBudgets;

  UserEntity? _currentUser;
  StreamSubscription<DocumentSnapshot>? _budgetSubscription;
  StreamSubscription<QuerySnapshot>? _categoryBudgetsSubscription;

  // Helper to format month ID
  String get _currentMonthId => DateFormat('yyyy-MM').format(DateTime.now());

  /// Get category budget for a specific category
  CategoryBudgetEntity? getCategoryBudget(String categoryId) {
    return _categoryBudgets[categoryId];
  }

  /// Get total of all category budgets
  double get totalCategoryBudgets {
    return _categoryBudgets.values.fold(0.0, (total, cb) => total + cb.amount);
  }

  /// Update user and initialize budget stream
  void updateUser(UserEntity? user) {
    if (_currentUser?.uid == user?.uid) return;
    _currentUser = user;
    _initBudgetStream();
    _initCategoryBudgetsStream();
  }

  /// Initialize budget stream based on user type
  void _initBudgetStream() {
    _budgetSubscription?.cancel();
    _currentBudget = null;
    notifyListeners();

    if (_currentUser == null) return;

    // Guest Mode - Load from Hive
    if (_currentUser!.isGuest) {
      _loadGuestBudget();
      return;
    }

    // Authenticated User - Listen to Firestore
    _budgetSubscription = FirebaseFirestore.instance
        .collection('users')
        .doc(_currentUser!.uid)
        .collection('budgets')
        .doc(_currentMonthId)
        .snapshots()
        .listen(
          (doc) {
            if (doc.exists) {
              _currentBudget = BudgetModel.fromFirestore(doc);
            } else {
              _currentBudget = null;
            }
            notifyListeners();
          },
          onError: (e) {
            debugPrint("Error fetching budget: $e");
          },
        );
  }

  /// Initialize category budgets stream
  void _initCategoryBudgetsStream() {
    _categoryBudgetsSubscription?.cancel();
    _categoryBudgets = {};
    notifyListeners();

    if (_currentUser == null) return;

    // Guest Mode - Load from Hive
    if (_currentUser!.isGuest) {
      _loadGuestCategoryBudgets();
      return;
    }

    // Authenticated User - Listen to Firestore
    _categoryBudgetsSubscription = FirebaseFirestore.instance
        .collection('users')
        .doc(_currentUser!.uid)
        .collection('budgets')
        .doc(_currentMonthId)
        .collection('categories')
        .snapshots()
        .listen(
          (snapshot) {
            _categoryBudgets = {};
            for (var doc in snapshot.docs) {
              final model = CategoryBudgetModel.fromJson(doc.data());
              _categoryBudgets[model.categoryId] = model.toEntity();
            }
            notifyListeners();
          },
          onError: (e) {
            debugPrint("Error fetching category budgets: $e");
          },
        );
  }

  /// Load budget from local storage for guest users
  void _loadGuestBudget() {
    try {
      final transactionBox = Hive.box('guest_transactions');
      final budgetKey = 'budget_$_currentMonthId';

      final data = transactionBox.get(budgetKey);
      if (data != null) {
        final map = Map<String, dynamic>.from(data as Map);
        _currentBudget = BudgetModel.fromLocalMap(map);
      } else {
        // Default budget for guests
        _currentBudget = BudgetEntity(
          id: _currentMonthId,
          amount: 5000.0,
          createdAt: DateTime.now(),
          userId: 'guest',
        );
      }
      notifyListeners();
    } catch (e) {
      debugPrint("Error loading guest budget: $e");
    }
  }

  /// Load category budgets from local storage for guest users
  void _loadGuestCategoryBudgets() {
    try {
      final transactionBox = Hive.box('guest_transactions');
      final categoryBudgetsKey = 'category_budgets_$_currentMonthId';

      final data = transactionBox.get(categoryBudgetsKey);
      if (data != null) {
        final list = List<Map<String, dynamic>>.from(
          (data as List).map((e) => Map<String, dynamic>.from(e as Map)),
        );
        _categoryBudgets = {};
        for (var map in list) {
          final model = CategoryBudgetModel.fromJson(map);
          _categoryBudgets[model.categoryId] = model.toEntity();
        }
      }
      notifyListeners();
    } catch (e) {
      debugPrint("Error loading guest category budgets: $e");
    }
  }

  /// Set or update budget for current month
  Future<void> setBudget(double amount) async {
    final entity = BudgetEntity(
      id: _currentMonthId,
      amount: amount,
      createdAt: DateTime.now(),
      userId: _currentUser?.uid ?? 'guest',
    );
    final model = BudgetModel.fromEntity(entity);

    if (_currentUser?.isGuest ?? true) {
      // Guest Save
      final box = Hive.box('guest_transactions');
      await box.put('budget_$_currentMonthId', model.toLocalMap());
      _currentBudget = entity;
      notifyListeners();
    } else {
      // Firestore Save
      await FirebaseFirestore.instance
          .collection('users')
          .doc(_currentUser!.uid)
          .collection('budgets')
          .doc(_currentMonthId)
          .set(model.toFirestore());
      // Listener will update _currentBudget
    }
  }

  /// Set category budgets for current month
  Future<void> setCategoryBudgets(Map<String, double> categoryBudgets) async {
    final entities = categoryBudgets.entries.map((entry) {
      return CategoryBudgetEntity(
        categoryId: entry.key,
        amount: entry.value,
        month: _currentMonthId,
      );
    }).toList();

    if (_currentUser?.isGuest ?? true) {
      // Guest Save
      final box = Hive.box('guest_transactions');
      final models = entities
          .map((e) => CategoryBudgetModel.fromEntity(e).toJson())
          .toList();
      await box.put('category_budgets_$_currentMonthId', models);

      // Update local state
      _categoryBudgets = {};
      for (var entity in entities) {
        _categoryBudgets[entity.categoryId] = entity;
      }
      notifyListeners();
    } else {
      // Firestore Save - batch write
      final batch = FirebaseFirestore.instance.batch();
      final categoryBudgetsRef = FirebaseFirestore.instance
          .collection('users')
          .doc(_currentUser!.uid)
          .collection('budgets')
          .doc(_currentMonthId)
          .collection('categories');

      // Delete all existing category budgets first
      final existing = await categoryBudgetsRef.get();
      for (var doc in existing.docs) {
        batch.delete(doc.reference);
      }

      // Add new category budgets
      for (var entity in entities) {
        final model = CategoryBudgetModel.fromEntity(entity);
        batch.set(categoryBudgetsRef.doc(entity.categoryId), model.toJson());
      }

      await batch.commit();
      // Listener will update _categoryBudgets
    }
  }

  @override
  void dispose() {
    _budgetSubscription?.cancel();
    _categoryBudgetsSubscription?.cancel();
    super.dispose();
  }
}
